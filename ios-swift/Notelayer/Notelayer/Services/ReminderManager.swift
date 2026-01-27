import Foundation
import UserNotifications

/// Manages task reminder notifications using UserNotifications framework
/// Handles permission requests, scheduling, and cancellation of local notifications
@MainActor
class ReminderManager {
    static let shared = ReminderManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission Management
    
    /// Request notification permission from the user
    /// - Returns: true if permission granted, false if denied
    func requestNotificationPermission() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("❌ [ReminderManager] Permission request failed: \(error)")
            return false
        }
    }
    
    /// Check current notification permission status
    var hasNotificationPermission: Bool {
        get async {
            let settings = await notificationCenter.notificationSettings()
            return settings.authorizationStatus == .authorized
        }
    }
    
    /// Get current notification authorization status
    var authorizationStatus: UNAuthorizationStatus {
        get async {
            let settings = await notificationCenter.notificationSettings()
            return settings.authorizationStatus
        }
    }
    
    // MARK: - Reminder Scheduling
    
    /// Schedule a reminder notification for a task
    /// - Parameters:
    ///   - task: The task to remind about
    ///   - date: When to fire the notification
    ///   - categories: Available categories for formatting notification body
    ///   - notificationId: Optional custom notification ID (defaults to new UUID)
    /// - Throws: ReminderError if scheduling fails
    func scheduleReminder(
        for task: Task,
        at date: Date,
        categories: [Category],
        notificationId: String = UUID().uuidString
    ) async throws {
        // Validate date is in the future
        guard date > Date() else {
            throw ReminderError.dateInPast
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = formatNotificationBody(task: task, categories: categories)
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": task.id]
        
        // Create trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create and add request
        let request = UNNotificationRequest(
            identifier: notificationId,
            content: content,
            trigger: trigger
        )
        
        do {
            try await notificationCenter.add(request)
            #if DEBUG
            print("✅ [ReminderManager] Scheduled reminder for '\(task.title)' at \(date)")
            #endif
        } catch {
            #if DEBUG
            print("❌ [ReminderManager] Failed to schedule reminder: \(error)")
            #endif
            throw ReminderError.schedulingFailed(error)
        }
    }
    
    /// Format the notification body with category information
    /// - Parameters:
    ///   - task: The task
    ///   - categories: Available categories
    /// - Returns: Formatted notification body text
    private func formatNotificationBody(task: Task, categories: [Category]) -> String {
        let taskCategories = categories.filter { task.categories.contains($0.id) }
        
        if taskCategories.isEmpty {
            return "Task reminder"
        }
        
        let categoryText = taskCategories
            .map { "\($0.icon) \($0.name)" }
            .joined(separator: ", ")
        
        return categoryText
    }
    
    // MARK: - Reminder Cancellation
    
    /// Cancel a reminder by notification ID
    /// - Parameter notificationId: The notification identifier to cancel
    func cancelReminder(notificationId: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
        #if DEBUG
        print("🔕 [ReminderManager] Cancelled reminder: \(notificationId)")
        #endif
    }
    
    /// Cancel a reminder for a specific task
    /// - Parameter task: The task whose reminder should be cancelled
    func cancelReminder(for task: Task) async {
        guard let notificationId = task.reminderNotificationId else {
            #if DEBUG
            print("⚠️ [ReminderManager] No notification ID for task '\(task.title)'")
            #endif
            return
        }
        
        await cancelReminder(notificationId: notificationId)
    }
    
    // MARK: - Pending Reminders
    
    /// Get all pending reminder notifications
    /// - Returns: Array of pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    /// Get count of pending reminders
    var pendingReminderCount: Int {
        get async {
            let requests = await getPendingNotifications()
            return requests.count
        }
    }
}

// MARK: - Error Types

enum ReminderError: LocalizedError {
    case dateInPast
    case schedulingFailed(Error)
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .dateInPast:
            return "Cannot set reminder for a time in the past"
        case .schedulingFailed(let error):
            return "Failed to schedule reminder: \(error.localizedDescription)"
        case .permissionDenied:
            return "Notification permission is required to set reminders"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dateInPast:
            return "Please choose a future date and time"
        case .schedulingFailed:
            return "Please try again or restart the app"
        case .permissionDenied:
            return "Grant notification permission in Settings to use reminders"
        }
    }
}
