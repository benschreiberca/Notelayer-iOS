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
    @State private var phoneStep: PhoneStep = .enterNumber
    @State private var countryCode = "+1"
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var phoneError = ""
    @State private var generalError = ""
    @State private var isBusy = false
    @State private var resendCountdown = 0
    @State private var resendTimer: Timer?

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

                // Phone auth section (always visible, inline)
                phoneSection
                
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
        .task {
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
                // Country code + Phone number input
                HStack(spacing: 8) {
                    // Country code picker
                    Menu {
                        Button("+1 (US)") { countryCode = "+1" }
                        Button("+44 (UK)") { countryCode = "+44" }
                        Button("+91 (IN)") { countryCode = "+91" }
                        Button("+61 (AU)") { countryCode = "+61" }
                        Button("+86 (CN)") { countryCode = "+86" }
                    } label: {
                        Text(countryCode)
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.secondarySystemBackground))
                            )
                    }
                    
                    TextField("Phone number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: phoneNumber) { newValue in
                            phoneNumber = formatPhoneNumber(newValue)
                        }
                }

                Button {
                    _Concurrency.Task { await startPhoneVerification() }
                } label: {
                    Text("Send code")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isBusy || phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            case .enterCode:
                TextField("Verification code", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.oneTimeCode)

                HStack(spacing: 12) {
                    Button {
                        _Concurrency.Task { await verifyPhoneCode() }
                    } label: {
                        Text("Verify")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isBusy || verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button {
                        phoneStep = .enterNumber
                        phoneError = ""
                        stopResendTimer()
                    } label: {
                        Text("Back")
                    }
                    .buttonStyle(PrimaryButtonStyle(isDestructive: true))
                    .disabled(isBusy)
                }
                
                // Resend code button
                if resendCountdown > 0 {
                    Text("Resend code in \(resendCountdown)s")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Button("Resend code") {
                        _Concurrency.Task { await startPhoneVerification() }
                    }
                    .font(.caption)
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
    
    private func formatPhoneNumber(_ number: String) -> String {
        // Remove non-numeric characters
        let digits = number.filter { $0.isNumber }
        
        // Limit to 10 digits for US numbers
        let limited = String(digits.prefix(10))
        
        // Format as (XXX) XXX-XXXX
        if limited.count >= 6 {
            let areaCode = limited.prefix(3)
            let prefix = limited.dropFirst(3).prefix(3)
            let suffix = limited.dropFirst(6)
            return "(\(areaCode)) \(prefix)-\(suffix)"
        } else if limited.count >= 3 {
            let areaCode = limited.prefix(3)
            let rest = limited.dropFirst(3)
            return "(\(areaCode)) \(rest)"
        } else {
            return limited
        }
    }
    
    private func startResendTimer() {
        resendCountdown = 60
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if resendCountdown > 0 {
                resendCountdown -= 1
            } else {
                stopResendTimer()
            }
        }
    }
    
    private func stopResendTimer() {
        resendTimer?.invalidate()
        resendTimer = nil
        resendCountdown = 0
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
            generalError = authErrorMessage(from: error)
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
            phoneError = authErrorMessage(from: error)
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
    private func startPhoneVerification() async {
        await runPhoneAction {
            // Combine country code with phone number
            let digitsOnly = phoneNumber.filter { $0.isNumber }
            let fullNumber = "\(countryCode)\(digitsOnly)"
            _ = try await authService.startPhoneNumberSignIn(phoneNumber: fullNumber)
            phoneStep = .enterCode
            startResendTimer()
        }
    }

    @MainActor
    private func verifyPhoneCode() async {
        await runPhoneAction {
            try await authService.verifyPhoneNumber(code: verificationCode)
            dismiss()
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
    
    // Provide a friendlier message when the user is already signed in.
    private func authErrorMessage(from error: Error) -> String {
        if case AuthServiceError.alreadySignedInWithDifferentMethod = error {
            let method = authService.authMethodDisplay ?? "another method"
            return "You're already signed in with \(method)."
        }
        return error.localizedDescription
    }
}

private enum PhoneStep {
    case inactive
    case enterNumber
    case enterCode
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
