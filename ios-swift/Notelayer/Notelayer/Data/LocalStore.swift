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

    private var backend: BackendSyncing?
    private var suppressBackendWrites = false
    
    private let notesKey = "com.notelayer.app.notes"
    private let tasksKey = "com.notelayer.app.tasks"
    private let categoriesKey = "com.notelayer.app.categories"
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
            saveNotes()
            saveTasks()
            saveCategories()
            migrateIfNeeded()
        }
    }

    func applyRemoteSnapshot(notes: [Note], tasks: [Task], categories: [Category]) {
        applyRemoteUpdate {
            self.notes = notes
            self.tasks = tasks
            self.categories = categories
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
    
    private func saveCategories() {
        if let categoriesData = try? JSONEncoder().encode(categories) {
            userDefaults.set(categoriesData, forKey: categoriesKey)
        }
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
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: newTask) }
        }
        return newTask.id
    }
    
    func updateTask(id: String, updates: (inout Task) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        var task = tasks[index]
        updates(&task)
        task.updatedAt = Date()
        tasks[index] = task
        saveTasks()
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
        var task = tasks[index]
        
        // Capture reminder info before mutation
        let notificationId = task.reminderNotificationId
        
        // Update task state
        task.completedAt = Date()
        task.reminderDate = nil
        task.reminderNotificationId = nil
        
        tasks[index] = task
        saveTasks()
        
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
        var task = tasks[index]
        
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
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(tasks: tasks) }
        }
    }
    
    // MARK: - Categories
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(category: category) }
        }
    }
    
    func updateCategory(id: String, updates: (inout Category) -> Void) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
        var category = categories[index]
        updates(&category)
        categories[index] = category
        saveCategories()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(category: category) }
        }
    }
    
    func reorderCategories(orderedIds: [String]) {
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        categories = orderedIds.compactMap { categoryMap[$0] }
        saveCategories()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(categories: categories) }
        }
    }

    func deleteCategory(id: String, reassignTo replacementId: String? = nil) {
        let resolvedReplacementId: String? = {
            guard let replacementId, replacementId != id else { return nil }
            return categories.contains(where: { $0.id == replacementId }) ? replacementId : nil
        }()
        let updatedTasks = updateTasksForCategoryRemoval(categoryId: id, replacementId: resolvedReplacementId)
        categories.removeAll { $0.id == id }
        saveCategories()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task {
                try? await backend.deleteCategory(id: id)
                if !updatedTasks.isEmpty {
                    try? await backend.upsert(tasks: updatedTasks)
                }
            }
        }
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
    
    func getCategory(id: String) -> Category? {
        categories.first { $0.id == id }
    }
}
