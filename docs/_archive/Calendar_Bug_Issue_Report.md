# Issue: Calendar Sheet Auto-Closing Bug

## TL;DR
When clicking the "calendar icon" in the Task Details view, a calendar sheet appears but immediately opens and closes itself automatically, forcing an app restart.

## Current State vs Expected Outcome
- **Current Behavior**: The calendar sheet (native iOS event editor) is presented but dismisses itself instantly without user interaction.
- **Expected Behavior**: The sheet should remain open for the user to edit or save the calendar event.

## Relevant Files
- `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift` (Likely source of the presentation logic)
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift` (Similar logic used here)
- `ios-swift/Notelayer/Notelayer/Views/Shared/CalendarEventEditView.swift` (The wrapper for the native controller)

## Risk/Notes
- This often happens in SwiftUI when the state variable controlling a sheet is modified during the presentation animation.
- Investigation shows the `Binding` used for the sheet might be triggering a re-render that clears the `item` state.

## Labels
- **Type**: Bug
- **Priority**: High
- **Effort**: Medium
