# Issue: Calendar Sheet Auto-Closing Bug

## TL;DR
When clicking the "Add to Calendar" icon in the Task Details view (or from the main list), the native iOS calendar event sheet appears but then immediately closes itself, sometimes causing the app to become unresponsive.

## Current State vs Expected Outcome
- **Current State**: The `calendarEventToEdit` state is being reset during the sheet's presentation because the `Binding`'s `set` closure is being called by SwiftUI during the animation, which in turn clears the state and dismisses the sheet.
- **Expected Outcome**: The calendar sheet should remain open until the user explicitly saves or cancels the event.

## Relevant Files
- `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- `ios-swift/Notelayer/Notelayer/Views/Shared/CalendarEventEditView.swift`

## Risk/Notes
- This was caused by a circular state update in the `Binding` used for `.sheet(item:)`.
- The fix involves ensuring the `set` closure only clears the state when explicitly told to (i.e., when `$0` is `nil`).

## Labels
- **Type**: Bug
- **Priority**: High
- **Effort**: Low
