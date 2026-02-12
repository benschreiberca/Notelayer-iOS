import Foundation

enum AppDateBounds {
    // Firestore Timestamp supports years 0001...9999.
    static let firestoreMinTimestampSeconds: TimeInterval = -62_135_596_800
    static let firestoreMaxTimestampSeconds: TimeInterval = 253_402_300_799
    static let metadataBaseline: Date = Date(timeIntervalSince1970: 0)

    static func clampedForFirestore(_ date: Date) -> Date {
        let seconds = date.timeIntervalSince1970
        guard seconds.isFinite else { return metadataBaseline }
        let clamped = min(max(seconds, firestoreMinTimestampSeconds), firestoreMaxTimestampSeconds)
        return Date(timeIntervalSince1970: clamped)
    }
}

enum Priority: String, Codable, CaseIterable, Identifiable {
    case high, medium, low, deferred
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .deferred: return "Deferred"
        }
    }
    
    var order: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .deferred: return 3
        }
    }
}

struct Category: Identifiable, Codable {
    let id: String
    var name: String
    var icon: String
    var color: String
    /// Lower values appear earlier in category ordering (0 is the top).
    var order: Int = 0
    
    static let defaultCategories: [Category] = [
        Category(id: "house", name: "House & Repairs", icon: "🏠", color: CategoryColorDefaults.defaultHex(forCategoryId: "house"), order: 0),
        Category(id: "garage", name: "Garage & Workshop", icon: "🔧", color: CategoryColorDefaults.defaultHex(forCategoryId: "garage"), order: 1),
        Category(id: "printing", name: "3D Printing", icon: "🖨️", color: CategoryColorDefaults.defaultHex(forCategoryId: "printing"), order: 2),
        Category(id: "vehicle", name: "Vehicle & Motorcycle", icon: "🏍️", color: CategoryColorDefaults.defaultHex(forCategoryId: "vehicle"), order: 3),
        Category(id: "tech", name: "Tech & Apps", icon: "💻", color: CategoryColorDefaults.defaultHex(forCategoryId: "tech"), order: 4),
        Category(id: "finance", name: "Finance & Admin", icon: "📊", color: CategoryColorDefaults.defaultHex(forCategoryId: "finance"), order: 5),
        Category(id: "shopping", name: "Shopping & Errands", icon: "🛒", color: CategoryColorDefaults.defaultHex(forCategoryId: "shopping"), order: 6),
        Category(id: "travel", name: "Travel & Health", icon: "✈️", color: CategoryColorDefaults.defaultHex(forCategoryId: "travel"), order: 7),
    ]
}

struct Task: Identifiable, Codable {
    let id: String
    var title: String
    var categories: [String]
    var priority: Priority
    var dueDate: Date?
    var completedAt: Date?
    var taskNotes: String?
    var createdAt: Date
    var updatedAt: Date
    var orderIndex: Int?
    
    // Reminder fields
    /// The date/time when the reminder notification should fire
    var reminderDate: Date?
    /// The notification identifier for cancellation (UNNotificationRequest.identifier)
    var reminderNotificationId: String?

    /// Hierarchy fields (v1: one level only, parent -> subtasks).
    var parentTaskId: String?
    /// Set when parent is manually reopened after all subtasks were complete.
    var parentManualReopenAt: Date?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        categories: [String] = [],
        priority: Priority = .medium,
        dueDate: Date? = nil,
        completedAt: Date? = nil,
        taskNotes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        orderIndex: Int? = nil,
        reminderDate: Date? = nil,
        reminderNotificationId: String? = nil,
        parentTaskId: String? = nil,
        parentManualReopenAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.categories = categories
        self.priority = priority
        self.dueDate = dueDate
        self.completedAt = completedAt
        self.taskNotes = taskNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.orderIndex = orderIndex ?? Int(createdAt.timeIntervalSince1970 * 1000)
        self.reminderDate = reminderDate
        self.reminderNotificationId = reminderNotificationId
        self.parentTaskId = parentTaskId
        self.parentManualReopenAt = parentManualReopenAt
    }
}

enum ExperimentalFeatureState: String, Codable {
    case off
    case on
    case pendingSyncReconcile
}

struct ExperimentalFeaturePreference: Codable, Equatable {
    var isEnabled: Bool
    var updatedAt: Date
    var state: ExperimentalFeatureState

    static let `default` = ExperimentalFeaturePreference(
        isEnabled: false,
        updatedAt: AppDateBounds.metadataBaseline,
        state: .off
    )
}

struct InsightsHintState: Codable, Equatable {
    var showCount: Int
    var dismissCount: Int
    var lastShownAt: Date?
    var lastDismissedAt: Date?
    var interactedAt: Date?
    var updatedAt: Date

    static let `default` = InsightsHintState(
        showCount: 0,
        dismissCount: 0,
        lastShownAt: nil,
        lastDismissedAt: nil,
        interactedAt: nil,
        updatedAt: AppDateBounds.metadataBaseline
    )

    func shouldShowHint(now: Date) -> Bool {
        if interactedAt != nil {
            return false
        }
        if showCount == 0 {
            return true
        }
        if showCount == 1,
           dismissCount >= 1,
           let lastDismissedAt,
           now.timeIntervalSince(lastDismissedAt) >= 24 * 60 * 60 {
            return true
        }
        return false
    }
}

struct VoiceParsedTaskDraft: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var notes: String
    var categories: [String]
    var priority: Priority
    var dueDate: Date?
    var confidenceScore: Double
    var needsReview: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        notes: String,
        categories: [String],
        priority: Priority,
        dueDate: Date?,
        confidenceScore: Double,
        needsReview: Bool
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.categories = categories
        self.priority = priority
        self.dueDate = dueDate
        self.confidenceScore = confidenceScore
        self.needsReview = needsReview
    }
}
