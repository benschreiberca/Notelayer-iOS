import SwiftUI

struct WatchTaskListView: View {
    @EnvironmentObject var store: WatchStore
    @State private var showingAddTask = false

    var body: some View {
        Group {
            if store.tasks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.green)
                    Text("All done!")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    if !store.isPhoneReachable {
                        Text("Phone offline")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            } else {
                List {
                    ForEach(store.tasks) { task in
                        WatchTaskRowView(task: task)
                    }
                }
                .listStyle(.carousel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    store.requestRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            WatchQuickAddView()
        }
        .onAppear {
            store.requestRefresh()
        }
    }
}

struct WatchTaskRowView: View {
    @EnvironmentObject var store: WatchStore
    let task: WatchTask

    var body: some View {
        Button {
            store.completeTask(id: task.id)
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 6, height: 6)
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.footnote)
                        .lineLimit(3)
                    if let due = task.dueDate {
                        Text(RelativeDateTimeFormatter().localizedString(for: due, relativeTo: Date()))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
