import SwiftUI
import UserNotifications

/// Settings view for managing all task reminders
/// Shows list of pending reminders, permission status, and allows cancellation
struct RemindersSettingsView: View {
    @StateObject private var store = LocalStore.shared
    @EnvironmentObject private var theme: ThemeManager
    
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var taskToNag: Task? = nil
    
    var body: some View {
        NavigationStack {
            List {
                // Permission banner if notifications not authorized
                if notificationStatus != .authorized {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.bell.fill")
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
                            }
                            .buttonStyle(PrimaryButtonStyle())
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
                            NagCardView(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    taskToNag = task
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        cancelReminder(for: task)
                                    } label: {
                                        Label("Cancel", systemImage: "bell.slash")
                                    }
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                } header: {
                    if !tasksWithReminders.isEmpty {
                        Text("Upcoming Nags")
                    }
                }
            }
            .listStyle(.plain)
            .padding(.horizontal, 20)
            .background(theme.tokens.screenBackground)
            .navigationTitle("Pending Nags")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationStatus()
            }
            .sheet(item: $taskToNag) { task in
                ReminderPickerSheet(
                    task: task,
                    onSave: { date in
                        _Concurrency.Task {
                            await store.setReminder(for: task.id, at: date)
                        }
                    }
                )
                .presentationDetents([.medium])
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

/// A card view for a nag that matches the regular task card style
struct NagCardView: View {
    @EnvironmentObject private var theme: ThemeManager
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Bell icon in the checkbox position
                Image(systemName: "bell.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body.weight(.medium))
                        .foregroundColor(theme.tokens.textPrimary)
                        .lineLimit(2)
                    
                    if !task.categories.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(task.categories.prefix(3), id: \.self) { catId in
                                if let category = LocalStore.shared.getCategory(id: catId) {
                                    HStack(spacing: 4) {
                                        Text(category.icon)
                                            .font(.caption2)
                                        Text(category.name)
                                            .font(.caption2.weight(.medium))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: category.color)?.opacity(0.15) ?? theme.tokens.accent.opacity(0.1))
                                    .foregroundColor(Color(hex: category.color) ?? theme.tokens.accent)
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Priority indicator
                if task.priority != .none {
                    Text(task.priority.label)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.1))
                        .foregroundColor(priorityColor)
                        .cornerRadius(4)
                }
            }
            
            // Nag details row (matching the Details view style)
            if let nagDate = task.reminderDate {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text(nagDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption.weight(.medium))
                    
                    Text("•")
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(relativeDateText(for: nagDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(theme.tokens.cardFill)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.tokens.cardStroke, lineWidth: 1)
        )
        .padding(.vertical, 6)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        case .none: return .secondary
        }
    }
    
    private func relativeDateText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
