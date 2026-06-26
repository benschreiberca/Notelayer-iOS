# Feature Implementation Plan

**Overall Progress:** `92%`

## TLDR
Add native-feeling Shake to Undo for task deletions so users can recover immediately from destructive actions.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Limit undo scope to task deletions first - highest-impact action with minimal scope.
- Decision 2: Use a shared `UndoManager` tied to a persistent responder - ensures shake prompt sees delete actions.

## Tasks:

- [x] 🟩 **Step 1: Define undo scope + payload**
  - [x] 🟩 Confirm undo applies to task deletions only
  - [x] 🟩 Identify the full task data needed to restore

- [x] 🟩 **Step 2: Wire undo registration**
  - [x] 🟩 Register undo at task delete call sites
  - [x] 🟩 Ensure restore re-inserts task and persists to storage/sync

- [x] 🟩 **Step 3: Integrate native shake UI**
  - [x] 🟩 Use a shared `UndoManager` anchored by `UndoShakeHost` and reassert its responder
  - [x] 🟩 Ensure undo action names read well in the system prompt

- [ ] 🟨 **Step 4: Verify**
  - [ ] 🟨 Delete task → Shake → Undo restores it
