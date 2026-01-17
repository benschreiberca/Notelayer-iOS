//
//  NoteEditorView.swift
//  Notelayer
//
//  Rich text note editor
//

import SwiftUI
import UIKit

struct NoteEditorView: View {
    @EnvironmentObject var appStore: AppStore
    @Environment(\.dismiss) var dismiss
    let noteId: String?
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var plainText: String = ""
    @State private var isNewNote: Bool = false
    @State private var currentNoteId: String? = nil
    
    private var note: Note? {
        guard let noteId = noteId else { return nil }
        return appStore.notes.first { $0.id == noteId }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Title input
                TextField("Title", text: $title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Divider()
                
                // Content editor
                NoteTextEditor(text: $content, plainText: $plainText)
                    .padding()
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        saveAndDismiss()
                    }
                }
            }
            .onAppear {
                if let note = note {
                    title = note.title
                    content = note.content
                    plainText = note.plainText
                    currentNoteId = note.id
                    isNewNote = false
                } else {
                    title = ""
                    content = ""
                    plainText = ""
                    currentNoteId = nil
                    isNewNote = true
                }
            }
        }
    }
    
    private func saveAndDismiss() {
        if isNewNote {
            if !title.trimmingCharacters(in: .whitespaces).isEmpty || !plainText.trimmingCharacters(in: .whitespaces).isEmpty {
                let finalTitle = title.trimmingCharacters(in: .whitespaces).isEmpty ? "Untitled Note" : title
                _ = appStore.addNote(title: finalTitle, content: content, plainText: plainText)
            }
        } else if let id = currentNoteId {
            appStore.updateNote(id: id, title: title, content: content, plainText: plainText)
        }
        dismiss()
    }
}

// Wrapper for UITextView to support rich text editing
struct NoteTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var plainText: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 16)
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Only update if text changed externally (not from user typing)
        if uiView.text != text {
            // Try to load HTML if available, otherwise use plain text
            if !text.isEmpty, let htmlData = text.data(using: .utf8),
               let attributedString = try? NSAttributedString(
                data: htmlData,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
               ) {
                uiView.attributedText = attributedString
            } else {
                uiView.text = text
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: NoteTextEditor
        
        init(_ parent: NoteTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.plainText = textView.text
            // For now, store as plain text (HTML conversion can be added later)
            parent.text = textView.text
        }
    }
}

extension NSAttributedString {
    func htmlData(from range: NSRange) -> Data? {
        let options: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return try? data(from: range, documentAttributes: options)
    }
}
