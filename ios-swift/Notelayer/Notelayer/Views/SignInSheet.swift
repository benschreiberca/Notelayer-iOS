import AuthenticationServices
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import UIKit
import _Concurrency

struct SignInSheet: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss

    // Two-step phone flow keeps verification state explicit and reduces edge cases.
    @State private var phoneStep: PhoneStep = .inactive
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var phoneError = ""
    @State private var generalError = ""
    @State private var isBusy = false

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
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                AppleIDSignInButton(isEnabled: !isBusy) {
                    _Concurrency.Task { await runAuthAction { try await authService.signInWithApple(presentationAnchor: nil) } }
                }
                .frame(height: 48)

                GoogleSignInButton(isEnabled: !isBusy) {
                    _Concurrency.Task { await startGoogleSignIn() }
                }
                .frame(height: 48)

                Button {
                    phoneStep = .enterNumber
                    phoneError = ""
                    generalError = ""
                } label: {
                    HStack {
                        Image(systemName: "phone")
                        Text("Continue with Phone")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.primary)
                .disabled(isBusy)

                if phoneStep != .inactive {
                    phoneSection
                }

                if let user = authService.user {
                    signedInSection(user: user)
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            // Phone auth requires APNS registration before verification.
            authService.prepareForPhoneAuth()
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

    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch phoneStep {
            case .enterNumber:
                TextField("Phone number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)

                Button("Send code") {
                    _Concurrency.Task { await startPhoneVerification() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy || phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            case .enterCode:
                TextField("Verification code", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 12) {
                    Button("Verify") {
                        _Concurrency.Task { await verifyPhoneCode() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isBusy || verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Back") {
                        phoneStep = .enterNumber
                        phoneError = ""
                    }
                    .buttonStyle(.bordered)
                    .disabled(isBusy)
                }

            case .inactive:
                EmptyView()
            }

            if !phoneError.isEmpty {
                Text(phoneError)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private func signedInSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Signed in as: \(user.email ?? user.phoneNumber ?? user.uid)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button(role: .destructive) {
                runSignOut()
            } label: {
                Text("Sign out")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
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
            generalError = error.localizedDescription
        }
    }

    @MainActor
    private func runPhoneAction(_ action: @escaping () async throws -> Void) async {
        isBusy = true
        phoneError = ""
        defer { isBusy = false }
        do {
            try await action()
        } catch {
            phoneError = error.localizedDescription
        }
    }

    @MainActor
    private func startGoogleSignIn() async {
        await runAuthAction {
            guard let controller = await waitForPresenter() else {
                throw AuthViewError.missingPresenter
            }
            try await authService.signInWithGoogle(presenting: controller)
        }
    }

    @MainActor
    private func startPhoneVerification() async {
        await runPhoneAction {
            _ = try await authService.startPhoneNumberSignIn(phoneNumber: phoneNumber)
            phoneStep = .enterCode
        }
    }

    @MainActor
    private func verifyPhoneCode() async {
        await runPhoneAction {
            try await authService.verifyPhoneNumber(code: verificationCode)
            dismiss()
        }
    }

    private func runSignOut() {
        generalError = ""
        do {
            try authService.signOut()
        } catch {
            generalError = error.localizedDescription
        }
    }

    @MainActor
    private func waitForPresenter() async -> UIViewController? {
        // Avoid presenting Google sign-in before the sheet is fully in place.
        for attempt in 0..<5 {
            if let controller = UIApplication.shared.topViewController, controller.view.window != nil {
                return controller
            }
            if attempt < 4 {
                try? await _Concurrency.Task.sleep(nanoseconds: 50_000_000)
            }
            await _Concurrency.Task.yield()
        }
        return nil
    }
}

private enum PhoneStep {
    case inactive
    case enterNumber
    case enterCode
}

private enum AuthViewError: LocalizedError {
    case missingPresenter

    var errorDescription: String? {
        switch self {
        case .missingPresenter:
            return "Missing presenter for Google sign-in."
        }
    }
}

private struct AppleIDSignInButton: UIViewRepresentable {
    let isEnabled: Bool
    let onTap: () -> Void

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        uiView.isEnabled = isEnabled
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    final class Coordinator: NSObject {
        private let onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        @objc func didTap() {
            onTap()
        }
    }
}

private struct GoogleSignInButton: UIViewRepresentable {
    let isEnabled: Bool
    let onTap: () -> Void

    func makeUIView(context: Context) -> GIDSignInButton {
        let button = GIDSignInButton()
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
        uiView.isEnabled = isEnabled
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    final class Coordinator: NSObject {
        private let onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        @objc func didTap() {
            onTap()
        }
    }
}

private extension UIApplication {
    var topViewController: UIViewController? {
        let scenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap { $0.windows }.first(where: { $0.isKeyWindow })
            ?? scenes.first?.windows.first
        guard let window else {
            return nil
        }
        return window.rootViewController?.topMostViewController
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
