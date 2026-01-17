//
//  PriorityView.swift
//  Notelayer
//
//  Priority grouped view
//

import SwiftUI

struct PriorityView: View {
    @EnvironmentObject var appStore: AppStore
    let tasks: [Task]
    let onEdit: (Task) -> Void
    let showInputs: Bool
    let selectionMode: Bool
    let selectedTaskIds: Set<String>
    let onToggleSelect: (String) -> Void
    
    private var grouped: [Priority: [Task]] {
        var groups: [Priority: [Task]] = [.high: [], .medium: [], .low: [], .deferred: []]
        for task in tasks {
            groups[task.priority, default: []].append(task)
        }
        for priority in Priority.allCases {
            groups[priority] = groups[priority]?.sortedByDate() ?? []
        }
        return groups
    }
    
    var body: some View {
        List {
            ForEach(Priority.allCases, id: \.self) { priority in
                Section {
                    if showInputs {
                        TaskInput(defaultPriority: priority)
                            .environmentObject(appStore)
                    }
                    
                    if let groupTasks = grouped[priority], !groupTasks.isEmpty {
                        ForEach(groupTasks) { task in
                            TaskItem(
                                task: task,
                                onEdit: onEdit,
                                selectionMode: selectionMode,
                                selected: selectedTaskIds.contains(task.id),
                                onSelectToggle: onToggleSelect
                            )
                            .environmentObject(appStore)
                        }
                    } else {
                        Text("No \(priority.displayName.lowercased()) priority tasks")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    }
                } header: {
                    HStack {
                        Circle()
                            .fill(priorityColor(priority))
                            .frame(width: 8, height: 8)
                        Text(priority.displayName)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        case .deferred: return .gray
        }
    }
}
