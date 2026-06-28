import Combine
import Foundation
import SwiftUI
import WatchConnectivity

/// Watch-side WatchConnectivity client. The iPhone owns all data; the watch
/// requests it and sends add/complete actions back.
@MainActor
final class WatchConnector: NSObject, ObservableObject {
    static let shared = WatchConnector()

    @Published private(set) var tasks: [WatchTaskDTO] = []
    @Published private(set) var isReachable = false
    @Published var lastError: String?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func refresh() {
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        if tasks.isEmpty { applyContext(session.receivedApplicationContext) }
        guard session.isReachable else { return }
        session.sendMessage(
            [WatchMessage.action: WatchMessage.fetchTasks],
            replyHandler: { [weak self] reply in
                Task { @MainActor [weak self] in self?.applyPayload(reply) }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor [weak self] in self?.lastError = error.localizedDescription }
            }
        )
    }

    func addTask(title: String) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        send(WatchMessage.addTask, payload: [WatchMessage.title: t])
    }

    func complete(_ task: WatchTaskDTO) {
        tasks.removeAll { $0.id == task.id }
        send(WatchMessage.completeTask, payload: [WatchMessage.id: task.id])
    }

    private func send(_ action: String, payload: [String: Any]) {
        var msg = payload
        msg[WatchMessage.action] = action
        let session = WCSession.default
        guard session.isReachable else { lastError = "iPhone not reachable"; return }
        session.sendMessage(
            msg,
            replyHandler: { [weak self] reply in
                Task { @MainActor [weak self] in self?.applyPayload(reply) }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor [weak self] in self?.lastError = error.localizedDescription }
            }
        )
    }

    private func applyPayload(_ payload: [String: Any]) {
        guard let raw = payload[WatchMessage.tasks] as? [[String: Any]] else { return }
        tasks = raw.compactMap(WatchTaskDTO.init(dictionary:))
        lastError = nil
    }

    private func applyContext(_ context: [String: Any]) { applyPayload(context) }
}

extension WatchConnector: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.isReachable = session.isReachable
            self.refresh()
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isReachable = session.isReachable
            if session.isReachable { self.refresh() }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        Task { @MainActor in self.applyContext(context) }
    }
}
