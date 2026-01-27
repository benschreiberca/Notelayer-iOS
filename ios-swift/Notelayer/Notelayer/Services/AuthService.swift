import AuthenticationServices
import Combine
import CryptoKit
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import Security
import UIKit
import _Concurrency

private func configureFirebaseIfNeeded() {
    if FirebaseApp.app() == nil {
        #if DEBUG
        print("🔥 [Firebase] Configuring Firebase...")
        #endif
        
        // Verify GoogleService-Info.plist exists in bundle
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") == nil {
            #if DEBUG
            print("⚠️ [Firebase] WARNING: GoogleService-Info.plist not found in bundle!")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            print("   Resource path: \(Bundle.main.resourcePath ?? "nil")")
            #endif
        } else {
            #if DEBUG
            print("✅ [Firebase] GoogleService-Info.plist found in bundle")
            #endif
        }
        
        FirebaseApp.configure()
        if let app = FirebaseApp.app() {
            #if DEBUG
            print("🔥 [Firebase] Configuration complete - App: \(app.name)")
            print("🔥 [Firebase] Project ID: \(app.options.projectID ?? "nil")")
            print("🔥 [Firebase] Client ID: \(app.options.clientID ?? "nil")")
            #endif
            if app.options.clientID == nil || app.options.clientID!.isEmpty {
                #if DEBUG
                print("❌ [Firebase] ERROR: Client ID is missing! Check GoogleService-Info.plist")
                #endif
            }
        } else {
            #if DEBUG
            print("❌ [Firebase] Configuration failed - FirebaseApp is nil")
            #endif
        }
    } else {
        #if DEBUG
        print("🔥 [Firebase] Already configured")
        #endif
    }
}

enum SyncStatus {
    case notSignedIn
    case signedInSynced(lastSync: Date)
    case signedInSyncError(error: String)
    
    var shouldShowBadge: Bool {
        switch self {
        case .notSignedIn, .signedInSyncError:
            return true
        case .signedInSynced:
            return false
        }
    }
    
    var badgeColor: String {
        switch self {
        case .notSignedIn:
            return "red"
        case .signedInSyncError:
            return "yellow"
        case .signedInSynced:
            return ""
        }
    }
}

@MainActor
final class AuthService: NSObject, ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var phoneVerificationID: String?
    @Published private(set) var syncStatus: SyncStatus = .notSignedIn
    @Published private(set) var lastSyncTime: Date?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let appleCoordinator = AppleSignInCoordinator()

    override init() {
        super.init()
        configureFirebaseIfNeeded()
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            #if DEBUG
            print("👤 [AuthService] Auth state changed - user: \(user?.uid ?? "nil")")
            if let user = user {
                print("   Email: \(user.email ?? "nil")")
                print("   Phone: \(user.phoneNumber ?? "nil")")
                print("   Providers: \(user.providerData.map { $0.providerID })")
            }
            #endif
            self?.user = user
            self?.updateSyncStatus()
        }
    }
    
    func updateSyncStatus() {
        if user == nil {
            syncStatus = .notSignedIn
        } else {
            // Default to synced - backend service will update if there's an error
            syncStatus = .signedInSynced(lastSync: lastSyncTime ?? Date())
        }
    }
    
    func updateLastSyncTime(_ date: Date) {
        lastSyncTime = date
        if user != nil {
            syncStatus = .signedInSynced(lastSync: date)
        }
    }
    
    func reportSyncError(_ error: String) {
        if user != nil {
            syncStatus = .signedInSyncError(error: error)
        }
    }
    
    var authMethodDisplay: String? {
        guard let user = user else { return nil }
        
        if let email = user.email {
            if user.providerData.contains(where: { $0.providerID == "google.com" }) {
                return "Google (\(email))"
            }
            if user.providerData.contains(where: { $0.providerID == "apple.com" }) {
                return "Apple (\(email))"
            }
            return email
        }
        
        if let phone = user.phoneNumber {
            return "Phone (\(phone))"
        }
        
        return "Unknown method"
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    func signOut() throws {
        configureFirebaseIfNeeded()
        try Auth.auth().signOut()
    }

    func signInWithGoogle(presenting viewController: UIViewController) async throws {
        #if DEBUG
        print("🔵 [AuthService] Starting Google Sign-In...")
        #endif
        configureFirebaseIfNeeded()
        
        // Check if user is already signed in with a different method
        if let existingUser = user {
            #if DEBUG
            print("⚠️ [AuthService] User already signed in with different method")
            #endif
            throw AuthServiceError.alreadySignedInWithDifferentMethod
        }
        
        guard let app = FirebaseApp.app() else {
            #if DEBUG
            print("❌ [AuthService] FirebaseApp is nil")
            #endif
            throw AuthServiceError.missingGoogleClientID
        }
        
        guard let clientID = app.options.clientID, !clientID.isEmpty else {
            #if DEBUG
            print("❌ [AuthService] Client ID is missing or empty")
            print("   Options: \(app.options)")
            #endif
            throw AuthServiceError.missingGoogleClientID
        }
        
        #if DEBUG
        print("✅ [AuthService] Client ID found: \(clientID)")
        #endif
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        #if DEBUG
        print("🔵 [AuthService] Calling GIDSignIn.sharedInstance.signIn...")
        #endif
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            
            #if DEBUG
            print("✅ [AuthService] Google Sign-In completed")
            print("   User ID: \(result.user.userID ?? "nil")")
            print("   Email: \(result.user.profile?.email ?? "nil")")
            #endif
            
            guard let idToken = result.user.idToken?.tokenString else {
                #if DEBUG
                print("❌ [AuthService] ID Token is nil")
                #endif
                throw AuthServiceError.missingGoogleIDToken
            }
            
            #if DEBUG
            print("✅ [AuthService] ID Token retrieved")
            #endif
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            #if DEBUG
            print("🔵 [AuthService] Signing in to Firebase with Google credential...")
            #endif
            let authResult = try await Auth.auth().signIn(with: credential)
            #if DEBUG
            print("✅ [AuthService] Firebase sign-in successful - user: \(authResult.user.uid)")
            #endif
        } catch {
            #if DEBUG
            print("❌ [AuthService] Google Sign-In ERROR: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            #endif
            throw error
        }
    }

    func signInWithApple(presentationAnchor: ASPresentationAnchor?) async throws {
        #if DEBUG
        print("🍎 [AuthService] Starting Apple Sign-In...")
        #endif
        configureFirebaseIfNeeded()
        
        // Check if user is already signed in with a different method
        if let existingUser = user {
            #if DEBUG
            print("⚠️ [AuthService] User already signed in with different method")
            #endif
            throw AuthServiceError.alreadySignedInWithDifferentMethod
        }
        
        // Try to get a presentation anchor
        var anchor = presentationAnchor
        if anchor == nil {
            // Try multiple methods to get a window
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                anchor = window
                #if DEBUG
                print("✅ [AuthService] Found key window from window scene")
                #endif
            } else if let window = UIApplication.shared.keyWindow {
                anchor = window
                #if DEBUG
                print("✅ [AuthService] Found key window from UIApplication")
                #endif
            } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first {
                anchor = window
                #if DEBUG
                print("✅ [AuthService] Found first window from window scene")
                #endif
            }
        }
        
        guard let anchor else {
            #if DEBUG
            print("❌ [AuthService] Missing presentation anchor")
            print("   Connected scenes: \(UIApplication.shared.connectedScenes.count)")
            #endif
            throw AuthServiceError.missingPresentationAnchor
        }
        
        #if DEBUG
        print("✅ [AuthService] Presentation anchor found")
        #endif
        do {
            _ = try await appleCoordinator.signIn(presentationAnchor: anchor)
            #if DEBUG
            print("✅ [AuthService] Apple Sign-In completed")
            #endif
        } catch {
            #if DEBUG
            print("❌ [AuthService] Apple Sign-In ERROR: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            #endif
            throw error
        }
    }

    func prepareForPhoneAuth() {
        #if DEBUG
        print("📱 [AuthService] Preparing for phone authentication")
        #endif
        configureFirebaseIfNeeded()
        
        #if targetEnvironment(simulator)
        #if DEBUG
        print("⚠️ [AuthService] Running on simulator - phone auth may not work properly")
        print("   APNS token cannot be set on simulator (would crash)")
        #endif
        #endif
        
        // Only register if not already registered
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            #if DEBUG
            print("📱 [AuthService] Already registered for remote notifications")
            #endif
        } else {
            #if DEBUG
            print("📱 [AuthService] Registering for remote notifications...")
            #endif
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func startPhoneNumberSignIn(phoneNumber: String) async throws -> String {
        #if DEBUG
        print("📱 [AuthService] Starting phone number sign-in - phone: \(phoneNumber)")
        #endif
        configureFirebaseIfNeeded()
        
        // Check if user is already signed in with a different method
        if let existingUser = user {
            #if DEBUG
            print("⚠️ [AuthService] User already signed in with different method")
            #endif
            throw AuthServiceError.alreadySignedInWithDifferentMethod
        }
        let verificationID = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { id, error in
                if let error {
                    #if DEBUG
                    print("❌ [AuthService] Phone verification ERROR: \(error.localizedDescription)")
                    #endif
                    continuation.resume(throwing: error)
                    return
                }
                guard let id else {
                    #if DEBUG
                    print("❌ [AuthService] Phone verification ID is nil")
                    #endif
                    continuation.resume(throwing: AuthServiceError.missingPhoneVerificationID)
                    return
                }
                #if DEBUG
                print("✅ [AuthService] Phone verification ID received: \(id)")
                #endif
                continuation.resume(returning: id)
            }
        }

        phoneVerificationID = verificationID
        return verificationID
    }

    func verifyPhoneNumber(code: String, verificationID: String? = nil) async throws {
        #if DEBUG
        print("📱 [AuthService] Verifying phone number with code")
        #endif
        configureFirebaseIfNeeded()
        let id = verificationID ?? phoneVerificationID
        guard let id else {
            #if DEBUG
            print("❌ [AuthService] Missing phone verification ID")
            #endif
            throw AuthServiceError.missingPhoneVerificationID
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: code)
        do {
            let result = try await Auth.auth().signIn(with: credential)
            #if DEBUG
            print("✅ [AuthService] Phone verification successful - user: \(result.user.uid)")
            #endif
        } catch {
            #if DEBUG
            print("❌ [AuthService] Phone verification ERROR: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            #endif
            throw error
        }
    }
}

enum AuthServiceError: LocalizedError {
    case missingGoogleClientID
    case missingGoogleIDToken
    case missingAppleIDToken
    case missingPresentationAnchor
    case missingPhoneVerificationID
    case alreadySignedInWithDifferentMethod

    var errorDescription: String? {
        switch self {
        case .missingGoogleClientID:
            return "Missing Firebase client ID. Update GoogleService-Info.plist."
        case .missingGoogleIDToken:
            return "Missing Google ID token."
        case .missingAppleIDToken:
            return "Missing Apple ID token."
        case .missingPresentationAnchor:
            return "Missing presentation anchor for Sign in with Apple."
        case .missingPhoneVerificationID:
            return "Missing phone verification ID."
        case .alreadySignedInWithDifferentMethod:
            return "You're already signed in. Sign out first to use a different method."
        }
    }
}

private final class AppleSignInCoordinator: NSObject {
    private var continuation: CheckedContinuation<AuthDataResult, Error>?
    private var currentNonce: String?
    private var presentationAnchor: ASPresentationAnchor?

    func signIn(presentationAnchor: ASPresentationAnchor) async throws -> AuthDataResult {
        self.presentationAnchor = presentationAnchor
        let nonce = Self.randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            if status != errSecSuccess {
                continue
            }

            for byte in randomBytes where remainingLength > 0 {
                if byte < charset.count {
                    result.append(charset[Int(byte)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        #if DEBUG
        print("🍎 [AppleSignIn] Authorization completed")
        #endif
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let tokenData = appleIDCredential.identityToken,
            let tokenString = String(data: tokenData, encoding: .utf8)
        else {
            #if DEBUG
            print("❌ [AppleSignIn] Missing required credential data")
            #endif
            continuation?.resume(throwing: AuthServiceError.missingAppleIDToken)
            continuation = nil
            return
        }

        #if DEBUG
        print("✅ [AppleSignIn] Token retrieved, creating Firebase credential...")
        #endif
        configureFirebaseIfNeeded()
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: tokenString,
            rawNonce: nonce
        )
        _Concurrency.Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                #if DEBUG
                print("✅ [AppleSignIn] Firebase sign-in successful - user: \(result.user.uid)")
                #endif
                continuation?.resume(returning: result)
            } catch {
                #if DEBUG
                print("❌ [AppleSignIn] Firebase sign-in ERROR: \(error.localizedDescription)")
                #endif
                continuation?.resume(throwing: error)
            }
            continuation = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        #if DEBUG
        print("❌ [AppleSignIn] Authorization failed: \(error.localizedDescription)")
        #endif
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        presentationAnchor ?? ASPresentationAnchor()
    }
}

private extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
