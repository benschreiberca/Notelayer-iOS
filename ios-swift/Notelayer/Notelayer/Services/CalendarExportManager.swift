import Foundation
import EventKit

@MainActor
class CalendarExportManager {
    static let shared = CalendarExportManager()
    
    private let eventStore = EKEventStore()
    
    private init() {}
    
    /// Request calendar access permission
    func requestCalendarAccess() async -> Bool {
        do {
            return try await eventStore.requestAccess(to: .event)
        } catch {
            print("Calendar permission request failed: \(error)")
            return false
        }
    }
    
    /// Check if we currently have calendar access
    var hasCalendarAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    /// Prepare a calendar event from a task (doesn't save it)
    /// - Parameters:
    ///   - task: The task to convert to an event
    ///   - categories: All available categories for lookup
    /// - Returns: A configured EKEvent ready to be presented in EKEventEditViewController
    /// - Throws: CalendarExportError if preparation fails
    func prepareEvent(for task: Task, categories: [Category]) async throws -> EKEvent {
        // Verify permission
        guard hasCalendarAccess else {
            throw CalendarExportError.permissionDenied
        }
        
        // Get default calendar
        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarExportError.noCalendarAvailable
        }
        
        // Create event
        let event = EKEvent(eventStore: eventStore)
        
        // Set title
        event.title = task.title
        
        // Set dates
        let startDate = task.dueDate ?? Date()
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(15 * 60) // +15 minutes
        
        // Set calendar
        event.calendar = calendar
        
        // Build and set notes (includes priority in notes since EKEvent doesn't support priority)
        event.notes = buildEventNotes(task, categories)
        
        return event
    }
    
    /// Expose the event store for use with EKEventEditViewController
    var eventStoreForUI: EKEventStore {
        return eventStore
    }
    
    // MARK: - Private Helpers
    
    /// Format categories for display
    private func formatCategories(_ task: Task, _ categories: [Category]) -> String {
        let taskCategories = categories.filter { task.categories.contains($0.id) }
        let formatted = taskCategories
            .map { "\($0.icon) \($0.name)" }
            .joined(separator: ", ")
        return formatted.isEmpty ? "None" : formatted
    }
    
    /// Build complete event notes including task notes, categories, and priority
    private func buildEventNotes(_ task: Task, _ categories: [Category]) -> String {
        var notes = ""
        
        // Task notes (if present)
        if let taskNotes = task.taskNotes, !taskNotes.isEmpty {
            notes += taskNotes + "\n\n"
        }
        
        // Categories
        notes += "Categories: \(formatCategories(task, categories))\n"
        
        // Priority
        notes += "Priority: \(task.priority.label)\n"
        
        // Source attribution
        notes += "\nSource: Notelayer"
        
        return notes
    }
}
