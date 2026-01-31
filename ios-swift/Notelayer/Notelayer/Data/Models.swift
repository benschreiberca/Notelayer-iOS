import Foundation

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
        reminderNotificationId: String? = nil
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
    }
}
