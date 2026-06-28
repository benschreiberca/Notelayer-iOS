import Combine
import SwiftUI

// Minimal stub — WatchConnectivity wired up once the app builds successfully.
@MainActor
final class WatchConnector: NSObject, ObservableObject {
    static let shared = WatchConnector()
    @Published private(set) var tasks: [String] = []
    private override init() { super.init() }
}
