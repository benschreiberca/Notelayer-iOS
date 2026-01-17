//
//  Models.swift
//  Notelayer
//
//  Data models matching web app TypeScript interfaces
//

import Foundation

// MARK: - Category

typealias CategoryId = String

struct Category: Identifiable, Codable, Hashable {
    let id: CategoryId
    var name: String
    var icon: String
    var color: String
}

// MARK: - Priority

enum Priority: String, Codable, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    case deferred = "deferred"
    
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .deferred: return "Deferred"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .deferred: return 3
        }
    }
}

// MARK: - Attachment

struct Attachment: Identifiable, Codable, Hashable {
    let id: String
    let type: AttachmentType
    let name: String
    var url: String?
    var filePath: String?
    var metadata: [String: AnyCodable]?
    let createdAt: Date
}

enum AttachmentType: String, Codable {
    case file = "file"
    case link = "link"
    case image = "image"
    case document = "document"
}

// MARK: - Task

struct Task: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var categories: [CategoryId]
    var priority: Priority
    var dueDate: Date?
    var completedAt: Date?
    var parentTaskId: String?
    var attachments: [Attachment]
    var noteId: String?
    var noteLine: Int?
    var taskNotes: String?
    let createdAt: Date
    var updatedAt: Date
    var inputMethod: InputMethod
    var orderIndex: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, categories, priority, dueDate, completedAt
        case parentTaskId, attachments, noteId, noteLine, taskNotes
        case createdAt, updatedAt, inputMethod, orderIndex
    }
    
    var isCompleted: Bool {
        completedAt != nil
    }
}

enum InputMethod: String, Codable {
    case text = "text"
    case voice = "voice"
    case continuation = "continuation"
}

// MARK: - Note

struct Note: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var content: String  // HTML content
    var plainText: String
    var isPinned: Bool
    let createdAt: Date
    var updatedAt: Date
}

// MARK: - Helper: AnyCodable

struct AnyCodable: Codable, Hashable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }
    
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        String(describing: lhs.value) == String(describing: rhs.value)
    }
}
