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

@MainActor
final class AuthService: NSObject, ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var phoneVerificationID: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let appleCoordinator = AppleSignInCoordinator()

    override init() {
        super.init()
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUpWithEmail(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func signInWithGoogle(presenting viewController: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID, !clientID.isEmpty else {
            throw AuthServiceError.missingGoogleClientID
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthServiceError.missingGoogleIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        _ = try await Auth.auth().signIn(with: credential)
    }

    func signInWithApple(presentationAnchor: ASPresentationAnchor?) async throws {
        let anchor = presentationAnchor ?? UIApplication.shared.keyWindow
        guard let anchor else {
            throw AuthServiceError.missingPresentationAnchor
        }

        _ = try await appleCoordinator.signIn(presentationAnchor: anchor)
    }

    func prepareForPhoneAuth() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func startPhoneNumberSignIn(phoneNumber: String) async throws -> String {
        let verificationID = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { id, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let id else {
                    continuation.resume(throwing: AuthServiceError.missingPhoneVerificationID)
                    return
                }
                continuation.resume(returning: id)
            }
        }

        phoneVerificationID = verificationID
        return verificationID
    }

    func verifyPhoneNumber(code: String, verificationID: String? = nil) async throws {
        let id = verificationID ?? phoneVerificationID
        guard let id else {
            throw AuthServiceError.missingPhoneVerificationID
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: code)
        _ = try await Auth.auth().signIn(with: credential)
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
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let tokenData = appleIDCredential.identityToken,
            let tokenString = String(data: tokenData, encoding: .utf8)
        else {
            continuation?.resume(throwing: AuthServiceError.missingAppleIDToken)
            continuation = nil
            return
        }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: tokenString,
            rawNonce: nonce
        )
        _Concurrency.Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                continuation?.resume(returning: result)
            } catch {
                continuation?.resume(throwing: error)
            }
            continuation = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
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
