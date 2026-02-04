import SwiftUI
import UserNotifications

/// Settings view for managing all task reminders
/// Shows list of pending reminders, permission status, and allows cancellation
struct RemindersSettingsView: View {
    @StateObject private var store = LocalStore.shared
    @EnvironmentObject private var theme: ThemeManager
    
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var taskToNag: Task? = nil
    @State private var viewSession: AnalyticsViewSession? = nil
    @State private var reminderPickerSession: AnalyticsViewSession? = nil
    
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
                
                // List of reminders (iOS-standard Section with system dividers)
                Section("Upcoming Nags") {
                    if tasksWithReminders.isEmpty {
                        Text("No pending nags")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(sortedTasksWithReminders) { task in
                            Button {
                                taskToNag = task
                            } label: {
                                NagCardView(
                                    task: task,
                                    categoryLookup: categoryLookup
                                )
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    cancelReminder(for: task)
                                } label: {
                                    Label("Cancel", systemImage: "bell.slash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Pending Nags")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkNotificationStatus()
                viewSession = AnalyticsService.shared.trackViewOpen(
                    viewName: AnalyticsViewName.remindersSettings,
                    source: AnalyticsViewName.profileSettings
                )
            }
            .onDisappear {
                AnalyticsService.shared.trackViewDuration(viewSession)
                viewSession = nil
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
                .onAppear {
                    reminderPickerSession = AnalyticsService.shared.trackViewOpen(
                        viewName: AnalyticsViewName.reminderPicker,
                        source: AnalyticsViewName.remindersSettings
                    )
                }
                .onDisappear {
                    AnalyticsService.shared.trackViewDuration(reminderPickerSession)
                    reminderPickerSession = nil
                }
            }
        }
    }
    
    /// Category lookup for efficient rendering
    private var categoryLookup: [String: Category] {
        Dictionary(uniqueKeysWithValues: store.sortedCategories.map { ($0.id, $0) })
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

/// A simple row view for nags using iOS-standard List styling (no custom cards)
struct NagCardView: View {
    @EnvironmentObject private var theme: ThemeManager
    let task: Task
    let categoryLookup: [String: Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main content row (iOS List handles all card styling)
            HStack(alignment: .center, spacing: 12) {
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
                    
                    // Secondary metadata: ONE line; horizontal scroll if needed
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
            }
            
            // Nag details inset (indented to align with title text)
            if let nagDate = task.reminderDate {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text(nagDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                    
                    Text("•")
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(relativeDateText(for: nagDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.05))
                .cornerRadius(8)
                .padding(.leading, 36) // Indent to align with title (bell icon width 24 + spacing 12)
            }
        }
    }
    
    private func relativeDateText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
