import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit
import UserNotifications

private func configureFirebaseIfNeeded() {
    if FirebaseApp.app() == nil {
        #if DEBUG
        print("🔥 [AppDelegate] Configuring Firebase...")
        #endif
        FirebaseApp.configure()
        if let app = FirebaseApp.app() {
            #if DEBUG
            print("🔥 [AppDelegate] Firebase configured - App: \(app.name)")
            #endif
        } else {
            #if DEBUG
            print("❌ [AppDelegate] Firebase configuration failed")
            #endif
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        print("🚀 [AppDelegate] Application did finish launching")
        #endif
        
        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Register notification categories and actions
        registerNotificationActions()
        
        // NOTE: processSharedItems() is now called in TodosView.onAppear
        // with a delay to ensure backend sync completes first
        NSLog("========================================")
        NSLog("🚀 NOTELAYER APP LAUNCHED - DEBUG MODE")
        NSLog("========================================")
        
        // Verify URL schemes are configured
        #if DEBUG
        if let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] {
            print("📋 [AppDelegate] URL Types configured: \(urlTypes.count)")
            for (index, urlType) in urlTypes.enumerated() {
                if let schemes = urlType["CFBundleURLSchemes"] as? [String] {
                    print("   URL Type \(index): \(schemes)")
                    // Verify REVERSED_CLIENT_ID is properly set
                    if let reversedClientID = schemes.first, reversedClientID.contains("$(REVERSED_CLIENT_ID)") {
                        print("   ⚠️ WARNING: REVERSED_CLIENT_ID variable not expanded! Value: \(reversedClientID)")
                    } else if let reversedClientID = schemes.first, reversedClientID.hasPrefix("com.googleusercontent.apps") {
                        print("   ✅ REVERSED_CLIENT_ID properly configured: \(reversedClientID)")
                    }
                }
            }
        } else {
            print("⚠️ [AppDelegate] WARNING: No URL types found in Info.plist!")
        }
        #endif
        
        configureFirebaseIfNeeded()
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
        #if DEBUG
        print("📱 [AppDelegate] Received APNS device token: \(deviceToken.count) bytes")
        #endif
        configureFirebaseIfNeeded()
        
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
        #if DEBUG
        print("✅ [AppDelegate] APNS token set successfully")
        #endif
        #endif
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        #if DEBUG
        print("📬 [AppDelegate] Received remote notification")
        #endif
        configureFirebaseIfNeeded()
        
        guard FirebaseApp.app() != nil else {
            #if DEBUG
            print("⚠️ [AppDelegate] Firebase not configured, cannot handle notification")
            #endif
            completionHandler(.noData)
            return
        }
        
        if Auth.auth().canHandleNotification(userInfo) {
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
}

@main
struct NotelayerApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService: AuthService
    @StateObject private var backendService: FirebaseBackendService
    
    // Track scene phase to process shared items when app becomes active
    @Environment(\.scenePhase) var scenePhase

    init() {
        configureFirebaseIfNeeded()
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
                .onAppear {
                    print("⚠️⚠️⚠️ CONSOLE TEST - IF YOU SEE THIS, CONSOLE IS WORKING ⚠️⚠️⚠️")
                }
                .environmentObject(ThemeManager.shared)
                .environmentObject(authService)
        }
        .onChange(of: scenePhase) { newPhase in
            print("========================================")
            print("🔄 [NotelayerApp] Scene phase changed to: \(newPhase)")
            print("========================================")
            
            // NOTE: Shared items are processed in TodosView.onAppear with proper timing
        }
    }
}
