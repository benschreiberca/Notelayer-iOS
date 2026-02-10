# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Fix the regression where tapping the checkmark in the Done list fails to move a task back to Doing.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Inspect UI interaction handling first (row + checkbox taps) - most likely source of ignored taps.
- Decision 2: Validate LocalStore toggle paths only after UI is confirmed - avoids unnecessary data-layer changes.

## Tasks:

- [x] 🟩 **Step 1: Reproduce + pinpoint**
  - [x] 🟩 Reproduce in Done list and confirm tap behavior
  - [x] 🟩 Identify the Done list row component and its tap handlers

- [x] 🟩 **Step 2: UI interaction fix**
  - [x] 🟩 Inspect nested buttons/gestures that may intercept the checkmark tap
  - [x] 🟩 Update row structure so the checkmark tap reliably toggles completion

- [x] 🟩 **Step 3: Data flow verification**
  - [x] 🟩 Confirm toggle calls LocalStore restore path when completedAt is set
  - [x] 🟩 Verify state persists in store and not overwritten by list filtering/backend sync

- [x] 🟩 **Step 4: Validate**
  - [x] 🟩 Tap checkmark in Done list moves task to Doing
  - [x] 🟩 Repeat toggle across List/Priority/Category/Date views
