# Native iOS App Runbook

This document provides setup and build instructions for the native iOS app.

## Project Structure

```
ios-native/Notelayer/
  Notelayer/
    App/
      NotelayerApp.swift           # App entry point
    UI/
      RootTabsView.swift           # Root tab navigation
    Features/
      Notes/
        NotesView.swift            # Notes list view
        NoteEditorView.swift       # Note editor
      Todos/
        TodosView.swift           # Todos list view
        TaskEditView.swift        # Task editor
      Categories/
        CategoryManagerView.swift # Category management
    Data/
      Models/                      # Data models
      LocalStore/                  # Local persistence
      Sync/                        # Sync engine
      Supabase/                    # Supabase client
      AppStore.swift              # Central state store
```

## Xcode Project Setup

### 1. Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Product Name: `Notelayer`
5. Interface: `SwiftUI`
6. Language: `Swift`
7. Save location: `ios-native/Notelayer/`

### 2. Configure Bundle IDs

- **App**: `com.notelayer.app`
- **Share Extension**: `com.notelayer.app.NotelayerShare`

### 3. Configure App Groups

1. Select app target
2. Signing & Capabilities → + Capability → App Groups
3. Add group: `group.com.notelayer.app`
4. Repeat for Share Extension target

### 4. Configure Info.plist

Add to `Info.plist`:
- `CFBundleDisplayName`: `Notelayer`
- URL Schemes: `notelayer` (for deep links)

### 5. Add Source Files

Add all Swift files from `Notelayer/` directory to the Xcode project:
- Drag files into project navigator
- Ensure "Copy items if needed" is checked
- Select app target

### 6. Configure Build Settings

- **iOS Deployment Target**: 16.0
- **Swift Language Version**: 5.9
- **Swift Package Manager**: Enable

### 7. Add Dependencies (Swift Package Manager)

Add the following packages:
- Supabase Swift SDK: `https://github.com/supabase/supabase-swift`
- (Additional packages as needed)

## Environment Configuration

### Supabase Configuration

Create `SupabaseConfig.swift` (NOT committed to git):

```swift
import Foundation

enum SupabaseConfig {
    static let url = "https://your-project-id.supabase.co"
    static let anonKey = "your-anon-public-key-here"
}
```

Create `SupabaseConfig.template.swift` (committed):

```swift
import Foundation

enum SupabaseConfig {
    static let url = "REPLACE_WITH_SUPABASE_URL"
    static let anonKey = "REPLACE_WITH_SUPABASE_ANON_KEY"
}
```

Copy the template and fill in your values:
```bash
cp ios-native/Notelayer/Notelayer/Data/Supabase/SupabaseConfig.template.swift \
   ios-native/Notelayer/Notelayer/Data/Supabase/SupabaseConfig.swift
```

## Build & Run

1. Open `Notelayer.xcodeproj` in Xcode
2. Select target device/simulator
3. Product → Run (⌘R)

## Share Extension Setup

### 1. Add Share Extension Target

1. File → New → Target
2. Choose "Share Extension"
3. Product Name: `NotelayerShare`
4. Bundle ID: `com.notelayer.app.NotelayerShare`

### 2. Configure Share Extension

1. Configure App Groups (same as main app)
2. Add source files from `ShareExtension/` directory
3. Configure Info.plist for share extension

### 3. Share Extension Implementation

See `ShareExtension/ShareViewController.swift` for implementation.

## Testing

### Unit Tests

Create test target and add unit tests for:
- Data models
- Local store operations
- Sync logic

### UI Tests

Create UI test target and add tests for:
- Navigation flows
- CRUD operations
- Sync behavior

## Deployment

### Archive & Export

1. Product → Archive
2. Distribute App
3. Choose distribution method (App Store, Ad Hoc, etc.)

### App Store

1. Configure App Store Connect
2. Upload build
3. Submit for review

## Troubleshooting

### Build Errors

- Ensure all source files are added to target
- Check bundle IDs match configuration
- Verify dependencies are resolved

### Signing Errors

- Configure signing in Xcode (automatic or manual)
- Ensure certificates and provisioning profiles are valid

### Sync Issues

- Check Supabase credentials
- Verify network connectivity
- Check sync logs

## Development Notes

- **Local Storage**: Categories stored in UserDefaults
- **Supabase**: Notes and Tasks synced to Supabase
- **Offline-First**: All writes go to local store first, then sync
- **Conflict Resolution**: Last-write-wins using `updated_at` timestamp
