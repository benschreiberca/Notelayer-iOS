# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Move the "New Task" input to the bottom of each group in Date, Priority, and Category views (after active tasks), without changing any other UI, gestures, or drag-and-drop behavior.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Reorder only the "New Task" placement in grouped views (Date/Priority/Category) - keeps List view unchanged and preserves existing UI behavior.
- Decision 2: Place "New Task" after active tasks within each group - matches clarified expectation without impacting completed/overdue grouping logic.

## Tasks:

- [x] 🟩 **Step 1: Locate grouped view sections and current "New Task" placement**
  - [x] 🟩 Identify Date, Priority, and Category group builders in `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
  - [x] 🟩 Confirm List view placement to leave unchanged

- [x] 🟩 **Step 2: Move "New Task" row to bottom of active tasks in grouped views**
  - [x] 🟩 Reorder `TaskInputView` to render after `TodoGroupTaskList` in Date groups
  - [x] 🟩 Reorder `TaskInputView` to render after `TodoGroupTaskList` in Priority and Category groups

- [x] 🟩 **Step 3: Validate no UI/gesture/drag-and-drop changes**
  - [x] 🟩 Ensure list view placement is untouched
  - [x] 🟩 Confirm no changes to drag/drop callbacks or touch targets
