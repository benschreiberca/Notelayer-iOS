import SwiftUI

struct TaskItemView: View {
    @EnvironmentObject private var theme: ThemeManager
    let task: Task
    let categoryLookup: [String: Category]
    let onToggleComplete: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        let taskTokens = theme.tokens.components.taskItem
        // Use a tap gesture for the row to avoid nested Button conflicts with the checkbox.
        // Restore v1.2 alignment and spacing to avoid compressed cards.
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.completedAt != nil ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.completedAt != nil ? .green : .gray)
                    .font(.system(size: 24))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("task-checkmark")
            
            // Content - takes available space, allowing text to extend close to bell
            VStack(alignment: .leading, spacing: 6) {
                // Title - removed .infinity frame to allow natural width
                Text(task.title)
                    .strikethrough(task.completedAt != nil)
                    .foregroundColor(task.completedAt != nil ? taskTokens.titleCompletedText : taskTokens.titleText)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                // Secondary metadata: ONE line; horizontal scroll if needed.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let dueDate = task.dueDate {
                            Text(DateFormatters.cardDate.string(from: dueDate))
                                .font(.caption)
                                .foregroundStyle(taskTokens.metaText)
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
            
            // Bell icon if reminder is set - aligned with section chevron
            if task.reminderDate != nil {
                Spacer(minLength: 0)
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
                .fill(taskTokens.background)
                .opacity(taskTokens.opacity)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(taskTokens.border, lineWidth: taskTokens.borderWidth)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private var priorityBadge: some View {
        Text(priorityText)
            .font(.caption)
            .foregroundStyle(theme.tokens.components.taskItem.metaText)
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
        let categoryColor = Color(hex: category.color) ?? theme.tokens.accent
        return Text("\(category.icon) \(category.name)")
            .font(.caption)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(categoryColor.opacity(0.18))
            .foregroundStyle(theme.tokens.textSecondary.opacity(0.95))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(categoryColor.opacity(0.3), lineWidth: 0.5)
            )
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
