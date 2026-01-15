import SwiftUI
import Combine

enum ThemeMode: String, Codable, CaseIterable {
    case system, light, dark
}

enum PaletteMode: String, Codable, CaseIterable {
    case `default`, highContrast, warm, cool, neutral
}

class AppearanceStore: ObservableObject {
    static let shared = AppearanceStore()
    
    @Published var theme: ThemeMode = .system
    @Published var palette: PaletteMode = .default
    
    private let themeKey = "com.notelayer.app.theme"
    private let paletteKey = "com.notelayer.app.palette"
    
    private var userDefaults: UserDefaults {
        UserDefaults.standard
    }
    
    private init() {
        load()
    }
    
    func load() {
        if let themeString = userDefaults.string(forKey: themeKey),
           let theme = ThemeMode(rawValue: themeString) {
            self.theme = theme
        }
        
        if let paletteString = userDefaults.string(forKey: paletteKey),
           let palette = PaletteMode(rawValue: paletteString) {
            self.palette = palette
        }
    }
    
    func setTheme(_ theme: ThemeMode) {
        self.theme = theme
        userDefaults.set(theme.rawValue, forKey: themeKey)
    }
    
    func setPalette(_ palette: PaletteMode) {
        self.palette = palette
        userDefaults.set(palette.rawValue, forKey: paletteKey)
    }
}
