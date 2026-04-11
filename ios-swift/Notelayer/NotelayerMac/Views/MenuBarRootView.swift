import SwiftUI

struct MenuBarRootView: View {
    @EnvironmentObject var service: MacFirebaseService

    var body: some View {
        if service.isAuthenticated {
            MenuBarTaskListView()
        } else {
            MenuBarAuthView()
        }
    }
}
