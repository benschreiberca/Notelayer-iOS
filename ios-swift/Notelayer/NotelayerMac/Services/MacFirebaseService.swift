import Foundation
import Combine

/// Thin Firebase client for macOS using the REST APIs only — no SDK dependency.
/// Auth:      Identity Toolkit REST API (email/password sign-in)
/// Firestore: Cloud Firestore REST API
@MainActor
final class MacFirebaseService: ObservableObject {
    static let shared = MacFirebaseService()

    // MARK: - Firebase config (same project as iOS)
    private let apiKey = "AIzaSyABWHYGN9dr-m3a0qaUwYHlrJAhNd7PfvA"
    private let projectId = "notelayer-c7bba"
    private let firestoreBase: String

    // MARK: - Published state
    @Published var tasks: [MacTask] = []
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var idToken: String? {
        didSet { isAuthenticated = idToken != nil }
    }
    private var userId: String?

    private init() {
        firestoreBase = "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/(default)/documents"
        loadPersistedToken()
    }

    // MARK: - Auth

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": email, "password": password, "returnSecureToken": true] as [String: Any]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let token = json?["idToken"] as? String,
               let uid = json?["localId"] as? String {
                self.idToken = token
                self.userId = uid
                persistToken(token: token, userId: uid)
                await fetchTasks()
            } else if let error = json?["error"] as? [String: Any],
                      let message = error["message"] as? String {
                errorMessage = message.replacingOccurrences(of: "_", with: " ").capitalized
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        idToken = nil
        userId = nil
        tasks = []
        clearPersistedToken()
    }

    // MARK: - Firestore Operations

    func fetchTasks() async {
        guard let token = idToken, let uid = userId else { return }
        let url = URL(string: "\(firestoreBase)/tasks?pageSize=200")!
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let documents = json?["documents"] as? [[String: Any]] ?? []
            let parsed = documents.compactMap { doc -> MacTask? in
                MacTask(firestoreDocument: doc, userId: uid)
            }
            // Filter to current user's tasks, show active first
            tasks = parsed
                .filter { $0.userId == uid && $0.completedAt == nil }
                .sorted { ($0.priority.order, $0.createdAt) < ($1.priority.order, $1.createdAt) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addTask(title: String, priority: MacTaskPriority = .medium) async {
        guard let token = idToken, let uid = userId else { return }
        let url = URL(string: "\(firestoreBase)/tasks")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let now = Date()
        let body: [String: Any] = [
            "fields": [
                "title":      ["stringValue": title],
                "userId":     ["stringValue": uid],
                "priority":   ["stringValue": priority.rawValue],
                "createdAt":  ["timestampValue": ISO8601DateFormatter().string(from: now)],
                "updatedAt":  ["timestampValue": ISO8601DateFormatter().string(from: now)],
                "categories": ["arrayValue": ["values": []]],
                "orderIndex": ["integerValue": String(Int(now.timeIntervalSince1970 * 1000))]
            ]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            if let doc = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let task = MacTask(firestoreDocument: doc, userId: uid) {
                tasks.insert(task, at: 0)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeTask(id: String) async {
        guard let token = idToken else { return }
        // Optimistic update
        tasks.removeAll { $0.id == id }

        let url = URL(string: "\(firestoreBase)/tasks/\(id)?updateMask.fieldPaths=completedAt&updateMask.fieldPaths=updatedAt")!
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let now = ISO8601DateFormatter().string(from: Date())
        let body: [String: Any] = [
            "fields": [
                "completedAt": ["timestampValue": now],
                "updatedAt":   ["timestampValue": now]
            ]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await URLSession.shared.data(for: req)
    }

    // MARK: - Token Persistence

    private let tokenKey = "mac.firebase.idToken"
    private let userIdKey = "mac.firebase.userId"

    private func persistToken(token: String, userId: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    private func loadPersistedToken() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let uid = UserDefaults.standard.string(forKey: userIdKey) {
            self.idToken = token
            self.userId = uid
            Task { await fetchTasks() }
        }
    }

    private func clearPersistedToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}

// MARK: - Lightweight model for macOS (no Firebase SDK dependency)

enum MacTaskPriority: String, CaseIterable {
    case high, medium, low, deferred

    var label: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .deferred: return "Deferred"
        }
    }

    var order: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        case .deferred: return 3
        }
    }

    var systemImage: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        case .deferred: return "clock"
        }
    }

    var color: String {
        switch self {
        case .high: return "#E53E3E"
        case .medium: return "#DD6B20"
        case .low: return "#38A169"
        case .deferred: return "#718096"
        }
    }
}

struct MacTask: Identifiable {
    let id: String
    let title: String
    let userId: String
    let priority: MacTaskPriority
    let createdAt: Date
    let completedAt: Date?
    let categories: [String]

    /// Parse a Firestore REST document dictionary into a MacTask.
    init?(firestoreDocument doc: [String: Any], userId: String) {
        guard
            let name = doc["name"] as? String,
            let fields = doc["fields"] as? [String: Any],
            let titleField = fields["title"] as? [String: Any],
            let title = titleField["stringValue"] as? String,
            let userIdField = fields["userId"] as? [String: Any],
            let docUserId = userIdField["stringValue"] as? String,
            docUserId == userId
        else { return nil }

        self.id = String(name.split(separator: "/").last ?? "")
        self.title = title
        self.userId = docUserId

        let priorityStr = (fields["priority"] as? [String: Any])?["stringValue"] as? String ?? "medium"
        self.priority = MacTaskPriority(rawValue: priorityStr) ?? .medium

        let iso = ISO8601DateFormatter()
        if let ts = (fields["createdAt"] as? [String: Any])?["timestampValue"] as? String {
            self.createdAt = iso.date(from: ts) ?? Date()
        } else {
            self.createdAt = Date()
        }

        if let ts = (fields["completedAt"] as? [String: Any])?["timestampValue"] as? String {
            self.completedAt = iso.date(from: ts)
        } else {
            self.completedAt = nil
        }

        let catValues = ((fields["categories"] as? [String: Any])?["arrayValue"] as? [String: Any])?["values"] as? [[String: Any]] ?? []
        self.categories = catValues.compactMap { $0["stringValue"] as? String }
    }
}
