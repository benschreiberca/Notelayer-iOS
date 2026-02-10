# Calendar Export Feature - Implementation Plan

**Branch:** `more-features-share-and-remind`  
**Priority:** High  
**Complexity:** Medium

## Overview

Enable users to export tasks to their device calendar with full metadata including title, categories, due date, notes, and priority.

## User Requirements (From Clarification)

- ✅ Tasks without due date: Use today's date as default
- ✅ Categories: Include in event description/notes
- ✅ Event duration: 15 minutes default
- ✅ Integration: Direct EventKit (requires calendar permission)
- ✅ Task notes: Append to calendar event notes
- ✅ Task title: Same as calendar event title
- ✅ Priority: Pass to calendar priority if possible
- ✅ Completed tasks: Allowed to export
- ✅ Trigger locations: Long-press context menu + TaskEditView

## Technical Architecture

### 1. EventKit Integration

**Framework:** `import EventKit`

**Permission Flow:**
1. First export attempt triggers permission request
2. Show native iOS calendar access dialog
3. Handle granted/denied states
4. Persist permission state

**Required Info.plist Entry:**
```xml
<key>NSCalendarsUsageDescription</key>
<string>Notelayer needs calendar access to create events from your tasks.</string>
```

### 2. Calendar Event Structure

**Mapping Task → EKEvent:**
```
Task Field          → Calendar Event Field
────────────────────────────────────────────
title               → event.title
dueDate (or today)  → event.startDate
dueDate + 15 min    → event.endDate
taskNotes           → event.notes (with categories)
priority            → event.priority (EKEventPriority)
categories          → event.notes (formatted)
```

**Event Notes Format:**
```
[Task Notes if present]

Categories: 📊 Finance & Admin, 🏠 House & Repairs
Priority: High
Source: Notelayer
```

**Priority Mapping:**
```swift
Task.Priority → EKEventPriority
─────────────────────────────────
.high         → .high (9)
.medium       → .medium (5)
.low          → .low (1)
.deferred     → .low (1)
```

### 3. New Components

#### CalendarExportManager.swift
**Location:** `ios-swift/Notelayer/Notelayer/Services/CalendarExportManager.swift`

**Responsibilities:**
- Request calendar permission
- Create EKEvent from Task
- Handle calendar selection (default calendar)
- Format event notes with categories
- Error handling

**Public API:**
```swift
class CalendarExportManager {
    static let shared = CalendarExportManager()
    
    // Request permission (call first)
    func requestCalendarAccess() async -> Bool
    
    // Export task to calendar
    func exportTask(_ task: Task, categories: [Category]) async throws
    
    // Check current permission status
    var hasCalendarAccess: Bool { get }
}
```

#### CalendarExportError.swift
**Location:** `ios-swift/Notelayer/Notelayer/Services/CalendarExportError.swift`

**Error Cases:**
```swift
enum CalendarExportError: LocalizedError {
    case permissionDenied
    case noCalendarAvailable
    case eventCreationFailed
    case unknown(Error)
    
    var errorDescription: String? { ... }
}
```

### 4. UI Changes

#### A. Context Menu (RowContextMenu.swift)

**Add "Add to Calendar" option:**
```swift
struct RowContextMenuModifier: ViewModifier {
    let onShare: () -> Void
    let onCopy: () -> Void
    let onAddToCalendar: (() -> Void)?  // NEW
    let onDelete: (() -> Void)?
    
    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Share…") { onShare() }
            Button("Copy") { onCopy() }
            if let onAddToCalendar {
                Button("Add to Calendar") { onAddToCalendar() }  // NEW
            }
            if let onDelete {
                Button("Delete", role: .destructive) { onDelete() }
            }
        }
    }
}
```

#### B. TaskEditView.swift

**Add toolbar button:**
```swift
.toolbar {
    ToolbarItem(placement: .cancellationAction) { ... }
    
    // NEW: Calendar export button
    ToolbarItem(placement: .automatic) {
        Button {
            showCalendarExport = true
        } label: {
            Label("Add to Calendar", systemImage: "calendar.badge.plus")
        }
    }
    
    ToolbarItem(placement: .confirmationAction) { ... }
}
```

#### C. TodosView.swift

**Update all TodoGroupTaskList calls:**
```swift
TodoGroupTaskList(
    tasks: tasks,
    categoryLookup: categoryLookup,
    sourceGroupId: "all",
    onToggleComplete: toggleComplete,
    onTap: { editingTask = $0 },
    onShare: { sharePayload = SharePayload(items: [$0.title]) },
    onCopy: { UIPasteboard.general.string = $0.title },
    onAddToCalendar: { task in  // NEW
        Task {
            await exportTaskToCalendar(task)
        }
    },
    onDropMove: { ... }
)
```

**Add export handler:**
```swift
@State private var calendarExportError: CalendarExportError? = nil
@State private var showCalendarSuccess = false

private func exportTaskToCalendar(_ task: Task) async {
    let manager = CalendarExportManager.shared
    
    // Request permission if needed
    guard await manager.requestCalendarAccess() else {
        await MainActor.run {
            calendarExportError = .permissionDenied
        }
        return
    }
    
    // Export task
    do {
        try await manager.exportTask(task, categories: store.categories)
        await MainActor.run {
            showCalendarSuccess = true
        }
    } catch {
        await MainActor.run {
            calendarExportError = error as? CalendarExportError ?? .unknown(error)
        }
    }
}
```

**Add alert modifiers:**
```swift
.alert("Calendar Export Failed", isPresented: .constant(calendarExportError != nil)) {
    Button("Settings") {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    Button("OK") {
        calendarExportError = nil
    }
} message: {
    Text(calendarExportError?.localizedDescription ?? "Unknown error")
}
.alert("Added to Calendar", isPresented: $showCalendarSuccess) {
    Button("OK") {
        showCalendarSuccess = false
    }
} message: {
    Text("Task has been added to your calendar")
}
```

### 5. Implementation Details

#### Date Handling

**If task has no dueDate:**
```swift
let eventDate = task.dueDate ?? Date()
event.startDate = eventDate
event.endDate = eventDate.addingTimeInterval(15 * 60) // +15 minutes
```

#### Category Formatting

**Format categories for event notes:**
```swift
func formatCategories(_ task: Task, _ categories: [Category]) -> String {
    let taskCategories = categories.filter { task.categories.contains($0.id) }
    let formatted = taskCategories
        .map { "\($0.icon) \($0.name)" }
        .joined(separator: ", ")
    return formatted.isEmpty ? "None" : formatted
}
```

#### Full Event Notes Format

```swift
func buildEventNotes(_ task: Task, _ categories: [Category]) -> String {
    var notes = ""
    
    // Task notes
    if let taskNotes = task.taskNotes, !taskNotes.isEmpty {
        notes += taskNotes + "\n\n"
    }
    
    // Categories
    notes += "Categories: \(formatCategories(task, categories))\n"
    
    // Priority
    notes += "Priority: \(task.priority.label)\n"
    
    // Source
    notes += "\nSource: Notelayer"
    
    return notes
}
```

## Implementation Steps

### Phase 1: Core Calendar Export (Essential)
- [x] Add `NSCalendarsUsageDescription` to Info.plist ✅
- [x] Create `CalendarExportManager.swift` with EventKit integration ✅
- [x] Create `CalendarExportError.swift` enum ✅
- [x] Implement permission request flow ✅
- [x] Implement task → EKEvent conversion ✅
- [x] Add event to default calendar ✅

### Phase 2: UI Integration (Essential)
- [x] Update `RowContextMenu.swift` to add "Add to Calendar" option ✅
- [x] Update `TodosView.swift` with export handler and alerts ✅
- [x] Add calendar export to `TaskEditView.swift` toolbar ✅
- [x] Update all `TodoGroupTaskList` instantiations ✅
- [x] Handle permission denied state with Settings link ✅

### Phase 3: Testing & Polish (Essential)
- [x] Build succeeds ✅
- [ ] Test with tasks that have due dates (manual)
- [ ] Test with tasks without due dates - should use today (manual)
- [ ] Test permission flow - granted/denied (manual)
- [ ] Test with various categories and priorities (manual)
- [ ] Test with completed tasks (manual)
- [ ] Verify event appears in Calendar app (manual)
- [ ] Test error states (manual)

## Edge Cases & Error Handling

1. **No Calendars Available**
   - Check if user has any writable calendars
   - Show error if none available

2. **Permission Denied**
   - Show alert with "Open Settings" button
   - Gracefully handle and inform user

3. **Event Save Failed**
   - Show generic error
   - Don't crash app

4. **Default Calendar Selection**
   - Use `EKEventStore.defaultCalendarForNewEvents`
   - Fallback to first writable calendar

5. **Very Long Task Titles**
   - EventKit handles truncation
   - No special handling needed

## Testing Checklist

- [ ] Export task with due date to calendar
- [ ] Export task without due date (uses today)
- [ ] Verify 15-minute duration
- [ ] Check categories appear in notes
- [ ] Check priority is set correctly
- [ ] Check task notes appended
- [ ] Export from long-press menu
- [ ] Export from TaskEditView
- [ ] Test permission request flow
- [ ] Test permission denied handling
- [ ] Verify event title matches task title
- [ ] Export completed task
- [ ] Multiple exports of same task (creates duplicates - expected)

## Success Criteria

✅ Users can export any task to calendar from context menu  
✅ Users can export from TaskEditView  
✅ Calendar permission requested appropriately  
✅ Events created with 15-minute duration  
✅ All task metadata included in event  
✅ Works with and without due dates  
✅ Clear error messages for failures  
✅ No app crashes on permission denial

## Future Enhancements (Not in Scope)

- Select which calendar to export to
- Configurable event duration
- Batch export multiple tasks
- Two-way sync (update task when event changes)
- Recurring events for recurring tasks
- Custom reminder times for calendar events
