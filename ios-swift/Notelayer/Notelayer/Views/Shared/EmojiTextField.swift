import SwiftUI

#if os(iOS)
import UIKit

/// A custom UITextField subclass that defaults to the emoji keyboard
class UIEmojiTextFieldView: UITextField {
    override var textInputContextIdentifier: String? { "" }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" { return mode }
        }
        return super.textInputMode
    }
}

/// SwiftUI wrapper for UIEmojiTextFieldView
struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String

    func makeUIView(context: Context) -> UIEmojiTextFieldView {
        let textField = UIEmojiTextFieldView()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.returnKeyType = .done
        return textField
    }

    func updateUIView(_ uiView: UIEmojiTextFieldView, context: Context) {
        if uiView.text != text { uiView.text = text }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

#else

/// macOS: plain text field — the emoji keyboard doesn't exist on Mac;
/// users type emoji normally via the Character Viewer (Ctrl+Cmd+Space).
struct EmojiTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
    }
}

#endif
