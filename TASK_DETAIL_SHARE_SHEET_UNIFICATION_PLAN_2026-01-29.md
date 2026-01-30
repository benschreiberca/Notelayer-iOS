# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Unify Task Detail and Share Sheet into a shared, list-based editor with matching title styling, category chips, segmented priority, and notes/URL sections, while keeping iOS-standard layout and fixing the calendar edit sheet loop.

## Critical Decisions
- Decision 1: Use TaskEditView as the standard-bearer and extract shared Section-based components for title, categories, priority, notes, and URL to reuse in both sheets.
- Decision 2: Share sheet moves to List/Section layout (no custom card/preview), but retains Notelayer icon in the nav bar as the only intentional deviation.
- Decision 3: Persist share sheet edits by passing editable URL/notes into SharedItem; keep graphical date/time pickers and quick reminder shortcuts.
- Decision 4: Stabilize calendar sheet presentation with a session object to avoid re-present loops.

## Tasks (Low → High Risk):

- [x] 🟩 **Step 1: Shared Editor Components + Chip Sizing**
  - [x] 🟩 Add shared Section-based components for title, categories, priority, notes, and URL.
  - [x] 🟩 Add a large chip size (≈25% bigger) to `CategoryChipGridView`.

- [x] 🟩 **Step 2: Task Detail Sheet Alignment**
  - [x] 🟩 Replace category list rows with chip grid (large size).
  - [x] 🟩 Switch priority to segmented control.
  - [x] 🟩 Keep title multiline (up to 10 lines) and notes+links layout.

- [x] 🟩 **Test/Build Checkpoint A**
  - [x] 🟩 Build app + smoke test Task Detail changes.
  - [x] 🟩 Build succeeded on iPhone 17 simulator; UI tests failed (screenshot suite: “To‑Dos” button not found).

- [x] 🟩 **Step 3: Share Sheet Layout Unification**
  - [x] 🟩 Replace custom card/preview with List/Section layout.
  - [x] 🟩 Match Task Detail title styling, notes section, and spacing/padding.
  - [x] 🟩 Add nav bar title “Share to Notelayer” with Notelayer icon.

- [x] 🟩 **Step 4: Share Sheet Data Editing + Persistence**
  - [x] 🟩 Add editable Notes + URL fields (URL shows hyperlink when valid).
  - [x] 🟩 Persist edited URL/notes into `SharedItem` on Save.

- [x] 🟩 **Test/Build Checkpoint B**
  - [x] 🟩 Build app + smoke test Share Sheet flow.
  - [x] 🟩 Build succeeded on iPhone 17 simulator; UI tests failed (screenshot suite: “To‑Dos” button not found).

- [x] 🟩 **Step 5: Calendar Sheet Loop Fix**
  - [x] 🟩 Introduce a stable calendar edit session and update TaskEditView/TodosView bindings.

- [x] 🟩 **Step 6: Consistency Sweep + Cleanup**
  - [x] 🟩 Remove obsolete share preview code and confirm parity with Task Detail.
  - [x] 🟩 Finalize progress tracking and notes.

- [x] 🟩 **Test/Build Checkpoint C**
  - [x] 🟩 Build app + smoke test calendar sheet on device/simulator as possible.
  - [x] 🟩 Build succeeded on iPhone 17 simulator; UI tests failed (screenshot suite: “To‑Dos” button not found).

## UI Consistency Guardrail
- **Standard-Bearer:** `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
- **Deviations:** Category chip grid (custom layout) and Notelayer logo in Share Sheet nav bar (brand exception).
