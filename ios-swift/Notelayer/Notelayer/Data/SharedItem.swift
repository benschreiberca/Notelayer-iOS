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

enum SharedImportDestination: String, Codable {
    case task
    case note
    case taskBatch
}

enum SharedImportStatus: String, Codable {
    case pending
    case failed
}

struct SharedTaskDraft: Codable, Identifiable, Hashable {
    var id: String
    var title: String
    var notes: String?
    var isChecklistItem: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        notes: String? = nil,
        isChecklistItem: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isChecklistItem = isChecklistItem
    }
}

/// Represents an item shared from another app via the Share Extension
/// Stored in App Group UserDefaults and processed by the main app on launch
struct SharedItem: Codable, Identifiable {
    var id: String
    var title: String
    var url: String?         // Optional URL (e.g., "https://example.com")
    var text: String?        // Plain text content
    var sourceApp: String?   // Attribution (e.g., "Safari", "Chrome")
    var createdAt: Date

    // Task configuration fields
    var categories: [String]      // Category IDs selected in share sheet
    var priority: Priority        // Task priority (high, medium, low, deferred)
    var dueDate: Date?            // Optional due date
    var reminderDate: Date?       // Optional reminder date/time

    // Import metadata and mapping
    var destination: SharedImportDestination
    var taskDrafts: [SharedTaskDraft]
    var status: SharedImportStatus
    var lastError: String?
    var retryCount: Int
    var importTimestamp: Date
    var wasTruncated: Bool
    var preparationDurationMs: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case text
        case sourceApp
        case createdAt
        case categories
        case priority
        case dueDate
        case reminderDate
        case destination
        case taskDrafts
        case status
        case lastError
        case retryCount
        case importTimestamp
        case wasTruncated
        case preparationDurationMs
    }

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
        reminderDate: Date? = nil,
        destination: SharedImportDestination = .task,
        taskDrafts: [SharedTaskDraft] = [],
        status: SharedImportStatus = .pending,
        lastError: String? = nil,
        retryCount: Int = 0,
        importTimestamp: Date = Date(),
        wasTruncated: Bool = false,
        preparationDurationMs: Int? = nil
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
        self.destination = destination
        self.taskDrafts = taskDrafts
        self.status = status
        self.lastError = lastError
        self.retryCount = retryCount
        self.importTimestamp = importTimestamp
        self.wasTruncated = wasTruncated
        self.preparationDurationMs = preparationDurationMs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        url = try container.decodeIfPresent(String.self, forKey: .url)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        sourceApp = try container.decodeIfPresent(String.self, forKey: .sourceApp)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        categories = try container.decodeIfPresent([String].self, forKey: .categories) ?? []
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority) ?? .medium
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        destination = try container.decodeIfPresent(SharedImportDestination.self, forKey: .destination) ?? .task
        taskDrafts = try container.decodeIfPresent([SharedTaskDraft].self, forKey: .taskDrafts) ?? []
        status = try container.decodeIfPresent(SharedImportStatus.self, forKey: .status) ?? .pending
        lastError = try container.decodeIfPresent(String.self, forKey: .lastError)
        retryCount = try container.decodeIfPresent(Int.self, forKey: .retryCount) ?? 0
        importTimestamp = try container.decodeIfPresent(Date.self, forKey: .importTimestamp) ?? createdAt
        wasTruncated = try container.decodeIfPresent(Bool.self, forKey: .wasTruncated) ?? false
        preparationDurationMs = try container.decodeIfPresent(Int.self, forKey: .preparationDurationMs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(sourceApp, forKey: .sourceApp)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(categories, forKey: .categories)
        try container.encode(priority, forKey: .priority)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(reminderDate, forKey: .reminderDate)
        try container.encode(destination, forKey: .destination)
        try container.encode(taskDrafts, forKey: .taskDrafts)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(lastError, forKey: .lastError)
        try container.encode(retryCount, forKey: .retryCount)
        try container.encode(importTimestamp, forKey: .importTimestamp)
        try container.encode(wasTruncated, forKey: .wasTruncated)
        try container.encodeIfPresent(preparationDurationMs, forKey: .preparationDurationMs)
    }

    func markedPending() -> SharedItem {
        var copy = self
        copy.status = .pending
        copy.lastError = nil
        return copy
    }

    func markedFailed(reason: String) -> SharedItem {
        var copy = self
        copy.status = .failed
        copy.lastError = reason
        copy.retryCount += 1
        return copy
    }
}
