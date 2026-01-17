//
//  AppStore.swift
//  Notelayer
//
//  Central app state store (similar to useAppStore in web app)
//

import Foundation
import Combine

@MainActor
class AppStore: ObservableObject {
    static let shared = AppStore()
    
    // Notes
    @Published var notes: [Note] = []
    @Published var activeNoteId: String?
    
    // Tasks
    @Published var tasks: [Task] = []
    @Published var activeTaskId: String?
    
    // Categories (local only)
    @Published var categories: [Category] = Category.defaults
    
    // UI state
    @Published var showDoneTasks = false
    @Published var todoView: TodoView = .list
    
    private init() {
        // Load categories from UserDefaults
        loadCategories()
    }
    
    // MARK: - Initial Data Load
    
    func loadInitialData() async {
        // TODO: Sync from Supabase when implemented
    }
    
    // MARK: - Notes
    
    func addNote(title: String = "", content: String = "", plainText: String = "", isPinned: Bool = false) -> String {
        let id = IDGenerator.generate()
        let now = Date()
        
        let note = Note(
            id: id,
            title: title,
            content: content,
            plainText: plainText,
            isPinned: isPinned,
            createdAt: now,
            updatedAt: now
        )
        
        notes.insert(note, at: 0)
        // TODO: Sync to Supabase in Phase 3
        return id
    }
    
    func updateNote(id: String, title: String? = nil, content: String? = nil, plainText: String? = nil, isPinned: Bool? = nil) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        var note = notes[index]
        
        if let title = title { note.title = title }
        if let content = content { note.content = content }
        if let plainText = plainText { note.plainText = plainText }
        if let isPinned = isPinned { note.isPinned = isPinned }
        
        note.updatedAt = Date()
        notes[index] = note
        // TODO: Sync to Supabase in Phase 3
    }
    
    func deleteNote(id: String) {
        notes.removeAll { $0.id == id }
        if activeNoteId == id {
            activeNoteId = nil
        }
        // TODO: Sync to Supabase in Phase 3
    }
    
    func deleteNotes(ids: [String]) {
        notes.removeAll { ids.contains($0.id) }
        if let activeId = activeNoteId, ids.contains(activeId) {
            activeNoteId = nil
        }
        // TODO: Sync to Supabase in Phase 3
    }
    
    func togglePinNote(id: String) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        var note = notes[index]
        note.isPinned.toggle()
        note.updatedAt = Date()
        notes[index] = note
        // TODO: Sync to Supabase in Phase 3
    }
    
    func setActiveNote(id: String?) {
        activeNoteId = id
    }
    
    var sortedNotes: [Note] {
        notes.sorted { a, b in
            if a.isPinned && !b.isPinned { return true }
            if !a.isPinned && b.isPinned { return false }
            return a.updatedAt > b.updatedAt
        }
    }
    
    var pinnedNotes: [Note] {
        sortedNotes.filter { $0.isPinned }
    }
    
    var unpinnedNotes: [Note] {
        sortedNotes.filter { !$0.isPinned }
    }
    
    // MARK: - Tasks
    
    func addTask(title: String, categories: [CategoryId] = [], priority: Priority = .medium, dueDate: Date? = nil, taskNotes: String? = nil) -> String {
        let id = IDGenerator.generate()
        let now = Date()
        
        let task = Task(
            id: id,
            title: title,
            categories: categories,
            priority: priority,
            dueDate: dueDate,
            completedAt: nil,
            parentTaskId: nil,
            attachments: [],
            noteId: nil,
            noteLine: nil,
            taskNotes: taskNotes,
            createdAt: now,
            updatedAt: now,
            inputMethod: .text,
            orderIndex: now.timeIntervalSince1970
        )
        
        tasks.insert(task, at: 0)
        // TODO: Sync to Supabase in Phase 3
        return id
    }
    
    func updateTask(id: String, title: String? = nil, categories: [CategoryId]? = nil, priority: Priority? = nil, dueDate: Date? = nil, taskNotes: String? = nil, completedAt: Date? = nil) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        var task = tasks[index]
        
        if let title = title { task.title = title }
        if let categories = categories { task.categories = categories }
        if let priority = priority { task.priority = priority }
        task.dueDate = dueDate
        task.taskNotes = taskNotes
        task.completedAt = completedAt
        
        task.updatedAt = Date()
        tasks[index] = task
        // TODO: Sync to Supabase in Phase 3
    }
    
    func deleteTask(id: String) {
        tasks.removeAll { $0.id == id }
        if activeTaskId == id {
            activeTaskId = nil
        }
        // TODO: Sync to Supabase in Phase 3
    }
    
    func completeTask(id: String) {
        updateTask(id: id, completedAt: Date())
    }
    
    func restoreTask(id: String) {
        updateTask(id: id, completedAt: nil)
    }
    
    func setActiveTask(id: String?) {
        activeTaskId = id
    }
    
    func reorderTasks(orderedIds: [String]) {
        let taskMap = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        let reordered = orderedIds.compactMap { taskMap[$0] }
        let remaining = tasks.filter { !orderedIds.contains($0.id) }
        
        let now = Date().timeIntervalSince1970
        let reorderedWithOrder = reordered.enumerated().map { idx, task in
            var updated = task
            updated.orderIndex = now - Double(idx)
            updated.updatedAt = Date()
            return updated
        }
        
        tasks = reorderedWithOrder + remaining
        // TODO: Sync to Supabase in Phase 3
    }
    
    func bulkUpdateTaskCategories(taskIds: [String], add: [CategoryId]? = nil, remove: [CategoryId]? = nil) {
        for taskId in taskIds {
            guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { continue }
            var task = tasks[index]
            
            var newCategories = task.categories
            if let remove = remove {
                newCategories.removeAll { remove.contains($0) }
            }
            if let add = add {
                newCategories = Array(Set(newCategories + add))
            }
            
            task.categories = newCategories
            task.updatedAt = Date()
            tasks[index] = task
        }
        // TODO: Sync to Supabase in Phase 3
    }
    
    var activeTasks: [Task] {
        tasks.filter { $0.completedAt == nil }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.completedAt != nil }
    }
    
    // MARK: - Categories (Local Storage)
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: "categories"),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        } else {
            categories = Category.defaults
            saveCategories()
        }
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "categories")
        }
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func updateCategory(id: CategoryId, updates: Category) {
        if let index = categories.firstIndex(where: { $0.id == id }) {
            categories[index] = updates
            saveCategories()
        }
    }
    
    func reorderCategories(orderedIds: [CategoryId]) {
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        let reordered = orderedIds.compactMap { categoryMap[$0] }
        let remaining = categories.filter { !orderedIds.contains($0.id) }
        categories = reordered + remaining
        saveCategories()
    }
}

enum TodoView: String, Codable {
    case list = "list"
    case priority = "priority"
    case category = "category"
    case date = "date"
}
