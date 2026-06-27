import SwiftUI

@main
struct NotelayerWatchApp: App {
    @StateObject private var connector = WatchConnector.shared

    var body: some Scene {
        WindowGroup {
            WatchTasksView()
                .environmentObject(connector)
        }
    }
}

/// Priority colors mirrored from the iOS design tokens.
enum WatchPriorityStyle {
    static func color(for raw: String) -> Color {
        switch raw {
        case "high": return Color(red: 0.97, green: 0.44, blue: 0.44)   // red400
        case "medium": return Color(red: 0.96, green: 0.62, blue: 0.04) // amber
        case "low": return Color(red: 0.51, green: 0.55, blue: 0.97)    // indigo400
        default: return Color(red: 0.42, green: 0.45, blue: 0.50)        // gray500
        }
    }

    static let accent = Color(red: 0.39, green: 0.40, blue: 0.95) // indigo500
}
