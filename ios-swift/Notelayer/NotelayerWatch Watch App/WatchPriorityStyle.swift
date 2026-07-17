import SwiftUI

enum WatchPriorityStyle {
    static func color(for raw: String) -> Color {
        switch raw {
        case "high": return Color(red: 0.97, green: 0.44, blue: 0.44)
        case "medium": return Color(red: 0.96, green: 0.62, blue: 0.04)
        case "low": return Color(red: 0.51, green: 0.55, blue: 0.97)
        default: return Color(red: 0.42, green: 0.45, blue: 0.50)
        }
    }

    static func label(for raw: String) -> String {
        switch raw {
        case "high": return "High"
        case "medium": return "Medium"
        case "low": return "Low"
        default: return "Deferred"
        }
    }

    static let accent = Color(red: 0.39, green: 0.40, blue: 0.95)
}

extension Color {
    /// Initialize from a "#RRGGBB" (or "RRGGBB") hex string. Falls back to the
    /// Notelayer accent if the string can't be parsed.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&rgb), cleaned.count == 6 else {
            self = WatchPriorityStyle.accent
            return
        }
        self = Color(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
