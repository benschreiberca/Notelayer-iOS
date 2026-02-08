import AuthenticationServices
import GoogleSignIn
import SwiftUI
import UIKit
import _Concurrency

struct SignInSheet: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var generalError = ""
    @State private var isBusy = false
    @State private var emailAddress = ""
    @State private var emailError = ""
    @State private var emailLinkSent = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if !generalError.isEmpty {
                    Text(generalError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if isBusy {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                emailSection

                Divider()
                    .padding(.vertical, 8)
                
                // Social auth buttons
                VStack(spacing: 12) {
                    AuthButtonView(provider: .google, isEnabled: !isBusy) {
                        _Concurrency.Task { await startGoogleSignIn() }
                    }
                    
                    AuthButtonView(provider: .apple, isEnabled: !isBusy) {
                        _Concurrency.Task { await startAppleSignIn() }
                    }
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .onReceive(authService.$authErrorBanner) { message in
            guard let message, !message.isEmpty else { return }
            generalError = message
            authService.clearAuthErrorBanner()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sign into NoteLayer")
                .font(.title3.bold())
            Text("to sync everywhere")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField("Email address", text: $emailAddress)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            if emailLinkSent {
                Text("Check your email for a sign‑in link.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button("Resend link") {
                        _Concurrency.Task { await sendEmailLink() }
                    }
                    .font(.caption)
                    .disabled(isBusy)

                    Button("Change email") {
                        emailLinkSent = false
                        emailError = ""
                    }
                    .font(.caption)
                    .disabled(isBusy)
                }
            } else {
                Button {
                    _Concurrency.Task { await sendEmailLink() }
                } label: {
                    Text("Send magic link")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isBusy || emailAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !emailError.isEmpty {
                Text(emailError)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
    

    @MainActor
    private func runAuthAction(_ action: @escaping () async throws -> Void) async {
        isBusy = true
        generalError = ""
        defer { isBusy = false }
        do {
            try await action()
            // Auto-dismiss after successful sign-in to keep the flow minimal.
            dismiss()
        } catch {
            generalError = authService.userFacingAuthErrorMessage(from: error)
        }
    }

    @MainActor
    private func runEmailAction(_ action: @escaping () async throws -> Void) async {
        isBusy = true
        emailError = ""
        defer { isBusy = false }
        do {
            try await action()
        } catch {
            emailError = authService.userFacingAuthErrorMessage(from: error)
        }
    }

    @MainActor
    private func startAppleSignIn() async {
        await runAuthAction {
            guard let window = findKeyWindow() else {
                throw AuthViewError.missingWindow
            }
            try await authService.signInWithApple(presentationAnchor: window)
        }
    }

    @MainActor
    private func startGoogleSignIn() async {
        await runAuthAction {
            guard let controller = findTopViewController() else {
                throw AuthViewError.missingPresenter
            }
            try await authService.signInWithGoogle(presenting: controller)
        }
    }

    @MainActor
    private func sendEmailLink() async {
        await runEmailAction {
            let trimmedEmail = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            try await authService.sendEmailSignInLink(to: trimmedEmail)
            emailLinkSent = true
        }
    }

    @MainActor
    private func findTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController?.topMostViewController
    }

    @MainActor
    private func findKeyWindow() -> UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first(where: { $0.isKeyWindow })
            ?? windowScene.windows.first
    }
    
}

private enum AuthViewError: LocalizedError {
    case missingPresenter
    case missingWindow

    var errorDescription: String? {
        switch self {
        case .missingPresenter:
            return "Missing presenter for Google sign-in."
        case .missingWindow:
            return "Missing window for Apple sign-in."
        }
    }
}


private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        if let nav = self as? UINavigationController, let visible = nav.visibleViewController {
            return visible.topMostViewController
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.topMostViewController
        }
        return self
    }
}
