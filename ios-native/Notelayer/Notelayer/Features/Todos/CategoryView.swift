//
//  CategoryView.swift
//  Notelayer
//
//  Category grouped view
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var appStore: AppStore
    let tasks: [Task]
    let onEdit: (Task) -> Void
    let showInputs: Bool
    let selectionMode: Bool
    let selectedTaskIds: Set<String>
    let onToggleSelect: (String) -> Void
    
    private var grouped: [CategoryId: [Task]] {
        var groups: [CategoryId: [Task]] = [:]
        for category in appStore.categories {
            groups[category.id] = []
        }
        for task in tasks {
            for categoryId in task.categories {
                groups[categoryId, default: []].append(task)
            }
        }
        for categoryId in appStore.categories.map({ $0.id }) {
            groups[categoryId] = groups[categoryId]?.sortedByPriorityThenDate() ?? []
        }
        return groups
    }
    
    var body: some View {
        List {
            ForEach(appStore.categories) { category in
                Section {
                    if showInputs {
                        // Regression guard: Category lens should NOT set a due date by default.
                        TaskInput(defaultCategories: [category.id], defaultDueDate: nil)
                            .environmentObject(appStore)
                    }
                    
                    if let groupTasks = grouped[category.id], !groupTasks.isEmpty {
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
                        Text("No \(category.name.lowercased()) tasks")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    }
                } header: {
                    HStack {
                        Text(category.icon)
                        Text(category.name)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
