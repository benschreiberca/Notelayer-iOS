import Combine
import Foundation
import SwiftUI
import WatchConnectivity

/// Watch-side WatchConnectivity client. Talks to the paired iPhone, which owns
/// the data. Reads come from `applicationContext` (pushed live by the phone) and
/// from explicit `fetchTasks` requests; writes (add/complete) are sent as
/// messages and optimistically reflected locally.
@MainActor
final class WatchConnector: NSObject, ObservableObject {
    static let shared = WatchConnector()

    @Published private(set) var tasks: [WatchTaskDTO] = []
    @Published private(set) var isReachable = false
    @Published var lastError: String?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Reads

    func refresh() {
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        // Use cached context immediately if we have nothing yet.
        if tasks.isEmpty { applyContext(session.receivedApplicationContext) }

        guard session.isReachable else { return }
        session.sendMessage(
            [WatchMessage.action: WatchMessage.fetchTasks],
            replyHandler: { [weak self] reply in
                Concurrency.main { self?.applyTasksPayload(reply) }
            },
            errorHandler: { [weak self] error in
                Concurrency.main { self?.lastError = error.localizedDescription }
            }
        )
    }

    // MARK: - Writes

    func addTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        sendAction(WatchMessage.addTask, payload: [WatchMessage.title: trimmed])
    }

    func complete(_ task: WatchTaskDTO) {
        // Optimistic removal for snappy UI; the reply will reconcile.
        tasks.removeAll { $0.id == task.id }
        sendAction(WatchMessage.completeTask, payload: [WatchMessage.id: task.id])
    }

    private func sendAction(_ action: String, payload: [String: Any]) {
        let session = WCSession.default
        var message = payload
        message[WatchMessage.action] = action
        guard session.isReachable else {
            lastError = "iPhone not reachable"
            return
        }
        session.sendMessage(
            message,
            replyHandler: { [weak self] reply in
                Concurrency.main { self?.applyTasksPayload(reply) }
            },
            errorHandler: { [weak self] error in
                Concurrency.main { self?.lastError = error.localizedDescription }
            }
        )
    }

    // MARK: - Payload handling

    private func applyTasksPayload(_ payload: [String: Any]) {
        guard let raw = payload[WatchMessage.tasks] as? [[String: Any]] else { return }
        tasks = raw.compactMap(WatchTaskDTO.init(dictionary:))
        lastError = nil
    }

    private func applyContext(_ context: [String: Any]) {
        applyTasksPayload(context)
    }
}

extension WatchConnector: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Concurrency.main {
            self.isReachable = session.isReachable
            self.refresh()
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Concurrency.main {
            self.isReachable = session.isReachable
            if session.isReachable { self.refresh() }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Concurrency.main { self.applyContext(applicationContext) }
    }
}

/// Tiny helper to hop to the main actor from nonisolated delegate callbacks.
private enum Concurrency {
    static func main(_ work: @escaping () -> Void) {
        Task { @MainActor in work() }
    }
}
