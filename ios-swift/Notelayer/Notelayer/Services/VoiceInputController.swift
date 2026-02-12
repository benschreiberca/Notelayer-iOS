import AVFoundation
import Combine
import Foundation
import Speech

@MainActor
final class VoiceInputController: NSObject, ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var permissionDeniedMessage: String?
    @Published var errorMessage: String?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestPermissionsIfNeeded() async -> Bool {
        let speechAuthorized = await requestSpeechAuthorization()
        let microphoneAuthorized = await requestMicrophoneAuthorization()

        if !speechAuthorized || !microphoneAuthorized {
            permissionDeniedMessage = "Microphone and speech recognition access are required for voice input."
            return false
        }

        permissionDeniedMessage = nil
        return true
    }

    func startRecording() async {
        errorMessage = nil

        let granted = await requestPermissionsIfNeeded()
        guard granted else { return }

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is currently unavailable."
            return
        }

        stopRecording()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            recognitionRequest = request

            let inputNode = audioEngine.inputNode
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            recognitionTask = speechRecognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                guard let self else { return }
                if let result {
                    _Concurrency.Task { @MainActor in
                        self.transcript = result.bestTranscription.formattedString
                    }
                }
                if error != nil {
                    _Concurrency.Task { @MainActor in
                        self.stopRecording()
                    }
                }
            })

            isRecording = true
        } catch {
            stopRecording()
            errorMessage = "Could not start voice recording."
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func reset() {
        stopRecording()
        transcript = ""
        errorMessage = nil
        permissionDeniedMessage = nil
    }

    private func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
