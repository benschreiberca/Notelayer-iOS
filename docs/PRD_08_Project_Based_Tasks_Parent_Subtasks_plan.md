# Feature Implementation Plan

**Overall Progress:** `78%`

## TLDR
Add parent-to-subtask hierarchy to represent multi-step work while preserving existing category semantics and avoiding timeline/project-management scope expansion.

## Critical Decisions
- Decision 1: Parent/subtask is structural hierarchy, not category replacement.
- Decision 2: This feature solves flat-model limitations only (no timeline/deadline framework).
- Decision 3: Existing task behaviors must remain clear and predictable after hierarchy rollout.
- Decision 4: Project-based tasks UI visibility is gated by `Enable Experimental Features`.

## Dependency Gates
- Gate A: LOCKED - hierarchy depth is one level only (parent -> subtasks).
- Gate B: LOCKED - parent auto-completes when all subtasks are done; delete uses explicit prompt options.
- Gate C: LOCKED - top-level counts include parents + standalone tasks only (exclude subtasks).
- Gate D: LOCKED - parent/subtask categories both supported; subtasks inherit parent categories by default.
- Gate E: LOCKED - project-task UI visibility is gated by `PRD_01`.

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

### UI Consistency Evidence (Wave 3)
- Pre-check completed against hierarchy-related surfaces in `TodosView.swift`, `TaskItemView.swift`, and `TaskEditView.swift`.
- Post-check completed: hierarchy interactions are implemented with native `List`, `Section`, `Label`, context menus, and `confirmationDialog`.
- Quality trade-off: +316 net lines across hierarchy UI surfaces to support parent/subtask semantics and deterministic delete flows.

## Tasks:

- [x] ✅ **Step 1: Finalize Hierarchy Behavior Contract**
  - [x] ✅ Enforced one-level hierarchy (parent -> subtasks).
  - [x] ✅ Implemented parent auto-complete plus manual reopen override behavior.
  - [x] ✅ Implemented parent delete options: cascade delete or detach subtasks.
  - [x] ✅ Implemented detach/re-parent pathways through task edit controls.

- [x] ✅ **Step 1.5: Integrate Experimental Visibility Gate**
  - [x] ✅ Project hierarchy affordances appear only when `Enable Experimental Features` is on.
  - [x] ✅ Hierarchy affordances are hidden cleanly when gate is off.
  - [x] ✅ Non-experimental list behavior remains flat and unaffected.

- [x] ✅ **Step 2: Define Data Model Changes**
  - [x] ✅ Added `parentTaskId` and parent reopen-override metadata.
  - [x] ✅ Added invariants for no cycles and no nested subtasks.
  - [x] ✅ Added migration/sanitization path for invalid parent references.

- [x] ✅ **Step 3: Implement Persistence And Sync Handling**
  - [x] ✅ Persisted hierarchy metadata locally and through existing storage flows.
  - [x] ✅ Added Firestore encode/decode support for hierarchy fields.
  - [x] ✅ Added hierarchy sanitization on remote snapshot/task apply.

- [x] ✅ **Step 4: Implement Core Task Interactions**
  - [x] ✅ Added subtask creation from parent rows.
  - [x] ✅ Added reorder/drop behavior within parent subtask scope.
  - [x] ✅ Added parent completion reconciliation when child state changes.

- [x] ✅ **Step 5: Implement List Rendering Rules**
  - [x] ✅ Parent rows show subtask controls and collapsed defaults.
  - [x] ✅ Expanded rows render indented subtasks with native affordances.
  - [x] ✅ Context menus and delete prompts remain native-pattern aligned.

- [x] ✅ **Step 6: Integrate Cross-Feature Semantics**
  - [x] ✅ Category grouping remains distinct from hierarchy structure.
  - [x] ✅ Insights totals now exclude subtasks from top-level counts.
  - [x] ✅ Parent/subtask reminder and calendar actions remain per-task.

- [x] ✅ **Step 7: Migration And Safety Validation**
  - [x] ✅ Added migration-time hierarchy sanitization for old or invalid parent links.
  - [x] ✅ Added safe behavior for gate-off mode without data loss.

- [ ] 🟨 **Step 8: Verification And Acceptance**
  - [x] ✅ Added unit coverage for top-level count semantics in insights.
  - [ ] 🟨 Full integration tests for create/edit/reorder/sync are pending.
  - [ ] 🟨 Manual QA for hierarchy readability/usability is pending.
  - [x] ✅ Post-change UI consistency review completed for hierarchy surfaces.
