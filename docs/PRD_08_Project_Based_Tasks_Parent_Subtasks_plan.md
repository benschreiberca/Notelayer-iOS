# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Add parent-to-subtask hierarchy to represent multi-step work while preserving existing category semantics and avoiding timeline/project-management scope expansion.

## Critical Decisions
- Decision 1: Parent/subtask is structural hierarchy, not category replacement.
- Decision 2: This feature solves flat-model limitations only (no timeline/deadline framework).
- Decision 3: Existing task behaviors must remain clear and predictable after hierarchy rollout.

## Dependency Gates
- Gate A: Finalize hierarchy depth (single-level vs deeper nesting).
- Gate B: Finalize parent completion/deletion behavior.
- Gate C: Finalize counting semantics to avoid parent/subtask double counting.
- Gate D: Finalize category behavior across parent and subtasks.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Data/Models.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TaskItemView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
- `ios-swift/Notelayer/Notelayer/Services/InsightsAggregator.swift`

## UI Consistency Integration
- Before implementation, run `.codex/prompts/ui-consistency.md` in read-only mode:
- Standard-Bearer: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Deviators: task list rows and hierarchy interaction surfaces.
- Prefer native list/section indentation and disclosure affordances over custom containers.
- Use standard labels/icons for hierarchy indicators where possible.
- Run post-implementation consistency review and record deviations/line impact.

## Tasks:

- [ ] 🟥 **Step 1: Finalize Hierarchy Behavior Contract**
  - [ ] 🟥 Lock hierarchy depth rules for v1.
  - [ ] 🟥 Lock parent completion rules (manual/auto/hybrid).
  - [ ] 🟥 Lock deletion cascade/orphan/prompt behavior.
  - [ ] 🟥 Lock detach/re-parent rules for subtasks.

- [ ] 🟥 **Step 2: Define Data Model Changes**
  - [ ] 🟥 Add parent-child linkage fields to task model.
  - [ ] 🟥 Define invariants (no cycles, orphan rules, max depth if applicable).
  - [ ] 🟥 Define migration path for existing flat tasks.

- [ ] 🟥 **Step 3: Implement Persistence And Sync Handling**
  - [ ] 🟥 Persist parent/subtask relations locally.
  - [ ] 🟥 Ensure sync payloads preserve hierarchy integrity.
  - [ ] 🟥 Add reconciliation rules for conflicting hierarchy edits.

- [ ] 🟥 **Step 4: Implement Core Task Interactions**
  - [ ] 🟥 Create parent task and attach subtasks.
  - [ ] 🟥 Edit/reorder subtasks within parent scope.
  - [ ] 🟥 Handle parent/subtask completion per finalized rule.

- [ ] 🟥 **Step 5: Implement List Rendering Rules**
  - [ ] 🟥 Render parent and child tasks with clear structural cues.
  - [ ] 🟥 Add expand/collapse behavior if in scope.
  - [ ] 🟥 Keep list behavior readable without introducing custom heavy wrappers.

- [ ] 🟥 **Step 6: Integrate Cross-Feature Semantics**
  - [ ] 🟥 Ensure category grouping remains independent from hierarchy.
  - [ ] 🟥 Ensure analytics counts and summaries follow finalized counting rules.
  - [ ] 🟥 Ensure reminder/calendar behavior follows finalized parent/subtask scope.

- [ ] 🟥 **Step 7: Migration And Safety Validation**
  - [ ] 🟥 Validate no data loss during migration from flat tasks.
  - [ ] 🟥 Validate safe rollback behavior if hierarchy feature is disabled in test scenarios.

- [ ] 🟥 **Step 8: Verification And Acceptance**
  - [ ] 🟥 Unit tests for hierarchy invariants, completion, deletion, and counting rules.
  - [ ] 🟥 Integration tests for create/edit/reorder and sync scenarios.
  - [ ] 🟥 Manual QA for readability and usability of hierarchy in main list.
  - [ ] 🟥 Post-change UI consistency review for hierarchy list surfaces.
