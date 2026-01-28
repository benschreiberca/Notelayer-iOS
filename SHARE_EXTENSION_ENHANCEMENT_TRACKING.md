# Feature: Enhanced Share Sheet with Full Task Fields

**Type:** Feature Enhancement  
**Priority:** Medium  
**Effort:** Medium  
**Status:** Open  
**Branch:** `share-sheet-feature`

---

## TL;DR

Enhance the share sheet to include all task creation fields (categories, priority, due date, reminder) to match the main task edit view, allowing users to fully configure tasks at capture time.

## Current State

Share sheet currently shows:
- Title (editable text field)
- URL preview (read-only)
- Content preview (read-only)
- Source attribution (read-only)
- Save/Cancel buttons

**Missing fields:**
- Categories
- Priority
- Due Date
- Reminder/Nag

## Desired State

Share sheet should include all fields from `TaskEditView`:

### Fields to Add

1. **Categories** (custom UI)
   - Display as horizontal scrollable chip selector
   - Same chip style as task list cards (icon + name)
   - Multiple selection
   - Default: No categories selected

2. **Priority**
   - Picker or segmented control
   - Options: High, Medium, Low, Deferred
   - Default: Medium

3. **Due Date** (optional)
   - Button to show date picker
   - Display selected date if set
   - Option to remove date
   - Default: None

4. **Reminder/Nag** (optional)
   - Quick options: "Later today", "Tomorrow", "Custom"
   - Date/time picker for custom
   - Default: None

### UI Requirements

- **Category Chips (not list)**
  - User specifically requested chips instead of the list format used in TaskEditView
  - Horizontal scrollable row
  - Tap to toggle selection
  - Use same chip component as task cards in main list

- **Compact Layout**
  - All fields should fit without excessive scrolling
  - Consider collapsible sections or smart defaults

- **Visual Consistency**
  - Match Notelayer's design system
  - Use same colors, fonts, spacing as main app

## Implementation Notes

### Files to Modify

- `ios-swift/Notelayer/NotelayerShareExtension/ShareViewController.swift`
  - Update `ShareExtensionView` SwiftUI view
  - Add state variables for categories, priority, due date, reminder
  - Pass all fields to `saveTask()`

- `ios-swift/Notelayer/Notelayer/Data/SharedItem.swift`
  - Add optional fields: categories, priority, dueDate, reminderDate
  - Update `Codable` conformance

- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
  - Update `processSharedItems()` to use new fields when creating tasks
  - Remove hardcoded `priority: .medium` and `categories: []`

### Category Chips Component

Need to share category data between main app and extension:
- Categories are stored in `LocalStore`
- Extension needs read access to categories
- Could pass via App Group UserDefaults
- Or load from same source as main app

**Approach:**
1. Save categories to App Group UserDefaults when they change
2. Extension reads categories on load
3. Display as chips with tap-to-toggle

**Chip UI (reuse existing or create new):**
- Look for existing chip component in codebase
- If none exists, create reusable `CategoryChipView`
- Match styling from task list cards

### Priority Picker

Use `Picker` with `.segmented` style for compact display:
```swift
Picker("Priority", selection: $priority) {
    ForEach(Priority.allCases) { p in
        Text(p.label).tag(p)
    }
}
.pickerStyle(.segmented)
```

### Date Pickers

Reuse existing date picker sheets from TaskEditView:
- `DatePickerSheet` for due date
- `ReminderPickerSheet` for reminder

These may need to be moved to a shared location or duplicated in extension target.

## UX Considerations

### Quick Capture vs Full Creation

**Trade-off:** More fields = more friction vs more control

**Recommendation:**
- Make category/priority/date **optional** and easily skippable
- Default collapsed or at bottom of sheet
- Focus on title editing first
- Power users can expand for full options

### Smart Defaults

- Priority: Medium (most common)
- Categories: None (user can add later in main app)
- Dates: None (don't force date selection)

## Testing Checklist

Once implemented:
- [ ] Share URL and set categories - verify task has categories
- [ ] Share text and set priority - verify task has correct priority
- [ ] Share with due date - verify date appears in task
- [ ] Share with reminder - verify reminder is set
- [ ] Share with all fields - verify everything persists
- [ ] Share with no optional fields - verify defaults work
- [ ] Category chips display correctly
- [ ] Category selection state persists during editing
- [ ] Visual consistency with main app

## Risks & Dependencies

**Medium Complexity:**
- Need to sync categories between main app and extension
- More state management in share sheet
- Larger UI to maintain

**Dependency:**
- Requires fixing the "shared items not appearing" bug first
- No point adding fields if data doesn't persist

**Performance:**
- Share extension has memory limits (~30 MB)
- Keep category list reasonable size
- Avoid loading too much data

## Future Enhancements (Out of Scope)

- Tags/labels
- Task notes editing (currently auto-filled)
- Multiple item sharing (create multiple tasks)
- Smart suggestions based on URL/content
- Recently used categories

---

**Next Steps:**
1. Fix the data persistence bug first (see SHARE_EXTENSION_BUG_TRACKING.md)
2. Create reusable category chip component
3. Update SharedItem model with new fields
4. Implement enhanced share sheet UI
5. Test thoroughly with all field combinations
