import SwiftUI

struct WatchTasksView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Notelayer")
                    .font(.headline)
                Text("Connect your iPhone to sync tasks.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Tasks")
        }
    }
}
