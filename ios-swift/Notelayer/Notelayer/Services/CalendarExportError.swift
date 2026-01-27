import Foundation

enum CalendarExportError: LocalizedError {
    case permissionDenied
    case noCalendarAvailable
    case eventCreationFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Calendar access is required to export tasks. Please enable access in Settings."
        case .noCalendarAvailable:
            return "No calendars available. Please create a calendar in the Calendar app first."
        case .eventCreationFailed:
            return "Failed to create calendar event. Please try again."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Open Settings → Notelayer → Calendars and enable access."
        case .noCalendarAvailable:
            return "Open the Calendar app and create a new calendar."
        case .eventCreationFailed, .unknown:
            return "Please try again or contact support if the issue persists."
        }
    }
}
