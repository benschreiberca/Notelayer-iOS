# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Build a mandatory pre-save staging step for all voice captures with full user edit control, strict save validation, and a <=2s p95 preview target.

## Critical Decisions
- Decision 1: Preview is mandatory; no bypass path.
- Decision 2: Save model is batch-primary with per-item quick-save actions.
- Decision 3: Exit prompts every time.
- Decision 4: Save is blocked when required fields are missing.
- Decision 5: Staging persists during background/foreground in same session.
- Decision 6: Time-to-preview target is <=2 seconds p95.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Views/TaskInputView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Data/Models.swift`

## UI Consistency Integration
- Before implementation, run `.codex/prompts/ui-consistency.md` in read-only mode:
- Standard-Bearer: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Deviators: staging and preview surfaces touched by this feature.
- Use platform-standard list/section/edit controls for staged items.
- Avoid custom cards/wrappers unless necessary for core staged task readability.
- If custom UI is required, document rationale and line-count impact.
- Run post-implementation consistency pass and capture findings.

## Tasks:

- [ ] 🟥 **Step 1: Build Mandatory Staging Container**
  - [ ] 🟥 Route all parser output to staging before any persistence.
  - [ ] 🟥 Block direct insertion into main task list.
  - [ ] 🟥 Ensure staging can represent one or multiple tasks uniformly.

- [ ] 🟥 **Step 2: Implement Editing Operations**
  - [ ] 🟥 Allow add new staged task.
  - [ ] 🟥 Allow override/edit of parser-prefilled values.
  - [ ] 🟥 Allow delete staged task.
  - [ ] 🟥 Allow drag-and-drop reordering for staged tasks.

- [ ] 🟥 **Step 3: Implement Save Flows**
  - [ ] 🟥 Add primary `Save All` batch action.
  - [ ] 🟥 Add per-item quick-save actions where appropriate.
  - [ ] 🟥 Ensure per-item actions still enforce required-field validation.

- [ ] 🟥 **Step 4: Implement Validation Contract**
  - [ ] 🟥 Define required fields per staged task.
  - [ ] 🟥 Disable or block save when required fields are missing.
  - [ ] 🟥 Provide concise inline guidance for missing required values.

- [ ] 🟥 **Step 5: Implement Exit And Recovery Behavior**
  - [ ] 🟥 On exit attempt without save, show explicit prompt every time.
  - [ ] 🟥 Support `Discard` and `Continue Editing` actions.
  - [ ] 🟥 Prevent accidental dismissal paths from bypassing prompt.

- [ ] 🟥 **Step 6: Implement In-Session Persistence**
  - [ ] 🟥 Persist staging state through app background/foreground transitions.
  - [ ] 🟥 Restore editing context without data loss in same session.
  - [ ] 🟥 Define behavior for termination/force-quit edge case.

- [ ] 🟥 **Step 7: Performance Hardening**
  - [ ] 🟥 Measure time-to-preview from recording completion.
  - [ ] 🟥 Optimize parsing-to-preview pipeline to meet <=2s p95.
  - [ ] 🟥 Add instrumentation for p50/p95/p99 preview latency.

- [ ] 🟥 **Step 8: Verification And Acceptance**
  - [ ] 🟥 Unit tests for validation, save semantics, and exit prompts.
  - [ ] 🟥 Integration tests for single-item and multi-item staging flows.
  - [ ] 🟥 Manual QA for add/edit/delete/reorder and prompt reliability.
  - [ ] 🟥 Performance QA to confirm <=2s p95 target.
  - [ ] 🟥 Post-change UI consistency review of staging surfaces.
