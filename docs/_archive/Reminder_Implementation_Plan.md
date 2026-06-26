# Task Reminder Feature - Implementation Plan

**Branch:** `more-features-share-and-remind`  
**Priority:** High  
**Complexity:** High

## Overview

Add alarm-like reminder notifications for tasks, allowing users to be notified at specific times about pending tasks.

## User Requirements (From Clarification)

- ✅ Reminders can exist with or without due dates
- ✅ Simple date/time picker for setting reminders
- ✅ Single reminder per task
- ✅ Quick options + Custom picker (Option C)
- ✅ Notification shows: task title + category icons
- ✅ Notification actions: "Complete Task" + "Open Task"
- ✅ Visual indicator: Bell icon (🔔) in task row
- ✅ Auto-cancel notification when task completed
- ✅ Notification disappears normally after firing
- ✅ Manage reminders: Long-press menu + TaskEditView + Settings page
- ✅ Settings page: List reminders (soonest first), swipe to cancel
- ✅ Permission request: First time user sets reminder
- ✅ Sync reminders across devices via Firebase

## Technical Architecture

### 1. Data Model Changes

#### Task Model Enhancement
**File:** `ios-swift/Notelayer/Notelayer/Data/Models.swift`

```swift
struct Task: Identifiable, Codable {
    let id: String
    var title: String
    var categories: [String]
    var priority: Priority
    var dueDate: Date?
    var completedAt: Date?
    var taskNotes: String?
    var createdAt: Date
    var updatedAt: Date
    var orderIndex: Int?
    
    // NEW: Reminder fields
    var reminderDate: Date?  // When to fire notification
    var reminderNotificationId: String?  // UNNotification identifier for cancellation
}
```

**Migration:** Existing tasks will have `nil` for new fields (backward compatible)

### 2. Notification System

#### ReminderManager.swift
**Location:** `ios-swift/Notelayer/Notelayer/Services/ReminderManager.swift`

**Responsibilities:**
- Request notification permissions
- Schedule local notifications
- Cancel notifications
- Handle notification actions
- Deep linking to tasks

**Public API:**
```swift
class ReminderManager {
    static let shared = ReminderManager()
    
    // Permission management
    func requestNotificationPermission() async -> Bool
    var hasNotificationPermission: Bool { get async }
    
    // Reminder operations
    func scheduleReminder(for task: Task, at date: Date, categories: [Category]) async throws
    func cancelReminder(for task: Task) async
    func cancelReminder(notificationId: String) async
    
    // Fetch all pending reminders (for Settings page)
    func getPendingReminders() async -> [(Task, Date)]
}
```

#### Notification Content Format

**Title:** Task title  
**Body:** Categories (with icons): "📊 Finance, 🏠 House"  
**Category:** `"TASK_REMINDER"` (for actions)  
**UserInfo:** `["taskId": task.id]` (for deep linking)

**Actions:**
1. "Complete" - Marks task as complete
2. "Open" - Opens app to TaskEditView

### 3. Permission Handling

#### Info.plist Addition
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Notelayer sends reminders for your tasks at the times you choose.</string>
```

#### Permission Flow
1. User taps "Set Reminder" for first time
2. Show brief explanation alert
3. Request system permission
4. Handle granted/denied states

### 4. UI Components

#### A. Reminder Picker Sheet
**New File:** `ios-swift/Notelayer/Notelayer/Views/ReminderPickerSheet.swift`

**Features:**
- Quick preset buttons (30 min, 1 hour, Tomorrow 9 AM, etc.)
- "Custom" button opens date/time picker
- Save/Cancel actions
- Permission request on first use

**Structure:**
```swift
struct ReminderPickerSheet: View {
    @Binding var selectedDate: Date?
    let onSave: (Date) -> Void
    let onCancel: () -> Void
    
    @State private var showCustomPicker = false
    @State private var customDate = Date()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Quick Options") {
                    QuickReminderButton("In 30 minutes", minutes: 30)
                    QuickReminderButton("In 1 hour", minutes: 60)
                    QuickReminderButton("Tomorrow at 9 AM", date: tomorrowAt9AM)
                    Button("Custom...") { showCustomPicker = true }
                }
            }
            .sheet(isPresented: $showCustomPicker) {
                DatePicker("Remind me at", selection: $customDate)
                    .datePickerStyle(.graphical)
                // Save/Cancel toolbar
            }
        }
    }
}
```

#### B. Task Row Bell Icon
**File:** `ios-swift/Notelayer/Notelayer/Views/TaskItemView.swift`

**Add bell icon indicator:**
```swift
HStack(alignment: .top, spacing: 12) {
    // Checkbox
    Button(action: onToggleComplete) { ... }
    
    // Content
    VStack(alignment: .leading, spacing: 6) {
        // Title with bell icon
        HStack(spacing: 4) {
            Text(task.title)
                .strikethrough(task.completedAt != nil)
                .foregroundColor(...)
            
            // NEW: Bell icon if reminder set
            if task.reminderDate != nil {
                Image(systemName: "bell.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        
        // Metadata row...
    }
}
```

#### C. Context Menu Addition
**File:** `ios-swift/Notelayer/Notelayer/Views/Shared/RowContextMenu.swift`

**Add reminder option:**
```swift
struct RowContextMenuModifier: ViewModifier {
    let onShare: () -> Void
    let onCopy: () -> Void
    let onAddToCalendar: (() -> Void)?
    let onSetReminder: (() -> Void)?  // NEW
    let onRemoveReminder: (() -> Void)?  // NEW
    let onDelete: (() -> Void)?
    let hasReminder: Bool  // NEW
    
    func body(content: Content) -> some View {
        content.contextMenu {
            Button("Share…") { onShare() }
            Button("Copy") { onCopy() }
            if let onAddToCalendar {
                Button("Add to Calendar") { onAddToCalendar() }
            }
            
            // NEW: Reminder management
            if hasReminder, let onRemoveReminder {
                Button("Remove Reminder", role: .destructive) {
                    onRemoveReminder()
                }
            } else if let onSetReminder {
                Button("Set Reminder") {
                    onSetReminder()
                }
            }
            
            if let onDelete {
                Button("Delete", role: .destructive) { onDelete() }
            }
        }
    }
}
```

#### D. TaskEditView Integration
**File:** `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`

**Add reminder section:**
```swift
var body: some View {
    NavigationStack {
        List {
            Section("Title") { ... }
            Section("Categories") { ... }
            Section("Priority") { ... }
            Section("Due Date") { ... }
            
            // NEW: Reminder Section
            Section("Reminder") {
                if let reminderDate = task.reminderDate {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        Text(reminderDate.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                    }
                    
                    Button(role: .destructive) {
                        removeReminder()
                    } label: {
                        Text("Remove Reminder")
                    }
                } else {
                    Button {
                        showReminderPicker = true
                    } label: {
                        HStack {
                            Text("Set Reminder")
                            Spacer()
                            Image(systemName: "bell.badge.plus")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section("Notes") { ... }
            Section { /* Delete */ }
        }
        .sheet(isPresented: $showReminderPicker) {
            ReminderPickerSheet(...)
        }
    }
}
```

#### E. Settings - Reminders Management Page
**New File:** `ios-swift/Notelayer/Notelayer/Views/RemindersSettingsView.swift`

**Features:**
- List all tasks with reminders
- Sort by reminder time (soonest first)
- Swipe to cancel reminder
- Empty state if no reminders
- Tap task to open TaskEditView

**Structure:**
```swift
struct RemindersSettingsView: View {
    @StateObject private var store = LocalStore.shared
    @State private var pendingReminders: [(Task, Date)] = []
    
    var body: some View {
        NavigationStack {
            List {
                if pendingReminders.isEmpty {
                    ContentUnavailableView(
                        "No Active Reminders",
                        systemImage: "bell.slash",
                        description: Text("Set reminders on your tasks to see them here")
                    )
                } else {
                    ForEach(sortedReminders, id: \.0.id) { (task, reminderDate) in
                        ReminderRow(task: task, reminderDate: reminderDate)
                            .swipeActions {
                                Button(role: .destructive) {
                                    cancelReminder(for: task)
                                } label: {
                                    Label("Cancel", systemImage: "bell.slash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadReminders()
            }
        }
    }
    
    private var sortedReminders: [(Task, Date)] {
        pendingReminders.sorted { $0.1 < $1.1 }  // Soonest first
    }
}

struct ReminderRow: View {
    let task: Task
    let reminderDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.title)
                .font(.body)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "bell.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text(timeUntilReminder)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var timeUntilReminder: String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: reminderDate, relativeTo: Date())
    }
}
```

**Add to ProfileSettingsView:**
```swift
Section("Notifications") {
    NavigationLink {
        RemindersSettingsView()
    } label: {
        Label("Reminders", systemImage: "bell.badge")
    }
}
```

### 5. Notification Handling

#### AppDelegate Integration
**File:** `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`

**Add UNUserNotificationCenterDelegate:**
```swift
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(...) -> Bool {
        // ... existing code
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Register notification categories/actions
        registerNotificationActions()
        
        return true
    }
    
    private func registerNotificationActions() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Complete",
            options: [.foreground]
        )
        
        let openAction = UNNotificationAction(
            identifier: "OPEN_TASK",
            title: "Open",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, openAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let taskId = userInfo["taskId"] as? String else {
            completionHandler()
            return
        }
        
        switch response.actionIdentifier {
        case "COMPLETE_TASK":
            completeTask(taskId: taskId)
        case "OPEN_TASK", UNNotificationDefaultActionIdentifier:
            openTask(taskId: taskId)
        default:
            break
        }
        
        completionHandler()
    }
    
    // Handle notification when app in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner/sound even when app is open
        completionHandler([.banner, .sound])
    }
}
```

### 6. LocalStore Integration

**File:** `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`

**Add reminder methods:**
```swift
func setReminder(for taskId: String, at date: Date) async {
    guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
    var task = tasks[index]
    
    // Cancel existing reminder if any
    if let existingId = task.reminderNotificationId {
        await ReminderManager.shared.cancelReminder(notificationId: existingId)
    }
    
    // Schedule new reminder
    do {
        let notificationId = UUID().uuidString
        task.reminderDate = date
        task.reminderNotificationId = notificationId
        
        try await ReminderManager.shared.scheduleReminder(
            for: task,
            at: date,
            categories: categories
        )
        
        tasks[index] = task
        saveTasks()
        
        if let backend, !suppressBackendWrites {
            _Concurrency.Task { try? await backend.upsert(task: task) }
        }
    } catch {
        print("Failed to schedule reminder: \(error)")
    }
}

func removeReminder(for taskId: String) async {
    guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
    var task = tasks[index]
    
    if let notificationId = task.reminderNotificationId {
        await ReminderManager.shared.cancelReminder(notificationId: notificationId)
    }
    
    task.reminderDate = nil
    task.reminderNotificationId = nil
    tasks[index] = task
    saveTasks()
    
    if let backend, !suppressBackendWrites {
        _Concurrency.Task { try? await backend.upsert(task: task) }
    }
}
```

**Auto-cancel on completion:**
```swift
func toggleTaskCompletion(_ task: Task) {
    guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
    var updatedTask = task
    
    if updatedTask.completedAt == nil {
        updatedTask.completedAt = Date()
        
        // NEW: Cancel reminder when completing task
        if let notificationId = updatedTask.reminderNotificationId {
            _Concurrency.Task {
                await ReminderManager.shared.cancelReminder(notificationId: notificationId)
            }
            updatedTask.reminderDate = nil
            updatedTask.reminderNotificationId = nil
        }
    } else {
        updatedTask.completedAt = nil
    }
    
    tasks[index] = updatedTask
    saveTasks()
    // ...backend sync
}
```

### 7. Firebase Backend Sync

**File:** `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift`

**Update task mapping:**
```swift
func upsert(task: Task) async throws {
    let data: [String: Any] = [
        "id": task.id,
        "title": task.title,
        "categories": task.categories,
        "priority": task.priority.rawValue,
        // ... existing fields
        
        // NEW: Reminder fields
        "reminderDate": task.reminderDate?.timeIntervalSince1970 ?? NSNull(),
        "reminderNotificationId": task.reminderNotificationId ?? NSNull()
    ]
    // ... save to Firestore
}

private func taskFromDocument(_ doc: DocumentSnapshot) throws -> Task {
    let data = doc.data() ?? [:]
    // ... existing field parsing
    
    // NEW: Parse reminder fields
    let reminderTimestamp = data["reminderDate"] as? TimeInterval
    let reminderDate = reminderTimestamp.map { Date(timeIntervalSince1970: $0) }
    let reminderNotificationId = data["reminderNotificationId"] as? String
    
    return Task(
        // ... existing fields
        reminderDate: reminderDate,
        reminderNotificationId: reminderNotificationId
    )
}
```

**Note:** After syncing, reschedule notifications on device (notifications don't sync across devices, only reminder data)

## Implementation Steps

### Phase 1: Core Infrastructure (Essential)
- [ ] Update Task model with reminder fields
- [ ] Add `NSUserNotificationsUsageDescription` to Info.plist
- [ ] Create `ReminderManager.swift` with notification scheduling
- [ ] Implement permission request flow
- [ ] Register notification categories and actions in AppDelegate
- [ ] Add UNUserNotificationCenterDelegate methods

### Phase 2: UI Components (Essential)
- [ ] Create `ReminderPickerSheet.swift` with presets + custom picker
- [ ] Add bell icon to `TaskItemView.swift`
- [ ] Update `RowContextMenu.swift` with Set/Remove Reminder
- [ ] Add Reminder section to `TaskEditView.swift`
- [ ] Create `RemindersSettingsView.swift`
- [ ] Add Reminders link to `ProfileSettingsView.swift`

### Phase 3: LocalStore Integration (Essential)
- [ ] Add `setReminder(for:at:)` method
- [ ] Add `removeReminder(for:)` method
- [ ] Update `toggleTaskCompletion` to auto-cancel reminders
- [ ] Implement reminder cleanup on task deletion

### Phase 4: Backend Sync (Essential)
- [ ] Update Firebase task serialization with reminder fields
- [ ] Update Firebase task deserialization
- [ ] Handle reminder rescheduling after sync

### Phase 5: Testing & Polish (Essential)
- [ ] Test permission request flow
- [ ] Test notification scheduling and delivery
- [ ] Test "Complete Task" action from notification
- [ ] Test "Open Task" action (deep linking)
- [ ] Test reminder cancellation
- [ ] Test Settings reminders page
- [ ] Test swipe-to-cancel in Settings
- [ ] Test reminder sync across devices

## Edge Cases & Error Handling

1. **Permission Denied**
   - Show alert explaining why notifications are useful
   - Provide "Open Settings" button

2. **iOS Notification Limit (64 pending)**
   - Unlikely to hit, but handle gracefully
   - Show warning if approaching limit

3. **Reminder Time in Past**
   - Validate and show error
   - Don't allow scheduling past reminders

4. **Task Deleted with Active Reminder**
   - Cancel notification in `deleteTask` method
   - Clean up orphaned notifications

5. **App Uninstalled/Reinstalled**
   - Notifications lost (expected iOS behavior)
   - Reminder data syncs back from Firebase
   - Need to reschedule on device

6. **Notification Fired but Task Already Completed**
   - Handle gracefully (notification just closes)
   - Clean up reminder data

## Testing Checklist

- [ ] Set reminder with quick presets (30 min, 1 hour, tomorrow)
- [ ] Set custom reminder with date/time picker
- [ ] Verify bell icon appears on task row
- [ ] Receive notification at scheduled time
- [ ] Tap "Complete Task" from notification
- [ ] Tap "Open Task" from notification
- [ ] Cancel reminder from context menu
- [ ] Cancel reminder from TaskEditView
- [ ] View all reminders in Settings page
- [ ] Swipe to cancel reminder in Settings
- [ ] Complete task and verify reminder auto-cancels
- [ ] Delete task and verify reminder cancels
- [ ] Test permission request on first reminder
- [ ] Test permission denied handling
- [ ] Verify reminders sync to Firebase
- [ ] Test notification when app in foreground

## Success Criteria

✅ Users can set reminders for any task  
✅ Reminders use simple date/time picker with presets  
✅ Notifications show task title and category icons  
✅ Notification actions work (Complete, Open)  
✅ Bell icon visible on tasks with reminders  
✅ Reminders auto-cancel when task completed  
✅ Dedicated Settings page shows all reminders  
✅ Swipe-to-cancel works in Settings  
✅ Reminders sync across devices  
✅ Permission requested appropriately  
✅ No crashes or data loss

## Future Enhancements (Not in Scope)

- Multiple reminders per task
- Recurring reminders
- Snooze functionality
- Reminder templates
- Smart reminder suggestions based on task priority/due date
- Reminder statistics/insights
