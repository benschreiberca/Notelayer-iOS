import SwiftUI

@main
struct NotelayerMacApp: App {
    @StateObject private var service = MacFirebaseService.shared

    var body: some Scene {
        MenuBarExtra {
            MenuBarRootView()
                .environmentObject(service)
                .frame(width: 340)
        } label: {
            Label("Notelayer", systemImage: "checklist")
        }
        .menuBarExtraStyle(.window)
    }
}
