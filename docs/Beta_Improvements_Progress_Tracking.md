# Feature Implementation Plan

**Overall Progress:** `90%`

## TLDR
Add guarded category deletion with a choice to delete or bulk-rename tasks, fix done-to-doing toggling, and make the plus icon tappable in the new-task control.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Only show a confirmation action sheet when deleting a category that still has tasks - keeps empty deletes quick.
- Decision 2: Bulk-rename reassigns the category ID in affected tasks rather than mutating task titles - minimal data churn.
- Decision 3: Fix toggle behavior in the existing task row control to avoid new state pathways - smallest surface-area change.

## Tasks:

- [x] 🟩 **Step 1: Category delete entry + warning sheet**
  - [x] 🟩 Add delete affordance in category manager list
  - [x] 🟩 Detect task count for the category and branch to immediate delete vs confirm sheet
  - [x] 🟩 Action sheet: Delete Category, Bulk Rename Tasks, Cancel
  - [x] 🟩 Solution idea: use `confirmationDialog` to match current SwiftUI patterns

- [x] 🟩 **Step 2: Bulk rename workflow**
  - [x] 🟩 Present target category picker (exclude the category being deleted)
  - [x] 🟩 Reassign affected tasks to the selected category
  - [x] 🟩 Remove deleted category and refresh store state
  - [x] 🟩 Solution idea: update tasks in one batch, then persist

- [x] 🟩 **Step 3: Done → Doing toggle fix**
  - [x] 🟩 Ensure the completion toggle is not blocked by row tap handling
  - [x] 🟩 Verify that completion toggles both directions in all modes
  - [x] 🟩 Solution idea: avoid nested `Button` interactions for the row

- [x] 🟩 **Step 4: New task touch target**
  - [x] 🟩 Expand hit-testing to include the plus icon
  - [x] 🟩 Solution idea: add a row-level tap gesture and content shape

- [ ] 🟨 **Step 5: Build + quick verification**
  - [x] 🟩 Run a local build
  - [ ] 🟥 Spot-check the three behaviors in the UI
