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
        tasks.removeAll { $0.id == id }
        saveTasks()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.deleteTask(id: id) }
        }
    }
    
    func completeTask(id: String) {
        updateTask(id: id) { task in
            task.completedAt = Date()
        }
    }
    
    func restoreTask(id: String) {
        updateTask(id: id) { task in
            task.completedAt = nil
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
    
    func getCategory(id: String) -> Category? {
        categories.first { $0.id == id }
    }
}
