import Foundation

/// Reliability label used by Insights to avoid overstating precision.
enum InsightsDataFidelity: String, Codable {
    /// Computed from persisted telemetry events for the covered period.
    case eventExact = "Event-Exact"
    /// Inferred from current snapshot and may miss historical transitions.
    case snapshotEstimated = "Snapshot-Estimated"
    /// Combines event-exact and snapshot-estimated inputs.
    case mixed = "Mixed"
}

/// Supported rolling windows for historical charts and rankings.
enum InsightsWindow: Int, CaseIterable, Identifiable, Codable {
    case days7 = 7
    case days30 = 30
    case days60 = 60
    case days180 = 180
    case days365 = 365

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .days7:
            return "7D"
        case .days30:
            return "30D"
        case .days60:
            return "60D"
        case .days180:
            return "180D"
        case .days365:
            return "365D"
        }
    }
}

/// Canonical feature keys used for telemetry aggregation and gap analysis.
enum InsightsFeatureKey {
    static let taskCreate = "task_create"
    static let taskEdit = "task_edit"
    static let taskComplete = "task_complete"
    static let taskRestore = "task_restore"
    static let taskDelete = "task_delete"
    static let taskReorder = "task_reorder"

    static let dueDateSet = "due_date_set"
    static let dueDateCleared = "due_date_cleared"
    static let reminderSet = "reminder_set"
    static let reminderCleared = "reminder_cleared"
    static let reminderPermissionPrompted = "reminder_permission_prompted"
    static let reminderPermissionDenied = "reminder_permission_denied"

    static let calendarExportInitiated = "calendar_export_initiated"
    static let calendarExportPresented = "calendar_export_presented"
    static let calendarExportPermissionDenied = "calendar_export_permission_denied"

    static let categoryCreate = "category_create"
    static let categoryRename = "category_rename"
    static let categoryReorder = "category_reorder"
    static let categoryDelete = "category_delete"
    static let categoryAssign = "category_assign"

    static let tabSelect = "tab_select"
    static let viewOpen = "view_open"
    static let viewDuration = "view_duration"
    static let todosModeSwitch = "todos_mode_switch"
    static let todosFilterChange = "todos_filter_change"

    static let notesUsage = "notes_usage"
    static let themeChange = "theme_change"
    static let profileSettingsOpen = "profile_settings_open"
    static let insightsDrilldownOpen = "insights_drilldown_open"
}

/// Gap classification used by Insights feature-gap drilldown.
enum InsightsGapStatus: String, Codable, CaseIterable {
    case unused = "Unused"
    case underused = "Underused"
    case used = "Used"
}

/// Exposed copy for in-product disclosure of data coverage.
enum InsightsCoverageDisclosure {
    static let taskCoverage =
        "Task history uses all available local task records, including done tasks."
    static let appUsageCoverage =
        "App usage history starts when Insights telemetry is enabled on this device."
}

