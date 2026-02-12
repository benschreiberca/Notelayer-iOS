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

extension Notification.Name {
    static let experimentalFeaturesDidChange = Notification.Name("Notelayer.ExperimentalFeatures.DidChange")
    static let openOnboardingRequested = Notification.Name("Notelayer.Onboarding.OpenRequested")
}

enum ParentTaskDeletionStrategy {
    case deleteSubtasks
    case detachSubtasks
}

class LocalStore: ObservableObject {
    static let shared = LocalStore()
    
    @Published var notes: [Note] = []
    @Published var tasks: [Task] = []
    @Published var categories: [Category] = []
    @Published private(set) var uncategorizedPosition: Int = 0
    @Published private(set) var experimentalFeaturesPreference: ExperimentalFeaturePreference = .default
    @Published private(set) var insightsHintState: InsightsHintState = .default
    @Published var voiceStagingDrafts: [VoiceParsedTaskDraft] = []
    @Published var voiceSourceTranscript: String = ""
    @Published var isVoiceStagingPresented: Bool = false
    @Published private(set) var pendingSharedImportCount: Int = 0
    @Published private(set) var lastSharedImportError: String?
    @Published private(set) var lastSharedImportProcessedAt: Date?

    private var backend: BackendSyncing?
    private var suppressBackendWrites = false
    
    private let notesKey = "com.notelayer.app.notes"
    private let tasksKey = "com.notelayer.app.tasks"
    private let categoriesKey = "com.notelayer.app.categories"
    private let uncategorizedPositionKey = "com.notelayer.app.todos.uncategorizedPosition"
    private let experimentalFeaturesEnabledKey = "com.notelayer.app.experimentalFeatures.enabled"
    private let experimentalFeaturesUpdatedAtKey = "com.notelayer.app.experimentalFeatures.updatedAt"
    private let insightsHintStateKey = "com.notelayer.app.insights.hintState"
    private let voiceStagingDraftsKey = "com.notelayer.app.voice.stagingDrafts"
    private let voiceSourceTranscriptKey = "com.notelayer.app.voice.sourceTranscript"
    private let backendUserIdKey = "com.notelayer.app.backendUserId"
    private let sharedItemsQueueKey = "com.notelayer.app.sharedItems"
    private var hasStoredExperimentalPreference = false
    private var hasStoredInsightsHintState = false
    private let sharedImportProcessingQueue = DispatchQueue(
        label: "com.notelayer.app.sharedImport.processing",
        qos: .utility
    )
    private let sharedImportProcessingLock = NSLock()
    private var isSharedImportProcessing = false
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.migrateIfNeeded()
        }
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

    var topLevelTasks: [Task] {
        tasks.filter { $0.parentTaskId == nil }
    }

    var experimentalFeaturesEnabled: Bool {
        experimentalFeaturesPreference.isEnabled
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
            experimentalFeaturesPreference = .default
            insightsHintState = .default
            voiceStagingDrafts = []
            voiceSourceTranscript = ""
            isVoiceStagingPresented = false
            pendingSharedImportCount = 0
            lastSharedImportError = nil
            lastSharedImportProcessedAt = nil
            hasStoredExperimentalPreference = false
            hasStoredInsightsHintState = false
            saveNotes()
            saveTasks()
            saveCategories()
            saveUncategorizedPosition()
            saveExperimentalFeaturesPreference()
            saveInsightsHintState()
            saveVoiceStaging()
            migrateIfNeeded()
        }
    }

    func applyRemoteSnapshot(notes: [Note], tasks: [Task], categories: [Category]) {
        applyRemoteUpdate {
            self.notes = notes
            self.tasks = sanitizeHierarchy(tasks)
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
            let sanitizedTasks = sanitizeHierarchy(tasks)
            self.tasks = sanitizedTasks
            saveTasks()
            
            // Reschedule reminders for synced tasks
            // Notifications don't sync across devices, only reminder data syncs
            rescheduleRemindersAfterSync(sanitizedTasks)
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

    private func sanitizeHierarchy(_ tasks: [Task]) -> [Task] {
        let lookup = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        return tasks.map { task in
            var sanitized = task
            if let parentId = task.parentTaskId {
                if parentId == task.id || lookup[parentId]?.parentTaskId != nil || lookup[parentId] == nil {
                    sanitized.parentTaskId = nil
                }
            }
            if sanitized.parentTaskId != nil {
                sanitized.parentManualReopenAt = nil
            }
            return sanitized
        }
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
        if categories.isEmpty {
            categories = Category.defaultCategories
        }

        if let savedPosition = userDefaults.object(forKey: uncategorizedPositionKey) as? Int {
            uncategorizedPosition = savedPosition
        }

        if userDefaults.object(forKey: experimentalFeaturesEnabledKey) != nil {
            hasStoredExperimentalPreference = true
            let enabled = userDefaults.bool(forKey: experimentalFeaturesEnabledKey)
            let persistedUpdatedAt = userDefaults.object(forKey: experimentalFeaturesUpdatedAtKey) as? Date
                ?? AppDateBounds.metadataBaseline
            let updatedAt = AppDateBounds.clampedForFirestore(persistedUpdatedAt)
            experimentalFeaturesPreference = ExperimentalFeaturePreference(
                isEnabled: enabled,
                updatedAt: updatedAt,
                state: enabled ? .on : .off
            )
        } else {
            hasStoredExperimentalPreference = false
            experimentalFeaturesPreference = .default
        }

        if let hintData = userDefaults.data(forKey: insightsHintStateKey),
           let decodedHintState = try? JSONDecoder().decode(InsightsHintState.self, from: hintData) {
            insightsHintState = InsightsHintState(
                showCount: decodedHintState.showCount,
                dismissCount: decodedHintState.dismissCount,
                lastShownAt: decodedHintState.lastShownAt,
                lastDismissedAt: decodedHintState.lastDismissedAt,
                interactedAt: decodedHintState.interactedAt,
                updatedAt: AppDateBounds.clampedForFirestore(decodedHintState.updatedAt)
            )
            hasStoredInsightsHintState = true
        } else {
            insightsHintState = .default
            hasStoredInsightsHintState = false
        }

        if let draftsData = userDefaults.data(forKey: voiceStagingDraftsKey),
           let decodedDrafts = try? JSONDecoder().decode([VoiceParsedTaskDraft].self, from: draftsData) {
            voiceStagingDrafts = decodedDrafts
        } else {
            voiceStagingDrafts = []
        }
        voiceSourceTranscript = userDefaults.string(forKey: voiceSourceTranscriptKey) ?? ""
        isVoiceStagingPresented = !voiceStagingDrafts.isEmpty
        refreshSharedImportQueueStatusAsync()
    }

    private func refreshSharedImportQueueStatusAsync() {
        sharedImportProcessingQueue.async { [weak self] in
            guard let self else { return }
            guard let userDefaults = UserDefaults(suiteName: self.appGroupIdentifier) else {
                DispatchQueue.main.async { [weak self] in
                    self?.pendingSharedImportCount = 0
                    self?.lastSharedImportError = nil
                }
                return
            }

            let queuedItems = self.decodeSharedItems(from: userDefaults)
            let pendingCount = queuedItems.count
            let firstError = queuedItems.first(where: { $0.status == .failed })?.lastError

            DispatchQueue.main.async { [weak self] in
                self?.pendingSharedImportCount = pendingCount
                self?.lastSharedImportError = firstError
            }
        }
    }

    private func migrateIfNeeded() {
        // Categories: initialize defaults if empty
        if categories.isEmpty {
            categories = Category.defaultCategories
            saveCategories()
        }

        // Categories: normalize color field to hex (supports older non-hex values)
        var changed = false
        var tasksChanged = false
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

        // Tasks: enforce one-level hierarchy and clear invalid parent references.
        let taskLookup = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        for idx in tasks.indices {
            let currentId = tasks[idx].id
            if let parentId = tasks[idx].parentTaskId {
                let parent = taskLookup[parentId]
                let parentIsTopLevel = parent?.parentTaskId == nil
                if parent == nil || !parentIsTopLevel || parentId == currentId {
                    tasks[idx].parentTaskId = nil
                    tasksChanged = true
                }
            }
            if tasks[idx].parentTaskId != nil, tasks[idx].parentManualReopenAt != nil {
                tasks[idx].parentManualReopenAt = nil
                tasksChanged = true
            }
        }

        if changed {
            saveCategories()
        }
        if tasksChanged {
            saveTasks()
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

    private func saveExperimentalFeaturesPreference() {
        userDefaults.set(experimentalFeaturesPreference.isEnabled, forKey: experimentalFeaturesEnabledKey)
        userDefaults.set(
            AppDateBounds.clampedForFirestore(experimentalFeaturesPreference.updatedAt),
            forKey: experimentalFeaturesUpdatedAtKey
        )
        hasStoredExperimentalPreference = true
    }

    private func saveInsightsHintState() {
        if let data = try? JSONEncoder().encode(insightsHintState) {
            userDefaults.set(data, forKey: insightsHintStateKey)
            hasStoredInsightsHintState = true
        }
    }

    private func saveVoiceStaging() {
        if voiceStagingDrafts.isEmpty {
            userDefaults.removeObject(forKey: voiceStagingDraftsKey)
            userDefaults.removeObject(forKey: voiceSourceTranscriptKey)
            return
        }
        if let data = try? JSONEncoder().encode(voiceStagingDrafts) {
            userDefaults.set(data, forKey: voiceStagingDraftsKey)
            userDefaults.set(voiceSourceTranscript, forKey: voiceSourceTranscriptKey)
        }
    }

    // MARK: - Experimental Features

    func beginExperimentalReconciliation() {
        experimentalFeaturesPreference.state = .pendingSyncReconcile
    }

    @discardableResult
    func reconcileExperimentalPreference(
        remoteEnabled: Bool?,
        remoteUpdatedAt: Date?
    ) -> Bool {
        let local = experimentalFeaturesPreference
        var shouldPushLocal = false

        if let remoteEnabled, let remoteUpdatedAt {
            if !hasStoredExperimentalPreference {
                experimentalFeaturesPreference = ExperimentalFeaturePreference(
                    isEnabled: remoteEnabled,
                    updatedAt: remoteUpdatedAt,
                    state: remoteEnabled ? .on : .off
                )
            } else if remoteUpdatedAt > local.updatedAt {
                experimentalFeaturesPreference = ExperimentalFeaturePreference(
                    isEnabled: remoteEnabled,
                    updatedAt: remoteUpdatedAt,
                    state: remoteEnabled ? .on : .off
                )
            } else {
                shouldPushLocal = true
                experimentalFeaturesPreference.state = local.isEnabled ? .on : .off
            }
        } else {
            experimentalFeaturesPreference.state = local.isEnabled ? .on : .off
            shouldPushLocal = hasStoredExperimentalPreference
        }

        saveExperimentalFeaturesPreference()
        return shouldPushLocal
    }

    func setExperimentalFeaturesEnabled(_ enabled: Bool, source: String = "user") {
        let previousValue = experimentalFeaturesPreference.isEnabled
        guard previousValue != enabled else { return }

        experimentalFeaturesPreference = ExperimentalFeaturePreference(
            isEnabled: enabled,
            updatedAt: Date(),
            state: enabled ? .on : .off
        )
        saveExperimentalFeaturesPreference()

        NotificationCenter.default.post(
            name: .experimentalFeaturesDidChange,
            object: nil,
            userInfo: [
                "oldValue": previousValue,
                "newValue": enabled,
                "source": source
            ]
        )
    }

    // MARK: - Insights Hint State

    @discardableResult
    func reconcileInsightsHintState(_ remote: InsightsHintState?) -> Bool {
        let local = insightsHintState
        var shouldPushLocal = false

        if let remote {
            if !hasStoredInsightsHintState {
                insightsHintState = remote
            } else if remote.updatedAt > local.updatedAt {
                insightsHintState = remote
            } else {
                shouldPushLocal = true
            }
        } else {
            shouldPushLocal = hasStoredInsightsHintState
        }

        saveInsightsHintState()
        return shouldPushLocal
    }

    func shouldShowInsightsHint(now: Date = Date()) -> Bool {
        insightsHintState.shouldShowHint(now: now)
    }

    func markInsightsHintShown(now: Date = Date()) {
        var next = insightsHintState
        next.showCount += 1
        next.lastShownAt = now
        next.updatedAt = now
        insightsHintState = next
        saveInsightsHintState()
    }

    func dismissInsightsHint(now: Date = Date()) {
        var next = insightsHintState
        next.dismissCount += 1
        next.lastDismissedAt = now
        next.updatedAt = now
        insightsHintState = next
        saveInsightsHintState()
    }

    func recordInsightsInteraction(now: Date = Date()) {
        var next = insightsHintState
        guard next.interactedAt == nil else { return }
        next.interactedAt = now
        next.updatedAt = now
        insightsHintState = next
        saveInsightsHintState()
    }

    // MARK: - Voice Staging

    func stageVoiceDrafts(_ drafts: [VoiceParsedTaskDraft], transcript: String) {
        voiceStagingDrafts = drafts
        voiceSourceTranscript = transcript
        isVoiceStagingPresented = !drafts.isEmpty
        saveVoiceStaging()
    }

    func updateVoiceStagingDrafts(_ drafts: [VoiceParsedTaskDraft]) {
        voiceStagingDrafts = drafts
        isVoiceStagingPresented = !drafts.isEmpty
        saveVoiceStaging()
    }

    func clearVoiceStaging() {
        voiceStagingDrafts = []
        voiceSourceTranscript = ""
        isVoiceStagingPresented = false
        saveVoiceStaging()
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
        if let parentId = newTask.parentTaskId {
            if let parent = tasks.first(where: { $0.id == parentId && $0.parentTaskId == nil }) {
                if newTask.categories.isEmpty {
                    newTask.categories = parent.categories
                }
            } else {
                // Enforce one-level hierarchy and prevent orphaned parent references.
                newTask.parentTaskId = nil
            }
        } else {
            newTask.parentManualReopenAt = nil
        }
        tasks.append(newTask)
        if let parentId = newTask.parentTaskId {
            reconcileParentCompletion(parentId: parentId, resetManualOverride: true)
        }
        saveTasks()
        logTaskCreatedAnalytics(for: newTask)
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: newTask) }
        }
        return newTask.id
    }

    private func logTaskCreatedAnalytics(for task: Task) {
        // Analytics: log task creation without PII.
        AnalyticsService.shared.logEvent(AnalyticsEventName.taskCreated, params: [
            "priority": task.priority.rawValue,
            "category_count": task.categories.count,
            "has_due_date": task.dueDate != nil,
            "has_reminder": task.reminderDate != nil,
            "category_ids_csv": task.categories.joined(separator: ",")
        ])
        if !task.categories.isEmpty {
            // Analytics: separate signal for category assignment on create.
            AnalyticsService.shared.logEvent(AnalyticsEventName.categoryAssignedToTask, params: [
                "category_count": task.categories.count,
                "source_view": "Task Create"
            ])
        }
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

    func subtasks(for parentId: String, includeCompleted: Bool? = nil) -> [Task] {
        tasks
            .filter { task in
                guard task.parentTaskId == parentId else { return false }
                if let includeCompleted {
                    return includeCompleted ? task.completedAt != nil : task.completedAt == nil
                }
                return true
            }
            .sorted { (lhs, rhs) in
                (lhs.orderIndex ?? 0) > (rhs.orderIndex ?? 0)
            }
    }

    func subtaskCount(for parentId: String) -> Int {
        tasks.reduce(into: 0) { count, task in
            if task.parentTaskId == parentId {
                count += 1
            }
        }
    }

    func hasSubtasks(parentId: String) -> Bool {
        tasks.contains(where: { $0.parentTaskId == parentId })
    }

    func availableParentTasks(excluding taskId: String) -> [Task] {
        topLevelTasks
            .filter { task in
                task.id != taskId
            }
            .sorted { (lhs, rhs) in
                (lhs.orderIndex ?? 0) > (rhs.orderIndex ?? 0)
            }
    }

    func addSubtask(to parentId: String, title: String = "New subtask", priority: Priority = .medium) -> String? {
        guard let parent = tasks.first(where: { $0.id == parentId && $0.parentTaskId == nil }) else {
            return nil
        }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let subtask = Task(
            title: trimmed,
            categories: parent.categories,
            priority: priority,
            parentTaskId: parentId
        )
        return addTask(subtask)
    }

    func setParent(for taskId: String, parentId: String?) {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        let oldParentId = tasks[index].parentTaskId

        if parentId == taskId {
            return
        }
        if parentId != nil, hasSubtasks(parentId: taskId) {
            // v1 prevents nesting: a task with subtasks cannot become a subtask.
            return
        }
        if let parentId,
           !tasks.contains(where: { $0.id == parentId && $0.parentTaskId == nil }) {
            return
        }

        tasks[index].parentTaskId = parentId
        tasks[index].updatedAt = Date()
        if parentId != nil {
            tasks[index].parentManualReopenAt = nil
            if tasks[index].categories.isEmpty, let parentId,
               let parent = tasks.first(where: { $0.id == parentId }) {
                tasks[index].categories = parent.categories
            }
        }
        saveTasks()

        if let oldParentId {
            reconcileParentCompletion(parentId: oldParentId, resetManualOverride: true)
        }
        if let parentId {
            reconcileParentCompletion(parentId: parentId, resetManualOverride: true)
        }

        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(tasks: tasks) }
        }
    }

    func deleteParentTask(id: String, strategy: ParentTaskDeletionStrategy) {
        guard hasSubtasks(parentId: id) else {
            deleteTask(id: id)
            return
        }

        switch strategy {
        case .deleteSubtasks:
            let childIds = subtasks(for: id).map(\.id)
            for childId in childIds {
                deleteTask(id: childId)
            }
            deleteTask(id: id)
        case .detachSubtasks:
            let childIds = subtasks(for: id).map(\.id)
            for childId in childIds {
                setParent(for: childId, parentId: nil)
            }
            deleteTask(id: id)
        }
    }
    
    func deleteTask(id: String) {
        // Capture reminder info before deletion
        let taskToDelete = tasks.first(where: { $0.id == id })
        let notificationId = taskToDelete?.reminderNotificationId
        let parentId = taskToDelete?.parentTaskId
        
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

        if let parentId {
            reconcileParentCompletion(parentId: parentId, resetManualOverride: true)
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
        task.parentManualReopenAt = nil
        
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

        if let parentId = task.parentTaskId {
            reconcileParentCompletion(parentId: parentId, resetManualOverride: false)
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
        let childCount = subtaskCount(for: task.id)
        if childCount > 0 {
            // Manual reopen override: keep parent open even if all subtasks are still complete.
            task.parentManualReopenAt = Date()
        }
        
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

        if let parentId = task.parentTaskId {
            reconcileParentCompletion(parentId: parentId, resetManualOverride: true)
        }
    }

    private func reconcileParentCompletion(parentId: String, resetManualOverride: Bool) {
        guard let parentIndex = tasks.firstIndex(where: { $0.id == parentId && $0.parentTaskId == nil }) else {
            return
        }
        let children = tasks.filter { $0.parentTaskId == parentId }
        guard !children.isEmpty else {
            if tasks[parentIndex].parentManualReopenAt != nil {
                tasks[parentIndex].parentManualReopenAt = nil
                tasks[parentIndex].updatedAt = Date()
                saveTasks()
                if let backend, !suppressBackendWrites {
                    _Concurrency.Task { try? await backend.upsert(task: tasks[parentIndex]) }
                }
            }
            return
        }

        var parent = tasks[parentIndex]
        var didChange = false
        let allSubtasksCompleted = children.allSatisfy { $0.completedAt != nil }

        if resetManualOverride, parent.parentManualReopenAt != nil {
            parent.parentManualReopenAt = nil
            didChange = true
        }

        if allSubtasksCompleted {
            if parent.parentManualReopenAt == nil, parent.completedAt == nil {
                parent.completedAt = Date()
                parent.updatedAt = Date()
                didChange = true
            }
        } else {
            if parent.completedAt != nil {
                parent.completedAt = nil
                parent.updatedAt = Date()
                didChange = true
            }
            if parent.parentManualReopenAt != nil {
                parent.parentManualReopenAt = nil
                didChange = true
            }
        }

        guard didChange else { return }
        tasks[parentIndex] = parent
        saveTasks()
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: parent) }
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

    func applyOnboardingPresetCategories(_ presetCategories: [Category]) {
        categories = presetCategories.enumerated().map { index, category in
            var updated = category
            updated.order = index
            return updated
        }
        setUncategorizedPosition(min(uncategorizedPosition, categories.count))
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

    func retryPendingSharedImports() {
        processSharedItems()
    }

    /// Process shared items from the share extension
    /// Called on app launch to convert shared items into tasks or notes.
    /// Processing is intentionally offloaded to a utility queue to keep the launch path responsive.
    func processSharedItems() {
        scheduleSharedImportProcessing(after: 0)
    }

    func processSharedItems(after delay: TimeInterval) {
        scheduleSharedImportProcessing(after: delay)
    }

    private func scheduleSharedImportProcessing(after delay: TimeInterval) {
        sharedImportProcessingLock.lock()
        if isSharedImportProcessing {
            sharedImportProcessingLock.unlock()
            return
        }
        isSharedImportProcessing = true
        sharedImportProcessingLock.unlock()

        let work: () -> Void = { [weak self] in
            guard let self else { return }
            self.processSharedItemsOnBackgroundQueue()
        }

        let clampedDelay = max(0, delay)
        if clampedDelay > 0 {
            sharedImportProcessingQueue.asyncAfter(deadline: .now() + clampedDelay, execute: work)
        } else {
            sharedImportProcessingQueue.async(execute: work)
        }
    }

    private func finishSharedImportProcessing() {
        sharedImportProcessingLock.lock()
        isSharedImportProcessing = false
        sharedImportProcessingLock.unlock()
    }

    private func processSharedItemsOnBackgroundQueue() {
        NSLog("========================================")
        NSLog("🔍 [LocalStore] processSharedItems() START")
        NSLog("   App Group: %@", appGroupIdentifier)
        NSLog("========================================")

        let processedAt = Date()

        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            DispatchQueue.main.async { [weak self] in
                self?.lastSharedImportProcessedAt = processedAt
                self?.lastSharedImportError = "Shared import storage is unavailable on this device."
                self?.finishSharedImportProcessing()
            }
            return
        }

        let sharedItems = decodeSharedItems(from: userDefaults)
        guard !sharedItems.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.lastSharedImportProcessedAt = processedAt
                self?.pendingSharedImportCount = 0
                self?.lastSharedImportError = nil
                self?.finishSharedImportProcessing()
            }
            return
        }

        NSLog("📥 [LocalStore] Processing %d shared item(s)", sharedItems.count)

        var failedItems: [SharedItem] = []
        var importedCount = 0
        var failedCount = 0
        var importedNotes: [Note] = []
        var importedTasks: [Task] = []

        for item in sharedItems {
            do {
                let payload = try buildSharedImportPayload(from: item.markedPending())
                importedNotes.append(contentsOf: payload.notes)
                importedTasks.append(contentsOf: payload.tasks)
                importedCount += 1
            } catch {
                failedCount += 1
                let reason = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                failedItems.append(item.markedFailed(reason: reason))
                NSLog("❌ [LocalStore] Failed to process shared item %@: %@", item.title, reason)
            }
        }

        let persistenceError = persistSharedItemsForBackground(failedItems, into: userDefaults)

        NSLog("✅ [LocalStore] Imported \(importedCount) shared item(s), failed \(failedCount)")
        if !failedItems.isEmpty {
            NSLog("⚠️ [LocalStore] Retained %d pending shared item(s) for retry", failedItems.count)
        } else {
            NSLog("🧹 [LocalStore] Cleared shared items from App Group")
        }

        userDefaults.synchronize()
        NSLog("========================================")

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.lastSharedImportProcessedAt = processedAt
            self.applySharedImports(notes: importedNotes, tasks: importedTasks)
            self.pendingSharedImportCount = failedItems.count
            self.lastSharedImportError = failedItems.first?.lastError ?? persistenceError
            self.finishSharedImportProcessing()
        }
    }

    private func persistSharedItemsForBackground(_ items: [SharedItem], into userDefaults: UserDefaults) -> String? {
        if items.isEmpty {
            userDefaults.removeObject(forKey: sharedItemsQueueKey)
            return nil
        }
        guard let encoded = try? JSONEncoder().encode(items) else {
            return "Unable to persist pending shared imports."
        }
        userDefaults.set(encoded, forKey: sharedItemsQueueKey)
        return nil
    }

    private func applySharedImports(notes importedNotes: [Note], tasks importedTasks: [Task]) {
        if !importedNotes.isEmpty {
            notes.append(contentsOf: importedNotes)
            saveNotes()
            if let backend, !suppressBackendWrites {
                _Concurrency.Task { try? await backend.upsert(notes: importedNotes) }
            }
        }

        if importedTasks.isEmpty {
            return
        }

        let baseOrderIndex = Int(Date().timeIntervalSince1970 * 1000)
        var preparedTasks: [Task] = []
        preparedTasks.reserveCapacity(importedTasks.count)

        for (offset, task) in importedTasks.enumerated() {
            var newTask = task
            if newTask.orderIndex == nil {
                newTask.orderIndex = baseOrderIndex + offset
            }
            if let parentId = newTask.parentTaskId {
                if let parent = tasks.first(where: { $0.id == parentId && $0.parentTaskId == nil }) {
                    if newTask.categories.isEmpty {
                        newTask.categories = parent.categories
                    }
                } else {
                    // Enforce one-level hierarchy and prevent orphaned parent references.
                    newTask.parentTaskId = nil
                }
            } else {
                newTask.parentManualReopenAt = nil
            }
            preparedTasks.append(newTask)
        }

        tasks.append(contentsOf: preparedTasks)
        saveTasks()

        for task in preparedTasks {
            logTaskCreatedAnalytics(for: task)
        }

        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(tasks: preparedTasks) }
        }
    }

    private func decodeSharedItems(from userDefaults: UserDefaults) -> [SharedItem] {
        guard let data = userDefaults.data(forKey: sharedItemsQueueKey),
              let decoded = try? JSONDecoder().decode([SharedItem].self, from: data) else {
            return []
        }
        return decoded
    }

    private func buildSharedImportPayload(from item: SharedItem) throws -> (notes: [Note], tasks: [Task]) {
        switch resolvedDestination(for: item) {
        case .note:
            let noteText = buildImportedNoteText(from: item)
            guard !noteText.isEmpty else {
                throw SharedImportProcessingError.emptyPayload
            }
            return ([Note(text: noteText)], [])
        case .task:
            let title = resolvedTaskTitle(for: item)
            guard !title.isEmpty else {
                throw SharedImportProcessingError.missingTaskTitle
            }
            let notes = buildImportedTaskNotes(from: item, overrideBody: nil)
            let task = Task(
                title: title,
                categories: item.categories,
                priority: item.priority,
                dueDate: item.dueDate,
                taskNotes: notes.isEmpty ? nil : notes,
                reminderDate: item.reminderDate
            )
            return ([], [task])
        case .taskBatch:
            let drafts = item.taskDrafts
                .map { draft in
                    var sanitized = draft
                    sanitized.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    return sanitized
                }
                .filter { !$0.title.isEmpty }
            guard !drafts.isEmpty else {
                throw SharedImportProcessingError.noTaskDrafts
            }
            var batchTasks: [Task] = []
            batchTasks.reserveCapacity(drafts.count)
            for draft in drafts {
                let notes = buildImportedTaskNotes(from: item, overrideBody: draft.notes)
                let task = Task(
                    title: draft.title,
                    categories: item.categories,
                    priority: item.priority,
                    dueDate: item.dueDate,
                    taskNotes: notes.isEmpty ? nil : notes,
                    reminderDate: item.reminderDate
                )
                batchTasks.append(task)
            }
            return ([], batchTasks)
        }
    }

    private func resolvedDestination(for item: SharedItem) -> SharedImportDestination {
        if item.taskDrafts.count > 1 {
            return .taskBatch
        }
        return item.destination
    }

    private func resolvedTaskTitle(for item: SharedItem) -> String {
        let trimmedTitle = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            return trimmedTitle
        }
        guard let text = item.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return ""
        }
        let fallbackWords = text
            .split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .prefix(6)
            .joined(separator: " ")
        return String(fallbackWords)
    }

    private func buildImportedTaskNotes(from item: SharedItem, overrideBody: String?) -> String {
        var sections: [String] = []
        if let url = item.url?.trimmingCharacters(in: .whitespacesAndNewlines), !url.isEmpty {
            sections.append(url)
        }
        let body = (overrideBody ?? item.text)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let body, !body.isEmpty {
            sections.append(body)
        }
        sections.append(sharedImportAttributionLine(for: item))
        if item.wasTruncated {
            sections.append("Import truncated to 10,000 characters.")
        }
        return sections.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func buildImportedNoteText(from item: SharedItem) -> String {
        var sections: [String] = []
        let trimmedTitle = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            sections.append("# \(trimmedTitle)")
        }
        if let text = item.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            sections.append(text)
        }
        if let url = item.url?.trimmingCharacters(in: .whitespacesAndNewlines), !url.isEmpty {
            sections.append(url)
        }
        sections.append(sharedImportAttributionLine(for: item))
        if item.wasTruncated {
            sections.append("Import truncated to 10,000 characters.")
        }
        return sections.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sharedImportAttributionLine(for item: SharedItem) -> String {
        let source = item.sourceApp?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sourceLabel = (source?.isEmpty == false) ? source! : "Share Sheet"
        return "Imported from \(sourceLabel) on \(sharedImportDateFormatter.string(from: item.importTimestamp))"
    }

    private var sharedImportDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    private enum SharedImportProcessingError: LocalizedError {
        case emptyPayload
        case missingTaskTitle
        case noTaskDrafts

        var errorDescription: String? {
            switch self {
            case .emptyPayload:
                return "Shared content was empty."
            case .missingTaskTitle:
                return "Unable to determine a task title."
            case .noTaskDrafts:
                return "No valid task items were found in the shared list."
            }
        }
    }
}
