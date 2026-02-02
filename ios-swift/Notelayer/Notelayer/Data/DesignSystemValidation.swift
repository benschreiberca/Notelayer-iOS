import SwiftUI

#if DEBUG
/// Lightweight validation to catch missing tokens or wallpaper definitions during development.
enum DesignSystemValidator {
    static func validateThemes() {
        guard !ThemeCatalog.themes.isEmpty else {
            assertionFailure("ThemeCatalog.themes is empty")
            return
        }

        for theme in ThemeCatalog.themes {
            _ = theme.lightSemanticTokens
            _ = theme.darkSemanticTokens
            _ = theme.defaultConfiguration.wallpaper.definition
            _ = theme.surfaceTinting
        }
    }
}
#endif
