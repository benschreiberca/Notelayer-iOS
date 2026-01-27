import SwiftUI
import UserNotifications

/// Settings view for managing all task reminders
/// Shows list of pending reminders, permission status, and allows cancellation
struct RemindersSettingsView: View {
    @StateObject private var store = LocalStore.shared
    @EnvironmentObject private var theme: ThemeManager
    
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var taskToOpen: Task? = nil
    
    var body: some View {
        NavigationStack {
            List {
                // Permission banner if notifications not authorized
                if notificationStatus != .authorized {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.badge.exclamationmark.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notifications Not Permitted")
                                        .font(.headline)
                                    Text("Nags are set but won't notify you")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Open Settings")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(theme.tokens.accent.opacity(0.15))
                                    .foregroundColor(theme.tokens.accent)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // List of reminders
                Section {
                    if tasksWithReminders.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No Active Nags")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Schedule some nags on your tasks to see them here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(sortedTasksWithReminders, id: \.id) { task in
                            ReminderRowView(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    taskToOpen = task
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        cancelReminder(for: task)
                                    } label: {
                                        Label("Cancel", systemImage: "bell.slash")
                                    }
                                }
                        }
                    }
                } header: {
                    if !tasksWithReminders.isEmpty {
                        Text("Upcoming Nags")
                    }
                }
            }
            .navigationTitle("Pending Nags")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationStatus()
            }
            .sheet(item: $taskToOpen) { task in
                TaskEditView(task: task, categories: store.categories)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    /// Get tasks that have reminders set
    private var tasksWithReminders: [Task] {
        store.tasks.filter { $0.reminderDate != nil }
    }
    
    /// Sort tasks by reminder date (soonest first)
    private var sortedTasksWithReminders: [Task] {
        tasksWithReminders.sorted { task1, task2 in
            guard let date1 = task1.reminderDate, let date2 = task2.reminderDate else {
                return false
            }
            return date1 < date2
        }
    }
    
    /// Check current notification permission status
    private func checkNotificationStatus() {
        _Concurrency.Task {
            let status = await ReminderManager.shared.authorizationStatus
            await MainActor.run {
                notificationStatus = status
            }
        }
    }
    
    /// Cancel a reminder for a task
    private func cancelReminder(for task: Task) {
        _Concurrency.Task {
            await store.removeReminder(for: task.id)
        }
    }
}

/// Row view for displaying a task with its reminder
private struct ReminderRowView: View {
    @EnvironmentObject private var theme: ThemeManager
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task title
            Text(task.title)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(theme.tokens.textPrimary)
            
            // Reminder date and time
            if let reminderDate = task.reminderDate {
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(absoluteDateText(for: reminderDate))
                            .font(.caption)
                            .foregroundColor(theme.tokens.textSecondary)
                        Text(relativeDateText(for: reminderDate))
                            .font(.caption2)
                            .foregroundColor(theme.tokens.textSecondary.opacity(0.7))
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    /// Format absolute date/time (e.g., "Jan 27, 3:00 PM")
    private func absoluteDateText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Format relative time (e.g., "In 2 hours")
    private func relativeDateText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
