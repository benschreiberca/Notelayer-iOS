import SwiftUI

@main
struct NotelayerApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environmentObject(ThemeManager.shared)
        }
    }
}
