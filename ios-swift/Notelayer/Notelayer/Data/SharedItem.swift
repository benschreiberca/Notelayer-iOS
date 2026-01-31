import Foundation

/// Helper to load categories from App Group for share extension
struct SharedItemHelpers {
    /// Load categories from App Group (for use in share extension)
    static func loadCategoriesFromAppGroup() -> [Category] {
        let appGroupId = "group.com.notelayer.app"
        guard let userDefaults = UserDefaults(suiteName: appGroupId),
              let data = userDefaults.data(forKey: "com.notelayer.app.categories"),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return []
        }
        return categories.sorted {
            if $0.order != $1.order {
                return $0.order < $1.order
            }
            return $0.id < $1.id
        }
    }
}

/// Represents an item shared from another app via the Share Extension
/// Stored in App Group UserDefaults and processed by the main app on launch
struct SharedItem: Codable, Identifiable {
    let id: String
    let title: String
    let url: String?         // Optional URL (e.g., "https://example.com")
    let text: String?        // Plain text content
    let sourceApp: String?   // Attribution (e.g., "Safari", "Chrome")
    let createdAt: Date
    
    // Task configuration fields
    let categories: [String]      // Category IDs selected in share sheet
    let priority: Priority        // Task priority (high, medium, low, deferred)
    let dueDate: Date?           // Optional due date
    let reminderDate: Date?      // Optional reminder date/time
    
    init(
        id: String = UUID().uuidString,
        title: String,
        url: String? = nil,
        text: String? = nil,
        sourceApp: String? = nil,
        createdAt: Date = Date(),
        categories: [String] = [],
        priority: Priority = .medium,
        dueDate: Date? = nil,
        reminderDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.text = text
        self.sourceApp = sourceApp
        self.createdAt = createdAt
        self.categories = categories
        self.priority = priority
        self.dueDate = dueDate
        self.reminderDate = reminderDate
    }
}
