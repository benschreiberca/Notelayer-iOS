# Feature Implementation Master Plan

**Branch:** `more-features-share-and-remind`  
**Status:** Planning Complete - Ready for Implementation  
**Date:** January 27, 2025

## Overview

This document provides a high-level overview of three major features planned for implementation in Notelayer. Each feature has a detailed implementation plan in its own document.

## Features Summary

### 1. 🗓️ Calendar Export ✅ COMPLETE
**Complexity:** Medium | **Priority:** High  
**Plan:** `CALENDAR_EXPORT_FEATURE_PLAN.md`  
**Summary:** `CALENDAR_EXPORT_IMPLEMENTATION_SUMMARY.md`

Export tasks to device calendar with full metadata.

**Key Capabilities:**
- Export to iOS Calendar via EventKit
- Includes task title, categories, notes, priority
- 15-minute default event duration
- Accessible from long-press menu + TaskEditView
- Tasks without due date use today's date

**Main Components:**
- CalendarExportManager.swift (EventKit integration)
- Updated context menu with "Add to Calendar"
- Permission handling
- Error alerts

---

### 2. ⏰ Task Reminders ✅ COMPLETE
**Complexity:** High | **Priority:** High  
**Plan:** `REMINDER_FEATURE_PLAN.md`  
**Summary:** `REMINDER_IMPLEMENTATION_SUMMARY.md`  
**Tracking:** `REMINDER_IMPLEMENTATION_TRACKING.md`

Alarm-like reminder notifications for tasks.

**Key Capabilities:**
- Set custom reminder times for any task
- Quick presets (30 min, 1 hour, tomorrow) + custom picker
- Notification shows task title + category icons
- "Complete Task" and "Open Task" notification actions
- Bell icon (🔔) on tasks with reminders
- Dedicated Settings page to manage all reminders
- Auto-cancel when task completed
- Sync across devices via Firebase

**Main Components:**
- ReminderManager.swift (UserNotifications integration)
- ReminderPickerSheet.swift (UI for setting reminders)
- RemindersSettingsView.swift (manage all reminders)
- Task model enhancement (reminderDate, reminderNotificationId)
- AppDelegate notification handling
- Firebase sync integration

---

### 3. 📤 Share Extension
**Complexity:** Very High | **Priority:** High  
**Plan:** `SHARE_EXTENSION_FEATURE_PLAN.md`

Receive content from other apps via iOS share sheet.

**Key Capabilities:**
- Accept URLs and plain text from any app
- Auto-fetch webpage titles for URLs
- Edit text field before saving
- Attribution shows source app
- URLs are clickable in task notes
- Creates tasks (not notes)
- Single item per share

**Main Components:**
- New Share Extension target in Xcode
- ShareViewController.swift (extension UI)
- SharedItem model (temporary storage)
- App Group for data sharing (already configured)
- LocalStore.processSharedItems() (convert to tasks)
- URL metadata fetching

---

## Implementation Order

### Recommended Sequence

**Phase 1: Calendar Export** (Estimated: 1-2 days)
- Lowest complexity
- No new targets or major architecture changes
- Standalone feature (no dependencies)
- Good warm-up for other features

**Phase 2: Task Reminders** (Estimated: 3-4 days)
- Medium complexity
- Introduces notification system (useful foundation)
- More extensive testing required
- Builds on existing Task model

**Phase 3: Share Extension** (Estimated: 3-4 days)
- Highest complexity
- Requires new Xcode target
- External integration testing needed
- Most moving parts

**Total Estimated Time:** 7-10 days of focused development

### Alternative: Parallel Development

If multiple developers or longer timeline:
- Calendar Export + Reminders can be developed in parallel
- Share Extension should be done last (most complex)

---

## Shared Dependencies

### Common Components
All three features use:
- LocalStore.swift (data persistence)
- Task model (Models.swift)
- Firebase backend (sync across devices)
- Error handling patterns
- Permission request patterns

### New Permissions Required

**Info.plist Additions:**
```xml
<!-- Calendar Export -->
<key>NSCalendarsUsageDescription</key>
<string>Notelayer needs calendar access to create events from your tasks.</string>

<!-- Task Reminders -->
<key>NSUserNotificationsUsageDescription</key>
<string>Notelayer sends reminders for your tasks at the times you choose.</string>
```

### Task Model Changes

**New Fields:**
```swift
struct Task: Identifiable, Codable {
    // ... existing fields
    
    // For Reminders feature
    var reminderDate: Date?
    var reminderNotificationId: String?
}
```

---

## Testing Strategy

### Unit Tests
- CalendarExportManager methods
- ReminderManager scheduling/cancellation
- SharedItem encoding/decoding
- URL title extraction

### Integration Tests
- Share extension → main app flow
- Reminder notification → task completion
- Calendar export with various task states
- Firebase sync with new fields

### Manual Testing
- Cross-app sharing (Safari, Chrome, iMessage, etc.)
- Notification interactions (Complete, Open)
- Calendar app verification
- Permission flows (granted/denied)
- Offline behavior

---

## Risk Assessment

### Low Risk
- **Calendar Export**: Uses standard EventKit, well-documented
- Minor UI changes to existing views

### Medium Risk
- **Task Reminders**: Notification system has edge cases
- Deep linking requires careful handling
- iOS notification limits (64 pending)

### High Risk
- **Share Extension**: New target, separate bundle
- App Group data sharing can be tricky
- Extension memory limits (~30MB)
- Network requests in extension (timeout concerns)

---

## Success Metrics

### Calendar Export
- Users can export tasks to calendar
- Zero crashes on permission denial
- Events appear correctly in Calendar app

### Task Reminders
- Notifications delivered at scheduled time
- Notification actions work reliably
- Settings page shows accurate list
- Sync works across devices

### Share Extension
- Notelayer appears in share sheet
- 90%+ success rate for URL title fetching
- Tasks created within 2 seconds
- Clear error messages for failures

---

## Rollback Plan

If issues arise:

**Calendar Export:**
- Easy rollback: remove menu items, hide feature
- No data model changes (safe)

**Task Reminders:**
- Medium rollback: new Task fields are optional
- Existing tasks unaffected
- Notifications can be cancelled in batch

**Share Extension:**
- Easy rollback: disable extension target
- Shared items in App Group can be cleared
- No impact on main app

---

## Documentation Needs

### User-Facing
- Help article: "How to export tasks to Calendar"
- Help article: "Setting reminders for tasks"
- Help article: "Sharing content to Notelayer"
- In-app tips/onboarding for new features

### Developer
- EventKit integration notes
- UserNotifications best practices
- Share Extension debugging guide
- App Group troubleshooting

---

## Future Considerations

### Post-Launch Enhancements

**Calendar Export:**
- Select target calendar
- Recurring events
- Two-way sync

**Task Reminders:**
- Multiple reminders per task
- Snooze functionality
- Smart suggestions

**Share Extension:**
- Support images/files
- Choose categories during share
- Rich link previews
- Batch sharing

---

## Getting Started

1. **Review individual feature plans:**
   - `CALENDAR_EXPORT_FEATURE_PLAN.md`
   - `REMINDER_FEATURE_PLAN.md`
   - `SHARE_EXTENSION_FEATURE_PLAN.md`

2. **Set up branch:**
   ```bash
   git checkout more-features-share-and-remind
   ```

3. **Start with Calendar Export** (recommended)
   - Follow Phase 1-3 in plan
   - Test thoroughly before moving on

4. **Proceed to Reminders**
   - Update Task model
   - Implement ReminderManager
   - Build UI components

5. **Complete with Share Extension**
   - Create new target
   - Build ShareViewController
   - Integrate with main app

---

## Questions or Issues?

Refer to the detailed implementation plans for:
- Specific code examples
- Edge case handling
- Testing checklists
- Success criteria

Ready to build! 🚀
