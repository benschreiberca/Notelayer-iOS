import SwiftUI

/// Reusable authentication button with consistent styling across the app.
/// Supports Phone, Google, and Apple sign-in variants.
struct AuthButtonView: View {
    enum AuthProvider {
        case phone
        case google
        case apple
        
        var icon: String {
            switch self {
            case .phone: return "phone.fill"
            case .google: return "g.circle.fill"
            case .apple: return "apple.logo"
            }
        }
        
        var label: String {
            switch self {
            case .phone: return "Continue with Phone"
            case .google: return "Continue with Google"
            case .apple: return "Continue with Apple"
            }
        }
        
        var iconColor: Color {
            switch self {
            case .phone: return .blue
            case .google: return .red
            case .apple: return .primary
            }
        }
    }
    
    let provider: AuthProvider
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: provider.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(provider.iconColor)
                    .frame(width: 24)
                
                Text(provider.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .frame(height: 48)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .accessibilityLabel(provider.label)
        .accessibilityHint(isEnabled ? "" : "Button is disabled")
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthButtonView(provider: .phone, isEnabled: true) {
            print("Phone tapped")
        }
        
        AuthButtonView(provider: .google, isEnabled: true) {
            print("Google tapped")
        }
        
        AuthButtonView(provider: .apple, isEnabled: true) {
            print("Apple tapped")
        }
        
        AuthButtonView(provider: .phone, isEnabled: false) {
            print("Disabled")
        }
    }
    .padding()
}
