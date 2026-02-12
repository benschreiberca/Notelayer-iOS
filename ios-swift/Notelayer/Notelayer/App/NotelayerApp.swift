import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Foundation
import UIKit
import UserNotifications

@MainActor
final class APNSTokenStore {
    static let shared = APNSTokenStore()
    private(set) var token: Data?
    private(set) var tokenType: AuthAPNSTokenType?

    func update(token: Data, type: AuthAPNSTokenType) {
        self.token = token
        self.tokenType = type
        NotificationCenter.default.post(name: .apnsTokenUpdated, object: nil)
    }
}

extension Notification.Name {
    static let apnsTokenUpdated = Notification.Name("Notelayer.APNS.TokenUpdated")
}

private enum FirebaseBootstrapper {
    private static let lock = NSLock()
    private static var hasConfigured = false

    static func configureIfNeeded(source: String) {
        lock.lock()
        defer { lock.unlock() }

        guard !hasConfigured else { return }

        // Avoid probing `FirebaseApp.app()` pre-config because that emits
        // a noisy "default app has not yet been configured" log line.
        if let allApps = FirebaseApp.allApps, !allApps.isEmpty {
            hasConfigured = true
            #if DEBUG
            print("🔥 [FirebaseBootstrapper] Firebase already configured (\(source))")
            #endif
            return
        }

        FirebaseApp.configure()
        hasConfigured = true

        #if DEBUG
        if hasConfigured {
            print("🔥 [FirebaseBootstrapper] Firebase configured (\(source))")
        } else {
            print("❌ [FirebaseBootstrapper] Firebase configuration failed (\(source))")
        }
        #endif
    }
}

private func configureFirebaseIfNeeded(source: String) {
    FirebaseBootstrapper.configureIfNeeded(source: source)
}

@objc(AppDelegate)
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        configureFirebaseIfNeeded(source: "AppDelegate.init")
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        configureFirebaseIfNeeded(source: "AppDelegate.didFinishLaunching")

        #if DEBUG
        print("🚀 [AppDelegate] Application did finish launching")
        #endif
        
        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Register notification categories and actions
        registerNotificationActions()
        // Avoid spending launch watchdog budget on APNS registration in the first frame.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.registerForRemoteNotificationsIfNeeded()
        }
        
        // NOTE: processSharedItems() is now called in TodosView.onAppear
        // with a delay to ensure backend sync completes first
        return true
    }
    
    // MARK: - Notification Actions Registration
    
    /// Register notification categories and actions for task reminders
    private func registerNotificationActions() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Complete",
            options: [.foreground]
        )
        
        let openAction = UNNotificationAction(
            identifier: "OPEN_TASK",
            title: "Open",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, openAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        #if DEBUG
        print("🔔 [AppDelegate] Registered notification categories and actions")
        #endif
    }

    private func registerForRemoteNotificationsIfNeeded() {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            #if DEBUG
            print("📱 [AppDelegate] Already registered for remote notifications")
            #endif
            return
        }

        #if DEBUG
        print("📱 [AppDelegate] Registering for remote notifications (APNS)")
        #endif
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notification tap and action buttons
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let taskId = userInfo["taskId"] as? String else {
            #if DEBUG
            print("⚠️ [AppDelegate] No taskId in notification userInfo")
            #endif
            completionHandler()
            return
        }
        
        #if DEBUG
        print("📬 [AppDelegate] Received notification response for task: \(taskId)")
        print("   Action: \(response.actionIdentifier)")
        #endif
        
        switch response.actionIdentifier {
        case "COMPLETE_TASK":
            completeTask(taskId: taskId)
        case "OPEN_TASK", UNNotificationDefaultActionIdentifier:
            openTask(taskId: taskId)
        default:
            break
        }
        
        completionHandler()
    }
    
    /// Handle notifications when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even when app is open
        #if DEBUG
        print("🔔 [AppDelegate] Presenting notification while app in foreground")
        #endif
        completionHandler([.banner, .sound])
    }
    
    // MARK: - Notification Action Handlers
    
    /// Complete a task from notification action
    private func completeTask(taskId: String) {
        _Concurrency.Task { @MainActor in
            let store = LocalStore.shared
            store.completeTask(id: taskId)
            #if DEBUG
            print("✅ [AppDelegate] Completed task from notification: \(taskId)")
            #endif
        }
    }
    
    /// Open a task from notification action
    /// Posts a notification that RootTabsView can observe to present the task
    private func openTask(taskId: String) {
        _Concurrency.Task { @MainActor in
            #if DEBUG
            print("📂 [AppDelegate] Opening task from notification: \(taskId)")
            #endif
            
            // Post notification for deep linking
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenTaskFromNotification"),
                object: nil,
                userInfo: ["taskId": taskId]
            )
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("📱 [AppDelegate] Received APNS device token: %lu bytes", deviceToken.count)
        #if DEBUG
        print("📱 [AppDelegate] Received APNS device token: \(deviceToken.count) bytes")
        #endif
        configureFirebaseIfNeeded(source: "didRegisterForRemoteNotifications")
        
        // CRITICAL: Skip setting APNS token on simulator
        // Firebase Auth's setAPNSToken has an internal assertion that crashes on simulator
        #if targetEnvironment(simulator)
        #if DEBUG
        print("⚠️ [AppDelegate] Running on simulator - skipping APNS token (would crash)")
        print("   Phone authentication will not work on simulator")
        #endif
        return
        #else
        // Device-only: Safely set the APNS token with error handling
        guard FirebaseApp.app() != nil else {
            #if DEBUG
            print("⚠️ [AppDelegate] Firebase not configured, skipping APNS token")
            #endif
            return
        }
        
        // Additional safety check - ensure Auth is available
        let auth = Auth.auth()
        guard auth.app != nil else {
            #if DEBUG
            print("⚠️ [AppDelegate] Auth not properly initialized, skipping APNS token")
            #endif
            return
        }
        
        // Determine APNS token type based on build configuration
        // In debug builds, use .sandbox; in release builds, use .prod
        #if DEBUG
        let tokenType: AuthAPNSTokenType = .sandbox
        print("📱 [AppDelegate] Using APNS token type: .sandbox (DEBUG)")
        #else
        let tokenType: AuthAPNSTokenType = .prod
        #endif
        
        // Set the APNS token on real device
        auth.setAPNSToken(deviceToken, type: tokenType)
        APNSTokenStore.shared.update(token: deviceToken, type: tokenType)
        NSLog("✅ [AppDelegate] APNS token set successfully")
        #if DEBUG
        print("✅ [AppDelegate] APNS token set successfully")
        #endif
        #endif
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("❌ [AppDelegate] Failed to register for remote notifications: %@", error.localizedDescription)
        #if DEBUG
        print("❌ [AppDelegate] Failed to register for remote notifications: \(error.localizedDescription)")
        if let nsError = error as NSError? {
            print("   Domain: \(nsError.domain), Code: \(nsError.code)")
            print("   UserInfo: \(nsError.userInfo)")
        }
        #endif
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("📬 [AppDelegate] Received remote notification")
        #if DEBUG
        print("📬 [AppDelegate] Received remote notification")
        #endif
        configureFirebaseIfNeeded(source: "didReceiveRemoteNotification:fetch")
        
        guard FirebaseApp.app() != nil else {
            #if DEBUG
            print("⚠️ [AppDelegate] Firebase not configured, cannot handle notification")
            #endif
            completionHandler(.noData)
            return
        }
        
        if Auth.auth().canHandleNotification(userInfo) {
            NSLog("✅ [AppDelegate] Firebase Auth handled the notification")
            #if DEBUG
            print("✅ [AppDelegate] Firebase Auth handled the notification")
            #endif
            completionHandler(.noData)
            return
        }
        
        #if DEBUG
        print("ℹ️ [AppDelegate] Notification not handled by Firebase Auth")
        #endif
        completionHandler(.noData)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NSLog("📬 [AppDelegate] Received remote notification (no fetch handler)")
        #if DEBUG
        print("📬 [AppDelegate] Received remote notification (no fetch handler)")
        #endif

        configureFirebaseIfNeeded(source: "didReceiveRemoteNotification")
        _ = Auth.auth().canHandleNotification(userInfo)
    }
}

@main
struct NotelayerApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService: AuthService
    @StateObject private var backendService: FirebaseBackendService
    
    init() {
        configureFirebaseIfNeeded(source: "NotelayerApp.init")
        let authService = AuthService()
        _authService = StateObject(wrappedValue: authService)
        _backendService = StateObject(wrappedValue: FirebaseBackendService(authService: authService, store: .shared))
        
        // Check if we're in screenshot generation mode
        let isScreenshotMode = ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "true" ||
                              ProcessInfo.processInfo.arguments.contains("--screenshot-generation")
        
        if isScreenshotMode {
            #if DEBUG
            print("📸 [NotelayerApp] Screenshot generation mode detected - seeding quirky tasks")
            #endif
            // Seed data for screenshots (uses isolated data store)
            ScreenshotDataSeeder.seedData()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environmentObject(ThemeManager.shared)
                .environmentObject(authService)
                .onOpenURL { url in
                    _Concurrency.Task { @MainActor in
                        await authService.handleIncomingURL(url)
                    }
                }
        }
    }
}
