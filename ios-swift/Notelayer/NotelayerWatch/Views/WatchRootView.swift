import SwiftUI

struct WatchRootView: View {
    @EnvironmentObject var store: WatchStore

    var body: some View {
        NavigationStack {
            WatchTaskListView()
                .navigationTitle("Tasks")
        }
    }
}
