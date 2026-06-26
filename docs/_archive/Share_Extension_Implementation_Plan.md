# Share Extension Feature - Implementation Plan

**Branch:** `more-features-share-and-remind`  
**Priority:** High  
**Complexity:** Very High

## Overview

Allow users to share content (URLs, plain text) from other apps (Safari, Chrome, iMessage, etc.) directly into Notelayer as tasks.

## User Requirements (From Clarification)

- ✅ Content types: URLs and plain text only (no images/files yet)
- ✅ URL title: Fetch webpage title for highest context (like NYT article title)
- ✅ Links must be clickable in task details
- ✅ Destination: Always save to Tasks (not Notes)
- ✅ UI: Edit text field before saving
- ✅ Attribution: Include source (e.g., "Shared from Safari")
- ✅ Single item only: One task at a time
- ✅ After saving: Dismiss with confirmation (implied)

## Technical Architecture

### 1. Share Extension Target

**New Target:** "Notelayer Share Extension"  
**Type:** Share Extension  
**Bundle ID:** `com.notelayer.app.ShareExtension`

**Files Structure:**
```
ios-swift/Notelayer/NotelayerShareExtension/
├── Info.plist
├── ShareViewController.swift
├── ShareExtension.entitlements
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

### 2. App Group Configuration

**App Group:** `group.com.notelayer.app` (already exists!)

**Entitlements Required:**

**Main App** (`Notelayer.entitlements`):
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.notelayer.app</string>
</array>
```

**Share Extension** (`ShareExtension.entitlements`):
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.notelayer.app</string>
</array>
```

### 3. Share Extension Info.plist

**Activation Rules:**
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <dict>
            <!-- Accept URLs -->
            <key>NSExtensionActivationSupportsWebURLWithMaxCount</key>
            <integer>1</integer>
            
            <!-- Accept plain text -->
            <key>NSExtensionActivationSupportsText</key>
            <true/>
        </dict>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
</dict>
```

### 4. Data Flow

```
Other App (Safari, etc.)
    ↓
User taps Share → Notelayer
    ↓
Share Extension opens
    ↓
Extract content (URL/text)
    ↓
Fetch URL metadata (if URL)
    ↓
Show edit UI with pre-filled content
    ↓
User edits title/adds categories
    ↓
Save to App Group UserDefaults
    ↓
Dismiss with success message
    ↓
Main app detects new shared item on next launch
    ↓
Create task from shared item
    ↓
Sync to Firebase (if signed in)
    ↓
Clean up shared item from UserDefaults
```

### 5. Shared Data Structure

**New File:** `ios-swift/Notelayer/Notelayer/Data/SharedItem.swift`

```swift
struct SharedItem: Codable, Identifiable {
    let id: String
    let title: String
    let url: String?  // Optional URL
    let text: String?  // Plain text content
    let sourceApp: String?  // Attribution
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        url: String? = nil,
        text: String? = nil,
        sourceApp: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.text = text
        self.sourceApp = sourceApp
        self.createdAt = createdAt
    }
}
```

**Storage Key:** `com.notelayer.app.sharedItems`

### 6. Share Extension UI

**File:** `NotelayerShareExtension/ShareViewController.swift`

```swift
import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    private var titleTextField: UITextField!
    private var categoriesLabel: UILabel!
    private var sourceLabel: UILabel!
    private var saveButton: UIButton!
    private var cancelButton: UIButton!
    
    private var extractedContent: ExtractedContent?
    
    struct ExtractedContent {
        let title: String
        let url: String?
        let text: String?
        let sourceApp: String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        extractSharedContent()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title field
        titleTextField = UITextField()
        titleTextField.placeholder = "Task title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.font = .systemFont(ofSize: 17)
        
        // Source attribution
        sourceLabel = UILabel()
        sourceLabel.font = .systemFont(ofSize: 13)
        sourceLabel.textColor = .secondaryLabel
        
        // Buttons
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save to Notelayer", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTask), for: .touchUpInside)
        
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        // Layout (using Auto Layout or SwiftUI)
        // ... layout code
    }
    
    private func extractSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            cancel()
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
            showError("Unsupported content type")
        }
    }
    
    private func extractURL(from itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
            guard let url = item as? URL else { return }
            
            // Fetch page title
            self?.fetchPageTitle(for: url) { title in
                DispatchQueue.main.async {
                    let sourceApp = self?.getSourceAppName() ?? "Safari"
                    self?.extractedContent = ExtractedContent(
                        title: title ?? url.absoluteString,
                        url: url.absoluteString,
                        text: nil,
                        sourceApp: sourceApp
                    )
                    self?.updateUI()
                }
            }
        }
    }
    
    private func extractText(from itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (item, error) in
            guard let text = item as? String else { return }
            
            DispatchQueue.main.async {
                let sourceApp = self?.getSourceAppName() ?? "Unknown"
                self?.extractedContent = ExtractedContent(
                    title: self?.generateTitleFromText(text) ?? text,
                    url: nil,
                    text: text,
                    sourceApp: sourceApp
                )
                self?.updateUI()
            }
        }
    }
    
    private func fetchPageTitle(for url: URL, completion: @escaping (String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            // Extract <title> tag
            if let titleRange = html.range(of: "<title>(.*?)</title>", options: .regularExpression) {
                let title = String(html[titleRange])
                    .replacingOccurrences(of: "<title>", with: "")
                    .replacingOccurrences(of: "</title>", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                completion(title)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    private func generateTitleFromText(_ text: String) -> String {
        // Use first sentence or first 50 chars
        let firstLine = text.components(separatedBy: .newlines).first ?? text
        return String(firstLine.prefix(50))
    }
    
    private func getSourceAppName() -> String? {
        // Try to get source app name from extension context
        // This is best-effort; not always available
        return extensionContext?.inputItems.first
            .flatMap { ($0 as? NSExtensionItem)?.userInfo?["NSExtensionItemSourceApplicationKey"] as? String }
    }
    
    private func updateUI() {
        guard let content = extractedContent else { return }
        
        titleTextField.text = content.title
        
        if let sourceApp = content.sourceApp {
            sourceLabel.text = "Shared from \(sourceApp)"
            sourceLabel.isHidden = false
        }
    }
    
    @objc private func saveTask() {
        guard let content = extractedContent,
              let title = titleTextField.text, !title.isEmpty else {
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
        
        // Save to App Group
        saveToAppGroup(sharedItem)
        
        // Show success and dismiss
        showSuccessAndDismiss()
    }
    
    private func saveToAppGroup(_ item: SharedItem) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.notelayer.app") else {
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
        items.append(item)
        
        // Save back
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: "com.notelayer.app.sharedItems")
            userDefaults.synchronize()
        }
    }
    
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
    
    @objc private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0))
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

### 7. Main App Integration

**Update LocalStore.swift:**

```swift
// Add method to process shared items
func processSharedItems() {
    guard let userDefaults = UserDefaults(suiteName: "group.com.notelayer.app") else { return }
    
    // Get shared items
    guard let data = userDefaults.data(forKey: "com.notelayer.app.sharedItems"),
          let sharedItems = try? JSONDecoder().decode([SharedItem].self, from: data),
          !sharedItems.isEmpty else {
        return
    }
    
    // Convert to tasks
    for item in sharedItems {
        let taskNotes = buildTaskNotes(from: item)
        let task = Task(
            title: item.title,
            categories: [],
            priority: .medium,
            dueDate: nil,
            taskNotes: taskNotes
        )
        _ = addTask(task)
    }
    
    // Clear shared items
    userDefaults.removeObject(forKey: "com.notelayer.app.sharedItems")
    userDefaults.synchronize()
}

private func buildTaskNotes(from item: SharedItem) -> String {
    var notes = ""
    
    // Add URL if present (clickable)
    if let url = item.url {
        notes += "\(url)\n\n"
    }
    
    // Add text if present
    if let text = item.text {
        notes += "\(text)\n\n"
    }
    
    // Add attribution
    if let sourceApp = item.sourceApp {
        notes += "Shared from \(sourceApp)"
    }
    
    return notes.trimmingCharacters(in: .whitespacesAndNewlines)
}
```

**Update NotelayerApp.swift:**

```swift
struct NotelayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authService = AuthService.shared
    @StateObject private var theme = ThemeManager.shared
    @StateObject private var store = LocalStore.shared  // Make sure this exists
    
    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environmentObject(authService)
                .environmentObject(theme)
                .onAppear {
                    // Process any shared items from share extension
                    store.processSharedItems()
                }
        }
    }
}
```

### 8. Task Notes with Clickable URLs

**File:** `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`

**Update Notes section to detect and linkify URLs:**

```swift
Section("Notes") {
    if hasURL(in: taskNotes) {
        // Use Text with markdown to make links clickable
        Text(try! AttributedString(markdown: taskNotes))
            .textSelection(.enabled)
            .frame(minHeight: 100, alignment: .topLeading)
    } else {
        TextEditor(text: $taskNotes)
            .frame(minHeight: 100)
    }
}

private func hasURL(in text: String) -> Bool {
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector?.matches(in: text, range: NSRange(text.startIndex..., in: text))
    return !(matches?.isEmpty ?? true)
}
```

**Alternative: Make URLs always tappable in TextEditor**
```swift
// In TaskEditView
Section("Notes") {
    VStack(alignment: .leading) {
        TextEditor(text: $taskNotes)
            .frame(minHeight: 100)
        
        // Show detected URLs as tappable links below
        if !detectedURLs.isEmpty {
            Divider()
            ForEach(detectedURLs, id: \.self) { url in
                Link(url.absoluteString, destination: url)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
    }
}

private var detectedURLs: [URL] {
    let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector?.matches(in: taskNotes, range: NSRange(taskNotes.startIndex..., in: taskNotes)) ?? []
    return matches.compactMap { match in
        Range(match.range, in: taskNotes).flatMap { URL(string: String(taskNotes[$0])) }
    }
}
```

### 9. URL Metadata Enhancement (Optional)

**Using LinkPresentation Framework:**

```swift
import LinkPresentation

class URLMetadataFetcher {
    static func fetch(url: URL, completion: @escaping (LPLinkMetadata?) -> Void) {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            completion(metadata)
        }
    }
}

// In ShareViewController
private func fetchPageTitle(for url: URL, completion: @escaping (String?) -> Void) {
    URLMetadataFetcher.fetch(url: url) { metadata in
        completion(metadata?.title)
    }
}
```

## Implementation Steps

### Phase 1: Share Extension Setup (Essential)
- [ ] Create Share Extension target in Xcode
- [ ] Configure Info.plist with activation rules (URL + text)
- [ ] Add Share Extension entitlements (App Group)
- [ ] Verify main app has App Group entitlement
- [ ] Create basic ShareViewController UI

### Phase 2: Content Extraction (Essential)
- [ ] Implement URL extraction from share context
- [ ] Implement plain text extraction
- [ ] Implement source app detection
- [ ] Add webpage title fetching
- [ ] Generate title from text content

### Phase 3: Data Storage (Essential)
- [ ] Create SharedItem model
- [ ] Implement save to App Group UserDefaults
- [ ] Add LocalStore.processSharedItems() method
- [ ] Call processSharedItems() on app launch
- [ ] Convert SharedItem to Task with formatted notes

### Phase 4: UI Polish (Essential)
- [ ] Create edit text field in ShareViewController
- [ ] Show source attribution
- [ ] Add Save/Cancel buttons
- [ ] Show success message on save
- [ ] Handle errors gracefully

### Phase 5: URL Handling (Essential)
- [ ] Format task notes with clickable URLs
- [ ] Update TaskEditView to show tappable links
- [ ] Test URL opening in Safari

### Phase 6: Testing (Essential)
- [ ] Share URL from Safari
- [ ] Share URL from Chrome
- [ ] Share text from iMessage
- [ ] Share text from Notes app
- [ ] Verify task created with correct title
- [ ] Verify URL is clickable in task notes
- [ ] Verify attribution appears
- [ ] Test cancellation
- [ ] Test with very long URLs/text

## Edge Cases & Error Handling

1. **No Content to Share**
   - Show error and dismiss
   - Should not happen with proper activation rules

2. **Network Error Fetching URL Title**
   - Fallback to URL domain name
   - Don't block on network request

3. **Very Long URLs/Text**
   - Truncate title to reasonable length (50-100 chars)
   - Store full content in notes

4. **App Group Not Configured**
   - Show error in share extension
   - Log error for debugging

5. **Invalid URL**
   - Treat as plain text
   - Don't crash

6. **Main App Not Installed**
   - Cannot happen (extension requires main app)

7. **Share Extension Memory Limit**
   - iOS limits extension memory (~30MB)
   - Don't load large content

## Testing Checklist

- [ ] Share URL from Safari
- [ ] Share URL from Chrome/Firefox
- [ ] Share highlighted text from iMessage
- [ ] Share note from Notes app
- [ ] Share tweet (URL) from Twitter/X
- [ ] Share article from News app
- [ ] Edit title before saving
- [ ] Cancel without saving
- [ ] Verify "Saved!" message appears
- [ ] Open main app and find task
- [ ] Tap URL in task notes (opens Safari)
- [ ] Verify attribution shows source app
- [ ] Share when main app not running
- [ ] Share when main app is running
- [ ] Multiple shares in quick succession

## Success Criteria

✅ Notelayer appears in iOS share sheet  
✅ Can share URLs from any browser  
✅ Can share plain text from any app  
✅ URL title automatically fetched  
✅ Text field allows editing before save  
✅ Attribution shows source app  
✅ URLs are clickable in task notes  
✅ Tasks appear in main app after sharing  
✅ Single task created per share  
✅ Clear success confirmation  
✅ No crashes or data loss

## Future Enhancements (Not in Scope)

- Support images and files
- Choose task categories in share extension
- Set task priority in share extension
- Set due date in share extension
- Rich link previews in task notes
- Share multiple items as separate tasks
- Batch processing of queued shared items
- Deep link from share extension to main app
