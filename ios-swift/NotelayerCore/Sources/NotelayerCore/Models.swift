import Foundation

public enum AppDateBounds {
    public static let firestoreMinTimestampSeconds: TimeInterval = -62_135_596_800
    public static let firestoreMaxTimestampSeconds: TimeInterval = 253_402_300_799
    public static let metadataBaseline: Date = Date(timeIntervalSince1970: 0)

    public static func clampedForFirestore(_ date: Date) -> Date {
        let seconds = date.timeIntervalSince1970
        guard seconds.isFinite else { return metadataBaseline }
        let clamped = min(max(seconds, firestoreMinTimestampSeconds), firestoreMaxTimestampSeconds)
        return Date(timeIntervalSince1970: clamped)
    }
}

public enum Priority: String, Codable, CaseIterable, Identifiable, Sendable {
    case high, medium, low, deferred

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .deferred: return "Deferred"
        }
    }

    public var order: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .deferred: return 3
        }
    }
}

public struct Category: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var name: String
    public var icon: String
    public var color: String
    public var order: Int

    public init(id: String, name: String, icon: String, color: String, order: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.order = order
    }

    public static let defaultCategories: [Category] = [
        Category(id: "house",    name: "House & Repairs",      icon: "🏠", color: CategoryColorDefaults.defaultHex(forCategoryId: "house"),    order: 0),
        Category(id: "garage",   name: "Garage & Workshop",    icon: "🔧", color: CategoryColorDefaults.defaultHex(forCategoryId: "garage"),   order: 1),
        Category(id: "printing", name: "3D Printing",          icon: "🖨️", color: CategoryColorDefaults.defaultHex(forCategoryId: "printing"), order: 2),
        Category(id: "vehicle",  name: "Vehicle & Motorcycle", icon: "🏍️", color: CategoryColorDefaults.defaultHex(forCategoryId: "vehicle"),  order: 3),
        Category(id: "tech",     name: "Tech & Apps",          icon: "💻", color: CategoryColorDefaults.defaultHex(forCategoryId: "tech"),     order: 4),
        Category(id: "finance",  name: "Finance & Admin",      icon: "📊", color: CategoryColorDefaults.defaultHex(forCategoryId: "finance"),  order: 5),
        Category(id: "shopping", name: "Shopping & Errands",   icon: "🛒", color: CategoryColorDefaults.defaultHex(forCategoryId: "shopping"), order: 6),
        Category(id: "travel",   name: "Travel & Health",      icon: "✈️", color: CategoryColorDefaults.defaultHex(forCategoryId: "travel"),   order: 7),
    ]
}

public struct Task: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var categories: [String]
    public var priority: Priority
    public var dueDate: Date?
    public var completedAt: Date?
    public var taskNotes: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var orderIndex: Int?
    public var reminderDate: Date?
    public var reminderNotificationId: String?
    public var parentTaskId: String?
    public var parentManualReopenAt: Date?

    public var isComplete: Bool { completedAt != nil }

    public init(
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
