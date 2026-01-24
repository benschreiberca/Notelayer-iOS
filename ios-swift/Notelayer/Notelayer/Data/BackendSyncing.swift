import Foundation

protocol BackendSyncing: AnyObject {
    func upsert(note: Note) async throws
    func upsert(notes: [Note]) async throws
    func deleteNote(id: UUID) async throws

    func upsert(task: Task) async throws
    func upsert(tasks: [Task]) async throws
    func deleteTask(id: String) async throws

    func upsert(category: Category) async throws
    func upsert(categories: [Category]) async throws
}
