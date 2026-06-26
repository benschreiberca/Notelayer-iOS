---
title: Bug Tracker
last_updated: 2026-06-26
status: active
scope: notelayer-ios
group: governance
tags: [bugs, fixes]
---

# Bug Tracker

Active bugs across the Notelayer codebase. Each bug gets a `fix/` branch when work starts.

---

## Open

### BUG-001 — "Done" group scroll lag
**Reported:** 2026-06-26  
**Branch:** `fix/done-scroll-lag`  
**Status:** Open

Scrolling in the "Done" task group is noticeably laggy. The "Doing" group appears to have had this fixed. The "Done" group still shows the older behavior. Likely the same fix (e.g. lazy rendering, row diffing, or `@State` re-evaluation) needs to be applied to the Done list.

**File to check:** `Views/TodosView.swift` — look for the Done group's list rendering vs. Doing group.

---

### BUG-002 — Subtask disappears on check-off instead of moving to "Done"
**Reported:** 2026-06-26  
**Branch:** `fix/subtask-done-visibility`  
**Status:** Open

When a subtask is checked off, it disappears from the list entirely. Expected behavior: it should move to the "Done" group (consistent with how parent tasks behave). Likely a filtering/state issue where subtasks are excluded from the Done group's query or the completion state update doesn't trigger re-grouping.

**File to check:** `Views/TodosView.swift` (subtask rendering logic), `Data/LocalStore.swift` (task completion + filtering).

---

### BUG-003 — Subtask text field doesn't auto-focus; has default text to delete
**Reported:** 2026-06-26  
**Branch:** `fix/subtask-focus`  
**Status:** Open

When adding a new subtask, the cursor is not automatically placed in the text entry field — the user has to tap it manually. Additionally there is default placeholder or pre-filled text that must be deleted before typing. Both are friction in a flow that should be instant.

**Expected:** New subtask row appears → cursor is immediately focused → field is empty, ready to type.

**File to check:** `Views/TodosView.swift` or wherever the subtask add row is rendered — look for `@FocusState` / `.focused()` usage and any default text initialization.

---

## In Progress

*(none)*

---

## Fixed

*(none yet)*

---

## Notes

- Use `fix/` branch prefix for all bug fixes.
- Link the branch name here when work starts.
- Move to Fixed when merged to main.
