import UIKit
import SwiftUI
import UniformTypeIdentifiers
import Combine

/// Share Extension view controller
/// Handles content shared from other apps (URLs, plain text) and saves to Notelayer
class ShareViewController: UIViewController {
    
    // MARK: - Properties
    
    private typealias PreparedShareText = (
        text: String,
        title: String,
        destination: SharedImportDestination,
        taskDrafts: [SharedTaskDraft],
        warnings: [String],
        wasTruncated: Bool,
        preparationDurationMs: Int
    )

    private let maxShareCharacters = 10_000
    private var hostingController: UIHostingController<ShareExtensionView>?
    private var contentModel: ShareContentModel?
    
    /// Content extracted from the share extension context
    struct ExtractedContent {
        let title: String
        let url: String?
        let text: String?
        let sourceApp: String?
        let destination: SharedImportDestination
        let taskDrafts: [SharedTaskDraft]
        let warnings: [String]
        let importTimestamp: Date
        let wasTruncated: Bool
        let preparationDurationMs: Int?
    }
    
    /// Observable model for sharing content between UIKit and SwiftUI
    class ShareContentModel: ObservableObject {
        @Published var title: String
        @Published var destination: SharedImportDestination
        @Published var taskDrafts: [SharedTaskDraft]
        let url: String?
        let text: String?
        let sourceApp: String?
        let warnings: [String]
        let importTimestamp: Date
        let wasTruncated: Bool
        let preparationDurationMs: Int?
        
        init(content: ExtractedContent) {
            self.title = content.title
            self.destination = content.destination
            self.taskDrafts = content.taskDrafts
            self.url = content.url
            self.text = content.text
            self.sourceApp = content.sourceApp
            self.warnings = content.warnings
            self.importTimestamp = content.importTimestamp
            self.wasTruncated = content.wasTruncated
            self.preparationDurationMs = content.preparationDurationMs
        }

        var destinationLabel: String {
            switch destination {
            case .task:
                return "Task"
            case .note:
                return "Note"
            case .taskBatch:
                return "Task List"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        NSLog("========================================")
        NSLog("📤 [ShareViewController] viewDidLoad() START")
        NSLog("========================================")
        
        extractSharedContent()
    }
    
    // MARK: - Content Extraction
    
    /// Extract content from the extension context
    private func extractSharedContent() {
        NSLog("🔍 [ShareViewController] extractSharedContent() START")
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            NSLog("❌ [ShareViewController] No extension items found")
            cancelShare()
            return
        }
        
        NSLog("✅ [ShareViewController] Found extension item provider")
        
        // Try URL first
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            NSLog("📎 [ShareViewController] Content type: URL")
            extractURL(from: itemProvider)
        }
        // Then try plain text
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            NSLog("📎 [ShareViewController] Content type: Plain Text")
            extractText(from: itemProvider)
        }
        else {
            NSLog("❌ [ShareViewController] Unsupported content type")
            showError("Unsupported content type")
        }
    }
    
    /// Extract URL from item provider
    private func extractURL(from itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
            if let error = error {
                #if DEBUG
                print("❌ [ShareViewController] Error loading URL: \(error)")
                #endif
                DispatchQueue.main.async {
                    self?.showError("Failed to load URL")
                }
                return
            }
            
            guard let url = item as? URL else {
                #if DEBUG
                print("❌ [ShareViewController] Item is not a URL")
                #endif
                DispatchQueue.main.async {
                    self?.showError("Invalid URL")
                }
                return
            }
            
            #if DEBUG
            print("✅ [ShareViewController] Extracted URL: \(url.absoluteString)")
            #endif
            
            // Show UI immediately with URL as title, then fetch page title in background
            DispatchQueue.main.async {
                let sourceApp = self?.getSourceAppName() ?? "Safari"
                let now = Date()
                let content = ExtractedContent(
                    title: url.absoluteString,
                    url: url.absoluteString,
                    text: nil,
                    sourceApp: sourceApp,
                    destination: .task,
                    taskDrafts: [],
                    warnings: [],
                    importTimestamp: now,
                    wasTruncated: false,
                    preparationDurationMs: 0
                )
                let model = ShareContentModel(content: content)
                self?.contentModel = model
                self?.showUI()
                
                // Fetch page title in background and update the model
                self?.fetchPageTitle(for: url) { title in
                    if let title = title {
                        DispatchQueue.main.async {
                            model.title = title
                            #if DEBUG
                            print("📝 [ShareViewController] Updated title to: \(title)")
                            #endif
                        }
                    }
                }
            }
        }
    }
    
    /// Extract plain text from item provider
    private func extractText(from itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (item, error) in
            if let error = error {
                #if DEBUG
                print("❌ [ShareViewController] Error loading text: \(error)")
                #endif
                DispatchQueue.main.async {
                    self?.showError("Failed to load text")
                }
                return
            }
            
            guard let text = item as? String else {
                #if DEBUG
                print("❌ [ShareViewController] Item is not a string")
                #endif
                DispatchQueue.main.async {
                    self?.showError("Invalid text")
                }
                return
            }
            
            #if DEBUG
            print("✅ [ShareViewController] Extracted text: \(text.prefix(50))...")
            #endif
            
            DispatchQueue.main.async {
                let sourceApp = self?.getSourceAppName() ?? "Unknown"
                let prepared = self?.prepareSharedText(text) ?? self?.fallbackPreparedText(text) ?? (
                    text: text,
                    title: self?.generateTitleFromText(text) ?? text,
                    destination: SharedImportDestination.note,
                    taskDrafts: [],
                    warnings: [],
                    wasTruncated: false,
                    preparationDurationMs: 0
                )
                let content = ExtractedContent(
                    title: prepared.title,
                    url: nil,
                    text: prepared.text,
                    sourceApp: sourceApp,
                    destination: prepared.destination,
                    taskDrafts: prepared.taskDrafts,
                    warnings: prepared.warnings,
                    importTimestamp: Date(),
                    wasTruncated: prepared.wasTruncated,
                    preparationDurationMs: prepared.preparationDurationMs
                )
                self?.contentModel = ShareContentModel(content: content)
                self?.showUI()
            }
        }
    }
    
    // MARK: - URL Metadata
    
    /// Fetch webpage title from URL
    private func fetchPageTitle(for url: URL, completion: @escaping (String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                #if DEBUG
                print("⚠️ [ShareViewController] Failed to fetch page title")
                #endif
                completion(nil)
                return
            }
            
            // Extract <title> tag using regex
            if let titleRange = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
                let title = String(html[titleRange])
                    .replacingOccurrences(of: "<title>", with: "")
                    .replacingOccurrences(of: "</title>", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                #if DEBUG
                print("✅ [ShareViewController] Fetched page title: \(title)")
                #endif
                
                completion(title)
            } else {
                #if DEBUG
                print("⚠️ [ShareViewController] No <title> tag found")
                #endif
                completion(nil)
            }
        }
        task.resume()
    }
    
    /// Generate a title from plain text (first sentence or 50 chars)
    private func generateTitleFromText(_ text: String) -> String {
        let firstLine = text.components(separatedBy: .newlines).first ?? text
        return String(firstLine.prefix(50))
    }

    private func fallbackPreparedText(_ text: String) -> PreparedShareText {
        (
            text: text,
            title: generateTitleFromText(text),
            destination: .note,
            taskDrafts: [],
            warnings: [],
            wasTruncated: false,
            preparationDurationMs: 0
        )
    }

    private func prepareSharedText(_ rawText: String) -> PreparedShareText {
        let start = Date()
        let normalizedNewlines = rawText.replacingOccurrences(of: "\r\n", with: "\n")
        var warnings: [String] = []
        var workingText = normalizedNewlines
        var wasTruncated = false

        if workingText.count > maxShareCharacters {
            workingText = String(workingText.prefix(maxShareCharacters))
            wasTruncated = true
            warnings.append("Long share text was truncated to 10,000 characters.")
        }

        let normalizedText = normalizeMarkdownForImport(workingText)
        let drafts = parseTaskDrafts(from: normalizedText)
        let destination = inferredDestination(from: normalizedText, drafts: drafts)
        let title = inferredTitle(from: normalizedText, destination: destination, drafts: drafts)
        let durationMs = Int(Date().timeIntervalSince(start) * 1000.0)
        if durationMs > 2000 {
            NSLog("⚠️ [ShareViewController] Share preparation exceeded 2s: %dms", durationMs)
        }

        return (
            text: normalizedText,
            title: title,
            destination: destination,
            taskDrafts: drafts,
            warnings: warnings,
            wasTruncated: wasTruncated,
            preparationDurationMs: durationMs
        )
    }

    private func normalizeMarkdownForImport(_ text: String) -> String {
        var normalized = text
        normalized = normalized.replacingOccurrences(of: "```", with: "")
        normalized = normalized.replacingOccurrences(of: "`", with: "")

        // Convert markdown links into readable plain text.
        let linkPattern = #"\[([^\]]+)\]\(([^)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: linkPattern) {
            let range = NSRange(normalized.startIndex..., in: normalized)
            normalized = regex.stringByReplacingMatches(
                in: normalized,
                options: [],
                range: range,
                withTemplate: "$1 ($2)"
            )
        }

        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseTaskDrafts(from text: String) -> [SharedTaskDraft] {
        let lines = text.components(separatedBy: .newlines)
        var drafts: [SharedTaskDraft] = []

        let numberedRegex = try? NSRegularExpression(pattern: #"^\s*\d+[.)]\s+(.+)$"#)
        let bulletRegex = try? NSRegularExpression(pattern: #"^\s*[-*+]\s+(.+)$"#)
        let checklistRegex = try? NSRegularExpression(pattern: #"^\s*[-*+]\s+\[(x|X| )\]\s+(.+)$"#)

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            let nsRange = NSRange(line.startIndex..., in: line)

            if let checklistRegex,
               let match = checklistRegex.firstMatch(in: line, options: [], range: nsRange),
               match.numberOfRanges >= 3,
               let titleRange = Range(match.range(at: 2), in: line) {
                let title = line[titleRange].trimmingCharacters(in: .whitespacesAndNewlines)
                if !title.isEmpty {
                    drafts.append(SharedTaskDraft(title: title, notes: nil, isChecklistItem: true))
                }
                continue
            }

            if let numberedRegex,
               let match = numberedRegex.firstMatch(in: line, options: [], range: nsRange),
               match.numberOfRanges >= 2,
               let titleRange = Range(match.range(at: 1), in: line) {
                let title = line[titleRange].trimmingCharacters(in: .whitespacesAndNewlines)
                if !title.isEmpty {
                    drafts.append(SharedTaskDraft(title: title))
                }
                continue
            }

            if let bulletRegex,
               let match = bulletRegex.firstMatch(in: line, options: [], range: nsRange),
               match.numberOfRanges >= 2,
               let titleRange = Range(match.range(at: 1), in: line) {
                let title = line[titleRange].trimmingCharacters(in: .whitespacesAndNewlines)
                if !title.isEmpty {
                    drafts.append(SharedTaskDraft(title: title))
                }
            }
        }

        return drafts
    }

    private func inferredDestination(from text: String, drafts: [SharedTaskDraft]) -> SharedImportDestination {
        if drafts.count > 1 {
            return .taskBatch
        }
        if drafts.count == 1 {
            return .task
        }
        // Ambiguous prose defaults to note.
        return .note
    }

    private func inferredTitle(from text: String, destination: SharedImportDestination, drafts: [SharedTaskDraft]) -> String {
        switch destination {
        case .taskBatch:
            return "Imported task list"
        case .task:
            if let first = drafts.first?.title, !first.isEmpty {
                return first
            }
            return generateTitleFromText(text)
        case .note:
            let headingLine = text
                .components(separatedBy: .newlines)
                .first(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("#") })
            let firstHeading = headingLine?
                .replacingOccurrences(of: "#", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let firstHeading, !firstHeading.isEmpty {
                return firstHeading
            }
            return generateTitleFromText(text)
        }
    }
    
    /// Get source app name from extension context (best effort)
    private func getSourceAppName() -> String? {
        // Try to extract source app name from extension context
        // This is not always available, so it's best-effort
        return extensionContext?.inputItems.first
            .flatMap { ($0 as? NSExtensionItem)?.userInfo?["NSExtensionItemSourceApplicationKey"] as? String }
    }
    
    // MARK: - UI
    
    /// Show the SwiftUI interface for editing and saving
    private func showUI() {
        NSLog("🎨 [ShareViewController] showUI() START")
        
        guard let model = contentModel else {
            NSLog("❌ [ShareViewController] contentModel is nil!")
            return
        }
        
        NSLog("✅ [ShareViewController] Creating SwiftUI view with title: %@", model.title)
        
        let swiftUIView = ShareExtensionView(
            contentModel: model,
            onSave: { [weak self] title, url, notes, categories, priority, dueDate, reminderDate in
                NSLog("💾 [ShareViewController] Save tapped - title: %@, categories: %d, priority: %@",
                      title, categories.count, priority.label)
                self?.saveTask(
                    title: title,
                    model: model,
                    url: url,
                    notes: notes,
                    categories: categories,
                    priority: priority,
                    dueDate: dueDate,
                    reminderDate: reminderDate
                )
            },
            onCancel: { [weak self] in
                NSLog("❌ [ShareViewController] Cancel button tapped")
                self?.cancelShare()
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .systemBackground
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        self.hostingController = hostingController
        
        NSLog("✅ [ShareViewController] SwiftUI view added to hierarchy")
    }
    
    /// Show error alert
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.cancelShare()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Save
    
    /// Save share import payload into App Group queue with pending status.
    private func saveTask(
        title: String,
        model: ShareContentModel,
        url: String?,
        notes: String?,
        categories: [String],
        priority: Priority,
        dueDate: Date?,
        reminderDate: Date?
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            showError("Please enter a title")
            return
        }

        let trimmedNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = url?.trimmingCharacters(in: .whitespacesAndNewlines)
        let drafts: [SharedTaskDraft] = model.taskDrafts.map { draft in
            var updated = draft
            if let trimmedNotes, !trimmedNotes.isEmpty, (updated.notes ?? "").isEmpty {
                updated.notes = trimmedNotes
            }
            return updated
        }

        let sharedItem = SharedItem(
            title: trimmedTitle,
            url: trimmedURL?.isEmpty == true ? nil : trimmedURL,
            text: trimmedNotes?.isEmpty == true ? nil : trimmedNotes,
            sourceApp: model.sourceApp,
            categories: categories,
            priority: priority,
            dueDate: dueDate,
            reminderDate: reminderDate,
            destination: model.destination,
            taskDrafts: drafts,
            status: .pending,
            importTimestamp: model.importTimestamp,
            wasTruncated: model.wasTruncated,
            preparationDurationMs: model.preparationDurationMs
        )

        NSLog("========================================")
        NSLog("💾 [ShareViewController] Saving shared item: %@", trimmedTitle)
        NSLog("========================================")

        // Save to App Group UserDefaults
        guard let userDefaults = UserDefaults(suiteName: "group.com.notelayer.app") else {
            NSLog("❌ [ShareViewController] Failed to access App Group")
            showError("Unable to access shared storage. Try again.")
            return
        }

        // Get existing items
        var items: [SharedItem] = []
        if let data = userDefaults.data(forKey: "com.notelayer.app.sharedItems"),
           let decoded = try? JSONDecoder().decode([SharedItem].self, from: data) {
            items = decoded
        }

        // Add new pending import item
        items.append(sharedItem)

        // Save back
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: "com.notelayer.app.sharedItems")
            userDefaults.synchronize()

            NSLog("✅ [ShareViewController] Saved successfully")
            NSLog("   Total items in storage: %d", items.count)
            NSLog("   Saved to key: com.notelayer.app.sharedItems")
            NSLog("   App Group: group.com.notelayer.app")

            // Verify it was saved
            if let verifyData = userDefaults.data(forKey: "com.notelayer.app.sharedItems"),
               let verifyItems = try? JSONDecoder().decode([SharedItem].self, from: verifyData) {
                NSLog("   ✅ Verified: %d items in storage", verifyItems.count)
            } else {
                NSLog("   ⚠️ WARNING: Could not verify save!")
            }
            
            NSLog("========================================")

            showSuccessAndDismiss()
        } else {
            NSLog("❌ [ShareViewController] Failed to encode items")
            showError("Unable to queue this share. Please try again.")
        }
    }
    
    /// Show success message and dismiss
    private func showSuccessAndDismiss() {
        // Show brief success message
        let alert = UIAlertController(
            title: "✓ Saved!",
            message: "Import queued for Notelayer",
            preferredStyle: .alert
        )
        present(alert, animated: true)
        
        // Dismiss after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    /// Cancel share extension
    private func cancelShare() {
        extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0))
    }
}

// MARK: - SwiftUI View

/// SwiftUI view for the share extension interface
struct ShareExtensionView: View {
    @ObservedObject var contentModel: ShareViewController.ShareContentModel
    let onSave: (String, String?, String?, [String], Priority, Date?, Date?) -> Void
    let onCancel: () -> Void
    
    // Field state
    @FocusState private var titleFieldFocused: Bool
    @State private var selectedCategories: Set<String> = []
    @State private var priority: Priority = .medium
    @State private var dueDate: Date? = nil
    @State private var reminderDate: Date? = nil
    @State private var notesText: String = ""
    @State private var urlText: String = ""
    @State private var showingDueDatePicker = false
    @State private var showingReminderPicker = false
    
    // Data
    @State private var availableCategories: [Category] = []
    
    var body: some View {
        NavigationStack {
            List {
                TaskEditorTitleSection(title: $contentModel.title, focus: $titleFieldFocused)

                Section("Detected Import Type") {
                    HStack {
                        Text("Destination")
                        Spacer()
                        Text(contentModel.destinationLabel)
                            .foregroundColor(.secondary)
                    }
                    if contentModel.destination == .taskBatch {
                        Text("\(contentModel.taskDrafts.count) list items will become staged tasks.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if contentModel.destination == .note {
                        Text("Ambiguous or prose content defaults to a note.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if !contentModel.warnings.isEmpty {
                    Section("Import Warning") {
                        ForEach(contentModel.warnings, id: \.self) { warning in
                            Text(warning)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }

                if contentModel.destination == .taskBatch && !contentModel.taskDrafts.isEmpty {
                    Section("Parsed Task Preview") {
                        ForEach(contentModel.taskDrafts) { draft in
                            HStack {
                                Image(systemName: draft.isChecklistItem ? "checklist" : "list.bullet")
                                    .foregroundColor(.secondary)
                                Text(draft.title)
                                    .lineLimit(2)
                            }
                        }
                    }
                }

                if showsTaskControls && !availableCategories.isEmpty {
                    TaskEditorCategorySection(
                        categories: availableCategories,
                        selectedIds: $selectedCategories,
                        chipSize: .large
                    )
                }

                if showsTaskControls {
                    TaskEditorPrioritySection(priority: $priority)
                }

                if showsTaskControls {
                    Section("Due Date") {
                        Button {
                            if dueDate == nil {
                                dueDate = Date()
                            }
                            showingDueDatePicker = true
                        } label: {
                            HStack {
                                Text("Due Date")
                                Spacer()
                                if let dueDate = dueDate {
                                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Tap to set date & time")
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                            }
                        }

                        if dueDate != nil {
                            Button(role: .destructive) {
                                dueDate = nil
                            } label: {
                                Text("Remove Due Date")
                            }
                        }
                    }
                }

                if showsTaskControls {
                    Section("Nag") {
                        if let activeReminderDate = reminderDate {
                            Button {
                                showingReminderPicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.orange)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(activeReminderDate.formatted(date: .abbreviated, time: .shortened))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text(relativeTimeText(for: activeReminderDate))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)

                            Button(role: .destructive) {
                                reminderDate = nil
                            } label: {
                                Text("Stop nagging me")
                            }
                        } else {
                            Button {
                                showingReminderPicker = true
                            } label: {
                                HStack {
                                    Text("Nag me later")
                                    Spacer()
                                    Image(systemName: "bell.badge.plus")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                TaskEditorNotesSection(notes: $notesText, links: detectedNoteLinks)

                if shouldShowURLSection {
                    TaskEditorURLSection(urlText: $urlText)
                }

                if let sourceApp = contentModel.sourceApp {
                    Section {
                        Text("Shared from \(sourceApp)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Share to Notelayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    headerTitle
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.body)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedNotes = notesText.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedURL = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(
                            contentModel.title,
                            trimmedURL.isEmpty ? nil : trimmedURL,
                            trimmedNotes.isEmpty ? nil : trimmedNotes,
                            showsTaskControls ? Array(selectedCategories) : [],
                            showsTaskControls ? priority : .medium,
                            showsTaskControls ? dueDate : nil,
                            showsTaskControls ? reminderDate : nil
                        )
                    }
                    .font(.body.weight(.semibold))
                    .disabled(contentModel.title.isEmpty)
                }
            }
            .sheet(isPresented: $showingDueDatePicker) {
                DueDatePickerSheet(dueDate: $dueDate)
            }
            .sheet(isPresented: $showingReminderPicker) {
                ReminderDatePickerSheet(reminderDate: $reminderDate)
            }
            .onAppear {
                // Load categories from App Group
                availableCategories = SharedItemHelpers.loadCategoriesFromAppGroup()

                if notesText.isEmpty {
                    notesText = contentModel.text ?? ""
                }

                if urlText.isEmpty {
                    urlText = contentModel.url ?? ""
                }
                
                // Auto-focus title field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    titleFieldFocused = true
                }
            }
        }
    }

    private var headerTitle: some View {
        HStack(spacing: 8) {
            Image("NotelayerLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            Text("Share to Notelayer")
                .font(.headline)
        }
        .accessibilityElement(children: .combine)
    }

    private var detectedNoteLinks: [URL] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: notesText, range: NSRange(notesText.startIndex..., in: notesText)) ?? []
        return matches.compactMap { match in
            Range(match.range, in: notesText).flatMap { URL(string: String(notesText[$0])) }
        }
    }

    private var shouldShowURLSection: Bool {
        !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contentModel.url != nil
    }

    private var showsTaskControls: Bool {
        contentModel.destination != .note
    }

    private func relativeTimeText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Date Picker Sheets

/// Simple due date picker sheet
struct DueDatePickerSheet: View {
    @Binding var dueDate: Date?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Due Date",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Set Due Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        dueDate = selectedDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedDate = dueDate ?? Date()
            }
        }
    }
}

/// Reminder date/time picker with quick options
struct ReminderDatePickerSheet: View {
    @Binding var reminderDate: Date?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date = Date()
    @State private var showingCustomPicker = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Quick Options") {
                    Button(action: { setReminder(hours: 1) }) {
                        HStack {
                            Label("In 1 hour", systemImage: "clock")
                            Spacer()
                            Text(formatTime(Date().addingTimeInterval(3600)))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { setReminder(tomorrow: 9) }) {
                        HStack {
                            Label("Tomorrow at 9 AM", systemImage: "sunrise")
                            Spacer()
                            Text(formatDate(tomorrowAt(hour: 9)))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { setReminder(tomorrow: 18) }) {
                        HStack {
                            Label("Tomorrow at 6 PM", systemImage: "sunset")
                            Spacer()
                            Text(formatDate(tomorrowAt(hour: 18)))
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Section {
                    Button(action: { showingCustomPicker = true }) {
                        Label("Custom Date & Time", systemImage: "calendar.badge.clock")
                    }
                }
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCustomPicker) {
                CustomReminderPicker(reminderDate: $reminderDate, dismiss: dismiss)
            }
        }
    }
    
    private func setReminder(hours: Double) {
        reminderDate = Date().addingTimeInterval(hours * 3600)
        dismiss()
    }
    
    private func setReminder(tomorrow hour: Int) {
        reminderDate = tomorrowAt(hour: hour)
        dismiss()
    }
    
    private func tomorrowAt(hour: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.day! += 1
        components.hour = hour
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Custom date & time picker for reminders
struct CustomReminderPicker: View {
    @Binding var reminderDate: Date?
    let dismiss: DismissAction
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Reminder Date & Time",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Custom Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        reminderDate = selectedDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedDate = reminderDate ?? Date()
            }
        }
    }
}
