import Foundation
import SwiftUI
import Combine
import _Concurrency

struct Note: Identifiable, Codable {
    let id: UUID
    var text: String
    let createdAt: Date
    
    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}

class LocalStore: ObservableObject {
    static let shared = LocalStore()
    
    @Published var notes: [Note] = []
    @Published var tasks: [Task] = []
    @Published var categories: [Category] = []
    @Published private(set) var uncategorizedPosition: Int = 0

    private var backend: BackendSyncing?
    private var suppressBackendWrites = false
    
    private let notesKey = "com.notelayer.app.notes"
    private let tasksKey = "com.notelayer.app.tasks"
    private let categoriesKey = "com.notelayer.app.categories"
    private let uncategorizedPositionKey = "com.notelayer.app.todos.uncategorizedPosition"
    private let backendUserIdKey = "com.notelayer.app.backendUserId"
    
    // Use isolated data store for screenshot generation to protect user's real data
    private static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "true" ||
        ProcessInfo.processInfo.arguments.contains("--screenshot-generation")
    }
    
    private var appGroupIdentifier: String {
        Self.isScreenshotMode ? "group.com.notelayer.app.screenshots" : "group.com.notelayer.app"
    }
    
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }

    var lastBackendUserId: String? {
        userDefaults.string(forKey: backendUserIdKey)
    }
    
    private init() {
        load()
        migrateIfNeeded()
    }

    nonisolated static func categorySort(_ lhs: Category, _ rhs: Category) -> Bool {
        if lhs.order != rhs.order {
            return lhs.order < rhs.order
        }
        return lhs.id < rhs.id
    }

    var sortedCategories: [Category] {
        categories.sorted(by: Self.categorySort)
    }

    func attachBackend(_ backend: BackendSyncing?) {
        self.backend = backend
    }

    func updateBackendUserId(_ userId: String?) {
        userDefaults.set(userId, forKey: backendUserIdKey)
    }

    func resetForNewUser() {
        applyRemoteUpdate {
            notes = []
            tasks = []
            categories = []
            uncategorizedPosition = 0
            saveNotes()
            saveTasks()
            saveCategories()
            saveUncategorizedPosition()
            migrateIfNeeded()
        }
    }

    func applyRemoteSnapshot(notes: [Note], tasks: [Task], categories: [Category]) {
        applyRemoteUpdate {
            self.notes = notes
            self.tasks = tasks
            self.categories = categories
                .sorted(by: Self.categorySort)
            saveNotes()
            saveTasks()
            saveCategories()
            migrateIfNeeded()
        }
    }

    func applyRemoteNotes(_ notes: [Note]) {
        applyRemoteUpdate {
            self.notes = notes
            saveNotes()
        }
    }

    func applyRemoteTasks(_ tasks: [Task]) {
        applyRemoteUpdate {
            self.tasks = tasks
            saveTasks()
            
            // Reschedule reminders for synced tasks
            // Notifications don't sync across devices, only reminder data syncs
            rescheduleRemindersAfterSync(tasks)
        }
    }

    func applyRemoteUncategorizedPosition(_ position: Int) {
        applyRemoteUpdate {
            uncategorizedPosition = clampUncategorizedPosition(position, categoryCount: categories.count)
            saveUncategorizedPosition()
        }
    }
    
    /// Reschedule local notifications for tasks with reminder data from Firebase
    /// Notifications don't sync across devices automatically, only the reminder metadata syncs
    private func rescheduleRemindersAfterSync(_ tasks: [Task]) {
        _Concurrency.Task {
            for task in tasks {
                // Only reschedule if task has reminder data and date is in future
                guard let reminderDate = task.reminderDate,
                      let notificationId = task.reminderNotificationId,
                      reminderDate > Date(),
                      task.completedAt == nil else {
                    continue
                }
                
                // Reschedule the reminder on this device
                do {
                    try await ReminderManager.shared.scheduleReminder(
                        for: task,
                        at: reminderDate,
                        categories: categories,
                        notificationId: notificationId
                    )
                } catch {
                    #if DEBUG
                    print("⚠️ [LocalStore] Failed to reschedule reminder for '\(task.title)': \(error)")
                    #endif
                }
            }
        }
    }

    func applyRemoteCategories(_ categories: [Category]) {
        applyRemoteUpdate {
            self.categories = categories
                .sorted(by: Self.categorySort)
            saveCategories()
            migrateIfNeeded()
        }
    }

    private func applyRemoteUpdate(_ updates: () -> Void) {
        let wasSuppressed = suppressBackendWrites
        suppressBackendWrites = true
        updates()
        suppressBackendWrites = wasSuppressed
    }
    
    // MARK: - Load & Save
    
    func load() {
        if let notesData = userDefaults.data(forKey: notesKey),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: notesData) {
            notes = decodedNotes
        }
        
        if let tasksData = userDefaults.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            tasks = decodedTasks
        }
        
        if let categoriesData = userDefaults.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: categoriesData) {
            categories = decodedCategories
        }

        if let savedPosition = userDefaults.object(forKey: uncategorizedPositionKey) as? Int {
            uncategorizedPosition = savedPosition
        }
    }

    private func migrateIfNeeded() {
        // Categories: initialize defaults if empty
        if categories.isEmpty {
            categories = Category.defaultCategories
            saveCategories()
            return
        }

        // Categories: normalize color field to hex (supports older non-hex values)
        var changed = false
        for idx in categories.indices {
            let c = categories[idx]
            let normalized = CategoryColorDefaults.normalizeHexOrDefault(c.color, categoryId: c.id)
            if normalized != c.color {
                categories[idx].color = normalized
                changed = true
            }
        }
        // Categories: backfill ordering if missing (preserve current array order).
        if categories.count > 1, categories.allSatisfy({ $0.order == 0 }) {
            for idx in categories.indices {
                categories[idx].order = idx
            }
            changed = true
        }
        // Uncategorized: clamp to valid range after any ordering changes.
        let clampedPosition = clampUncategorizedPosition(uncategorizedPosition, categoryCount: categories.count)
        if clampedPosition != uncategorizedPosition {
            uncategorizedPosition = clampedPosition
            saveUncategorizedPosition()
        }
        if changed {
            saveCategories()
        }
    }
    
    private func saveNotes() {
        if let notesData = try? JSONEncoder().encode(notes) {
            userDefaults.set(notesData, forKey: notesKey)
        }
    }
    
    private func saveTasks() {
        if let tasksData = try? JSONEncoder().encode(tasks) {
            userDefaults.set(tasksData, forKey: tasksKey)
        }
    }

    /// Save categories to local storage and App Group (for share extension access)
    private func saveCategories() {
        if let categoriesData = try? JSONEncoder().encode(categories) {
            userDefaults.set(categoriesData, forKey: categoriesKey)
            // Categories are automatically synced to App Group since userDefaults
            // uses the App Group suite name (loadable via SharedItemHelpers)
        }
    }

    private func saveUncategorizedPosition() {
        userDefaults.set(uncategorizedPosition, forKey: uncategorizedPositionKey)
    }
    
    // MARK: - Notes
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(note: note) }
        }
    }
    
    func deleteNotes(at offsets: IndexSet) {
        let deletedNotes = offsets.map { notes[$0] }
        notes.remove(atOffsets: offsets)
        saveNotes()
        if let backend, !suppressBackendWrites {
            for note in deletedNotes {
                _Concurrency.Task { try? await backend.deleteNote(id: note.id) }
            }
        }
    }
    
    // MARK: - Tasks
    
    func addTask(_ task: Task) -> String {
        var newTask = task
        if newTask.orderIndex == nil {
            newTask.orderIndex = Int(Date().timeIntervalSince1970 * 1000)
        }
        tasks.append(newTask)
        saveTasks()
        // Analytics: log task creation without PII.
        AnalyticsService.shared.logEvent(AnalyticsEventName.taskCreated, params: [
            "priority": newTask.priority.rawValue,
            "category_count": newTask.categories.count,
            "has_due_date": newTask.dueDate != nil,
            "has_reminder": newTask.reminderDate != nil,
            "category_ids_csv": newTask.categories.joined(separator: ",")
        ])
        if !newTask.categories.isEmpty {
            // Analytics: separate signal for category assignment on create.
            AnalyticsService.shared.logEvent(AnalyticsEventName.categoryAssignedToTask, params: [
                "category_count": newTask.categories.count,
                "source_view": "Task Create"
            ])
        }
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: newTask) }
        }
        return newTask.id
    }
    
    func updateTask(id: String, updates: (inout Task) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        let oldTask = tasks[index]
        var task = oldTask
        updates(&task)
        task.updatedAt = Date()
        tasks[index] = task
        saveTasks()
        // Analytics: capture edit intent and specific field changes.
        let titleChanged = oldTask.title != task.title
        let categoriesChanged = oldTask.categories != task.categories
        let priorityChanged = oldTask.priority != task.priority
        let dueDateChanged = oldTask.dueDate != task.dueDate
        let notesChanged = oldTask.taskNotes != task.taskNotes
        if titleChanged || categoriesChanged || priorityChanged || dueDateChanged || notesChanged {
            AnalyticsService.shared.logEvent(AnalyticsEventName.taskEdited, params: [
                "title_changed": titleChanged,
                "categories_changed": categoriesChanged,
                "priority_changed": priorityChanged,
                "due_date_changed": dueDateChanged,
                "notes_changed": notesChanged
            ])
        }
        if oldTask.dueDate == nil && task.dueDate != nil {
            // Analytics: due date added.
            AnalyticsService.shared.logEvent(AnalyticsEventName.taskDueDateSet, params: [
                "category_count": task.categories.count,
                "priority": task.priority.rawValue
            ])
        } else if oldTask.dueDate != nil && task.dueDate == nil {
            // Analytics: due date cleared.
            AnalyticsService.shared.logEvent(AnalyticsEventName.taskDueDateCleared, params: [
                "category_count": task.categories.count,
                "priority": task.priority.rawValue
            ])
        }
        if categoriesChanged {
            let addedCount = Set(task.categories).subtracting(oldTask.categories).count
            let removedCount = Set(oldTask.categories).subtracting(task.categories).count
            if addedCount > 0 || removedCount > 0 {
                // Analytics: category assignment changes.
                AnalyticsService.shared.logEvent(AnalyticsEventName.categoryAssignedToTask, params: [
                    "added_count": addedCount,
                    "removed_count": removedCount,
                    "source_view": "Task Edit"
                ])
            }
        }
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: task) }
        }
    }
    
    func deleteTask(id: String) {
        // Capture reminder info before deletion
        let taskToDelete = tasks.first(where: { $0.id == id })
        let notificationId = taskToDelete?.reminderNotificationId
        
        // Remove task
        tasks.removeAll { $0.id == id }
        saveTasks()
        if let taskToDelete {
            AnalyticsService.shared.logEvent(AnalyticsEventName.taskDeleted, params: [
                "has_due_date": taskToDelete.dueDate != nil,
                "has_reminder": taskToDelete.reminderDate != nil,
                "category_count": taskToDelete.categories.count
            ])
        }
        
        // Cancel reminder if task had one
        if let notificationId {
            _Concurrency.Task {
                await ReminderManager.shared.cancelReminder(notificationId: notificationId)
            }
        }
        
        // Sync deletion to backend
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.deleteTask(id: id) }
        }
    }

    func deleteTask(id: String, undoManager: UndoManager?) {
        guard let task = tasks.first(where: { $0.id == id }) else { return }
        deleteTask(id: id)
        registerUndoForTaskDeletion(task, undoManager: undoManager)
    }

    private func registerUndoForTaskDeletion(_ task: Task, undoManager: UndoManager?) {
        // Restore the task and register a redo that deletes it again.
        undoManager?.registerUndo(withTarget: self) { store in
            _ = store.addTask(task)
            store.registerRedoForTaskDeletion(task, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete Task")
    }

    private func registerRedoForTaskDeletion(_ task: Task, undoManager: UndoManager?) {
        undoManager?.registerUndo(withTarget: self) { store in
            store.deleteTask(id: task.id)
            store.registerUndoForTaskDeletion(task, undoManager: undoManager)
        }
        undoManager?.setActionName("Delete Task")
    }
    
    func completeTask(id: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        let oldTask = tasks[index]
        var task = oldTask
        
        // Capture reminder info before mutation
        let notificationId = task.reminderNotificationId
        
        // Update task state
        task.completedAt = Date()
        task.reminderDate = nil
        task.reminderNotificationId = nil
        
        tasks[index] = task
        saveTasks()
        // Analytics: completion includes time-to-complete from creation.
        let completionLatency = Date().timeIntervalSince(oldTask.createdAt)
        AnalyticsService.shared.logEvent(AnalyticsEventName.taskCompleted, params: [
            "completion_latency_s": max(0, Int(completionLatency.rounded())),
            "category_count": oldTask.categories.count,
            "priority": oldTask.priority.rawValue,
            "had_due_date": oldTask.dueDate != nil,
            "had_reminder": oldTask.reminderDate != nil,
            "category_ids_csv": oldTask.categories.joined(separator: ",")
        ])
        
        // Cancel reminder asynchronously if it existed
        if let notificationId {
            _Concurrency.Task {
                await ReminderManager.shared.cancelReminder(notificationId: notificationId)
            }
        }
        
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: task) }
        }
    }
    
    func restoreTask(id: String) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        let oldTask = tasks[index]
        var task = oldTask
        
        // Capture reminder info before mutation
        let reminderDate = task.reminderDate
        let notificationId = task.reminderNotificationId
        let currentCategories = categories
        
        // Update completion state
        task.completedAt = nil
        
        // Handle reminder restoration
        if let reminderDate, let notificationId {
            if reminderDate > Date() {
                // Reminder is in the future, reschedule it
                _Concurrency.Task {
                    do {
                        try await ReminderManager.shared.scheduleReminder(
                            for: task,
                            at: reminderDate,
                            categories: currentCategories,
                            notificationId: notificationId
                        )
                    } catch {
                        print("⚠️ [LocalStore] Failed to restore reminder: \(error)")
                    }
                }
            } else {
                // Reminder is in the past, clear it
                task.reminderDate = nil
                task.reminderNotificationId = nil
            }
        }
        
        tasks[index] = task
        saveTasks()
        AnalyticsService.shared.logEvent(AnalyticsEventName.taskRestored, params: [
            "category_count": oldTask.categories.count,
            "priority": oldTask.priority.rawValue,
            "category_ids_csv": oldTask.categories.joined(separator: ",")
        ])
        
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: task) }
        }
    }
    
    // MARK: - Reminders
    
    /// Set a reminder for a task
    /// - Parameters:
    ///   - taskId: The task ID
    ///   - date: When to fire the reminder
    func setReminder(for taskId: String, at date: Date) async {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        var task = tasks[index]
        
        // Cancel existing reminder if any
        if let existingId = task.reminderNotificationId {
            await ReminderManager.shared.cancelReminder(notificationId: existingId)
        }
        
        // Schedule new reminder
        do {
            let notificationId = UUID().uuidString
            try await ReminderManager.shared.scheduleReminder(
                for: task,
                at: date,
                categories: categories,
                notificationId: notificationId
            )
            
            // Update task with reminder info
            task.reminderDate = date
            task.reminderNotificationId = notificationId
            task.updatedAt = Date()
            
            tasks[index] = task
            saveTasks()
            // Analytics: reminder set with lead time in minutes.
            let leadMinutes = max(0, Int(date.timeIntervalSinceNow / 60))
            AnalyticsService.shared.logEvent(AnalyticsEventName.taskReminderSet, params: [
                "lead_time_minutes": leadMinutes,
                "has_due_date": task.dueDate != nil,
                "category_count": task.categories.count,
                "category_ids_csv": task.categories.joined(separator: ",")
            ])
            AnalyticsService.shared.logEvent(AnalyticsEventName.reminderScheduled, params: [
                "lead_time_minutes": leadMinutes,
                "category_ids_csv": task.categories.joined(separator: ",")
            ])
            
            // Sync to backend
            if let backend, !suppressBackendWrites {
                _Concurrency.Task { try? await backend.upsert(task: task) }
            }
        } catch {
            print("❌ [LocalStore] Failed to set reminder: \(error)")
        }
    }
    
    /// Remove a reminder from a task
    /// - Parameter taskId: The task ID
    func removeReminder(for taskId: String) async {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        var task = tasks[index]
        
        // Cancel the notification
        if let notificationId = task.reminderNotificationId {
            await ReminderManager.shared.cancelReminder(notificationId: notificationId)
        }
        
        // Clear reminder data
        task.reminderDate = nil
        task.reminderNotificationId = nil
        task.updatedAt = Date()
        
        tasks[index] = task
        saveTasks()
        AnalyticsService.shared.logEvent(AnalyticsEventName.taskReminderCleared, params: [
            "category_count": task.categories.count,
            "has_due_date": task.dueDate != nil,
            "category_ids_csv": task.categories.joined(separator: ",")
        ])
        AnalyticsService.shared.logEvent(AnalyticsEventName.reminderCleared, params: [
            "category_ids_csv": task.categories.joined(separator: ",")
        ])
        
        // Sync to backend
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: task) }
        }
    }
    
    func reorderTasks(orderedIds: [String]) {
        let taskMap = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        let reordered = orderedIds.compactMap { taskMap[$0] }
        let remaining = tasks.filter { !orderedIds.contains($0.id) }
        
        let nowBase = Int(Date().timeIntervalSince1970 * 1000)
        let reorderedWithOrder = reordered.enumerated().map { index, task in
            var updated = task
            updated.orderIndex = nowBase - index
            updated.updatedAt = Date()
            return updated
        }
        
        tasks = reorderedWithOrder + remaining
        saveTasks()
        AnalyticsService.shared.logEvent(AnalyticsEventName.taskReordered, params: [
            "task_count": tasks.count
        ])
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(tasks: tasks) }
        }
    }
    
    // MARK: - Categories
    
    func addCategory(_ category: Category) {
        // Insert new categories at the top and shift others down to preserve order.
        for idx in categories.indices {
            categories[idx].order += 1
        }
        var newCategory = category
        newCategory.order = 0
        categories.append(newCategory)
        categories.sort(by: Self.categorySort)
        setUncategorizedPosition(uncategorizedPosition + 1)
        saveCategories()
        AnalyticsService.shared.logEvent(AnalyticsEventName.categoryCreated, params: [
            "category_count": categories.count
        ])
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(categories: categories) }
        }
    }
    
    func updateCategory(id: String, updates: (inout Category) -> Void) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
        let oldCategory = categories[index]
        var category = oldCategory
        updates(&category)
        categories[index] = category
        categories.sort(by: Self.categorySort)
        saveCategories()
        let nameChanged = oldCategory.name != category.name
        let iconChanged = oldCategory.icon != category.icon
        let colorChanged = oldCategory.color != category.color
        if nameChanged || iconChanged || colorChanged {
            AnalyticsService.shared.logEvent(AnalyticsEventName.categoryRenamed, params: [
                "name_changed": nameChanged,
                "icon_changed": iconChanged,
                "color_changed": colorChanged
            ])
        }
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(category: category) }
        }
    }
    
    func reorderCategories(orderedIds: [String]) {
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        var reordered: [Category] = []
        reordered.reserveCapacity(orderedIds.count)
        for (index, id) in orderedIds.enumerated() {
            guard var category = categoryMap[id] else { continue }
            category.order = index
            reordered.append(category)
        }
        // Preserve any categories not present in the ordered list.
        let remaining = categories
            .filter { !orderedIds.contains($0.id) }
            .enumerated()
            .map { offset, category in
                var updated = category
                updated.order = reordered.count + offset
                return updated
            }
        categories = (reordered + remaining).sorted(by: Self.categorySort)
        saveCategories()
        AnalyticsService.shared.logEvent(AnalyticsEventName.categoryReordered, params: [
            "category_count": categories.count
        ])
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(categories: categories) }
        }
    }

    func setUncategorizedPosition(_ position: Int) {
        let clamped = clampUncategorizedPosition(position, categoryCount: categories.count)
        uncategorizedPosition = clamped
        saveUncategorizedPosition()
    }

    func deleteCategory(id: String, reassignTo replacementId: String? = nil) {
        let resolvedReplacementId: String? = {
            guard let replacementId, replacementId != id else { return nil }
            return categories.contains(where: { $0.id == replacementId }) ? replacementId : nil
        }()
        let removedIndex = sortedCategories.firstIndex { $0.id == id }
        let updatedTasks = updateTasksForCategoryRemoval(categoryId: id, replacementId: resolvedReplacementId)
        categories.removeAll { $0.id == id }
        normalizeCategoryOrder()
        if let removedIndex, removedIndex < uncategorizedPosition {
            setUncategorizedPosition(uncategorizedPosition - 1)
        } else {
            setUncategorizedPosition(uncategorizedPosition)
        }
        saveCategories()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task {
                try? await backend.deleteCategory(id: id)
                if !updatedTasks.isEmpty {
                    try? await backend.upsert(tasks: updatedTasks)
                }
            }
        }
        AnalyticsService.shared.logEvent(AnalyticsEventName.categoryDeleted, params: [
            "reassigned_task_count": updatedTasks.count,
            "category_count": categories.count
        ])
    }

    private func updateTasksForCategoryRemoval(categoryId: String, replacementId: String?) -> [Task] {
        var updatedTasks: [Task] = []
        let now = Date()
        for idx in tasks.indices {
            var task = tasks[idx]
            guard task.categories.contains(categoryId) else { continue }
            // Remove the deleted category and optionally reassign it in one pass.
            task.categories.removeAll { $0 == categoryId }
            if let replacementId, !task.categories.contains(replacementId) {
                task.categories.append(replacementId)
            }
            task.updatedAt = now
            tasks[idx] = task
            updatedTasks.append(task)
        }
        if !updatedTasks.isEmpty {
            saveTasks()
        }
        return updatedTasks
    }

    private func normalizeCategoryOrder() {
        let sorted = categories.sorted(by: Self.categorySort)
        categories = sorted.enumerated().map { index, category in
            var updated = category
            updated.order = index
            return updated
        }
    }

    private func clampUncategorizedPosition(_ position: Int, categoryCount: Int) -> Int {
        let maxIndex = max(0, categoryCount)
        return min(max(position, 0), maxIndex)
    }
    
    func getCategory(id: String) -> Category? {
        categories.first { $0.id == id }
    }
    
    // MARK: - Share Extension Integration
    
    /// Process shared items from the share extension
    /// Called on app launch to convert shared items into tasks
    func processSharedItems() {
        NSLog("========================================")
        NSLog("🔍 [LocalStore] processSharedItems() START")
        NSLog("   App Group: %@", appGroupIdentifier)
        NSLog("========================================")
        
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            NSLog("❌ [LocalStore] Failed to access App Group for shared items")
            return
        }
        
        NSLog("✅ [LocalStore] Accessed UserDefaults for App Group")
        
        // Get shared items
        guard let data = userDefaults.data(forKey: "com.notelayer.app.sharedItems") else {
            NSLog("ℹ️ [LocalStore] No shared items data found")
            return
        }
        
        guard let sharedItems = try? JSONDecoder().decode([SharedItem].self, from: data) else {
            NSLog("❌ [LocalStore] Failed to decode shared items")
            return
        }
        
        guard !sharedItems.isEmpty else {
            NSLog("ℹ️ [LocalStore] Shared items array is empty")
            return
        }
        
        NSLog("📥 [LocalStore] Processing %d shared item(s)", sharedItems.count)
        for (index, item) in sharedItems.enumerated() {
            NSLog("   Item %d: %@", index + 1, item.title)
        }
        
        // Success! Tasks have been added
        NSLog("✅ [LocalStore] Successfully processed \(sharedItems.count) shared item(s)")
        
        // Convert to tasks
        for item in sharedItems {
            let taskNotes = buildTaskNotes(from: item)
            let task = Task(
                title: item.title,
                categories: item.categories,
                priority: item.priority,
                dueDate: item.dueDate,
                taskNotes: taskNotes,
                reminderDate: item.reminderDate
            )
            _ = addTask(task)
            
            NSLog("✅ [LocalStore] Created task from shared item: %@", item.title)
        }
        
        // Clear shared items
        userDefaults.removeObject(forKey: "com.notelayer.app.sharedItems")
        userDefaults.synchronize()
        
        NSLog("🧹 [LocalStore] Cleared shared items from App Group")
        NSLog("========================================")
    }
    
    /// Build task notes from shared item
    /// Formats URL and text content with attribution
    private func buildTaskNotes(from item: SharedItem) -> String {
        var notes = ""
        
        // Add URL if present (clickable)
        if let url = item.url {
            notes += "\(url)\n\n"
        }
        
        // Add text if present
        if let text = item.text {
            notes += "\(text)\n\n"
        }
        
        // Add attribution
        if let sourceApp = item.sourceApp {
            notes += "Shared from \(sourceApp)"
        }
        
        return notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
