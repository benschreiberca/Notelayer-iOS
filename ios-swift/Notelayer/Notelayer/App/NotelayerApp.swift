import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

private func configureFirebaseIfNeeded() {
    if FirebaseApp.app() == nil {
        print("🔥 [AppDelegate] Configuring Firebase...")
        FirebaseApp.configure()
        if let app = FirebaseApp.app() {
            print("🔥 [AppDelegate] Firebase configured - App: \(app.name)")
        } else {
            print("❌ [AppDelegate] Firebase configuration failed")
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("🚀 [AppDelegate] Application did finish launching")
        
        // Verify URL schemes are configured
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
        
        configureFirebaseIfNeeded()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("🔗 [AppDelegate] Handling URL: \(url)")
        configureFirebaseIfNeeded()
        let handled = GIDSignIn.sharedInstance.handle(url)
        print("🔗 [AppDelegate] Google Sign-In URL handled: \(handled)")
        return handled
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("📱 [AppDelegate] Received APNS device token: \(deviceToken.count) bytes")
        configureFirebaseIfNeeded()
        
        // Determine APNS token type based on build configuration
        // In debug builds, use .sandbox; in release builds, use .prod
        #if DEBUG
        let tokenType: AuthAPNSTokenType = .sandbox
        print("📱 [AppDelegate] Using APNS token type: .sandbox (DEBUG)")
        #else
        let tokenType: AuthAPNSTokenType = .prod
        print("📱 [AppDelegate] Using APNS token type: .prod (RELEASE)")
        #endif
        
        // Safely set the APNS token with error handling
        guard FirebaseApp.app() != nil else {
            print("⚠️ [AppDelegate] Firebase not configured, skipping APNS token")
            return
        }
        
        // Additional safety check - ensure Auth is available
        let auth = Auth.auth()
        guard auth.app != nil else {
            print("⚠️ [AppDelegate] Auth not properly initialized, skipping APNS token")
            return
        }
        
        // Set the APNS token - this should not throw, but we'll catch any issues
        auth.setAPNSToken(deviceToken, type: tokenType)
        print("✅ [AppDelegate] APNS token set successfully")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("📬 [AppDelegate] Received remote notification")
        configureFirebaseIfNeeded()
        
        guard FirebaseApp.app() != nil else {
            print("⚠️ [AppDelegate] Firebase not configured, cannot handle notification")
            completionHandler(.noData)
            return
        }
        
        if Auth.auth().canHandleNotification(userInfo) {
            print("✅ [AppDelegate] Firebase Auth handled the notification")
            completionHandler(.noData)
            return
        }
        
        print("ℹ️ [AppDelegate] Notification not handled by Firebase Auth")
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
    }

    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environmentObject(ThemeManager.shared)
                .environmentObject(authService)
        }
    }
}
