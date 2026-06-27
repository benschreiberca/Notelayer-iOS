import Foundation

/// Wire format shared between the iOS app and the watchOS companion.
///
/// This file must be a member of BOTH the `Notelayer` (iOS) target and the
/// `NotelayerWatch Watch App` target. It deliberately avoids depending on the
/// app's `Task`/`Priority` types so the watch target stays lightweight — the
/// phone is the source of truth and sends these DTOs over WatchConnectivity.

/// Message keys + payload keys used across the WatchConnectivity link.
public enum WatchMessage {
    /// Watch → phone: request the current task list. Reply: `{ tasks: [[String: Any]] }`.
    public static let fetchTasks = "fetchTasks"
    /// Watch → phone: add a task. Payload: `{ title: String }`. Reply: `{ ok: Bool }`.
    public static let addTask = "addTask"
    /// Watch → phone: complete a task. Payload: `{ id: String }`. Reply: `{ ok: Bool }`.
    public static let completeTask = "completeTask"

    /// Common payload keys.
    public static let action = "action"
    public static let title = "title"
    public static let id = "id"
    public static let tasks = "tasks"
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

    public init(id: String, title: String, priority: String, dueDate: Date?, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }

    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "priority": priority,
            "isCompleted": isCompleted,
        ]
        if let dueDate { dict["dueDate"] = dueDate.timeIntervalSince1970 }
        return dict
    }

    public init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String else { return nil }
        self.id = id
        self.title = title
        self.priority = (dictionary["priority"] as? String) ?? "medium"
        self.isCompleted = (dictionary["isCompleted"] as? Bool) ?? false
        if let interval = dictionary["dueDate"] as? TimeInterval {
            self.dueDate = Date(timeIntervalSince1970: interval)
        } else {
            self.dueDate = nil
        }
    }
}
