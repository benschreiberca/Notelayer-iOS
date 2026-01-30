import UIKit
import SwiftUI
import UniformTypeIdentifiers
import Combine

/// Share Extension view controller
/// Handles content shared from other apps (URLs, plain text) and saves to Notelayer
class ShareViewController: UIViewController {
    
    // MARK: - Properties
    
    private var hostingController: UIHostingController<ShareExtensionView>?
    private var contentModel: ShareContentModel?
    
    /// Content extracted from the share extension context
    struct ExtractedContent {
        let title: String
        let url: String?
        let text: String?
        let sourceApp: String?
    }
    
    /// Observable model for sharing content between UIKit and SwiftUI
    class ShareContentModel: ObservableObject {
        @Published var title: String
        let url: String?
        let text: String?
        let sourceApp: String?
        
        init(content: ExtractedContent) {
            self.title = content.title
            self.url = content.url
            self.text = content.text
            self.sourceApp = content.sourceApp
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
                let content = ExtractedContent(
                    title: url.absoluteString,
                    url: url.absoluteString,
                    text: nil,
                    sourceApp: sourceApp
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
                let content = ExtractedContent(
                    title: self?.generateTitleFromText(text) ?? text,
                    url: nil,
                    text: text,
                    sourceApp: sourceApp
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
    
    /// Save task to App Group UserDefaults with all fields
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
        guard !title.isEmpty else {
            showError("Please enter a title")
            return
        }
        
        // Create shared item with all fields
        let sharedItem = SharedItem(
            title: title,
            url: url,
            text: notes,
            sourceApp: model.sourceApp,
            categories: categories,
            priority: priority,
            dueDate: dueDate,
            reminderDate: reminderDate
        )
        
        NSLog("========================================")
        NSLog("💾 [ShareViewController] Saving shared item: %@", title)
        NSLog("========================================")
        
        // Save to App Group UserDefaults
        guard let userDefaults = UserDefaults(suiteName: "group.com.notelayer.app") else {
            NSLog("❌ [ShareViewController] Failed to access App Group")
            showError("Failed to save")
            return
        }
        
        // Get existing items
        var items: [SharedItem] = []
        if let data = userDefaults.data(forKey: "com.notelayer.app.sharedItems"),
           let decoded = try? JSONDecoder().decode([SharedItem].self, from: data) {
            items = decoded
        }
        
        // Add new item
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
            showError("Failed to save")
        }
    }
    
    /// Show success message and dismiss
    private func showSuccessAndDismiss() {
        // Show brief success message
        let alert = UIAlertController(
            title: "✓ Saved!",
            message: "Task added to Notelayer",
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

                if !availableCategories.isEmpty {
                    TaskEditorCategorySection(
                        categories: availableCategories,
                        selectedIds: $selectedCategories,
                        chipSize: .large
                    )
                }

                TaskEditorPrioritySection(priority: $priority)

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
                            Array(selectedCategories),
                            priority,
                            dueDate,
                            reminderDate
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
