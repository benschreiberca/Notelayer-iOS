import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import _Concurrency

@MainActor
final class FirebaseBackendService: ObservableObject {
    private let store: LocalStore
    private var backend: FirestoreBackend?
    private var cancellable: AnyCancellable?
    nonisolated(unsafe) private var listeners: [ListenerRegistration] = []

    init(authService: AuthService, store: LocalStore) {
        self.store = store
        cancellable = authService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                _Concurrency.Task { @MainActor in
                    await self?.handleUserChange(user)
                }
            }
    }

    deinit {
        cancellable?.cancel()
        stopListeners()
    }

    private func handleUserChange(_ user: User?) async {
        stopListeners()
        backend = nil
        store.attachBackend(nil)

        guard let user else {
            return
        }

        if let lastUserId = store.lastBackendUserId, lastUserId != user.uid {
            store.resetForNewUser()
        }
        store.updateBackendUserId(user.uid)

        let backend = FirestoreBackend(userId: user.uid)
        self.backend = backend
        store.attachBackend(backend)

        await syncInitialData(using: backend)
        startListeners(using: backend)
    }

    private func syncInitialData(using backend: FirestoreBackend) async {
        do {
            let remote = try await backend.fetchAll()
            var notes = remote.notes
            var tasks = remote.tasks
            var categories = remote.categories

            if remote.notes.isEmpty, !store.notes.isEmpty {
                try await backend.upsert(notes: store.notes)
                notes = store.notes
            }

            if remote.tasks.isEmpty, !store.tasks.isEmpty {
                try await backend.upsert(tasks: store.tasks)
                tasks = store.tasks
            }

            if remote.categories.isEmpty, !store.categories.isEmpty {
                try await backend.upsert(categories: store.categories)
                categories = store.categories
            }

            store.applyRemoteSnapshot(notes: notes, tasks: tasks, categories: categories)
        } catch {
            #if DEBUG
            print("Firebase backend initial sync failed: \(error)")
            #endif
        }
    }

    private func startListeners(using backend: FirestoreBackend) {
        listeners = [
            backend.listenNotes { [weak self] notes in
                _Concurrency.Task { @MainActor in
                    self?.store.applyRemoteNotes(notes)
                }
            },
            backend.listenTasks { [weak self] tasks in
                _Concurrency.Task { @MainActor in
                    self?.store.applyRemoteTasks(tasks)
                }
            },
            backend.listenCategories { [weak self] categories in
                _Concurrency.Task { @MainActor in
                    self?.store.applyRemoteCategories(categories)
                }
            }
        ]
    }

    nonisolated private func stopListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
}

private final class FirestoreBackend: BackendSyncing {
    private let db: Firestore
    private let userId: String

    init(userId: String, db: Firestore = Firestore.firestore()) {
        self.userId = userId
        self.db = db
    }

    private var userDocument: DocumentReference {
        db.collection("users").document(userId)
    }

    private var notesCollection: CollectionReference {
        userDocument.collection("notes")
    }

    private var tasksCollection: CollectionReference {
        userDocument.collection("tasks")
    }

    private var categoriesCollection: CollectionReference {
        userDocument.collection("categories")
    }

    func fetchAll() async throws -> (notes: [Note], tasks: [Task], categories: [Category]) {
        async let notes = fetchNotes()
        async let tasks = fetchTasks()
        async let categories = fetchCategories()
        return try await (notes, tasks, categories)
    }

    func upsert(note: Note) async throws {
        let data = noteData(note)
        try await setData(on: notesCollection.document(note.id.uuidString), data: data)
    }

    func upsert(notes: [Note]) async throws {
        try await upsertBatch(notes: notes)
    }

    func deleteNote(id: UUID) async throws {
        try await deleteDocument(notesCollection.document(id.uuidString))
    }

    func upsert(task: Task) async throws {
        let data = taskData(task)
        try await setData(on: tasksCollection.document(task.id), data: data)
    }

    func upsert(tasks: [Task]) async throws {
        try await upsertBatch(tasks: tasks)
    }

    func deleteTask(id: String) async throws {
        try await deleteDocument(tasksCollection.document(id))
    }

    func upsert(category: Category) async throws {
        let data = categoryData(category)
        try await setData(on: categoriesCollection.document(category.id), data: data)
    }

    func upsert(categories: [Category]) async throws {
        try await upsertBatch(categories: categories)
    }

    func listenNotes(_ handler: @escaping ([Note]) -> Void) -> ListenerRegistration {
        notesCollection.addSnapshotListener { snapshot, error in
            guard let snapshot, error == nil else { return }
            let notes = snapshot.documents.compactMap { document in
                self.note(from: document)
            }
            handler(notes)
        }
    }

    func listenTasks(_ handler: @escaping ([Task]) -> Void) -> ListenerRegistration {
        tasksCollection.addSnapshotListener { snapshot, error in
            guard let snapshot, error == nil else { return }
            let tasks = snapshot.documents.compactMap { document in
                self.task(from: document)
            }
            handler(tasks)
        }
    }

    func listenCategories(_ handler: @escaping ([Category]) -> Void) -> ListenerRegistration {
        categoriesCollection.addSnapshotListener { snapshot, error in
            guard let snapshot, error == nil else { return }
            let categories = snapshot.documents.compactMap { document in
                self.category(from: document)
            }
            handler(categories)
        }
    }

    private func fetchNotes() async throws -> [Note] {
        let snapshot = try await getDocuments(from: notesCollection)
        return snapshot.documents.compactMap { document in
            note(from: document)
        }
    }

    private func fetchTasks() async throws -> [Task] {
        let snapshot = try await getDocuments(from: tasksCollection)
        return snapshot.documents.compactMap { document in
            task(from: document)
        }
    }

    private func fetchCategories() async throws -> [Category] {
        let snapshot = try await getDocuments(from: categoriesCollection)
        return snapshot.documents.compactMap { document in
            category(from: document)
        }
    }

    private func getDocuments(from collection: CollectionReference) async throws -> QuerySnapshot {
        try await withCheckedThrowingContinuation { continuation in
            collection.getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(throwing: FirestoreBackendError.missingSnapshot)
                }
            }
        }
    }

    private func setData(on document: DocumentReference, data: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            document.setData(data, merge: true) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func deleteDocument(_ document: DocumentReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            document.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private func upsertBatch(notes: [Note]) async throws {
        let batch = db.batch()
        for note in notes {
            let data = noteData(note)
            batch.setData(data, forDocument: notesCollection.document(note.id.uuidString), merge: true)
        }
        try await commit(batch)
    }

    private func upsertBatch(tasks: [Task]) async throws {
        let batch = db.batch()
        for task in tasks {
            let data = taskData(task)
            batch.setData(data, forDocument: tasksCollection.document(task.id), merge: true)
        }
        try await commit(batch)
    }

    private func upsertBatch(categories: [Category]) async throws {
        let batch = db.batch()
        for category in categories {
            let data = categoryData(category)
            batch.setData(data, forDocument: categoriesCollection.document(category.id), merge: true)
        }
        try await commit(batch)
    }

    private func noteData(_ note: Note) -> [String: Any] {
        [
            "id": note.id.uuidString,
            "text": note.text,
            "createdAt": note.createdAt
        ]
    }

    private func taskData(_ task: Task) -> [String: Any] {
        var data: [String: Any] = [
            "id": task.id,
            "title": task.title,
            "categories": task.categories,
            "priority": task.priority.rawValue,
            "createdAt": task.createdAt,
            "updatedAt": task.updatedAt,
            "orderIndex": task.orderIndex as Any
        ]
        if let dueDate = task.dueDate { data["dueDate"] = dueDate }
        if let completedAt = task.completedAt { data["completedAt"] = completedAt }
        if let taskNotes = task.taskNotes { data["taskNotes"] = taskNotes }
        return data
    }

    private func categoryData(_ category: Category) -> [String: Any] {
        [
            "id": category.id,
            "name": category.name,
            "icon": category.icon,
            "color": category.color
        ]
    }

    private func note(from document: QueryDocumentSnapshot) -> Note? {
        let data = document.data()
        guard let text = data["text"] as? String else { return nil }
        let idString = data["id"] as? String ?? document.documentID
        guard let uuid = UUID(uuidString: idString) else { return nil }
        let createdAt = dateValue(from: data["createdAt"]) ?? Date()
        return Note(id: uuid, text: text, createdAt: createdAt)
    }

    private func task(from document: QueryDocumentSnapshot) -> Task? {
        let data = document.data()
        let id = (data["id"] as? String) ?? document.documentID
        guard let title = data["title"] as? String else { return nil }
        let categories = data["categories"] as? [String] ?? []
        let priorityRaw = data["priority"] as? String ?? Priority.medium.rawValue
        let priority = Priority(rawValue: priorityRaw) ?? .medium
        let dueDate = dateValue(from: data["dueDate"])
        let completedAt = dateValue(from: data["completedAt"])
        let taskNotes = data["taskNotes"] as? String
        let createdAt = dateValue(from: data["createdAt"]) ?? Date()
        let updatedAt = dateValue(from: data["updatedAt"]) ?? createdAt
        let orderIndex = intValue(from: data["orderIndex"])
        return Task(
            id: id,
            title: title,
            categories: categories,
            priority: priority,
            dueDate: dueDate,
            completedAt: completedAt,
            taskNotes: taskNotes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            orderIndex: orderIndex
        )
    }

    private func category(from document: QueryDocumentSnapshot) -> Category? {
        let data = document.data()
        guard
            let name = data["name"] as? String,
            let icon = data["icon"] as? String,
            let color = data["color"] as? String
        else {
            return nil
        }
        let id = data["id"] as? String ?? document.documentID
        return Category(id: id, name: name, icon: icon, color: color)
    }

    private func dateValue(from value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }
        if let date = value as? Date {
            return date
        }
        if let interval = value as? TimeInterval {
            return Date(timeIntervalSince1970: interval)
        }
        return nil
    }

    private func intValue(from value: Any?) -> Int? {
        if let intValue = value as? Int { return intValue }
        if let int64Value = value as? Int64 { return Int(int64Value) }
        if let doubleValue = value as? Double { return Int(doubleValue) }
        if let stringValue = value as? String, let intValue = Int(stringValue) { return intValue }
        return nil
    }

    private func commit(_ batch: WriteBatch) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            batch.commit { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

private enum FirestoreBackendError: Error {
    case missingSnapshot
}
