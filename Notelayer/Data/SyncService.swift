import Foundation

class SyncService {
    static let shared = SyncService()
    
    private init() {}
    
    func sync() {
        // Placeholder for sync functionality
        // TODO: Implement Supabase sync
        push()
        pull()
    }
    
    func push() {
        // Placeholder for push to server
        // TODO: Push local changes to Supabase
    }
    
    func pull() {
        // Placeholder for pull from server
        // TODO: Pull remote changes from Supabase
    }
}
