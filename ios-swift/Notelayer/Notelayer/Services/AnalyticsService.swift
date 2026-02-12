import Foundation
import FirebaseAnalytics

// Centralized analytics wrapper to keep event names, parameters,
// and screenshot-mode suppression consistent across the app.
final class AnalyticsService {
    static let shared = AnalyticsService()

    private let isEnabled: Bool
    private let telemetryQueue = DispatchQueue(label: "com.notelayer.analytics.telemetry", qos: .utility)

    private init() {
        let env = ProcessInfo.processInfo.environment
        let args = ProcessInfo.processInfo.arguments
        let isScreenshotMode = env["SCREENSHOT_MODE"] == "true" || args.contains("--screenshot-generation")
        isEnabled = !isScreenshotMode
    }

    func logEvent(_ name: String, params: [String: Any] = [:]) {
        guard isEnabled else { return }

        let viewName = params["view_name"] as? String
        let tabName = params["tab_name"] as? String
        let categoryIds = categoryIdsFromParams(params)
        let taskId = (params["task_id"] as? String) ?? (params["taskId"] as? String)
        let feature = featureKey(for: name, viewName: viewName)
        let metadata = metadataStringMap(params)

        // Recording into InsightsTelemetryStore can trigger large decode/migration work
        // on first access; keep that off the main thread to protect launch responsiveness.
        telemetryQueue.async {
            Analytics.logEvent(name, parameters: params)
            InsightsTelemetryStore.shared.record(
                eventName: name,
                featureKey: feature,
                tabName: tabName,
                viewName: viewName,
                categoryIds: categoryIds,
                taskIdPolicyField: taskId,
                metadata: metadata
            )
        }
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

    private func metadataStringMap(_ params: [String: Any]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in params {
            if let stringValue = value as? String {
                result[key] = stringValue
            } else if let boolValue = value as? Bool {
                result[key] = boolValue ? "true" : "false"
            } else if let numberValue = value as? NSNumber {
                result[key] = numberValue.stringValue
            } else if let dateValue = value as? Date {
                result[key] = ISO8601DateFormatter().string(from: dateValue)
            }
        }
        return result
    }

    private func categoryIdsFromParams(_ params: [String: Any]) -> [String] {
        if let values = params["category_ids"] as? [String] {
            return values.filter { !$0.isEmpty }.sorted()
        }

        if let csv = params["category_ids_csv"] as? String {
            return csv
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .sorted()
        }

        if let categoryId = params["category_id"] as? String, !categoryId.isEmpty {
            return [categoryId]
        }

        return []
    }

    private func featureKey(for eventName: String, viewName: String?) -> String {
        switch eventName {
        case AnalyticsEventName.tabSelected:
            return InsightsFeatureKey.tabSelect
        case AnalyticsEventName.viewOpen:
            if viewName == AnalyticsViewName.notes {
                return InsightsFeatureKey.notesUsage
            }
            if viewName == AnalyticsViewName.profileSettings {
                return InsightsFeatureKey.profileSettingsOpen
            }
            return InsightsFeatureKey.viewOpen
        case AnalyticsEventName.viewDuration:
            return InsightsFeatureKey.viewDuration
        case AnalyticsEventName.todosFilterChanged:
            return InsightsFeatureKey.todosFilterChange
        case AnalyticsEventName.taskCreated:
            return InsightsFeatureKey.taskCreate
        case AnalyticsEventName.taskEdited:
            return InsightsFeatureKey.taskEdit
        case AnalyticsEventName.taskCompleted:
            return InsightsFeatureKey.taskComplete
        case AnalyticsEventName.taskRestored:
            return InsightsFeatureKey.taskRestore
        case AnalyticsEventName.taskDeleted:
            return InsightsFeatureKey.taskDelete
        case AnalyticsEventName.taskReordered:
            return InsightsFeatureKey.taskReorder
        case AnalyticsEventName.taskDueDateSet:
            return InsightsFeatureKey.dueDateSet
        case AnalyticsEventName.taskDueDateCleared:
            return InsightsFeatureKey.dueDateCleared
        case AnalyticsEventName.taskReminderSet:
            return InsightsFeatureKey.reminderSet
        case AnalyticsEventName.taskReminderCleared:
            return InsightsFeatureKey.reminderCleared
        case AnalyticsEventName.categoryCreated:
            return InsightsFeatureKey.categoryCreate
        case AnalyticsEventName.categoryRenamed:
            return InsightsFeatureKey.categoryRename
        case AnalyticsEventName.categoryReordered:
            return InsightsFeatureKey.categoryReorder
        case AnalyticsEventName.categoryDeleted:
            return InsightsFeatureKey.categoryDelete
        case AnalyticsEventName.categoryAssignedToTask:
            return InsightsFeatureKey.categoryAssign
        case AnalyticsEventName.reminderPermissionPrompted:
            return InsightsFeatureKey.reminderPermissionPrompted
        case AnalyticsEventName.reminderPermissionDenied:
            return InsightsFeatureKey.reminderPermissionDenied
        case AnalyticsEventName.reminderScheduled:
            return InsightsFeatureKey.reminderSet
        case AnalyticsEventName.reminderCleared:
            return InsightsFeatureKey.reminderCleared
        case AnalyticsEventName.calendarExportInitiated:
            return InsightsFeatureKey.calendarExportInitiated
        case AnalyticsEventName.calendarExportPermissionDenied:
            return InsightsFeatureKey.calendarExportPermissionDenied
        case AnalyticsEventName.calendarExportPresented:
            return InsightsFeatureKey.calendarExportPresented
        case AnalyticsEventName.themeChanged:
            return InsightsFeatureKey.themeChange
        case AnalyticsEventName.insightsDrilldownOpened:
            return InsightsFeatureKey.insightsDrilldownOpen
        default:
            return eventName
        }
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
    static let insightsDrilldownOpened = "insights_drilldown_opened"
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
    static let insightsOverview = "Insights / Overview"
    static let insightsTrendDetail = "Insights / Trend Detail"
    static let insightsCategoryDetail = "Insights / Category Detail"
    static let insightsUsageDetail = "Insights / Usage Detail"
    static let insightsGapDetail = "Insights / Gap Detail"
    static let insightsOldestOpenDetail = "Insights / Oldest Open Detail"
}

enum AnalyticsTabName {
    static let notes = "Notes"
    static let todos = "Todos"
    static let insights = "Insights"
}
