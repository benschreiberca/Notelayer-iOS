import Foundation

/// Wire format shared between the iOS app and the watchOS companion.
///
/// This file must be a member of BOTH the `Notelayer` (iOS) target and the
/// `NotelayerWatch Watch App` target. It deliberately avoids depending on the
/// app's `Task`/`Priority` types so the watch target stays lightweight — the
/// phone is the source of truth and sends these DTOs over WatchConnectivity.

/// Message keys + payload keys used across the WatchConnectivity link.
public enum WatchMessage {
    /// Watch → phone: request the current task list. Reply: `{ tasks, categories }`.
    public static let fetchTasks = "fetchTasks"
    /// Watch → phone: add a task. Payload: `{ title }`. Reply: `{ ok }`.
    public static let addTask = "addTask"
    /// Watch → phone: complete a task. Payload: `{ id }`. Reply: `{ ok }`.
    public static let completeTask = "completeTask"

    /// Common payload keys.
    public static let action = "action"
    public static let title = "title"
    public static let id = "id"
    public static let tasks = "tasks"
    public static let categories = "categories"
    public static let ok = "ok"
}

/// A task as seen by the watch. Encoded to a `[String: Any]` dictionary for
/// WatchConnectivity (which only accepts plist types).
public struct WatchTaskDTO: Identifiable, Equatable {
    public let id: String
    public let title: String
    /// Raw priority value: "high" | "medium" | "low" | "deferred".
    public let priority: String
    public let dueDate: Date?
    public let isCompleted: Bool
    /// Category ids this task belongs to.
    public let categoryIds: [String]
    /// Optional free-text notes.
    public let notes: String?

    public init(
        id: String,
        title: String,
        priority: String,
        dueDate: Date?,
        isCompleted: Bool,
        categoryIds: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.categoryIds = categoryIds
        self.notes = notes
    }

    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "priority": priority,
            "isCompleted": isCompleted,
            "categoryIds": categoryIds,
        ]
        if let dueDate { dict["dueDate"] = dueDate.timeIntervalSince1970 }
        if let notes, !notes.isEmpty { dict["notes"] = notes }
        return dict
    }

    public init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
        self.priority = (dictionary["priority"] as? String) ?? "medium"
        self.isCompleted = (dictionary["isCompleted"] as? Bool) ?? false
        self.categoryIds = (dictionary["categoryIds"] as? [String]) ?? []
        self.notes = dictionary["notes"] as? String
        if let interval = dictionary["dueDate"] as? TimeInterval {
            self.dueDate = Date(timeIntervalSince1970: interval)
        } else {
            self.dueDate = nil
        }
    }
}

/// A category as seen by the watch — enough to label and color tasks.
public struct WatchCategoryDTO: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let icon: String
    /// Hex color string, e.g. "#6366F1".
    public let colorHex: String

    public init(id: String, name: String, icon: String, colorHex: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }

    public func toDictionary() -> [String: Any] {
        ["id": id, "name": name, "icon": icon, "colorHex": colorHex]
    }

    public init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String else { return nil }
        self.id = id
        self.name = name
        self.icon = (dictionary["icon"] as? String) ?? ""
        self.colorHex = (dictionary["colorHex"] as? String) ?? "#6366F1"
    }
}
