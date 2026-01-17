//
//  TaskItem.swift
//  Notelayer
//
//  Individual task card component
//

import SwiftUI

struct TaskItem: View {
    let task: Task
    @EnvironmentObject var appStore: AppStore
    var showCompleted: Bool = false
    var onEdit: ((Task) -> Void)?
    var selectionMode: Bool = false
    var selected: Bool = false
    var onSelectToggle: ((String) -> Void)?
    
    private var isCompleted: Bool {
        task.completedAt != nil
    }
    
    private var hasMetaRow: Bool {
        !task.categories.isEmpty || task.dueDate != nil
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Selection or priority indicator
            if selectionMode {
                Button(action: {
                    onSelectToggle?(task.id)
                }) {
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selected ? .accentColor : .secondary)
                        .font(.system(size: 22))
                }
                .buttonStyle(.plain)
            } else {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 8)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Button(action: {
                    onEdit?(task)
                }) {
                    Text(task.title)
                        .font(.body)
                        .foregroundColor(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted)
                        .multilineTextAlignment(.leading)
                }
                .buttonStyle(.plain)
                
                // Meta row
                if hasMetaRow {
                    HStack(spacing: 8) {
                        // Categories
                        if !task.categories.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(task.categories.prefix(3), id: \.self) { categoryId in
                                    if let category = appStore.categories.first(where: { $0.id == categoryId }) {
                                        Text(category.icon)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
                        
                        // Due date
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11))
                                Text(formatDate(dueDate))
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Complete button
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    if isCompleted {
                        appStore.restoreTask(id: task.id)
                    } else {
                        appStore.completeTask(id: task.id)
                    }
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .accentColor : .secondary)
                    .font(.system(size: 24))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(selected && selectionMode ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        case .deferred: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
