import SwiftUI
import UIKit

/// Wraps `UIActivityViewController`. On regular-width layouts (iPad, Mac
/// Catalyst) UIKit forces popover presentation and requires a non-nil
/// `sourceView`/`sourceRect` — without one it either silently no-ops or
/// crashes. We anchor the popover to the controller's own view (valid once
/// presented as a sheet) so Share always appears on every platform, Mac
/// included.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.sourceView = controller.view
            popover.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        if let popover = uiViewController.popoverPresentationController, popover.sourceView == nil {
            popover.sourceView = uiViewController.view
            popover.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }
}

struct SharePayload: Identifiable {
    let id = UUID()
    let items: [Any]
}
