import SwiftUI
import UIKit

/// A custom UITextField subclass that defaults to the emoji keyboard
class UIEmojiTextFieldView: UITextField {
    
    /// Required to allow the emoji keyboard override
    override var textInputContextIdentifier: String? { "" }
    
    /// Override to force emoji keyboard as default
    override var textInputMode: UITextInputMode? {
        // Iterate through available input modes and find emoji keyboard
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
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
        textField.font = UIFont.systemFont(ofSize: 17) // Match SwiftUI TextField default
        
        // Allow switching to other keyboards
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
        // Ensure keyboard can be dismissed
        textField.returnKeyType = .done
        
        return textField
    }
    
    func updateUIView(_ uiView: UIEmojiTextFieldView, context: Context) {
        // Update text if changed externally
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    /// Coordinator to handle TextField delegate callbacks
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            // Update binding when text changes
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Dismiss keyboard when return/done is pressed
            textField.resignFirstResponder()
            return true
        }
    }
}
