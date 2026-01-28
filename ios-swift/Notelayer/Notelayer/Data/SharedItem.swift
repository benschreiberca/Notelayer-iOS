import Foundation

/// Represents an item shared from another app via the Share Extension
/// Stored in App Group UserDefaults and processed by the main app on launch
struct SharedItem: Codable, Identifiable {
    let id: String
    let title: String
    let url: String?         // Optional URL (e.g., "https://example.com")
    let text: String?        // Plain text content
    let sourceApp: String?   // Attribution (e.g., "Safari", "Chrome")
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        url: String? = nil,
        text: String? = nil,
        sourceApp: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.text = text
        self.sourceApp = sourceApp
        self.createdAt = createdAt
    }
}
