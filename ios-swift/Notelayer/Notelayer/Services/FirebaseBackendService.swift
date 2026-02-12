import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import _Concurrency

@MainActor
final class FirebaseBackendService: ObservableObject {
    private let store: LocalStore
    private var backend: FirestoreBackend?
    private var backendUserId: String?
    private var isForceSyncInProgress = false
    private var cancellable: AnyCancellable?
    private var metadataCancellables: Set<AnyCancellable> = []
    private var suppressMetadataWrites = false
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
        metadataCancellables.forEach { $0.cancel() }
        stopListeners()
    }

    private func handleUserChange(_ user: User?) async {
        stopListeners()
        backend = nil
        backendUserId = nil
        store.attachBackend(nil)
        metadataCancellables.forEach { $0.cancel() }
        metadataCancellables.removeAll()
        InsightsTelemetryStore.shared.setUserScope(user?.uid)

        guard let user else {
            return
        }

        if let lastUserId = store.lastBackendUserId, lastUserId != user.uid {
            store.resetForNewUser()
        }
        store.updateBackendUserId(user.uid)

        let backend = FirestoreBackend(userId: user.uid)
        self.backend = backend
        backendUserId = user.uid
        store.attachBackend(backend)

        await syncInitialData(using: backend)
        startListeners(using: backend)
        startMetadataSync(using: backend)
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

            if let remotePosition = try await backend.fetchCategoryGroupMetadata() {
                suppressMetadataWrites = true
                store.applyRemoteUncategorizedPosition(remotePosition)
                suppressMetadataWrites = false
            } else if store.uncategorizedPosition != 0 {
                try await backend.upsertCategoryGroupMetadata(uncategorizedPosition: store.uncategorizedPosition)
            }

            let remoteExperimental = try await backend.fetchExperimentalFeatureMetadata()
            let remoteInsightsHint = try await backend.fetchInsightsHintMetadata()

            suppressMetadataWrites = true
            store.beginExperimentalReconciliation()
            let shouldPushExperimental = store.reconcileExperimentalPreference(
                remoteEnabled: remoteExperimental?.isEnabled,
                remoteUpdatedAt: remoteExperimental?.updatedAt
            )
            let shouldPushHint = store.reconcileInsightsHintState(remoteInsightsHint)
            suppressMetadataWrites = false

            if shouldPushExperimental {
                try await backend.upsertExperimentalFeatureMetadata(preference: store.experimentalFeaturesPreference)
            }
            if shouldPushHint {
                try await backend.upsertInsightsHintMetadata(store.insightsHintState)
            }
        } catch {
            #if DEBUG
            print("Firebase backend initial sync failed: \(error)")
            #endif
        }
    }

    func forceSync() async {
        if isForceSyncInProgress {
            #if DEBUG
            print("⚠️ [FirebaseBackendService] Force sync skipped: already in progress")
            #endif
            return
        }
        guard let backend = self.backend else {
            #if DEBUG
            print("⚠️ [FirebaseBackendService] Force sync skipped: backend not initialized")
            #endif
            return
        }
        guard FirebaseApp.app() != nil else {
            #if DEBUG
            print("⚠️ [FirebaseBackendService] Force sync skipped: Firebase not configured")
            #endif
            return
        }
        guard Auth.auth().currentUser != nil else {
            #if DEBUG
            print("⚠️ [FirebaseBackendService] Force sync skipped: no signed-in user")
            #endif
            return
        }
        if let currentUserId = Auth.auth().currentUser?.uid,
           let backendUserId,
           currentUserId != backendUserId {
            #if DEBUG
            print("⚠️ [FirebaseBackendService] Force sync skipped: user mismatch (backend: \(backendUserId), auth: \(currentUserId))")
            #endif
            return
        }
        
        isForceSyncInProgress = true
        defer { isForceSyncInProgress = false }

        // 1. Push local data to Firestore (ensures everything local is backed up)
        do {
            if !store.notes.isEmpty {
                try await backend.upsert(notes: store.notes)
            }
            if !store.tasks.isEmpty {
                try await backend.upsert(tasks: store.tasks)
            }
            if !store.categories.isEmpty {
                try await backend.upsert(categories: store.categories)
            }
            
            // 2. Re-fetch from Firestore to ensure local is in sync with remote
            await syncInitialData(using: backend)
            
            #if DEBUG
            print("✅ [FirebaseBackendService] Force sync completed successfully")
            #endif
        } catch {
            #if DEBUG
            print("❌ [FirebaseBackendService] Force sync failed: \(error)")
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
            },
            backend.listenCategoryGroupMetadata { [weak self] position in
                _Concurrency.Task { @MainActor in
                    guard let self, let position else { return }
                    self.suppressMetadataWrites = true
                    self.store.applyRemoteUncategorizedPosition(position)
                    self.suppressMetadataWrites = false
                }
            },
            backend.listenExperimentalFeatureMetadata { [weak self] remoteEnabled, remoteUpdatedAt in
                _Concurrency.Task { @MainActor in
                    guard let self else { return }
                    self.suppressMetadataWrites = true
                    let shouldPushLocal = self.store.reconcileExperimentalPreference(
                        remoteEnabled: remoteEnabled,
                        remoteUpdatedAt: remoteUpdatedAt
                    )
                    self.suppressMetadataWrites = false
                    if shouldPushLocal {
                        try? await backend.upsertExperimentalFeatureMetadata(
                            preference: self.store.experimentalFeaturesPreference
                        )
                    }
                }
            },
            backend.listenInsightsHintMetadata { [weak self] remoteState in
                _Concurrency.Task { @MainActor in
                    guard let self else { return }
                    self.suppressMetadataWrites = true
                    let shouldPushLocal = self.store.reconcileInsightsHintState(remoteState)
                    self.suppressMetadataWrites = false
                    if shouldPushLocal {
                        try? await backend.upsertInsightsHintMetadata(self.store.insightsHintState)
                    }
                }
            }
        ]
    }

    private func startMetadataSync(using backend: FirestoreBackend) {
        metadataCancellables.forEach { $0.cancel() }
        metadataCancellables.removeAll()

        store.$uncategorizedPosition
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] position in
                guard let self, !self.suppressMetadataWrites else { return }
                _Concurrency.Task {
                    try? await backend.upsertCategoryGroupMetadata(uncategorizedPosition: position)
                }
            }
            .store(in: &metadataCancellables)

        store.$experimentalFeaturesPreference
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] preference in
                guard let self, !self.suppressMetadataWrites else { return }
                _Concurrency.Task {
                    try? await backend.upsertExperimentalFeatureMetadata(preference: preference)
                }
            }
            .store(in: &metadataCancellables)

        store.$insightsHintState
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] hintState in
                guard let self, !self.suppressMetadataWrites else { return }
                _Concurrency.Task {
                    try? await backend.upsertInsightsHintMetadata(hintState)
                }
            }
            .store(in: &metadataCancellables)
    }

    func deleteAllUserData() async throws {
        guard let backend = self.backend else { return }
        try await backend.deleteAllUserData()
        
        // Clear local store as well
        store.resetForNewUser()
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

    func deleteAllUserData() async throws {
        // Delete notes
        let notesSnapshot = try await notesCollection.getDocuments()
        for document in notesSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete tasks
        let tasksSnapshot = try await tasksCollection.getDocuments()
        for document in tasksSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete categories
        let categoriesSnapshot = try await categoriesCollection.getDocuments()
        for document in categoriesSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Finally delete the user document itself
        try await userDocument.delete()
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

    func deleteCategory(id: String) async throws {
        try await deleteDocument(categoriesCollection.document(id))
    }

    func upsertCategoryGroupMetadata(uncategorizedPosition: Int) async throws {
        try await setData(on: userDocument, data: ["uncategorizedPosition": uncategorizedPosition])
    }

    func fetchCategoryGroupMetadata() async throws -> Int? {
        let snapshot = try await fetchUserDocumentSnapshot()
        return snapshot.data()?["uncategorizedPosition"] as? Int
    }

    func listenCategoryGroupMetadata(_ handler: @escaping (Int?) -> Void) -> ListenerRegistration {
        userDocument.addSnapshotListener { snapshot, error in
            guard let snapshot, error == nil else { return }
            let position = snapshot.data()?["uncategorizedPosition"] as? Int
            handler(position)
        }
    }

    func upsertExperimentalFeatureMetadata(preference: ExperimentalFeaturePreference) async throws {
        try await setData(on: userDocument, data: [
            "experimentalFeaturesEnabled": preference.isEnabled,
            "experimentalFeaturesUpdatedAt": firestoreSafeDate(preference.updatedAt)
        ])
    }

    func fetchExperimentalFeatureMetadata() async throws -> (isEnabled: Bool, updatedAt: Date)? {
        let snapshot = try await fetchUserDocumentSnapshot()
        guard let data = snapshot.data(),
              let isEnabled = data["experimentalFeaturesEnabled"] as? Bool else {
            return nil
        }
        let updatedAt = dateValue(from: data["experimentalFeaturesUpdatedAt"]) ?? AppDateBounds.metadataBaseline
        return (isEnabled, updatedAt)
    }

    func listenExperimentalFeatureMetadata(_ handler: @escaping (Bool?, Date?) -> Void) -> ListenerRegistration {
        userDocument.addSnapshotListener { snapshot, error in
            guard let snapshot, error == nil else { return }
            let data = snapshot.data()
            let isEnabled = data?["experimentalFeaturesEnabled"] as? Bool
            let updatedAt = self.dateValue(from: data?["experimentalFeaturesUpdatedAt"])
            handler(isEnabled, updatedAt)
        }
    }

    func upsertInsightsHintMetadata(_ state: InsightsHintState) async throws {
        var data: [String: Any] = [
            "insightsHintShowCount": state.showCount,
            "insightsHintDismissCount": state.dismissCount,
            "insightsHintUpdatedAt": firestoreSafeDate(state.updatedAt)
        ]
        if let lastShownAt = state.lastShownAt {
            data["insightsHintLastShownAt"] = firestoreSafeDate(lastShownAt)
        } else {
            data["insightsHintLastShownAt"] = FieldValue.delete()
        }
        if let lastDismissedAt = state.lastDismissedAt {
            data["insightsHintLastDismissedAt"] = firestoreSafeDate(lastDismissedAt)
        } else {
            data["insightsHintLastDismissedAt"] = FieldValue.delete()
        }
        if let interactedAt = state.interactedAt {
            data["insightsHintInteractedAt"] = firestoreSafeDate(interactedAt)
        } else {
            data["insightsHintInteractedAt"] = FieldValue.delete()
        }
        try await setData(on: userDocument, data: data)
    }

    func fetchInsightsHintMetadata() async throws -> InsightsHintState? {
        let snapshot = try await fetchUserDocumentSnapshot()
        guard let data = snapshot.data(),
              data["insightsHintUpdatedAt"] != nil else {
            return nil
        }
        let updatedAt = dateValue(from: data["insightsHintUpdatedAt"]) ?? AppDateBounds.metadataBaseline
        return InsightsHintState(
            showCount: data["insightsHintShowCount"] as? Int ?? 0,
            dismissCount: data["insightsHintDismissCount"] as? Int ?? 0,
            lastShownAt: dateValue(from: data["insightsHintLastShownAt"]),
            lastDismissedAt: dateValue(from: data["insightsHintLastDismissedAt"]),
            interactedAt: dateValue(from: data["insightsHintInteractedAt"]),
            updatedAt: updatedAt
        )
    }

    func listenInsightsHintMetadata(_ handler: @escaping (InsightsHintState?) -> Void) -> ListenerRegistration {
        userDocument.addSnapshotListener { snapshot, error in
            guard let snapshot, error == nil else { return }
            let data = snapshot.data()
            guard let data,
                  data["insightsHintUpdatedAt"] != nil else {
                handler(nil)
                return
            }
            let state = InsightsHintState(
                showCount: data["insightsHintShowCount"] as? Int ?? 0,
                dismissCount: data["insightsHintDismissCount"] as? Int ?? 0,
                lastShownAt: self.dateValue(from: data["insightsHintLastShownAt"]),
                lastDismissedAt: self.dateValue(from: data["insightsHintLastDismissedAt"]),
                interactedAt: self.dateValue(from: data["insightsHintInteractedAt"]),
                updatedAt: self.dateValue(from: data["insightsHintUpdatedAt"]) ?? AppDateBounds.metadataBaseline
            )
            handler(state)
        }
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

    private func fetchUserDocumentSnapshot() async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DocumentSnapshot, Error>) in
            userDocument.getDocument { snapshot, error in
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
            "createdAt": firestoreSafeDate(note.createdAt)
        ]
    }

    private func taskData(_ task: Task) -> [String: Any] {
        var data: [String: Any] = [
            "id": task.id,
            "title": task.title,
            "categories": task.categories,
            "priority": task.priority.rawValue,
            "createdAt": firestoreSafeDate(task.createdAt),
            "updatedAt": firestoreSafeDate(task.updatedAt),
            "orderIndex": task.orderIndex as Any
        ]
        if let dueDate = task.dueDate { data["dueDate"] = firestoreSafeDate(dueDate) }
        if let completedAt = task.completedAt {
            data["completedAt"] = firestoreSafeDate(completedAt)
        } else {
            // Ensure completedAt is removed when restoring a task.
            data["completedAt"] = FieldValue.delete()
        }
        if let taskNotes = task.taskNotes { data["taskNotes"] = taskNotes }
        
        // Reminder fields
        if let reminderDate = task.reminderDate {
            data["reminderDate"] = firestoreSafeDate(reminderDate)
        } else {
            data["reminderDate"] = FieldValue.delete()
        }
        if let reminderNotificationId = task.reminderNotificationId {
            data["reminderNotificationId"] = reminderNotificationId
        } else {
            data["reminderNotificationId"] = FieldValue.delete()
        }

        if let parentTaskId = task.parentTaskId {
            data["parentTaskId"] = parentTaskId
        } else {
            data["parentTaskId"] = FieldValue.delete()
        }
        if let parentManualReopenAt = task.parentManualReopenAt {
            data["parentManualReopenAt"] = firestoreSafeDate(parentManualReopenAt)
        } else {
            data["parentManualReopenAt"] = FieldValue.delete()
        }
        
        return data
    }

    private func categoryData(_ category: Category) -> [String: Any] {
        [
            "id": category.id,
            "name": category.name,
            "icon": category.icon,
            "color": category.color,
            "order": category.order
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
        
        // Reminder fields
        let reminderDate = dateValue(from: data["reminderDate"])
        let reminderNotificationId = data["reminderNotificationId"] as? String
        let parentTaskId = data["parentTaskId"] as? String
        let parentManualReopenAt = dateValue(from: data["parentManualReopenAt"])
        
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
            orderIndex: orderIndex,
            reminderDate: reminderDate,
            reminderNotificationId: reminderNotificationId,
            parentTaskId: parentTaskId,
            parentManualReopenAt: parentManualReopenAt
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
        let order = data["order"] as? Int ?? 0
        return Category(id: id, name: name, icon: icon, color: color, order: order)
    }

    private func dateValue(from value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return firestoreSafeDate(timestamp.dateValue())
        }
        if let date = value as? Date {
            return firestoreSafeDate(date)
        }
        if let interval = value as? TimeInterval {
            return firestoreSafeDate(Date(timeIntervalSince1970: interval))
        }
        return nil
    }

    private func firestoreSafeDate(_ date: Date) -> Date {
        AppDateBounds.clampedForFirestore(date)
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
