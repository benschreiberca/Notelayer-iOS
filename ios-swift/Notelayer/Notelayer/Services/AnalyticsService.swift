import Foundation
import FirebaseAnalytics

// Centralized analytics wrapper to keep event names, parameters,
// and screenshot-mode suppression consistent across the app.
final class AnalyticsService {
    static let shared = AnalyticsService()

    private let isEnabled: Bool

    private init() {
        let env = ProcessInfo.processInfo.environment
        let args = ProcessInfo.processInfo.arguments
        let isScreenshotMode = env["SCREENSHOT_MODE"] == "true" || args.contains("--screenshot-generation")
        isEnabled = !isScreenshotMode
    }

    func logEvent(_ name: String, params: [String: Any] = [:]) {
        guard isEnabled else { return }
        Analytics.logEvent(name, parameters: params)
    }

    func trackTabSelected(tabName: String, previousTab: String?) {
        var params: [String: Any] = ["tab_name": tabName]
        if let previousTab {
            params["previous_tab"] = previousTab
        }
        logEvent(AnalyticsEventName.tabSelected, params: params)
    }

    func trackViewOpen(viewName: String, tabName: String? = nil, source: String? = nil) -> AnalyticsViewSession {
        var params: [String: Any] = ["view_name": viewName]
        if let tabName {
            params["tab_name"] = tabName
        }
        if let source {
            params["source_view"] = source
        }
        logEvent(AnalyticsEventName.viewOpen, params: params)
        return AnalyticsViewSession(viewName: viewName, startedAt: Date())
    }

    func trackViewDuration(_ session: AnalyticsViewSession?) {
        guard let session else { return }
        let duration = Date().timeIntervalSince(session.startedAt)
        logEvent(AnalyticsEventName.viewDuration, params: [
            "view_name": session.viewName,
            "duration_s": max(0, Int(duration.rounded()))
        ])
    }
}

struct AnalyticsViewSession {
    let viewName: String
    let startedAt: Date
}

enum AnalyticsEventName {
    static let tabSelected = "tab_selected"
    static let viewOpen = "view_open"
    static let viewDuration = "view_duration"

    static let todosFilterChanged = "todos_filter_changed"

    static let taskCreated = "task_created"
    static let taskCompleted = "task_completed"
    static let taskRestored = "task_restored"
    static let taskDeleted = "task_deleted"
    static let taskEdited = "task_edited"
    static let taskReordered = "task_reordered"
    static let taskDueDateSet = "task_due_date_set"
    static let taskDueDateCleared = "task_due_date_cleared"
    static let taskReminderSet = "task_reminder_set"
    static let taskReminderCleared = "task_reminder_cleared"

    static let categoryCreated = "category_created"
    static let categoryRenamed = "category_renamed"
    static let categoryDeleted = "category_deleted"
    static let categoryReordered = "category_reordered"
    static let categoryAssignedToTask = "category_assigned_to_task"

    static let reminderPermissionDenied = "reminder_permission_denied"
    static let reminderPermissionPrompted = "reminder_permission_prompted"
    static let reminderScheduled = "reminder_scheduled"
    static let reminderCleared = "reminder_cleared"

    static let calendarExportInitiated = "calendar_export_initiated"
    static let calendarExportPermissionDenied = "calendar_export_permission_denied"
    static let calendarExportPresented = "calendar_export_presented"

    static let themeChanged = "theme_changed"
}

enum AnalyticsViewName {
    static let notes = "Notes"
    static let todosList = "Todos / List"
    static let todosPriority = "Todos / Priority"
    static let todosCategory = "Todos / Category"
    static let todosDate = "Todos / Date"
    static let taskEdit = "Task Edit"
    static let categoryManager = "Category Manager"
    static let appearance = "Appearance"
    static let profileSettings = "Profile & Settings"
    static let reminderPicker = "Reminder Picker"
    static let calendarExport = "Calendar Export"
    static let welcome = "Welcome"
    static let remindersSettings = "Reminders Settings"
}

enum AnalyticsTabName {
    static let notes = "Notes"
    static let todos = "Todos"
}
