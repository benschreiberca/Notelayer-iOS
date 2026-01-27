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
                                Image(systemName: "bell.badge.slash.fill")
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
                            NagCardView(task: task, categoryLookup: categoryLookup)
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
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
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
    
    /// Category lookup for efficient rendering
    private var categoryLookup: [String: Category] {
        Dictionary(uniqueKeysWithValues: store.categories.map { ($0.id, $0) })
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

/// A card view for a nag that uses EXACT parity with TaskItemView
struct NagCardView: View {
    @EnvironmentObject private var theme: ThemeManager
    let task: Task
    let categoryLookup: [String: Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Main content row (matches TaskItemView exactly)
            HStack(alignment: .top, spacing: 12) {
                // Bell icon in the checkbox position
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 24))
                
                // Content (matches TaskItemView structure)
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .foregroundColor(theme.tokens.textPrimary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Secondary metadata: ONE line; horizontal scroll if needed (EXACT parity)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if let dueDate = task.dueDate {
                                Text(DateFormatters.cardDate.string(from: dueDate))
                                    .font(.caption)
                                    .foregroundStyle(theme.tokens.textSecondary)
                            }

                            TaskPriorityBadge(priority: task.priority)

                            // Use the lookup table (same as main list)
                            ForEach(task.categories, id: \.self) { id in
                                if let category = categoryLookup[id] {
                                    TaskCategoryChip(category: category)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            // Nag details inset (the colored card-within-a-card)
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
    }
    
    private func relativeDateText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
