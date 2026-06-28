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
