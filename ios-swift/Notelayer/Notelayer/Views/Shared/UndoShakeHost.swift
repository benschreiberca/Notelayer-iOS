import SwiftUI
import UIKit

/// Keeps an active responder in the view tree so Shake to Undo can surface the system prompt.
struct UndoShakeHost: UIViewRepresentable {
    func makeUIView(context: Context) -> UndoResponderView {
        let view = UndoResponderView()
        return view
    }

    func updateUIView(_ uiView: UndoResponderView, context: Context) {
        uiView.refreshUndoManager()
    }
}

final class UndoResponderView: UIView {
    override var canBecomeFirstResponder: Bool { true }

    override var undoManager: UndoManager? {
        UndoCoordinator.shared.undoManager
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        UndoCoordinator.shared.attachResponder(self)
        refreshUndoManager()
    }

    func refreshUndoManager() {
        guard window != nil else { return }
        if !isFirstResponder {
            becomeFirstResponder()
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Allow touch events to pass through while keeping first responder.
        false
    }
}

final class UndoCoordinator {
    static let shared = UndoCoordinator()
    let undoManager = UndoManager()
    private weak var responder: UndoResponderView?

    func attachResponder(_ responder: UndoResponderView) {
        self.responder = responder
    }

    func activateResponder() {
        // Reassert the responder so shake routes to the same undo manager after deletes.
        DispatchQueue.main.async { [weak responder] in
            responder?.refreshUndoManager()
        }
    }
}
