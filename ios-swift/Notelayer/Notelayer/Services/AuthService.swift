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
        print("🔥 [Firebase] Configuring Firebase...")
        
        // Verify GoogleService-Info.plist exists in bundle
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") == nil {
            print("⚠️ [Firebase] WARNING: GoogleService-Info.plist not found in bundle!")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            print("   Resource path: \(Bundle.main.resourcePath ?? "nil")")
        } else {
            print("✅ [Firebase] GoogleService-Info.plist found in bundle")
        }
        
        FirebaseApp.configure()
        if let app = FirebaseApp.app() {
            print("🔥 [Firebase] Configuration complete - App: \(app.name)")
            print("🔥 [Firebase] Project ID: \(app.options.projectID ?? "nil")")
            print("🔥 [Firebase] Client ID: \(app.options.clientID ?? "nil")")
            if app.options.clientID == nil || app.options.clientID!.isEmpty {
                print("❌ [Firebase] ERROR: Client ID is missing! Check GoogleService-Info.plist")
            }
        } else {
            print("❌ [Firebase] Configuration failed - FirebaseApp is nil")
        }
    } else {
        print("🔥 [Firebase] Already configured")
    }
}

@MainActor
final class AuthService: NSObject, ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var phoneVerificationID: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let appleCoordinator = AppleSignInCoordinator()

    override init() {
        super.init()
        configureFirebaseIfNeeded()
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            print("👤 [AuthService] Auth state changed - user: \(user?.uid ?? "nil")")
            if let user = user {
                print("   Email: \(user.email ?? "nil")")
                print("   Phone: \(user.phoneNumber ?? "nil")")
                print("   Providers: \(user.providerData.map { $0.providerID })")
            }
            self?.user = user
        }
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
        print("🔵 [AuthService] Starting Google Sign-In...")
        configureFirebaseIfNeeded()
        
        guard let app = FirebaseApp.app() else {
            print("❌ [AuthService] FirebaseApp is nil")
            throw AuthServiceError.missingGoogleClientID
        }
        
        guard let clientID = app.options.clientID, !clientID.isEmpty else {
            print("❌ [AuthService] Client ID is missing or empty")
            print("   Options: \(app.options)")
            throw AuthServiceError.missingGoogleClientID
        }
        
        print("✅ [AuthService] Client ID found: \(clientID)")
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        print("🔵 [AuthService] Calling GIDSignIn.sharedInstance.signIn...")
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            
            print("✅ [AuthService] Google Sign-In completed")
            print("   User ID: \(result.user.userID ?? "nil")")
            print("   Email: \(result.user.profile?.email ?? "nil")")
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("❌ [AuthService] ID Token is nil")
                throw AuthServiceError.missingGoogleIDToken
            }
            
            print("✅ [AuthService] ID Token retrieved")
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            print("🔵 [AuthService] Signing in to Firebase with Google credential...")
            let authResult = try await Auth.auth().signIn(with: credential)
            print("✅ [AuthService] Firebase sign-in successful - user: \(authResult.user.uid)")
        } catch {
            print("❌ [AuthService] Google Sign-In ERROR: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            throw error
        }
    }

    func signInWithApple(presentationAnchor: ASPresentationAnchor?) async throws {
        print("🍎 [AuthService] Starting Apple Sign-In...")
        configureFirebaseIfNeeded()
        
        // Try to get a presentation anchor
        var anchor = presentationAnchor
        if anchor == nil {
            // Try multiple methods to get a window
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                anchor = window
                print("✅ [AuthService] Found key window from window scene")
            } else if let window = UIApplication.shared.keyWindow {
                anchor = window
                print("✅ [AuthService] Found key window from UIApplication")
            } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first {
                anchor = window
                print("✅ [AuthService] Found first window from window scene")
            }
        }
        
        guard let anchor else {
            print("❌ [AuthService] Missing presentation anchor")
            print("   Connected scenes: \(UIApplication.shared.connectedScenes.count)")
            throw AuthServiceError.missingPresentationAnchor
        }
        
        print("✅ [AuthService] Presentation anchor found")
        do {
            _ = try await appleCoordinator.signIn(presentationAnchor: anchor)
            print("✅ [AuthService] Apple Sign-In completed")
        } catch {
            print("❌ [AuthService] Apple Sign-In ERROR: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            throw error
        }
    }

    func prepareForPhoneAuth() {
        print("📱 [AuthService] Preparing for phone authentication")
        configureFirebaseIfNeeded()
        
        #if targetEnvironment(simulator)
        print("⚠️ [AuthService] Running on simulator - phone auth may not work properly")
        print("   APNS token cannot be set on simulator (would crash)")
        #endif
        
        // Only register if not already registered
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            print("📱 [AuthService] Already registered for remote notifications")
        } else {
            print("📱 [AuthService] Registering for remote notifications...")
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func startPhoneNumberSignIn(phoneNumber: String) async throws -> String {
        print("📱 [AuthService] Starting phone number sign-in - phone: \(phoneNumber)")
        configureFirebaseIfNeeded()
        let verificationID = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { id, error in
                if let error {
                    print("❌ [AuthService] Phone verification ERROR: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                guard let id else {
                    print("❌ [AuthService] Phone verification ID is nil")
                    continuation.resume(throwing: AuthServiceError.missingPhoneVerificationID)
                    return
                }
                print("✅ [AuthService] Phone verification ID received: \(id)")
                continuation.resume(returning: id)
            }
        }

        phoneVerificationID = verificationID
        return verificationID
    }

    func verifyPhoneNumber(code: String, verificationID: String? = nil) async throws {
        print("📱 [AuthService] Verifying phone number with code")
        configureFirebaseIfNeeded()
        let id = verificationID ?? phoneVerificationID
        guard let id else {
            print("❌ [AuthService] Missing phone verification ID")
            throw AuthServiceError.missingPhoneVerificationID
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: code)
        do {
            let result = try await Auth.auth().signIn(with: credential)
            print("✅ [AuthService] Phone verification successful - user: \(result.user.uid)")
        } catch {
            print("❌ [AuthService] Phone verification ERROR: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
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
        print("🍎 [AppleSignIn] Authorization completed")
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let tokenData = appleIDCredential.identityToken,
            let tokenString = String(data: tokenData, encoding: .utf8)
        else {
            print("❌ [AppleSignIn] Missing required credential data")
            continuation?.resume(throwing: AuthServiceError.missingAppleIDToken)
            continuation = nil
            return
        }

        print("✅ [AppleSignIn] Token retrieved, creating Firebase credential...")
        configureFirebaseIfNeeded()
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: tokenString,
            rawNonce: nonce
        )
        _Concurrency.Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                print("✅ [AppleSignIn] Firebase sign-in successful - user: \(result.user.uid)")
                continuation?.resume(returning: result)
            } catch {
                print("❌ [AppleSignIn] Firebase sign-in ERROR: \(error.localizedDescription)")
                continuation?.resume(throwing: error)
            }
            continuation = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ [AppleSignIn] Authorization failed: \(error.localizedDescription)")
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
