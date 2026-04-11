import Foundation
import SwiftUI
import WatchConnectivity
import Combine

/// Local task cache + WCSession bridge for the Watch app.
/// The phone holds Firebase auth and is the authoritative writer.
/// Watch sends action messages; phone executes them against Firestore.
@MainActor
final class WatchStore: NSObject, ObservableObject {
    static let shared = WatchStore()

    @Published var tasks: [WatchTask] = []
    @Published var isPhoneReachable = false
    @Published var pendingActions: [WatchPendingAction] = []

    private let tasksKey = "com.notelayer.watch.cachedTasks"
    private let pendingKey = "com.notelayer.watch.pendingActions"

    private override init() {
        super.init()
        loadFromCache()
        activate()
    }

    // MARK: - WCSession

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func requestRefresh() {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["action": "fetchTasks"], replyHandler: nil)
    }

    // MARK: - Actions

    func completeTask(id: String) {
        // Optimistic: remove from local list immediately
        tasks.removeAll { $0.id == id }
        persistTasks()

        let action = WatchPendingAction(type: .complete, taskId: id)
        if WCSession.default.isReachable {
            sendAction(action)
        } else {
            pendingActions.append(action)
            persistPending()
        }
    }

    func quickAddTask(title: String) {
        let action = WatchPendingAction(type: .addTask, taskId: UUID().uuidString, title: title)
        if WCSession.default.isReachable {
            sendAction(action)
        } else {
            pendingActions.append(action)
            persistPending()
        }
    }

    private func sendAction(_ action: WatchPendingAction) {
        var message: [String: Any] = ["action": action.type.rawValue, "taskId": action.taskId]
        if let title = action.title { message["title"] = title }
        WCSession.default.sendMessage(message, replyHandler: nil)
    }

    func flushPendingActions() {
        guard WCSession.default.isReachable else { return }
        for action in pendingActions {
            sendAction(action)
        }
        pendingActions.removeAll()
        persistPending()
    }

    // MARK: - Persistence

    private func loadFromCache() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([WatchTask].self, from: data) {
            tasks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: pendingKey),
           let decoded = try? JSONDecoder().decode([WatchPendingAction].self, from: data) {
            pendingActions = decoded
        }
    }

    private func persistTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }

    private func persistPending() {
        if let data = try? JSONEncoder().encode(pendingActions) {
            UserDefaults.standard.set(data, forKey: pendingKey)
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchStore: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.isPhoneReachable = session.isReachable
            if activationState == .activated {
                self.flushPendingActions()
                self.requestRefresh()
            }
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isPhoneReachable = session.isReachable
            if session.isReachable {
                self.flushPendingActions()
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let decoded = try? JSONDecoder().decode([WatchTask].self, from: messageData) else { return }
        Task { @MainActor in
            self.tasks = decoded.filter { $0.completedAt == nil }
                .sorted { ($0.priority.order, $0.createdAt) < ($1.priority.order, $1.createdAt) }
            self.persistTasks()
        }
    }
}

// MARK: - Models

struct WatchTask: Identifiable, Codable {
    let id: String
    var title: String
    var priority: WatchPriority
    var createdAt: Date
    var completedAt: Date?
    var categories: [String]
    var dueDate: Date?
}

enum WatchPriority: String, Codable {
    case high, medium, low, deferred

    var order: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .deferred: return 3
        }
    }

    var color: Color {
        switch self {
        case .high:     return .red
        case .medium:   return .orange
        case .low:      return .green
        case .deferred: return .gray
        }
    }
}

struct WatchPendingAction: Codable, Identifiable {
    let id: String
    let type: ActionType
    let taskId: String
    var title: String?

    init(type: ActionType, taskId: String, title: String? = nil) {
        self.id = UUID().uuidString
        self.type = type
        self.taskId = taskId
        self.title = title
    }

    enum ActionType: String, Codable {
        case complete
        case addTask
    }
}
