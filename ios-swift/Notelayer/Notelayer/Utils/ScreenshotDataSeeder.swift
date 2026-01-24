import Foundation

/// Seeds the app with quirky but relatable tasks for screenshot generation.
/// This only affects the isolated screenshot data store - user's production data is never touched.
struct ScreenshotDataSeeder {
    
    static func seedData() {
        let store = LocalStore.shared
        
        // Clear existing data in screenshot store
        store.applyRemoteSnapshot(notes: [], tasks: [], categories: [])
        
        // Initialize categories with defaults
        let categories = Category.defaultCategories
        store.applyRemoteCategories(categories)
        
        // Create quirky tasks based on SCREENSHOT_TASK_DATA.md
        let now = Date()
        let calendar = Calendar.current
        
        // Helper to create dates
        func date(daysFromNow: Int, hour: Int = 10, minute: Int = 0) -> Date? {
            calendar.date(byAdding: .day, value: daysFromNow, to: now)
                .flatMap { calendar.date(bySettingHour: hour, minute: minute, second: 0, of: $0) }
        }
        
        // High Priority Tasks
        let task1 = Task(
            id: "screenshot-task-1",
            title: "Pay credit card bill (the one I keep forgetting exists)",
            categories: ["finance"],
            priority: .high,
            dueDate: date(daysFromNow: 0, hour: 23, minute: 59), // Today
            completedAt: nil,
            taskNotes: "Due by end of day - $450 minimum payment",
            createdAt: date(daysFromNow: -2) ?? now,
            updatedAt: date(daysFromNow: -1) ?? now,
            orderIndex: Int((date(daysFromNow: -2) ?? now).timeIntervalSince1970 * 1000)
        )
        
        let task2 = Task(
            id: "screenshot-task-2",
            title: "Fix the door that makes that weird noise (but only sometimes)",
            categories: ["house"],
            priority: .high,
            dueDate: date(daysFromNow: 1), // Tomorrow
            completedAt: nil,
            taskNotes: "It's driving me crazy - need to buy WD-40",
            createdAt: date(daysFromNow: -3) ?? now,
            updatedAt: date(daysFromNow: -2) ?? now,
            orderIndex: Int((date(daysFromNow: -3) ?? now).timeIntervalSince1970 * 1000)
        )
        
        // Medium Priority Tasks
        let task3 = Task(
            id: "screenshot-task-3",
            title: "Buy groceries (and remember the reusable bags this time)",
            categories: ["shopping"],
            priority: .medium,
            dueDate: date(daysFromNow: 1), // Tomorrow
            completedAt: nil,
            taskNotes: nil,
            createdAt: date(daysFromNow: -1) ?? now,
            updatedAt: date(daysFromNow: -1) ?? now,
            orderIndex: Int((date(daysFromNow: -1) ?? now).timeIntervalSince1970 * 1000)
        )
        
        let task4 = Task(
            id: "screenshot-task-4",
            title: "Call mom (she knows I saw her text)",
            categories: ["travel"],
            priority: .medium,
            dueDate: date(daysFromNow: 3), // This week
            completedAt: nil,
            taskNotes: nil,
            createdAt: date(daysFromNow: -4) ?? now,
            updatedAt: date(daysFromNow: -3) ?? now,
            orderIndex: Int((date(daysFromNow: -4) ?? now).timeIntervalSince1970 * 1000)
        )
        
        let task5 = Task(
            id: "screenshot-task-5",
            title: "Actually read those terms and conditions I agreed to",
            categories: ["tech"],
            priority: .medium,
            dueDate: date(daysFromNow: 4), // This week
            completedAt: nil,
            taskNotes: "Probably should know what I signed up for",
            createdAt: date(daysFromNow: -5) ?? now,
            updatedAt: date(daysFromNow: -4) ?? now,
            orderIndex: Int((date(daysFromNow: -5) ?? now).timeIntervalSince1970 * 1000)
        )
        
        // Low Priority Tasks
        let task6 = Task(
            id: "screenshot-task-6",
            title: "Organize the drawer that eats single socks",
            categories: ["house"],
            priority: .low,
            dueDate: date(daysFromNow: 14), // Later
            completedAt: nil,
            taskNotes: nil,
            createdAt: date(daysFromNow: -6) ?? now,
            updatedAt: date(daysFromNow: -5) ?? now,
            orderIndex: Int((date(daysFromNow: -6) ?? now).timeIntervalSince1970 * 1000)
        )
        
        let task7 = Task(
            id: "screenshot-task-7",
            title: "Find where I put my 'important documents' folder",
            categories: ["shopping"],
            priority: .low,
            dueDate: nil, // No due date
            completedAt: nil,
            taskNotes: nil,
            createdAt: date(daysFromNow: -7) ?? now,
            updatedAt: date(daysFromNow: -6) ?? now,
            orderIndex: Int((date(daysFromNow: -7) ?? now).timeIntervalSince1970 * 1000)
        )
        
        // Deferred Priority Task
        let task8 = Task(
            id: "screenshot-task-8",
            title: "Review insurance policy (the one I've never read)",
            categories: ["finance"],
            priority: .deferred,
            dueDate: nil, // No due date
            completedAt: nil,
            taskNotes: "Someday I'll actually read this",
            createdAt: date(daysFromNow: -8) ?? now,
            updatedAt: date(daysFromNow: -7) ?? now,
            orderIndex: Int((date(daysFromNow: -8) ?? now).timeIntervalSince1970 * 1000)
        )
        
        // Apply all tasks
        let tasks = [task1, task2, task3, task4, task5, task6, task7, task8]
        store.applyRemoteTasks(tasks)
        
        #if DEBUG
        print("📸 [ScreenshotDataSeeder] Seeded \(tasks.count) quirky tasks for screenshots")
        #endif
    }
}
