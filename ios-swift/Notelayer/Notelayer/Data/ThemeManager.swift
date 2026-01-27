import SwiftUI
import Combine
import UIKit

enum ThemePreset: String, CaseIterable, Codable, Identifiable {
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

    var id: String { rawValue }

    var title: String {
        switch self {
        case .barbie: return "Barbie"
        case .cheetah: return "Cheetah"
        case .iridescent: return "Iridescent"
        case .arctic: return "Arctic"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .sunset: return "Sunset"
        case .lavender: return "Lavender"
        case .graphite: return "Graphite"
        case .sand: return "Sand"
        case .mint: return "Mint"
        case .ember: return "Ember"
        case .berry: return "Berry"
        case .citrus: return "Citrus"
        case .slate: return "Slate"
        case .mono: return "Mono"
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var mode: ThemeMode = .system {
        didSet { save() }
    }
    @Published var preset: ThemePreset = .barbie {
        didSet { save() }
    }

    private let appGroupIdentifier = "group.com.notelayer.app"
    private let modeKey = "com.notelayer.app.theme.mode"
    private let presetKey = "com.notelayer.app.theme.preset"

    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }

    private init() {
        load()
    }

    func load() {
        if let modeString = userDefaults.string(forKey: modeKey),
           let m = ThemeMode(rawValue: modeString) {
            mode = m
        }
        if let presetString = userDefaults.string(forKey: presetKey),
           let p = ThemePreset(rawValue: presetString) {
            preset = p
        }
    }

    private func save() {
        userDefaults.set(mode.rawValue, forKey: modeKey)
        userDefaults.set(preset.rawValue, forKey: presetKey)
    }

    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var tokens: ThemeTokens {
        ThemeTokens(preset: preset)
    }
}

struct ThemeTokens: Equatable {
    let preset: ThemePreset

    var accent: Color {
        switch preset {
        case .barbie: return Color(hex: "#FF4FD8") ?? .pink
        case .cheetah: return Color(hex: "#FFB000") ?? .orange
        case .iridescent: return Color(hex: "#00D2FF") ?? .cyan
        case .arctic: return Color(hex: "#4DA3FF") ?? .blue
        case .ocean: return Color(hex: "#0077B6") ?? .blue
        case .forest: return Color(hex: "#2F855A") ?? .green
        case .sunset: return Color(hex: "#FB5607") ?? .orange
        case .lavender: return Color(hex: "#9B5DE5") ?? .purple
        case .graphite: return Color(hex: "#64748B") ?? .gray
        case .sand: return Color(hex: "#C2A875") ?? .brown
        case .mint: return Color(hex: "#20C997") ?? .mint
        case .ember: return Color(hex: "#E63946") ?? .red
        case .berry: return Color(hex: "#B5179E") ?? .purple
        case .citrus: return Color(hex: "#FFBE0B") ?? .yellow
        case .slate: return Color(hex: "#334155") ?? .gray
        case .mono: return Color(hex: "#111827") ?? .primary
        }
    }

    // Palette-driven surfaces & text (used throughout UI)
    var screenBackground: Color {
        dynamicColor(light: paletteLightBackgroundHex, dark: paletteDarkBackgroundHex)
    }

    // Explicit access for contrast checks
    var lightBackground: Color { Color(hex: paletteLightBackgroundHex) ?? .white }
    var darkBackground: Color { Color(hex: paletteDarkBackgroundHex) ?? .black }

    var textPrimary: Color {
        Color(.label)
    }

    var textSecondary: Color {
        Color(.secondaryLabel)
    }

    var cardFill: Color {
        // Requirement: cards and group areas share the same color.
        groupFill
    }

    var cardStroke: Color {
        Color(.separator).opacity(0.18)
    }

    var groupFill: Color {
        dynamicColor(light: paletteLightSurfaceHex, dark: paletteDarkSurfaceHex)
    }

    var groupPatternOpacity: Double {
        0 // Removed from cards/groups, moved to wallpaper
    }

    var badgeText: Color { textSecondary }

    // MARK: - Palette definitions
    private var paletteLightBackgroundHex: String {
        switch preset {
        case .barbie: return "#FFE9F6"
        case .cheetah: return "#FFF7E6"
        case .iridescent: return "#F4F8FF"
        case .arctic: return "#EEF7FF"
        case .ocean: return "#EAF6FF"
        case .forest: return "#F1FAF2"
        case .sunset: return "#FFF2EA"
        case .lavender: return "#F4EEFF"
        case .graphite: return "#F3F4F6"
        case .sand: return "#FFFDF6"
        case .mint: return "#ECFFF7"
        case .ember: return "#FFF1F2"
        case .berry: return "#FFEAF6"
        case .citrus: return "#FFF9DB"
        case .slate: return "#F1F5F9"
        case .mono: return "#F5F5F5"
        }
    }

    private var paletteDarkBackgroundHex: String {
        // Dark-mode companions (avoid light-mode whites).
        switch preset {
        case .barbie: return "#1A0E16"
        case .cheetah: return "#15110B"
        case .iridescent: return "#0B1020"
        case .arctic: return "#0A121A"
        case .ocean: return "#07131B"
        case .forest: return "#0B140F"
        case .sunset: return "#170E0B"
        case .lavender: return "#120D1A"
        case .graphite: return "#0E1116"
        case .sand: return "#14110B"
        case .mint: return "#08130F"
        case .ember: return "#160B0D"
        case .berry: return "#160A12"
        case .citrus: return "#14120A"
        case .slate: return "#0B1119"
        case .mono: return "#0B0B0B"
        }
    }

    private var paletteLightSurfaceHex: String {
        // Same color used for group containers AND todo cards (tinted in light mode).
        switch preset {
        case .barbie: return "#FFF6FB"
        case .cheetah: return "#FFF8EE"
        case .iridescent: return "#F7FAFF"
        case .arctic: return "#F5FBFF"
        case .ocean: return "#F2FAFF"
        case .forest: return "#F3FBF5"
        case .sunset: return "#FFF7F2"
        case .lavender: return "#F7F2FF"
        case .graphite: return "#FFFFFF"
        case .sand: return "#FFFFFF"
        case .mint: return "#F2FFFA"
        case .ember: return "#FFF6F7"
        case .berry: return "#FFF2FA"
        case .citrus: return "#FFFBEE"
        case .slate: return "#FFFFFF"
        case .mono: return "#FFFFFF"
        }
    }

    private var paletteDarkSurfaceHex: String {
        // Palette-specific dark surfaces (not the same across palettes).
        switch preset {
        case .barbie: return "#24131F"
        case .cheetah: return "#20180F"
        case .iridescent: return "#121A2F"
        case .arctic: return "#101A22"
        case .ocean: return "#0E1B25"
        case .forest: return "#0F1C15"
        case .sunset: return "#22140F"
        case .lavender: return "#121424"
        case .graphite: return "#151A22"
        case .sand: return "#201B12"
        case .mint: return "#0E1B16"
        case .ember: return "#221114"
        case .berry: return "#22101C"
        case .citrus: return "#1E1A10"
        case .slate: return "#111A25"
        case .mono: return "#151515"
        }
    }

    private func dynamicColor(light: String, dark: String) -> Color {
        Color(UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            return UIColor(hex: isDark ? dark : light) ?? UIColor.systemBackground
        })
    }
}

struct ThemeBackground: View {
    let preset: ThemePreset

    var body: some View {
        switch preset {
        case .barbie:
            LinearGradient(
                colors: [
                    Color(hex: "#FFE6F7") ?? Color.pink.opacity(0.12),
                    Color(hex: "#E6F0FF") ?? Color.blue.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

        case .cheetah:
            ZStack {
                // Background color (dynamic based on light/dark mode)
                Color(UIColor { traits in
                    let isDark = traits.userInterfaceStyle == .dark
                    return UIColor(hex: isDark ? "#15110B" : "#FFF7E6") ?? UIColor.systemBackground
                })
                .ignoresSafeArea()
                
                // Cheetah pattern overlay
                CheetahCardPattern()
                    .opacity(0.4)
                    .ignoresSafeArea()
            }

        case .iridescent:
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                LinearGradient(
                    colors: [
                        Color(hex: "#00D2FF") ?? .cyan,
                        Color(hex: "#7B2FF7") ?? .purple,
                        Color(hex: "#FF4FD8") ?? .pink,
                        Color(hex: "#00D2FF") ?? .cyan
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(0.14)
                .blur(radius: 18)
                .ignoresSafeArea()
            }
        case .arctic:
            LinearGradient(
                colors: [
                    Color(hex: "#E6F4FF") ?? Color.blue.opacity(0.08),
                    Color(hex: "#F2FBFF") ?? Color.cyan.opacity(0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

        case .ocean:
            LinearGradient(
                colors: [
                    Color(hex: "#E6F7FF") ?? Color.cyan.opacity(0.07),
                    Color(hex: "#E6ECFF") ?? Color.blue.opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

        case .forest:
            LinearGradient(
                colors: [
                    Color(hex: "#ECFDF3") ?? Color.green.opacity(0.06),
                    Color(hex: "#F7FFE8") ?? Color.mint.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

        case .sunset:
            LinearGradient(
                colors: [
                    Color(hex: "#FFF1E6") ?? Color.orange.opacity(0.06),
                    Color(hex: "#FFE6EE") ?? Color.pink.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

        case .lavender:
            LinearGradient(
                colors: [
                    Color(hex: "#F3E8FF") ?? Color.purple.opacity(0.06),
                    Color(hex: "#E0E7FF") ?? Color.indigo.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

        case .graphite:
            Color(.systemBackground)
                .ignoresSafeArea()

        case .sand:
            LinearGradient(
                colors: [
                    Color(hex: "#FFF7E6") ?? Color.yellow.opacity(0.05),
                    Color(hex: "#FFFDF6") ?? Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

        case .mint:
            LinearGradient(
                colors: [
                    Color(hex: "#E8FFF8") ?? Color.mint.opacity(0.06),
                    Color(hex: "#F6FFFB") ?? Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

        case .ember:
            LinearGradient(
                colors: [
                    Color(hex: "#FFF1F2") ?? Color.red.opacity(0.05),
                    Color(hex: "#FFF7ED") ?? Color.orange.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

        case .berry:
            LinearGradient(
                colors: [
                    Color(hex: "#FFE6F7") ?? Color.pink.opacity(0.06),
                    Color(hex: "#F3E8FF") ?? Color.purple.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

        case .citrus:
            LinearGradient(
                colors: [
                    Color(hex: "#FFF9DB") ?? Color.yellow.opacity(0.06),
                    Color(hex: "#E6FFFA") ?? Color.mint.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

        case .slate:
            LinearGradient(
                colors: [
                    Color(hex: "#F1F5F9") ?? Color.gray.opacity(0.06),
                    Color(hex: "#FFFFFF") ?? Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

        case .mono:
            Color(.systemBackground)
                .ignoresSafeArea()
        }
    }
}

private struct CheetahThemeBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { p in
                // Subtle cheetah-like blobs in a deterministic grid
                let step: CGFloat = 44
                var y: CGFloat = 0
                while y < h + step {
                    var x: CGFloat = 0
                    while x < w + step {
                        let dx = (sin((x + y) / 37) * 6)
                        let dy = (cos((x - y) / 41) * 6)
                        let center = CGPoint(x: x + step/2 + dx, y: y + step/2 + dy)
                        p.addEllipse(in: CGRect(x: center.x - 10, y: center.y - 6, width: 20, height: 12))
                        p.addEllipse(in: CGRect(x: center.x - 4, y: center.y - 2, width: 8, height: 4))
                        x += step
                    }
                    y += step
                }
            }
            .fill(Color.primary.opacity(0.10))
        }
    }
}

