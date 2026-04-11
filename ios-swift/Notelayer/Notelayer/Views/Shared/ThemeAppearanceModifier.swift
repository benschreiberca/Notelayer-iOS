import SwiftUI

/// Applies the app's current theme color scheme and accent tint to a sheet.
///
/// Each `.sheet()` presentation creates a new view hierarchy that does not
/// inherit `.preferredColorScheme` or `.tint` from the parent. Applying this
/// modifier to every sheet ensures consistent appearance across all themes
/// without needing to add two separate modifiers per sheet.
///
/// Usage:
/// ```swift
/// .sheet(isPresented: $showingSomething) {
///     SomeView()
///         .withThemeAppearance()
///         .presentationDetents([.medium, .large])
/// }
/// ```
///
/// Scalability: Adding a new theme only requires updating `ThemeManager`.
/// No sheet call sites need to change.
extension View {
    func withThemeAppearance() -> some View {
        let theme = ThemeManager.shared
        return self
            .preferredColorScheme(theme.preferredColorScheme)
            .tint(theme.tokens.accent)
    }
}
