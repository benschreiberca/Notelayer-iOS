import Combine
import Foundation
import WatchConnectivity

/// Phone-side WatchConnectivity bridge. The iPhone is the source of truth; the
/// watch asks for tasks and sends add/complete actions back here, which are
/// applied to `LocalStore` (and therefore synced to Firestore like any edit).
///
/// Lives only in the iOS target. Activate once at launch via `activate()`.
final class WatchSessionProvider: NSObject {
    static let shared = WatchSessionProvider()

    private let store = LocalStore.shared
    private var cancellable: AnyCancellable?

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()

        // Push fresh task snapshots to the watch whenever the list changes.
        cancellable = store.$tasks
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.pushContext()
            }
    }

    // MARK: - Snapshot

    /// Open, top-level tasks the watch should show, due/overdue first, capped.
    private func currentWatchTasks() -> [WatchTaskDTO] {
        let calendar = Calendar.current
        let endOfToday = calendar.date(
            bySettingHour: 23, minute: 59, second: 59, of: Date()
        ) ?? Date()

        let open = store.tasks.filter { $0.completedAt == nil && $0.parentTaskId == nil }
        let sorted = open.sorted { lhs, rhs in
            // Tasks with a due date that is today/overdue sort first, by date.
            let l = lhs.dueDate.map { $0 <= endOfToday } ?? false
            let r = rhs.dueDate.map { $0 <= endOfToday } ?? false
            if l != r { return l }
            switch (lhs.dueDate, rhs.dueDate) {
            case let (ld?, rd?): return ld < rd
            case (_?, nil): return true
            case (nil, _?): return false
            default: return lhs.createdAt > rhs.createdAt
            }
        }
        return sorted.prefix(50).map {
            WatchTaskDTO(
                id: $0.id,
                title: $0.title,
                priority: $0.priority.rawValue,
                dueDate: $0.dueDate,
                isCompleted: false
            )
        }
    }

    private func pushContext() {
        guard WCSession.default.activationState == .activated else { return }
        let payload = [WatchMessage.tasks: currentWatchTasks().map { $0.toDictionary() }]
        try? WCSession.default.updateApplicationContext(payload)
    }

    // MARK: - Action handling

    private func handle(message: [String: Any], reply: @escaping ([String: Any]) -> Void) {
        let action = message[WatchMessage.action] as? String
        switch action {
        case WatchMessage.fetchTasks:
            reply([WatchMessage.tasks: currentWatchTasks().map { $0.toDictionary() }])

        case WatchMessage.addTask:
            let title = (message[WatchMessage.title] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !title.isEmpty else { reply([WatchMessage.ok: false]); return }
            _ = store.addTask(Task(title: title))
            reply([WatchMessage.ok: true, WatchMessage.tasks: currentWatchTasks().map { $0.toDictionary() }])

        case WatchMessage.completeTask:
            guard let id = message[WatchMessage.id] as? String else {
                reply([WatchMessage.ok: false]); return
            }
            store.completeTask(id: id)
            reply([WatchMessage.ok: true, WatchMessage.tasks: currentWatchTasks().map { $0.toDictionary() }])

        default:
            reply([WatchMessage.ok: false])
        }
    }
}

extension WatchSessionProvider: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        if state == .activated { DispatchQueue.main.async { [weak self] in self?.pushContext() } }
    }

    // Required no-ops on iOS so the session can re-activate for a new watch.
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.handle(message: message, reply: replyHandler)
        }
    }
}
