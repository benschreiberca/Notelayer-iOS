import Combine
import SwiftUI

struct VoiceCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @StateObject private var store = LocalStore.shared
    @StateObject private var controller = VoiceInputController()

    @State private var parseErrorMessage: String?
    @State private var wavePhase = false

    // Fixed per-bar tuning values — deterministic, no random per-redraw jitter
    private let barCount = 9
    private let barPhaseOffsets: [Double] = [0.0, 0.18, 0.08, 0.26, 0.04, 0.22, 0.12, 0.30, 0.06]
    private let barPeakFactors: [CGFloat] = [0.55, 0.90, 0.70, 1.00, 0.62, 0.85, 0.78, 0.95, 0.50]

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

                    // Animated waveform — visible only while recording
                    if controller.isRecording {
                        HStack(alignment: .center, spacing: 5) {
                            ForEach(0..<barCount, id: \.self) { i in
                                let peakH: CGFloat = 8 + (40 - 8) * barPeakFactors[i]
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(theme.tokens.accent)
                                    .frame(width: 4, height: wavePhase ? peakH : 6)
                                    .animation(
                                        .easeInOut(duration: 0.35 + barPhaseOffsets[i] * 1.4)
                                            .repeatForever(autoreverses: true)
                                            .delay(barPhaseOffsets[i]),
                                        value: wavePhase
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .onAppear {
                            // Kick off one tick so the repeating animation starts
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                wavePhase = true
                            }
                        }
                        .onDisappear {
                            wavePhase = false
                        }
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
        .onChange(of: controller.isRecording) { recording in
            store.isVoiceRecording = recording
        }
        .onDisappear {
            store.isVoiceRecording = false
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
