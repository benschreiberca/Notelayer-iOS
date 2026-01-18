//
//  DateView.swift
//  Notelayer
//
//  Date grouped view
//

import SwiftUI

struct DateView: View {
    @EnvironmentObject var appStore: AppStore
    let tasks: [Task]
    let onEdit: (Task) -> Void
    let showInputs: Bool
    let selectionMode: Bool
    let selectedTaskIds: Set<String>
    let onToggleSelect: (String) -> Void
    
    enum DateBucket: String, CaseIterable {
        case overdue = "Overdue"
        case today = "Today"
        case tomorrow = "Tomorrow"
        case thisWeek = "This Week"
        case later = "Later"
        case noDueDate = "No Due Date"
    }

    /// Default due date to use when creating a task from within a specific bucket.
    /// IMPORTANT: We intentionally only return a value for buckets that have an inline input today,
    /// to avoid changing behavior in other buckets without explicit UX decisions.
    private func defaultDueDate(for bucket: DateBucket) -> Date? {
        let calendar = Calendar.current
        switch bucket {
        case .today:
            return calendar.startOfDay(for: Date())
        default:
            return nil
        }
    }
    
    private var grouped: [DateBucket: [Task]] {
        var groups: [DateBucket: [Task]] = [:]
        for bucket in DateBucket.allCases {
            groups[bucket] = []
        }
        
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        for task in tasks {
            guard let dueDate = task.dueDate else {
                groups[.noDueDate]?.append(task)
                continue
            }
            
            let dueDay = calendar.startOfDay(for: dueDate)
            let daysFromToday = calendar.dateComponents([.day], from: today, to: dueDay).day ?? 0
            
            if daysFromToday < 0 {
                groups[.overdue]?.append(task)
            } else if daysFromToday == 0 {
                groups[.today]?.append(task)
            } else if daysFromToday == 1 {
                groups[.tomorrow]?.append(task)
            } else if daysFromToday <= 7 {
                groups[.thisWeek]?.append(task)
            } else {
                groups[.later]?.append(task)
            }
        }
        
        for bucket in DateBucket.allCases {
            groups[bucket] = groups[bucket]?.sortedByPriorityThenDate() ?? []
        }
        
        return groups
    }
    
    var body: some View {
        List {
            ForEach(DateBucket.allCases, id: \.self) { bucket in
                Section {
                    if bucket == .today && showInputs {
                        TaskInput(defaultDueDate: defaultDueDate(for: bucket))
                            .environmentObject(appStore)
                    }
                    
                    if let groupTasks = grouped[bucket], !groupTasks.isEmpty {
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
                        Text("No tasks \(bucket.rawValue.lowercased())")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    }
                } header: {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(bucket.rawValue)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
