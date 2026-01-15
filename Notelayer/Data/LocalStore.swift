import Foundation
import SwiftUI
import Combine

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
    
    private let notesKey = "com.notelayer.app.notes"
    private let tasksKey = "com.notelayer.app.tasks"
    private let categoriesKey = "com.notelayer.app.categories"
    private let appGroupIdentifier = "group.com.notelayer.app"
    
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    private init() {
        load()
        migrateIfNeeded()
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
    }
    
    func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    // MARK: - Tasks
    
    func addTask(_ task: Task) -> String {
        var newTask = task
        if newTask.orderIndex == nil {
            newTask.orderIndex = Int(Date().timeIntervalSince1970 * 1000)
        }
        tasks.append(newTask)
        saveTasks()
        return newTask.id
    }
    
    func updateTask(id: String, updates: (inout Task) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        var task = tasks[index]
        updates(&task)
        task.updatedAt = Date()
        tasks[index] = task
        saveTasks()
    }
    
    func deleteTask(id: String) {
        tasks.removeAll { $0.id == id }
        saveTasks()
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
    }
    
    // MARK: - Categories
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func updateCategory(id: String, updates: (inout Category) -> Void) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
        var category = categories[index]
        updates(&category)
        categories[index] = category
        saveCategories()
    }
    
    func reorderCategories(orderedIds: [String]) {
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        categories = orderedIds.compactMap { categoryMap[$0] }
        saveCategories()
    }
    
    func getCategory(id: String) -> Category? {
        categories.first { $0.id == id }
    }
}
