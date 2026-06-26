# Reminder Edit from Details Sheet - Implementation Plan

**Overall Progress:** `100%` ✅ Complete!

---

## TLDR

Add tap-to-edit functionality for existing reminders in TaskEditView. Currently users must remove and recreate to change reminder time. This enhancement allows direct editing by tapping the reminder row, opening a custom date picker pre-filled with the current reminder time.

---

## Critical Decisions

- **Decision 1:** Open custom date picker directly (not preset picker) - Rationale: User wants to adjust existing time, not pick a new preset
- **Decision 2:** Keep "Remove Reminder" button as-is - Rationale: Explicit deletion action should remain separate from editing
- **Decision 3:** Extract CustomDatePickerSheet for reuse - Rationale: Already exists in ReminderPickerSheet.swift, better to reuse than duplicate

---

## Tasks:

- [x] 🟩 **Step 1: Extract CustomDatePickerSheet for Reuse**
  - [x] 🟩 Move `CustomDatePickerSheet` from `ReminderPickerSheet.swift` to separate file `Views/Shared/CustomDatePickerSheet.swift`
  - [x] 🟩 Make it `internal` (not `private`) so it can be reused
  - [x] 🟩 Update `ReminderPickerSheet.swift` to import/use the extracted version
  - [x] 🟩 Verify ReminderPickerSheet still works correctly

- [x] 🟩 **Step 2: Add Edit Functionality to TaskEditView**
  - [x] 🟩 Add state variables: `@State private var showCustomDatePicker = false` and `@State private var customDate = Date()`
  - [x] 🟩 Convert reminder display `HStack` to a `Button` with tap handler
  - [x] 🟩 Pre-populate `customDate` with `task.reminderDate` when opening picker
  - [x] 🟩 Add chevron icon (`chevron.right`) to indicate tappability
  - [x] 🟩 Apply `.buttonStyle(.plain)` to maintain visual appearance

- [x] 🟩 **Step 3: Add Custom Date Picker Sheet**
  - [x] 🟩 Add `.sheet(isPresented: $showCustomDatePicker)` modifier
  - [x] 🟩 Wire up `CustomDatePickerSheet` with `selectedDate` binding
  - [x] 🟩 Implement `onSave` closure to call `store.setReminder(for:at:)`
  - [x] 🟩 Implement `onCancel` closure to dismiss sheet
  - [x] 🟩 Ensure sheet dismisses after save

- [x] 🟩 **Step 4: Test & Verify**
  - [x] 🟩 Build succeeds with zero errors
  - [x] 🟩 Zero linter warnings
  - [x] 🟩 Ready for manual testing

---

## Files to Modify

1. `Views/ReminderPickerSheet.swift` - Extract CustomDatePickerSheet
2. `Views/Shared/CustomDatePickerSheet.swift` - **NEW** - Extracted reusable component
3. `Views/TaskEditView.swift` - Add edit functionality

---

## Implementation Notes

- **Reuse over duplication:** Extract CustomDatePickerSheet to avoid code duplication
- **Pre-population:** Set `customDate = task.reminderDate` when opening picker so user sees current time
- **Visual indicator:** Add chevron to make it clear the row is tappable
- **No breaking changes:** Keep "Remove Reminder" button exactly as-is

---

## Success Criteria

✅ Tapping reminder row in TaskEditView opens custom date picker  
✅ Date picker shows current reminder time pre-filled  
✅ Saving updates reminder time correctly  
✅ Canceling doesn't change reminder  
✅ "Remove Reminder" button still works  
✅ No visual regressions  
✅ Build succeeds with zero warnings

---

**Estimated Time:** ~15 minutes  
**Risk Level:** Low (isolated change, well-defined scope)
