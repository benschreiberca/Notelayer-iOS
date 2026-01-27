import SwiftUI

/// Welcome page shown on first app launch for unauthenticated users.
/// Displays logo animation and auth options with an easy dismiss.
struct WelcomeView: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    
    @State private var isBusy = false
    @State private var errorMessage = ""
    
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Themed background
            theme.tokens.screenBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Logo with animation
                    AnimatedLogoView(logoSize: 100)
                        .frame(height: 140)
                    
                    // Welcome text
                    VStack(spacing: 8) {
                        Text("Welcome to Notelayer")
                            .font(.title2.bold())
                        
                        Text("Sign in to sync your notes across all devices")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    // Auth buttons
                    VStack(spacing: 12) {
                        AuthButtonView(provider: .phone, isEnabled: !isBusy) {
                            // Phone auth requires inline input, so we'll handle this differently
                            // For now, just show message that it's not implemented in welcome
                            errorMessage = "Phone auth from Profile & Settings"
                        }
                        
                        AuthButtonView(provider: .google, isEnabled: !isBusy) {
                            _Concurrency.Task { await signInWithGoogle() }
                        }
                        
                        AuthButtonView(provider: .apple, isEnabled: !isBusy) {
                            _Concurrency.Task { await signInWithApple() }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    // Loading indicator
                    if isBusy {
                        ProgressView()
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                        .frame(height: 24)
                    
                    // Dismiss button
                    Button {
                        onDismiss()
                        dismiss()
                    } label: {
                        Text("Nah, I don't want to backup")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    @MainActor
    private func signInWithGoogle() async {
        isBusy = true
        errorMessage = ""
        defer { isBusy = false }
        
        do {
            guard let controller = await findTopViewController() else {
                errorMessage = "Unable to present sign-in"
                return
            }
            try await authService.signInWithGoogle(presenting: controller)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func signInWithApple() async {
        isBusy = true
        errorMessage = ""
        defer { isBusy = false }
        
        do {
            guard let window = await findKeyWindow() else {
                errorMessage = "Unable to present sign-in"
                return
            }
            try await authService.signInWithApple(presentationAnchor: window)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func findTopViewController() async -> UIViewController? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let controller = windowScene.windows.first?.rootViewController?.topMostViewController {
            return controller
        }
        return nil
    }
    
    @MainActor
    private func findKeyWindow() async -> UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        return nil
    }
}

// Helper extension for finding top view controller
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

#Preview {
    WelcomeView(onDismiss: {})
        .environmentObject(AuthService())
        .environmentObject(ThemeManager.shared)
}
