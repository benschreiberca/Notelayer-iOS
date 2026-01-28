import UIKit
import SwiftUI
import UniformTypeIdentifiers

/// Share Extension view controller
/// Handles content shared from other apps (URLs, plain text) and saves to Notelayer
class ShareViewController: UIViewController {
    
    // MARK: - Properties
    
    private var hostingController: UIHostingController<ShareExtensionView>?
    private var extractedContent: ExtractedContent?
    
    /// Content extracted from the share extension context
    struct ExtractedContent {
        let title: String
        let url: String?
        let text: String?
        let sourceApp: String?
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        print("📤 [ShareViewController] View loaded, extracting shared content...")
        #endif
        
        extractSharedContent()
    }
    
    // MARK: - Content Extraction
    
    /// Extract content from the extension context
    private func extractSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            #if DEBUG
            print("❌ [ShareViewController] No extension items found")
            #endif
            cancelShare()
            return
        }
        
        // Try URL first
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            extractURL(from: itemProvider)
        }
        // Then try plain text
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            extractText(from: itemProvider)
        }
        else {
            #if DEBUG
            print("❌ [ShareViewController] Unsupported content type")
            #endif
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
            
            // Fetch page title asynchronously
            self?.fetchPageTitle(for: url) { title in
                DispatchQueue.main.async {
                    let sourceApp = self?.getSourceAppName() ?? "Safari"
                    self?.extractedContent = ExtractedContent(
                        title: title ?? url.absoluteString,
                        url: url.absoluteString,
                        text: nil,
                        sourceApp: sourceApp
                    )
                    self?.showUI()
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
                self?.extractedContent = ExtractedContent(
                    title: self?.generateTitleFromText(text) ?? text,
                    url: nil,
                    text: text,
                    sourceApp: sourceApp
                )
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
        guard let content = extractedContent else { return }
        
        let swiftUIView = ShareExtensionView(
            extractedContent: content,
            onSave: { [weak self] title in
                self?.saveTask(title: title, content: content)
            },
            onCancel: { [weak self] in
                self?.cancelShare()
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        self.hostingController = hostingController
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
    
    /// Save task to App Group UserDefaults
    private func saveTask(title: String, content: ExtractedContent) {
        guard !title.isEmpty else {
            showError("Please enter a title")
            return
        }
        
        // Create shared item
        let sharedItem = SharedItem(
            title: title,
            url: content.url,
            text: content.text,
            sourceApp: content.sourceApp
        )
        
        #if DEBUG
        print("💾 [ShareViewController] Saving shared item: \(title)")
        #endif
        
        // Save to App Group UserDefaults
        guard let userDefaults = UserDefaults(suiteName: "group.com.notelayer.app") else {
            #if DEBUG
            print("❌ [ShareViewController] Failed to access App Group")
            #endif
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
            
            #if DEBUG
            print("✅ [ShareViewController] Saved successfully")
            #endif
            
            showSuccessAndDismiss()
        } else {
            #if DEBUG
            print("❌ [ShareViewController] Failed to encode items")
            #endif
            showError("Failed to save")
        }
    }
    
    /// Show success message and dismiss
    private func showSuccessAndDismiss() {
        // Show brief success message
        let alert = UIAlertController(
            title: "Saved!",
            message: "Added to Notelayer",
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
    let extractedContent: ShareViewController.ExtractedContent
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var title: String
    
    init(
        extractedContent: ShareViewController.ExtractedContent,
        onSave: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.extractedContent = extractedContent
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: extractedContent.title)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Task Title") {
                    TextField("Enter title", text: $title)
                        .font(.body)
                }
                
                if let url = extractedContent.url {
                    Section("URL") {
                        Text(url)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                if let text = extractedContent.text {
                    Section("Content") {
                        Text(text)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(5)
                    }
                }
                
                if let sourceApp = extractedContent.sourceApp {
                    Section {
                        HStack {
                            Image(systemName: "arrow.up.forward.square")
                                .foregroundColor(.blue)
                            Text("Shared from \(sourceApp)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Save to Notelayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title)
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
