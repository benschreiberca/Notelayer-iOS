import SwiftUI

#if os(iOS)
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
        DispatchQueue.main.async { [weak responder] in
            responder?.refreshUndoManager()
        }
    }
}

#else

/// macOS stub — shake-to-undo is not available; renders nothing.
struct UndoShakeHost: View {
    var body: some View { EmptyView() }
}

/// macOS stub — provides a plain UndoManager for callers that reference it directly.
final class UndoCoordinator {
    static let shared = UndoCoordinator()
    let undoManager = UndoManager()
    func activateResponder() {}
}

#endif
