import Combine
import Foundation
import SwiftUI

/// Isolated observable for voice capture and staging state.
/// Separated from LocalStore so that the 14+ views observing LocalStore
/// are not invalidated by voice state changes.
final class VoiceStateStore: ObservableObject {
    static let shared = VoiceStateStore()

    /// True while VoiceCaptureSheet is actively recording.
    @Published var isRecording: Bool = false
    /// True while there are staged voice drafts awaiting review.
    @Published var isVoiceStagingPresented: Bool = false
    @Published var stagingDrafts: [VoiceParsedTaskDraft] = []
    @Published var sourceTranscript: String = ""

    private let userDefaults: UserDefaults
    private let draftsKey = "com.notelayer.app.voice.stagingDrafts"
    private let transcriptKey = "com.notelayer.app.voice.sourceTranscript"

    private static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "true" ||
        ProcessInfo.processInfo.arguments.contains("--screenshot-generation")
    }

    init() {
        let appGroup = Self.isScreenshotMode
            ? "group.com.notelayer.app.screenshots"
            : "group.com.notelayer.app"
        userDefaults = UserDefaults(suiteName: appGroup) ?? .standard
        load()
    }

    func load() {
        if let data = userDefaults.data(forKey: draftsKey),
           let decoded = try? JSONDecoder().decode([VoiceParsedTaskDraft].self, from: data) {
            stagingDrafts = decoded
        } else {
            stagingDrafts = []
        }
        sourceTranscript = userDefaults.string(forKey: transcriptKey) ?? ""
        isVoiceStagingPresented = !stagingDrafts.isEmpty
    }

    func stageVoiceDrafts(_ drafts: [VoiceParsedTaskDraft], transcript: String) {
        stagingDrafts = drafts
        sourceTranscript = transcript
        isVoiceStagingPresented = !drafts.isEmpty
        save()
    }

    func updateVoiceStagingDrafts(_ drafts: [VoiceParsedTaskDraft]) {
        stagingDrafts = drafts
        isVoiceStagingPresented = !drafts.isEmpty
        save()
    }

    func clearVoiceStaging() {
        stagingDrafts = []
        sourceTranscript = ""
        isVoiceStagingPresented = false
        save()
    }

    private func save() {
        if stagingDrafts.isEmpty {
            userDefaults.removeObject(forKey: draftsKey)
            userDefaults.removeObject(forKey: transcriptKey)
            return
        }
        if let data = try? JSONEncoder().encode(stagingDrafts) {
            userDefaults.set(data, forKey: draftsKey)
            userDefaults.set(sourceTranscript, forKey: transcriptKey)
        }
    }
}
