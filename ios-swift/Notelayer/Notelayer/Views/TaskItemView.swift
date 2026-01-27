import SwiftUI

struct TaskItemView: View {
    @EnvironmentObject private var theme: ThemeManager
    let task: Task
    let categoryLookup: [String: Category]
    let onToggleComplete: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        // Use a tap gesture for the row to avoid nested Button conflicts with the checkbox.
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.completedAt != nil ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.completedAt != nil ? .green : .gray)
                    .font(.system(size: 24))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("task-checkmark")
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(task.title)
                    .strikethrough(task.completedAt != nil)
                    .foregroundColor(task.completedAt != nil ? theme.tokens.textSecondary : theme.tokens.textPrimary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Secondary metadata: ONE line; horizontal scroll if needed.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let dueDate = task.dueDate {
                            Text(DateFormatters.cardDate.string(from: dueDate))
                                .font(.caption)
                                .foregroundStyle(theme.tokens.textSecondary)
                        }

                        priorityBadge

                        // Use the lookup table to avoid per-row linear scans.
                        ForEach(task.categories, id: \.self) { id in
                            if let category = categoryLookup[id] {
                                categoryBadge(category)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Bell icon if reminder is set (far right)
            if task.reminderDate != nil {
                Image(systemName: hasNotificationPermission() ? "bell.fill" : "bell.slash.fill")
                    .font(.caption)
                    .foregroundColor(hasNotificationPermission() ? .orange : .gray)
                    .accessibilityLabel(hasNotificationPermission() ? "Reminder set" : "Reminder set but notifications disabled")
            }
        }
        .padding(.vertical, 1)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.tokens.groupFill)
        )
        .background {
            if theme.preset == .cheetah {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.clear)
                    .overlay(CheetahCardPattern().opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(theme.tokens.cardStroke, lineWidth: 0.5)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private var priorityBadge: some View {
        Text(priorityText)
            .font(.caption)
            .foregroundStyle(theme.tokens.textSecondary)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }

    private var priorityText: String {
        switch task.priority {
        case .high: return "High"
        case .medium: return "Med"
        case .low: return "Low"
        case .deferred: return "Def"
        }
    }

    private func categoryBadge(_ category: Category) -> some View {
        Text("\(category.icon) \(category.name)")
            .font(.caption)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background((Color(hex: category.color) ?? theme.tokens.accent).opacity(0.125))
            .foregroundStyle(theme.tokens.textSecondary.opacity(0.95))
            .clipShape(Capsule(style: .continuous))
    }
    
    /// Check if notification permission is granted (simple sync check)
    /// Note: This is a best-effort check; actual permission state is async
    private func hasNotificationPermission() -> Bool {
        // For UI purposes, show bell.slash if we detect permission issues
        // The actual async check happens in ReminderManager
        return task.reminderNotificationId != nil
    }
}
