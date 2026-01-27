# Issue: Edit Reminder from TaskEditView Details Sheet

**Type:** Enhancement  
**Priority:** Low  
**Effort:** Small (~15 minutes)  
**Branch:** `reminders-feature` (or new branch)

---

## TL;DR

Users can't edit an existing reminder directly from the TaskEditView details sheet. They can only remove it and set a new one. Add tap-to-edit functionality on the reminder row.

---

## Current Behavior

In **TaskEditView** "Reminder" section:
- When reminder exists: Shows reminder date/time (absolute + relative)
- User can tap "Remove Reminder" button (destructive)
- To change the time, they must: Remove → Set New Reminder → Pick new time (3 steps)

---

## Expected Behavior

In **TaskEditView** "Reminder" section:
- When reminder exists: Shows reminder date/time (absolute + relative)
- **Tapping the reminder row** opens custom date picker directly
- User can adjust time immediately (1 tap)
- "Remove Reminder" button stays as-is for deletion

---

## Implementation Details

### Changes Required

**File:** `Views/TaskEditView.swift`

**Current code (~line 124-137):**
```swift
if let reminderDate = task.reminderDate {
    HStack {
        Image(systemName: "bell.fill")
            .foregroundColor(.orange)
        VStack(alignment: .leading, spacing: 2) {
            Text(reminderDate.formatted(date: .abbreviated, time: .shortened))
                .font(.body)
            Text(relativeTimeText(for: reminderDate))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        Spacer()
    }
    // ... Remove button below
}
```

**Update to:**
```swift
if let reminderDate = task.reminderDate {
    Button {
        customDate = reminderDate // Pre-populate with current time
        showCustomDatePicker = true
    } label: {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(reminderDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.body)
                Text(relativeTimeText(for: reminderDate))
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
    // ... Remove button below
}
```

**Additional state needed:**
```swift
@State private var showCustomDatePicker = false
@State private var customDate = Date()
```

**Add sheet:**
```swift
.sheet(isPresented: $showCustomDatePicker) {
    CustomDatePickerSheet(
        selectedDate: $customDate,
        onSave: { date in
            _Concurrency.Task {
                await store.setReminder(for: task.id, at: date)
            }
            showCustomDatePicker = false
        },
        onCancel: {
            showCustomDatePicker = false
        }
    )
}
```

**Note:** `CustomDatePickerSheet` already exists in `ReminderPickerSheet.swift` (private struct). Either:
- Extract it to a separate file for reuse, OR
- Duplicate it in TaskEditView (simpler, faster)

---

## User Flow

**Before (3 steps):**
```
1. Tap "Remove Reminder" button
2. Tap "Set Reminder"  
3. Choose new time from picker
```

**After (1 tap):**
```
1. Tap reminder row → Date picker opens with current time pre-filled → Adjust → Save
```

---

## Files to Touch

1. `Views/TaskEditView.swift` - Add tap handler + custom date picker sheet
2. `Views/ReminderPickerSheet.swift` - (optional) Extract CustomDatePickerSheet if reusing

---

## Risks/Notes

- **Low risk:** Isolated change to existing view
- **UX improvement:** Faster workflow for editing reminder times
- **No breaking changes:** Keep "Remove Reminder" button for explicit deletion
- **Design decision:** Opens custom picker (not preset picker) for direct time adjustment

---

## Priority Justification

**Low priority** because:
- Feature already works (just requires extra steps)
- Not blocking any workflows
- Nice-to-have UX polish

Can be done anytime after main reminder feature is tested and working.

---

**Status:** Captured - Not yet implemented  
**Created:** January 27, 2025
