import Combine
import SwiftUI

struct VoiceCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = LocalStore.shared
    @StateObject private var controller = VoiceInputController()

    @State private var parseErrorMessage: String?

    private var canParse: Bool {
        !controller.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            SwiftUI.Form {
                Section("Capture") {
                    if let permissionDeniedMessage = controller.permissionDeniedMessage {
                        Text(permissionDeniedMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if let errorMessage = controller.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button {
                        if controller.isRecording {
                            controller.stopRecording()
                        } else {
                            _Concurrency.Task {
                                await controller.startRecording()
                            }
                        }
                    } label: {
                        Label(controller.isRecording ? "Stop Recording" : "Start Recording", systemImage: controller.isRecording ? "stop.circle" : "mic.circle")
                    }
                }

                Section("Transcript") {
                    TextEditor(text: $controller.transcript)
                        .frame(minHeight: 180)
                        .textInputAutocapitalization(.sentences)
                }

                if let parseErrorMessage {
                    Section {
                        Text(parseErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Voice Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        controller.reset()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Parse") {
                        parseTranscript()
                    }
                    .disabled(!canParse)
                }
            }
        }
        .onDisappear {
            controller.stopRecording()
        }
    }

    private func parseTranscript() {
        let transcript = controller.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        let drafts = VoiceTaskParser.parse(transcript: transcript, existingCategories: store.sortedCategories)

        guard !drafts.isEmpty else {
            parseErrorMessage = "Could not parse tasks from this voice input. Try speaking in shorter task phrases."
            return
        }

        parseErrorMessage = nil
        store.stageVoiceDrafts(drafts, transcript: transcript)
        dismiss()
    }
}
