import SwiftUI

/// The watch mirrors the iPhone's view modes (minus Insights). It's a viewer +
/// quick-add surface: tap a task to see detail, swipe to complete.
enum WatchViewMode: String, CaseIterable, Identifiable {
    case list = "List"
    case priority = "Priority"
    case category = "Category"
    case date = "Date"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .priority: return "flag"
        case .category: return "folder"
        case .date: return "calendar"
        }
    }
}

struct WatchTasksView: View {
    @EnvironmentObject private var connector: WatchConnector
    @State private var mode: WatchViewMode = .list
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
            .navigationTitle(mode.rawValue)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    viewModeMenu
                }
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

    // MARK: - View mode switcher

    private var viewModeMenu: some View {
        Menu {
            Picker("View", selection: $mode) {
                ForEach(WatchViewMode.allCases) { m in
                    Label(m.rawValue, systemImage: m.icon).tag(m)
                }
            }
        } label: {
            Image(systemName: mode.icon)
        }
    }

    // MARK: - Task list (grouped per view mode)

    private var taskList: some View {
        List {
            ForEach(groupedSections, id: \.title) { section in
                Section(section.title) {
                    ForEach(section.tasks) { task in
                        NavigationLink {
                            WatchTaskDetailView(task: task)
                        } label: {
                            TaskRow(task: task)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                connector.complete(task)
                            } label: {
                                Label("Done", systemImage: "checkmark")
                            }
                            .tint(.green)
                        }
                    }
                }
            }
        }
    }

    private struct TaskSection {
        let title: String
        let tasks: [WatchTaskDTO]
    }

    /// Build sections based on the selected view mode.
    private var groupedSections: [TaskSection] {
        let tasks = connector.tasks
        switch mode {
        case .list:
            return [TaskSection(title: "All Tasks", tasks: tasks)]

        case .priority:
            let order = ["high", "medium", "low", "deferred"]
            return order.compactMap { p in
                let group = tasks.filter { $0.priority == p }
                guard !group.isEmpty else { return nil }
                return TaskSection(title: WatchPriorityStyle.label(for: p), tasks: group)
            }

        case .category:
            var sections: [TaskSection] = []
            for cat in connector.categories {
                let group = tasks.filter { $0.categoryIds.contains(cat.id) }
                if !group.isEmpty {
                    sections.append(TaskSection(title: "\(cat.icon) \(cat.name)", tasks: group))
                }
            }
            let uncategorized = tasks.filter { $0.categoryIds.isEmpty }
            if !uncategorized.isEmpty {
                sections.append(TaskSection(title: "Uncategorized", tasks: uncategorized))
            }
            return sections

        case .date:
            let withDate = tasks.filter { $0.dueDate != nil }
                .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
            let noDate = tasks.filter { $0.dueDate == nil }
            var sections: [TaskSection] = []
            if !withDate.isEmpty { sections.append(TaskSection(title: "Scheduled", tasks: withDate)) }
            if !noDate.isEmpty { sections.append(TaskSection(title: "No Date", tasks: noDate)) }
            return sections
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

/// Compact row: priority dot, title, and a category/date subline.
private struct TaskRow: View {
    @EnvironmentObject private var connector: WatchConnector
    let task: WatchTaskDTO

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(WatchPriorityStyle.color(for: task.priority))
                .frame(width: 9, height: 9)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.body)
                    .lineLimit(2)
                if let subline {
                    Text(subline)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var subline: String? {
        var parts: [String] = []
        if let due = task.dueDate {
            parts.append(due.formatted(date: .abbreviated, time: .omitted))
        }
        let names = task.categoryIds.compactMap { connector.category(for: $0)?.name }
        if let first = names.first { parts.append(first) }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
