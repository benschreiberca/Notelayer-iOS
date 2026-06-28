import SwiftUI

struct WatchTasksView: View {
    @EnvironmentObject private var connector: WatchConnector
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if connector.tasks.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(connector.tasks) { task in
                            TaskRow(task: task)
                                .onTapGesture { connector.complete(task) }
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                WatchQuickAddView { title in
                    connector.addTask(title: title)
                    showingAdd = false
                }
            }
            .onAppear { connector.refresh() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(connector.isReachable ? "No open tasks" : "Open Notelayer on iPhone")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

private struct TaskRow: View {
    let task: WatchTaskDTO

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(WatchPriorityStyle.color(for: task.priority))
                .frame(width: 8, height: 8)
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
        .padding(.vertical, 2)
    }
}
