import SwiftUI
import UIKit

/// Keyboard helpers for dismissing the current first responder without blocking taps.
enum Keyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Dismiss only when a text input is currently first responder.
    /// This avoids redundant resign actions on every tap.
    static func dismissIfNeeded() {
        guard let responder = UIResponder.currentFirstResponder,
              responder is UITextField || responder is UITextView else {
            return
        }
        dismiss()
    }
}

private final class FirstResponderTracker {
    static weak var current: UIResponder?
}

private extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        FirstResponderTracker.current = nil
        UIApplication.shared.sendAction(#selector(trackFirstResponder), to: nil, from: nil, for: nil)
        return FirstResponderTracker.current
    }

    @objc func trackFirstResponder() {
        FirstResponderTracker.current = self
    }
}

/// Adds a non-blocking tap recognizer that dismisses the keyboard when tapping outside text inputs.
struct KeyboardDismissRecognizer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = KeyboardDismissView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No-op: gesture handling is managed by the underlying UIView.
    }
}

private final class KeyboardDismissView: UIView, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTap() {
        Keyboard.dismiss()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !isTouchInsideTextInput(touch.view)
    }

    private func isTouchInsideTextInput(_ view: UIView?) -> Bool {
        var current = view
        while let candidate = current {
            if candidate is UITextField || candidate is UITextView {
                return true
            }
            current = candidate.superview
        }
        return false
    }
}
