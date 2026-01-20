import FirebaseAuth
import SwiftUI
import UIKit
import _Concurrency

struct AuthTestView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var statusMessage = ""
    @State private var isBusy = false
    @State private var showingMethods = true
    @State private var selectedMethod: AuthMethod?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                statusCard
                methodPickerButton
                if selectedMethod == .email {
                    emailSection
                }
                if selectedMethod == .phone {
                    phoneSection
                }
                if authService.user != nil {
                    signOutButton
                }
            }
            .padding(20)
        }
        .background(Color.clear)
        .onAppear {
            authService.prepareForPhoneAuth()
            showingMethods = true
        }
        .sheet(isPresented: $showingMethods) {
            AuthMethodSheet(
                isBusy: isBusy,
                onApple: { await runAction { try await authService.signInWithApple(presentationAnchor: nil) } },
                onGoogle: {
                    await runAction {
                        guard let controller = UIApplication.shared.topViewController else {
                            throw AuthViewError.missingPresenter
                        }
                        try await authService.signInWithGoogle(presenting: controller)
                    }
                },
                onEmail: {
                    selectedMethod = .email
                },
                onPhone: {
                    selectedMethod = .phone
                }
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Authentication")
                .font(.title.bold())
            Text("Choose a sign-in method to unlock sync across devices.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let user = authService.user {
                Text("Signed in as: \(user.email ?? user.phoneNumber ?? user.uid)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var methodPickerButton: some View {
        Button {
            showingMethods = true
        } label: {
            HStack {
                Image(systemName: "person.badge.key")
                Text("Change authentication method")
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.footnote)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var statusCard: some View {
        Group {
            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email & Password")
                .font(.headline)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            HStack(spacing: 12) {
                Button("Sign up") {
                    _Concurrency.Task { await runAction { try await authService.signUpWithEmail(email: email, password: password) } }
                }
                Button("Sign in") {
                    _Concurrency.Task { await runAction { try await authService.signInWithEmail(email: email, password: password) } }
                }
                Button("Reset") {
                    _Concurrency.Task { await runAction { try await authService.sendPasswordReset(email: email) } }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .disabled(isBusy)
        }
    }

    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Phone")
                .font(.headline)
            TextField("Phone number (+1...) ", text: $phoneNumber)
                .keyboardType(.phonePad)
                .textFieldStyle(.roundedBorder)
            Button("Send code") {
                _Concurrency.Task {
                    await runAction {
                        let id = try await authService.startPhoneNumberSignIn(phoneNumber: phoneNumber)
                        statusMessage = "Verification ID: \(id)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .disabled(isBusy)

            TextField("Verification code", text: $verificationCode)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            Button("Verify code") {
                _Concurrency.Task { await runAction { try await authService.verifyPhoneNumber(code: verificationCode) } }
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .disabled(isBusy)
        }
    }

    private var signOutButton: some View {
        Button(role: .destructive) {
            runSyncAction { try authService.signOut() }
        } label: {
            Text("Sign out")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }

    @MainActor
    private func runAction(_ action: @escaping () async throws -> Void) async {
        isBusy = true
        defer { isBusy = false }
        statusMessage = ""
        do {
            try await action()
            statusMessage = "Success"
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    @MainActor
    private func runSyncAction(_ action: () throws -> Void) {
        statusMessage = ""
        do {
            try action()
            statusMessage = "Success"
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

private enum AuthMethod {
    case email
    case phone
}

private struct AuthMethodSheet: View {
    let isBusy: Bool
    let onApple: () async -> Void
    let onGoogle: () async -> Void
    let onEmail: () -> Void
    let onPhone: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 14) {
            Text("Authentication method")
                .font(.headline)

            SignInMethodButton(
                title: "Continue with Apple",
                foreground: .white,
                background: .black,
                systemIcon: "applelogo",
                action: {
                    _Concurrency.Task {
                        await onApple()
                        dismiss()
                    }
                }
            )

            SignInMethodButton(
                title: "Continue with Google",
                foreground: .white,
                background: Color(red: 0.26, green: 0.52, blue: 0.96),
                iconView: AnyView(GoogleLogo()),
                action: {
                    _Concurrency.Task {
                        await onGoogle()
                        dismiss()
                    }
                }
            )

            SignInMethodButton(
                title: "Email & Password",
                foreground: .primary,
                background: Color.secondary.opacity(0.12),
                systemIcon: "envelope",
                action: {
                    onEmail()
                    dismiss()
                }
            )

            SignInMethodButton(
                title: "Phone Number",
                foreground: .primary,
                background: Color.secondary.opacity(0.12),
                systemIcon: "phone",
                action: {
                    onPhone()
                    dismiss()
                }
            )
        }
        .padding(20)
        .presentationDetents([.fraction(0.48)])
        .presentationDragIndicator(.visible)
        .disabled(isBusy)
    }
}

private struct SignInMethodButton: View {
    let title: String
    let foreground: Color
    let background: Color
    let systemIcon: String?
    let iconView: AnyView?
    let action: () -> Void

    init(
        title: String,
        foreground: Color,
        background: Color,
        systemIcon: String? = nil,
        iconView: AnyView? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.foreground = foreground
        self.background = background
        self.systemIcon = systemIcon
        self.iconView = iconView
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                iconSlot
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .foregroundStyle(foreground)
        }
        .buttonStyle(.borderedProminent)
        .tint(background)
        .controlSize(.large)
    }

    private var iconSlot: some View {
        Group {
            if let iconView {
                iconView
            } else if let systemIcon {
                Image(systemName: systemIcon)
                    .font(.system(size: 18, weight: .semibold))
            } else {
                Color.clear
            }
        }
        .frame(width: 28, height: 28, alignment: .center)
    }
}

private struct GoogleLogo: View {
    var body: some View {
        Image("GoogleLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)
            .padding(5)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
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

private extension UIApplication {
    var topViewController: UIViewController? {
        guard let scene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
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
