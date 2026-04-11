import Foundation
import WatchConnectivity
import Combine

/// iOS-side WatchConnectivity bridge.
/// Pushes task data to the Watch when requested and handles completion/add actions from the Watch.
final class WatchConnectivityService: NSObject, ObservableObject {
    static let shared = WatchConnectivityService()

    @Published var isWatchReachable = false

    private var cancellables = Set<AnyCancellable>()

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()

        // Push fresh tasks to Watch whenever LocalStore.tasks mutates
        LocalStore.shared.$tasks
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.pushTasksToWatch()
            }
            .store(in: &cancellables)
    }

    /// Encodes the current active tasks and pushes them to the Watch.
    func pushTasksToWatch() {
        guard WCSession.default.isReachable else { return }
        let store = LocalStore.shared
        let activeTasks = store.tasks.filter { $0.completedAt == nil }
        let watchTasks = activeTasks.map { task -> [String: Any] in
            var dict: [String: Any] = [
                "id": task.id,
                "title": task.title,
                "priority": task.priority.rawValue,
                "categories": task.categories,
                "createdAt": task.createdAt.timeIntervalSince1970
            ]
            if let due = task.dueDate { dict["dueDate"] = due.timeIntervalSince1970 }
            if let completed = task.completedAt { dict["completedAt"] = completed.timeIntervalSince1970 }
            return dict
        }
        guard let data = try? JSONSerialization.data(withJSONObject: watchTasks) else { return }
        WCSession.default.sendMessageData(data, replyHandler: nil)
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
        if activationState == .activated {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.pushTasksToWatch()
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
        if session.isReachable {
            pushTasksToWatch()
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let action = message["action"] as? String else { return }

        DispatchQueue.main.async {
            switch action {
            case "fetchTasks":
                self.pushTasksToWatch()

            case "complete":
                if let taskId = message["taskId"] as? String {
                    LocalStore.shared.completeTask(id: taskId)
                    // Push updated list back immediately
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.pushTasksToWatch()
                    }
                }

            case "addTask":
                if let title = message["title"] as? String {
                    let newTask = Task(title: title)
                    LocalStore.shared.addTask(newTask)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.pushTasksToWatch()
                    }
                }

            default:
                break
            }
        }
    }
}
