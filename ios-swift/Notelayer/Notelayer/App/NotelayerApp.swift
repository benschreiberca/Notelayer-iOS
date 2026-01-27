import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

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

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        print("🚀 [AppDelegate] Application did finish launching")
        #endif
        
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
        #endif
        
        // Determine APNS token type based on build configuration
        // In debug builds, use .sandbox; in release builds, use .prod
        #if DEBUG
        let tokenType: AuthAPNSTokenType = .sandbox
        print("📱 [AppDelegate] Using APNS token type: .sandbox (DEBUG)")
        #else
        let tokenType: AuthAPNSTokenType = .prod
        #endif
        
        // Safely set the APNS token with error handling
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
        
        // Set the APNS token on real device
        auth.setAPNSToken(deviceToken, type: tokenType)
        #if DEBUG
        print("✅ [AppDelegate] APNS token set successfully")
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
                .environmentObject(ThemeManager.shared)
                .environmentObject(authService)
        }
    }
}
