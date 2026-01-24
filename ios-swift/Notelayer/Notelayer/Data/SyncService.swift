import Foundation

class SyncService {
    static let shared = SyncService()
    
    private init() {}
    
    func sync() {
        push()
        pull()
    }
    
    func push() {
        // Implementation pending
    }
    
    func pull() {
        // Implementation pending
    }
}
