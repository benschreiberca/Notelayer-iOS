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
    
    static let defaultCategories: [Category] = [
        Category(id: "house", name: "House & Repairs", icon: "🏠", color: CategoryColorDefaults.defaultHex(forCategoryId: "house")),
        Category(id: "garage", name: "Garage & Workshop", icon: "🔧", color: CategoryColorDefaults.defaultHex(forCategoryId: "garage")),
        Category(id: "printing", name: "3D Printing", icon: "🖨️", color: CategoryColorDefaults.defaultHex(forCategoryId: "printing")),
        Category(id: "vehicle", name: "Vehicle & Motorcycle", icon: "🏍️", color: CategoryColorDefaults.defaultHex(forCategoryId: "vehicle")),
        Category(id: "tech", name: "Tech & Apps", icon: "💻", color: CategoryColorDefaults.defaultHex(forCategoryId: "tech")),
        Category(id: "finance", name: "Finance & Admin", icon: "📊", color: CategoryColorDefaults.defaultHex(forCategoryId: "finance")),
        Category(id: "shopping", name: "Shopping & Errands", icon: "🛒", color: CategoryColorDefaults.defaultHex(forCategoryId: "shopping")),
        Category(id: "travel", name: "Travel & Health", icon: "✈️", color: CategoryColorDefaults.defaultHex(forCategoryId: "travel")),
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
        orderIndex: Int? = nil
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
    }
}
