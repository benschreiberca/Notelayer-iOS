import SwiftUI
import EventKit
import EventKitUI

/// SwiftUI wrapper for EKEventEditViewController
/// Presents the native iOS calendar event editor
struct CalendarEventEditView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let event: EKEvent
    let eventStore: EKEventStore
    let onSaved: () -> Void
    let onCancelled: () -> Void
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        // EKEventEditViewController is already a UINavigationController subclass
        // Do NOT wrap it in another UINavigationController
        let eventEditController = EKEventEditViewController()
        eventEditController.event = event
        eventEditController.eventStore = eventStore
        eventEditController.editViewDelegate = context.coordinator
        
        return eventEditController
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSaved: onSaved, onCancelled: onCancelled)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        let onSaved: () -> Void
        let onCancelled: () -> Void
        
        init(onSaved: @escaping () -> Void, onCancelled: @escaping () -> Void) {
            self.onSaved = onSaved
            self.onCancelled = onCancelled
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            switch action {
            case .saved:
                onSaved()
            case .canceled, .deleted:
                onCancelled()
            @unknown default:
                onCancelled()
            }
        }
    }
}
