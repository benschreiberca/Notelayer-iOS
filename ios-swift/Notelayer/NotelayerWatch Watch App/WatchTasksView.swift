import SwiftUI

/// Main watch screen: today's open tasks with tap-to-complete, plus a quick-add
/// entry point. Data is owned by the paired iPhone via `WatchConnector`.
struct WatchTasksView: View {
    @EnvironmentObject private var connector: WatchConnector
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if connector.tasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(WatchPriorityStyle.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                WatchQuickAddView()
                    .environmentObject(connector)
            }
        }
        .onAppear { connector.refresh() }
    }

    private var taskList: some View {
        List {
            ForEach(connector.tasks) { task in
                Button {
                    withAnimation { connector.complete(task) }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "circle")
                            .foregroundStyle(WatchPriorityStyle.color(for: task.priority))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.body)
                                .lineLimit(2)
                            if let due = task.dueDate {
                                Text(due, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.largeTitle)
                .foregroundStyle(WatchPriorityStyle.accent)
            Text("All clear")
                .font(.headline)
            Text(connector.isReachable ? "No tasks for today" : "Open Notelayer on iPhone")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
