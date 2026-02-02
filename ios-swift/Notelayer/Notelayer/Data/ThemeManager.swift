import SwiftUI
import Combine
import UIKit

// MARK: - Theme Models

struct ThemeAccent: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let hex: String

    var color: Color {
        Color(hex: hex) ?? .accentColor
    }
}

enum ThemeSurfaceStyle: String, Codable, CaseIterable, Identifiable {
    case soft
    case frosted
    case gradient
    case solid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .soft: return "Soft"
        case .frosted: return "Frosted"
        case .gradient: return "Gradient"
        case .solid: return "Solid"
        }
    }
}

enum ThemeWallpaperKind: String, Codable, CaseIterable {
    case gradient
    case pattern
    case designer
    case image
}

enum ImageWallpaperMode: String, Codable {
    case fill
    case tile
}

struct ThemeWallpaperSelection: Codable, Equatable {
    var kind: ThemeWallpaperKind
    var id: String
    var imageFilename: String?
    var imageMode: ImageWallpaperMode?
}

struct ThemeConfiguration: Codable, Equatable {
    var wallpaper: ThemeWallpaperSelection
    var accent: ThemeAccent
    var sectionTint: ThemeAccent
    var surfaceStyle: ThemeSurfaceStyle
    var intensity: Double
    var surfaceOpacity: Double

    init(
        wallpaper: ThemeWallpaperSelection,
        accent: ThemeAccent,
        sectionTint: ThemeAccent? = nil,
        surfaceStyle: ThemeSurfaceStyle,
        intensity: Double,
        surfaceOpacity: Double = 0.85
    ) {
        self.wallpaper = wallpaper
        self.accent = accent
        self.sectionTint = sectionTint ?? accent
        self.surfaceStyle = surfaceStyle
        self.intensity = intensity
        self.surfaceOpacity = surfaceOpacity
    }

    private enum CodingKeys: String, CodingKey {
        case wallpaper
        case accent
        case sectionTint
        case surfaceStyle
        case intensity
        case surfaceOpacity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wallpaper = try container.decode(ThemeWallpaperSelection.self, forKey: .wallpaper)
        accent = try container.decode(ThemeAccent.self, forKey: .accent)
        sectionTint = try container.decodeIfPresent(ThemeAccent.self, forKey: .sectionTint) ?? accent
        surfaceStyle = try container.decode(ThemeSurfaceStyle.self, forKey: .surfaceStyle)
        intensity = try container.decode(Double.self, forKey: .intensity)
        surfaceOpacity = try container.decodeIfPresent(Double.self, forKey: .surfaceOpacity) ?? 0.85
    }

    static func clampedIntensity(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }

    static func clampedOpacity(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }

}

enum ThemePresetCategory: String, Codable {
    case traditional
    case pattern
}

struct SavedTheme: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var themeId: String
    var configuration: ThemeConfiguration
    var mode: ThemeMode
    var updatedAt: TimeInterval

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case themeId
        case configuration
        case mode
        case updatedAt
    }

    init(
        id: String,
        name: String,
        themeId: String,
        configuration: ThemeConfiguration,
        mode: ThemeMode,
        updatedAt: TimeInterval
    ) {
        self.id = id
        self.name = name
        self.themeId = themeId
        self.configuration = configuration
        self.mode = mode
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        themeId = try container.decodeIfPresent(String.self, forKey: .themeId) ?? ThemeCatalog.defaultTheme.id
        configuration = try container.decode(ThemeConfiguration.self, forKey: .configuration)
        mode = try container.decode(ThemeMode.self, forKey: .mode)
        updatedAt = try container.decode(TimeInterval.self, forKey: .updatedAt)
    }
}

struct UserWallpaper: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var filename: String
    var mode: ImageWallpaperMode
}

// MARK: - Theme Manager

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var mode: ThemeMode = .system {
        didSet { save() }
    }
    @Published private(set) var resolvedColorScheme: ColorScheme = .light
    @Published var configuration: ThemeConfiguration = ThemeCatalog.defaultTheme.defaultConfiguration {
        didSet { save() }
    }
    @Published var selectedPresetId: String? = ThemeCatalog.defaultTheme.id {
        didSet { save() }
    }
    @Published var selectedCustomThemeId: String? = nil {
        didSet { save() }
    }
    @Published var savedThemes: [SavedTheme] = [] {
        didSet { save() }
    }
    @Published var userWallpapers: [UserWallpaper] = [] {
        didSet { save() }
    }

    private let appGroupIdentifier = "group.com.notelayer.app"
    private let themeStateKey = "com.notelayer.app.theme.state.v2"
    private let updatedAtKey = "com.notelayer.app.theme.updatedAt"

    // Legacy keys for migration
    private let legacyModeKey = "com.notelayer.app.theme.mode"
    private let legacyPresetKey = "com.notelayer.app.theme.preset"

    private var isLoading = false

    private var appGroupDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    private var userDefaults: UserDefaults {
        appGroupDefaults ?? UserDefaults.standard
    }

    private init() {
        load()
        #if DEBUG
        DesignSystemValidator.validateThemes()
        #endif
    }

    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var tokens: DesignTokens {
        DesignTokens(
            theme: currentTheme,
            configuration: configuration,
            resolvedMode: resolvedColorScheme
        )
    }

    var activeTheme: ThemeDefinition? {
        guard let selectedPresetId else { return nil }
        return ThemeCatalog.theme(id: selectedPresetId)
    }

    var currentTheme: ThemeDefinition {
        activeTheme ?? ThemeCatalog.defaultTheme
    }

    var activeSavedTheme: SavedTheme? {
        guard let selectedCustomThemeId else { return nil }
        return savedThemes.first { $0.id == selectedCustomThemeId }
    }

    // MARK: - Apply Actions

    func applyPreset(_ preset: ThemeDefinition) {
        configuration = preset.defaultConfiguration
        selectedPresetId = preset.id
        selectedCustomThemeId = nil
    }

    func applySavedTheme(_ theme: SavedTheme) {
        configuration = theme.configuration
        mode = theme.mode
        selectedPresetId = theme.themeId
        selectedCustomThemeId = theme.id
    }

    func updateConfiguration(_ newConfiguration: ThemeConfiguration) {
        var updated = newConfiguration
        updated.intensity = ThemeConfiguration.clampedIntensity(updated.intensity)
        updated.surfaceOpacity = ThemeConfiguration.clampedOpacity(updated.surfaceOpacity)
        configuration = updated

        if let selectedCustomThemeId,
           let saved = savedThemes.first(where: { $0.id == selectedCustomThemeId }),
           saved.configuration != updated {
            self.selectedCustomThemeId = nil
        }
    }

    func updateMode(_ newMode: ThemeMode) {
        mode = newMode
    }

    func updateResolvedColorScheme(_ scheme: ColorScheme) {
        resolvedColorScheme = scheme
    }

    func saveTheme(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmed.isEmpty ? "Custom Theme" : trimmed
        let saved = SavedTheme(
            id: UUID().uuidString,
            name: finalName,
            themeId: currentTheme.id,
            configuration: configuration,
            mode: mode,
            updatedAt: Date().timeIntervalSince1970
        )
        savedThemes.append(saved)
        selectedCustomThemeId = saved.id
    }

    func updateActiveSavedTheme() {
        guard let selectedCustomThemeId,
              let index = savedThemes.firstIndex(where: { $0.id == selectedCustomThemeId }) else {
            return
        }
        savedThemes[index].themeId = currentTheme.id
        savedThemes[index].configuration = configuration
        savedThemes[index].mode = mode
        savedThemes[index].updatedAt = Date().timeIntervalSince1970
    }

    func renameSavedTheme(id: String, to newName: String) {
        guard let index = savedThemes.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        savedThemes[index].name = trimmed.isEmpty ? savedThemes[index].name : trimmed
        savedThemes[index].updatedAt = Date().timeIntervalSince1970
    }

    func deleteSavedTheme(id: String) {
        savedThemes.removeAll { $0.id == id }
        if selectedCustomThemeId == id {
            selectedCustomThemeId = nil
        }
    }

    // MARK: - User Wallpaper Storage

    func addUserWallpaper(name: String, data: Data, mode: ImageWallpaperMode) -> UserWallpaper? {
        guard let directory = wallpaperDirectoryURL() else { return nil }
        let fileId = UUID().uuidString
        let filename = "wallpaper_\(fileId).png"
        let fileURL = directory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: [.atomic])
            let wallpaper = UserWallpaper(id: fileId, name: name, filename: filename, mode: mode)
            userWallpapers.append(wallpaper)
            return wallpaper
        } catch {
            return nil
        }
    }

    func imageURL(for filename: String) -> URL? {
        guard let directory = wallpaperDirectoryURL() else { return nil }
        return directory.appendingPathComponent(filename)
    }

    private func wallpaperDirectoryURL() -> URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = documents.appendingPathComponent("Wallpapers", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    // MARK: - Persistence

    private struct ThemePersistenceState: Codable {
        let version: Int
        let mode: ThemeMode
        let configuration: ThemeConfiguration
        let selectedPresetId: String?
        let selectedCustomThemeId: String?
        let savedThemes: [SavedTheme]
        let userWallpapers: [UserWallpaper]
        let updatedAt: TimeInterval
    }

    func load() {
        isLoading = true
        defer { isLoading = false }

        let appGroupState = loadState(from: appGroupDefaults)
        let standardState = loadState(from: UserDefaults.standard)

        let primaryState: ThemePersistenceState?
        if let appState = appGroupState, let standardState = standardState {
            primaryState = appState.updatedAt >= standardState.updatedAt ? appState : standardState
        } else {
            primaryState = appGroupState ?? standardState
        }

        if let primaryState {
            applyState(primaryState)
            return
        }

        migrateLegacyIfNeeded()
    }

    private func applyState(_ state: ThemePersistenceState) {
        mode = state.mode
        var adjustedConfiguration = state.configuration
        adjustedConfiguration.intensity = ThemeConfiguration.clampedIntensity(adjustedConfiguration.intensity)
        adjustedConfiguration.surfaceOpacity = ThemeConfiguration.clampedOpacity(adjustedConfiguration.surfaceOpacity)
        configuration = adjustedConfiguration
        if let presetId = state.selectedPresetId, ThemeCatalog.theme(id: presetId) != nil {
            selectedPresetId = presetId
        } else {
            selectedPresetId = ThemeCatalog.defaultTheme.id
        }
        selectedCustomThemeId = state.selectedCustomThemeId
        savedThemes = state.savedThemes
        userWallpapers = state.userWallpapers
    }

    private func save() {
        guard !isLoading else { return }
        let timestamp = Date().timeIntervalSince1970
        var adjustedConfiguration = configuration
        adjustedConfiguration.intensity = ThemeConfiguration.clampedIntensity(adjustedConfiguration.intensity)
        adjustedConfiguration.surfaceOpacity = ThemeConfiguration.clampedOpacity(adjustedConfiguration.surfaceOpacity)
        let state = ThemePersistenceState(
            version: 3,
            mode: mode,
            configuration: adjustedConfiguration,
            selectedPresetId: selectedPresetId,
            selectedCustomThemeId: selectedCustomThemeId,
            savedThemes: savedThemes,
            userWallpapers: userWallpapers,
            updatedAt: timestamp
        )

        guard let data = try? JSONEncoder().encode(state) else { return }
        let targets = [appGroupDefaults, UserDefaults.standard].compactMap { $0 }
        for defaults in targets {
            defaults.set(data, forKey: themeStateKey)
            defaults.set(timestamp, forKey: updatedAtKey)
            defaults.synchronize()
        }
    }

    private func loadState(from defaults: UserDefaults?) -> ThemePersistenceState? {
        guard let defaults else { return nil }
        guard let data = defaults.data(forKey: themeStateKey),
              let state = try? JSONDecoder().decode(ThemePersistenceState.self, from: data) else {
            return nil
        }
        return state
    }

    // MARK: - Legacy Migration

    private func migrateLegacyIfNeeded() {
        let defaults = appGroupDefaults ?? UserDefaults.standard

        let legacyMode = defaults.string(forKey: legacyModeKey).flatMap(ThemeMode.init)
        let legacyPreset = defaults.string(forKey: legacyPresetKey).flatMap(LegacyThemePreset.init)

        if legacyMode == nil && legacyPreset == nil {
            // New or never-customized users default to Iridescent Flow.
            applyPreset(ThemeCatalog.defaultTheme)
            return
        }

        let legacyConfiguration = legacyPreset.map { ThemeCatalog.legacyConfiguration(for: $0) }
            ?? ThemeCatalog.defaultTheme.defaultConfiguration

        mode = legacyMode ?? .system
        configuration = legacyConfiguration
        selectedPresetId = nil
        selectedCustomThemeId = nil
    }
}

// MARK: - Preset Catalog

enum LegacyThemePreset: String, Codable {
    case barbie
    case cheetah
    case iridescent
    case arctic
    case ocean
    case forest
    case sunset
    case lavender
    case graphite
    case sand
    case mint
    case ember
    case berry
    case citrus
    case slate
    case mono
}

struct ThemeCatalog {
    static let themes: [ThemeDefinition] = [
        makeTheme(
            id: "iridescent-flow",
            name: "Iridescent Flow",
            description: "Bold iridescent gradient with frosted surfaces.",
            category: .traditional,
            preferredMode: .light,
            wallpaper: selection(kind: .gradient, id: "iridescent-flow"),
            accentName: "Cool Blue",
            sectionTintName: "Lavender",
            surfaceStyle: .frosted,
            intensity: 0.6,
            surfaceTinting: .tinted(style: .bold)
        ),
        makeTheme(
            id: "focus-dark",
            name: "Focus Dark",
            description: "Subtle dark gradient with solid surfaces.",
            category: .traditional,
            preferredMode: .dark,
            wallpaper: selection(kind: .gradient, id: "focus-dark"),
            accentName: "Graphite",
            sectionTintName: "Cool Blue",
            surfaceStyle: .solid,
            intensity: 0.25,
            surfaceTinting: .tinted(style: .subtle)
        ),
        makeTheme(
            id: "midnight-bloom",
            name: "Midnight Bloom",
            description: "Deep indigo gradient with soft contrast.",
            category: .traditional,
            preferredMode: .dark,
            wallpaper: selection(kind: .gradient, id: "midnight-bloom"),
            accentName: "Lavender",
            sectionTintName: "Berry",
            surfaceStyle: .gradient,
            intensity: 0.45
        ),
        makeTheme(
            id: "sunset-rise",
            name: "Sunset Rise",
            description: "Warm gradients with confident energy.",
            category: .traditional,
            preferredMode: .light,
            wallpaper: selection(kind: .gradient, id: "sunset-rise"),
            accentName: "Sunset",
            sectionTintName: "Citrus",
            surfaceStyle: .gradient,
            intensity: 0.65,
            surfaceTinting: .tinted(style: .bold)
        ),
        makeTheme(
            id: "arctic-glow",
            name: "Arctic Glow",
            description: "Cool, minimal gradients with clarity.",
            category: .traditional,
            preferredMode: .light,
            wallpaper: selection(kind: .gradient, id: "arctic-glow"),
            accentName: "Ocean",
            sectionTintName: "Mint",
            surfaceStyle: .soft,
            intensity: 0.5,
            surfaceTinting: .whiteCardsNeutral
        ),
        makeTheme(
            id: "playful-pattern",
            name: "Playful Pattern",
            description: "Patterned wallpaper with bright accents.",
            category: .pattern,
            preferredMode: .light,
            wallpaper: selection(kind: .pattern, id: "playful-dots"),
            accentName: "Hot Pink",
            sectionTintName: "Citrus",
            surfaceStyle: .soft,
            intensity: 0.75,
            surfaceTinting: .tinted(style: .bold)
        ),
        makeTheme(
            id: "cheetah-bold",
            name: "Cheetah Bold",
            description: "Cheetah pattern with warm neutrals.",
            category: .pattern,
            preferredMode: .light,
            wallpaper: selection(kind: .pattern, id: "cheetah"),
            accentName: "Warm Taupe",
            sectionTintName: "Ember",
            surfaceStyle: .gradient,
            intensity: 0.6,
            surfaceTinting: .tinted(style: .medium)
        ),
        makeTheme(
            id: "noir-dots",
            name: "Noir Dots",
            description: "Midnight dots with neon accents.",
            category: .pattern,
            preferredMode: .dark,
            wallpaper: selection(kind: .pattern, id: "noir-dots"),
            accentName: "Hot Pink",
            sectionTintName: "Cool Blue",
            surfaceStyle: .frosted,
            intensity: 0.55,
            surfaceTinting: .tinted(style: .bold)
        ),
        makeTheme(
            id: "designer-calm",
            name: "Designer Calm",
            description: "Designer texture with warm neutrals.",
            category: .pattern,
            preferredMode: .light,
            wallpaper: selection(kind: .designer, id: "gucci-monogram"),
            accentName: "Warm Taupe",
            sectionTintName: "Graphite",
            surfaceStyle: .gradient,
            intensity: 0.4,
            surfaceTinting: .tinted(style: .subtle)
        ),
        makeTheme(
            id: "marble-night",
            name: "Marble Night",
            description: "Marble texture with quiet contrast.",
            category: .pattern,
            preferredMode: .dark,
            wallpaper: selection(kind: .designer, id: "marble-fabric"),
            accentName: "Graphite",
            sectionTintName: "Lavender",
            surfaceStyle: .solid,
            intensity: 0.45,
            surfaceTinting: .tinted(style: .medium)
        )
    ]

    static let defaultTheme = themes[0]

    static func theme(id: String) -> ThemeDefinition? {
        themes.first { $0.id == id }
    }

    static func themes(for mode: ThemeMode) -> [ThemeDefinition] {
        switch mode {
        case .system:
            return themes
        case .light:
            return themes.filter { $0.preferredMode == .light }
        case .dark:
            return themes.filter { $0.preferredMode == .dark }
        }
    }

    static func legacyConfiguration(for preset: LegacyThemePreset) -> ThemeConfiguration {
        let gradientId = "legacy-\(preset.rawValue)"
        let accent = ThemeAccentCatalog.legacyAccent(for: preset)
        return ThemeConfiguration(
            wallpaper: ThemeWallpaperSelection(kind: .gradient, id: gradientId, imageFilename: nil, imageMode: nil),
            accent: accent,
            sectionTint: accent,
            surfaceStyle: .soft,
            intensity: 0.5,
            surfaceOpacity: 0.85
        )
    }

    private static func makeTheme(
        id: String,
        name: String,
        description: String,
        category: ThemePresetCategory,
        preferredMode: ThemeMode,
        wallpaper: ThemeWallpaperSelection,
        accentName: String,
        sectionTintName: String,
        surfaceStyle: ThemeSurfaceStyle,
        intensity: Double,
        surfaceTinting: SurfaceTintingDefinition = .tinted(style: .medium)
    ) -> ThemeDefinition {
        let accent = ThemeAccentCatalog.accent(named: accentName)
        let sectionTint = ThemeAccentCatalog.accent(named: sectionTintName)
        let lightTokens = SemanticTokens.defaultLight().applyingAccent(primary: accent.color, secondary: sectionTint.color)
        let darkTokens = SemanticTokens.defaultDark().applyingAccent(primary: accent.color, secondary: sectionTint.color)
        let configuration = ThemeConfiguration(
            wallpaper: wallpaper,
            accent: accent,
            sectionTint: sectionTint,
            surfaceStyle: surfaceStyle,
            intensity: intensity,
            surfaceOpacity: 0.85
        )

        return ThemeDefinition(
            id: id,
            name: name,
            description: description,
            category: category,
            preferredMode: preferredMode,
            lightSemanticTokens: lightTokens,
            darkSemanticTokens: darkTokens,
            defaultConfiguration: configuration,
            surfaceTinting: surfaceTinting,
            componentOverrides: nil
        )
    }

    private static func selection(kind: ThemeWallpaperKind, id: String) -> ThemeWallpaperSelection {
        ThemeWallpaperSelection(
            kind: kind,
            id: id,
            imageFilename: nil,
            imageMode: nil
        )
    }
}

// MARK: - Accent Catalog

struct ThemeAccentCatalog {
    static let accents: [ThemeAccent] = [
        ThemeAccent(id: "cool-blue", name: "Cool Blue", hex: "#3B82F6"),
        ThemeAccent(id: "graphite", name: "Graphite", hex: "#334155"),
        ThemeAccent(id: "hot-pink", name: "Hot Pink", hex: "#FF4FD8"),
        ThemeAccent(id: "warm-taupe", name: "Warm Taupe", hex: "#B8926A"),
        ThemeAccent(id: "mint", name: "Mint", hex: "#20C997"),
        ThemeAccent(id: "sunset", name: "Sunset", hex: "#FB5607"),
        ThemeAccent(id: "lavender", name: "Lavender", hex: "#9B5DE5"),
        ThemeAccent(id: "citrus", name: "Citrus", hex: "#FFBE0B"),
        ThemeAccent(id: "ocean", name: "Ocean", hex: "#0077B6"),
        ThemeAccent(id: "forest", name: "Forest", hex: "#2F855A"),
        ThemeAccent(id: "berry", name: "Berry", hex: "#B5179E"),
        ThemeAccent(id: "ember", name: "Ember", hex: "#E63946")
    ]

    static func accent(named name: String) -> ThemeAccent {
        accents.first(where: { $0.name == name }) ?? accents[0]
    }

    static func accent(for id: String) -> ThemeAccent {
        accents.first(where: { $0.id == id }) ?? accents[0]
    }

    static func legacyAccent(for preset: LegacyThemePreset) -> ThemeAccent {
        switch preset {
        case .barbie: return accent(named: "Hot Pink")
        case .cheetah: return accent(named: "Citrus")
        case .iridescent: return accent(named: "Cool Blue")
        case .arctic: return accent(named: "Cool Blue")
        case .ocean: return accent(named: "Ocean")
        case .forest: return accent(named: "Forest")
        case .sunset: return accent(named: "Sunset")
        case .lavender: return accent(named: "Lavender")
        case .graphite: return accent(named: "Graphite")
        case .sand: return accent(named: "Warm Taupe")
        case .mint: return accent(named: "Mint")
        case .ember: return accent(named: "Ember")
        case .berry: return accent(named: "Berry")
        case .citrus: return accent(named: "Citrus")
        case .slate: return accent(named: "Graphite")
        case .mono: return accent(named: "Graphite")
        }
    }
}

// MARK: - Wallpaper Catalog

struct ThemeGradientDefinition: Identifiable {
    let id: String
    let name: String
    let lightColors: [String]
    let darkColors: [String]
}

struct ThemePatternDefinition: Identifiable {
    let id: String
    let name: String
    let backgroundLightHex: String
    let backgroundDarkHex: String
    let foregroundLightHex: String
    let foregroundDarkHex: String
}

struct ThemeDesignerDefinition: Identifiable {
    let id: String
    let name: String
    let backgroundLightHex: String
    let backgroundDarkHex: String
    let foregroundLightHex: String
    let foregroundDarkHex: String
}

struct ThemeWallpaperCatalog {
    static let gradients: [ThemeGradientDefinition] = [
        ThemeGradientDefinition(
            id: "iridescent-flow",
            name: "Iridescent Flow",
            lightColors: ["#00D2FF", "#7B2FF7", "#FF4FD8", "#00D2FF"],
            darkColors: ["#0B1020", "#1B0F2B", "#2A0B1F", "#0B1020"]
        ),
        ThemeGradientDefinition(
            id: "focus-dark",
            name: "Focus Dark",
            lightColors: ["#1F2937", "#0F172A"],
            darkColors: ["#0B0F1A", "#05070B"]
        ),
        ThemeGradientDefinition(
            id: "midnight-bloom",
            name: "Midnight Bloom",
            lightColors: ["#1B1140", "#2B1B5A", "#0F172A"],
            darkColors: ["#07040F", "#12081F", "#05060B"]
        ),
        ThemeGradientDefinition(
            id: "sunset-rise",
            name: "Sunset Rise",
            lightColors: ["#FF6B6B", "#FFD93D", "#FF6B6B"],
            darkColors: ["#2B0B0B", "#2B1A0B", "#2B0B0B"]
        ),
        ThemeGradientDefinition(
            id: "arctic-glow",
            name: "Arctic Glow",
            lightColors: ["#8EC5FF", "#E0F2FF", "#B6E7FF"],
            darkColors: ["#0A121A", "#0D1C2B", "#0A121A"]
        )
    ]

    static let patterns: [ThemePatternDefinition] = [
        ThemePatternDefinition(
            id: "playful-dots",
            name: "Playful Dots",
            backgroundLightHex: "#FFF7FB",
            backgroundDarkHex: "#1A0F16",
            foregroundLightHex: "#FF4FD8",
            foregroundDarkHex: "#FF8ED8"
        ),
        ThemePatternDefinition(
            id: "cheetah",
            name: "Cheetah",
            backgroundLightHex: "#FFF7E6",
            backgroundDarkHex: "#15110B",
            foregroundLightHex: "#6B4F2D",
            foregroundDarkHex: "#B58A54"
        ),
        ThemePatternDefinition(
            id: "noir-dots",
            name: "Noir Dots",
            backgroundLightHex: "#0F111A",
            backgroundDarkHex: "#05060B",
            foregroundLightHex: "#8B5CF6",
            foregroundDarkHex: "#C4B5FD"
        )
    ]

    static let designers: [ThemeDesignerDefinition] = [
        ThemeDesignerDefinition(
            id: "gucci-monogram",
            name: "Gucci Monogram",
            backgroundLightHex: "#F5F0E8",
            backgroundDarkHex: "#1B1612",
            foregroundLightHex: "#6B5B4D",
            foregroundDarkHex: "#B59B7A"
        ),
        ThemeDesignerDefinition(
            id: "marble-fabric",
            name: "Marble Fabric",
            backgroundLightHex: "#F7F4F2",
            backgroundDarkHex: "#1A1714",
            foregroundLightHex: "#C7B8A8",
            foregroundDarkHex: "#8A7A6B"
        )
    ]

    static let legacyGradients: [ThemeGradientDefinition] = [
        ThemeGradientDefinition(id: "legacy-barbie", name: "Legacy Barbie", lightColors: ["#FFE6F7", "#E6F0FF"], darkColors: ["#1A0E16", "#24131F"]),
        ThemeGradientDefinition(id: "legacy-cheetah", name: "Legacy Cheetah", lightColors: ["#FFF7E6", "#FFF1D6"], darkColors: ["#15110B", "#20180F"]),
        ThemeGradientDefinition(id: "legacy-iridescent", name: "Legacy Iridescent", lightColors: ["#00D2FF", "#7B2FF7", "#FF4FD8"], darkColors: ["#0B1020", "#121A2F"]),
        ThemeGradientDefinition(id: "legacy-arctic", name: "Legacy Arctic", lightColors: ["#E6F4FF", "#F2FBFF"], darkColors: ["#0A121A", "#101A22"]),
        ThemeGradientDefinition(id: "legacy-ocean", name: "Legacy Ocean", lightColors: ["#E6F7FF", "#E6ECFF"], darkColors: ["#07131B", "#0E1B25"]),
        ThemeGradientDefinition(id: "legacy-forest", name: "Legacy Forest", lightColors: ["#ECFDF3", "#F7FFE8"], darkColors: ["#0B140F", "#0F1C15"]),
        ThemeGradientDefinition(id: "legacy-sunset", name: "Legacy Sunset", lightColors: ["#FFF1E6", "#FFE6EE"], darkColors: ["#170E0B", "#22140F"]),
        ThemeGradientDefinition(id: "legacy-lavender", name: "Legacy Lavender", lightColors: ["#F3E8FF", "#E0E7FF"], darkColors: ["#120D1A", "#121424"]),
        ThemeGradientDefinition(id: "legacy-graphite", name: "Legacy Graphite", lightColors: ["#F1F5F9", "#FFFFFF"], darkColors: ["#0E1116", "#151A22"]),
        ThemeGradientDefinition(id: "legacy-sand", name: "Legacy Sand", lightColors: ["#FFF7E6", "#FFFDF6"], darkColors: ["#14110B", "#201B12"]),
        ThemeGradientDefinition(id: "legacy-mint", name: "Legacy Mint", lightColors: ["#E8FFF8", "#F6FFFB"], darkColors: ["#08130F", "#0E1B16"]),
        ThemeGradientDefinition(id: "legacy-ember", name: "Legacy Ember", lightColors: ["#FFF1F2", "#FFF7ED"], darkColors: ["#160B0D", "#221114"]),
        ThemeGradientDefinition(id: "legacy-berry", name: "Legacy Berry", lightColors: ["#FFE6F7", "#F3E8FF"], darkColors: ["#160A12", "#22101C"]),
        ThemeGradientDefinition(id: "legacy-citrus", name: "Legacy Citrus", lightColors: ["#FFF9DB", "#E6FFFA"], darkColors: ["#14120A", "#1E1A10"]),
        ThemeGradientDefinition(id: "legacy-slate", name: "Legacy Slate", lightColors: ["#F1F5F9", "#FFFFFF"], darkColors: ["#0B1119", "#111A25"]),
        ThemeGradientDefinition(id: "legacy-mono", name: "Legacy Mono", lightColors: ["#F5F5F5", "#FFFFFF"], darkColors: ["#0B0B0B", "#151515"])
    ]

    static func gradient(id: String) -> ThemeGradientDefinition? {
        gradients.first { $0.id == id } ?? legacyGradients.first { $0.id == id }
    }

    static func pattern(id: String) -> ThemePatternDefinition? {
        patterns.first { $0.id == id }
    }

    static func designer(id: String) -> ThemeDesignerDefinition? {
        designers.first { $0.id == id }
    }

    static func definition(for selection: ThemeWallpaperSelection) -> WallpaperDefinition? {
        switch selection.kind {
        case .gradient:
            guard let gradient = gradient(id: selection.id) else { return nil }
            return WallpaperDefinition(
                id: gradient.id,
                name: gradient.name,
                type: .gradient,
                lightVariant: WallpaperVariant(
                    gradient: GradientVariant(
                        colors: gradient.lightColors,
                        configuration: GradientConfiguration(type: .linear)
                    ),
                    pattern: nil,
                    designer: nil,
                    imageName: nil
                ),
                darkVariant: WallpaperVariant(
                    gradient: GradientVariant(
                        colors: gradient.darkColors,
                        configuration: GradientConfiguration(type: .linear)
                    ),
                    pattern: nil,
                    designer: nil,
                    imageName: nil
                )
            )
        case .pattern:
            guard let pattern = pattern(id: selection.id) else { return nil }
            return WallpaperDefinition(
                id: pattern.id,
                name: pattern.name,
                type: .pattern,
                lightVariant: WallpaperVariant(
                    gradient: nil,
                    pattern: PatternVariant(
                        id: pattern.id,
                        backgroundHex: pattern.backgroundLightHex,
                        foregroundHex: pattern.foregroundLightHex
                    ),
                    designer: nil,
                    imageName: nil
                ),
                darkVariant: WallpaperVariant(
                    gradient: nil,
                    pattern: PatternVariant(
                        id: pattern.id,
                        backgroundHex: pattern.backgroundDarkHex,
                        foregroundHex: pattern.foregroundDarkHex
                    ),
                    designer: nil,
                    imageName: nil
                )
            )
        case .designer:
            guard let designer = designer(id: selection.id) else { return nil }
            return WallpaperDefinition(
                id: designer.id,
                name: designer.name,
                type: .designer,
                lightVariant: WallpaperVariant(
                    gradient: nil,
                    pattern: nil,
                    designer: PatternVariant(
                        id: designer.id,
                        backgroundHex: designer.backgroundLightHex,
                        foregroundHex: designer.foregroundLightHex
                    ),
                    imageName: nil
                ),
                darkVariant: WallpaperVariant(
                    gradient: nil,
                    pattern: nil,
                    designer: PatternVariant(
                        id: designer.id,
                        backgroundHex: designer.backgroundDarkHex,
                        foregroundHex: designer.foregroundDarkHex
                    ),
                    imageName: nil
                )
            )
        case .image:
            return nil
        }
    }

    static func fallbackDefinition(id: String) -> WallpaperDefinition {
        WallpaperDefinition(
            id: id,
            name: "Fallback",
            type: .gradient,
            lightVariant: WallpaperVariant(
                gradient: GradientVariant(
                    colors: ["#F3F4F6", "#FFFFFF"],
                    configuration: GradientConfiguration(type: .linear)
                ),
                pattern: nil,
                designer: nil,
                imageName: nil
            ),
            darkVariant: WallpaperVariant(
                gradient: GradientVariant(
                    colors: ["#0B0F1A", "#111827"],
                    configuration: GradientConfiguration(type: .linear)
                ),
                pattern: nil,
                designer: nil,
                imageName: nil
            )
        )
    }
}
