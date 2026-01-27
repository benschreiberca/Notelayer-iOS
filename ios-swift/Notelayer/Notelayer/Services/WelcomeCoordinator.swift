import Foundation
import Combine

/// Manages welcome page state - tracks if user has seen and dismissed the welcome screen.
@MainActor
final class WelcomeCoordinator: ObservableObject {
    static let shared = WelcomeCoordinator()
    
    private let appGroupIdentifier = "group.com.notelayer.app"
    private let hasSeenWelcomeKey = "com.notelayer.app.hasSeenWelcome"
    
    @Published private(set) var hasSeenWelcome: Bool = false
    
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    private init() {
        load()
    }
    
    /// Check if welcome should be shown (user not signed in AND hasn't dismissed welcome)
    func shouldShowWelcome(isSignedIn: Bool) -> Bool {
        return !isSignedIn && !hasSeenWelcome
    }
    
    /// Mark welcome as seen/dismissed permanently
    func markWelcomeAsSeen() {
        hasSeenWelcome = true
        save()
    }
    
    /// Reset welcome state (for testing/debugging)
    func resetWelcomeState() {
        hasSeenWelcome = false
        save()
    }
    
    private func load() {
        hasSeenWelcome = userDefaults.bool(forKey: hasSeenWelcomeKey)
    }
    
    private func save() {
        userDefaults.set(hasSeenWelcome, forKey: hasSeenWelcomeKey)
    }
}
