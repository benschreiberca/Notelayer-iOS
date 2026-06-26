# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Use one dependency-driven master plan to execute PRD lanes in waves, reducing merge collisions on high-risk files (`InsightsView.swift`, `LocalStore.swift`, `Models.swift`) and preventing rework from unresolved requirement decisions, while treating `PRD_01` as the UI visibility gate for Insights, Voice Input, First-Time Onboarding, and Project-Based Tasks.

## Why This Order Is Better

- Moves unresolved decisions to a formal gate before coding.
- Separates interface-producing lanes from interface-consuming lanes.
- Avoids parallel edits to the same conflict-prone files.
- Preserves true parallelism where dependencies are low.

## Critical Decisions
- Decision 1: Use wave-based start order (not flat lane sequence).
- Decision 2: Do not start blocked lanes (F/G) until PRD gaps are closed.
- Decision 3: Treat local/sync state policy and parser contract as upstream interfaces.
- Decision 4: Run `ui-consistency` checks pre and post in every UI-touching wave.
- Decision 5: Treat experimental-visibility gate from `PRD_01` as upstream dependency for PRD 03/04/06/08 UI surfaces.

## High-Risk Shared Files

- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Data/Models.swift`
- `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`

## Wave Plan

- Wave 0: Decision Lock (No implementation)
- Wave 1: Foundations and contracts
- Wave 2: Dependent feature implementation
- Wave 3: Clarified late-stage features
- Wave 4: Integration hardening and merge train

## Tasks:

- [x] ✅ **Step 1: Wave 0 - Decision Lock (Hard Gate)**
  - [x] ✅ Lock PRD 01/03 local-vs-synced conflict policy.
  - [x] ✅ Lock PRD 06 video skip timing and preset default behavior.
  - [x] ✅ Lock PRD 07 mapping and structure-preservation rules.
  - [x] ✅ Lock PRD 08 hierarchy semantics (depth/completion/deletion/counting).
  - [x] ✅ Exit criteria: no open blocker in `PRD_Parallel_Execution_Control_Plan.md`.

- [x] ✅ **Step 2: Wave 1 - Foundations (Run In Parallel: A + C)**
  - [x] ✅ Lane A: implement gating contract and experimental visibility foundation.
  - [x] ✅ Lane C: implement parser contract/fixtures and stable output payload.
  - [x] ✅ UI consistency pre-check for A before edits.
  - [x] ✅ Exit criteria: A state contract frozen and experimental surface set gating available; C parser payload frozen.

- [x] ✅ **Step 3: Wave 2 - Dependent Lanes (Run In Parallel: B + D + E)**
  - [x] ✅ Lane B starts only after A merges visibility-gating surfaces.
  - [x] ✅ Lane D starts only after C parser payload is frozen.
  - [x] ✅ Lane E starts after A gating foundation is available (onboarding visibility gate dependency).
  - [x] ✅ Prevent cross-edit collisions on `InsightsView.swift`, staging surfaces, and onboarding visibility paths.
  - [x] ✅ UI consistency pre/post checks for B, D, and E.
  - [x] ✅ Exit criteria: B UX acceptance checks pass; D validation/performance checks pass; E onboarding flow and visibility-gate behavior pass.

- [x] ✅ **Step 4: Wave 3 - Clarified Late Lanes (Sequential: F then G)**
  - [x] ✅ Lane F started after PRD 07 clarifications were locked.
  - [x] ✅ Lane F changes landed before lane G changes in single-chat execution order.
  - [x] ✅ Lane G started only after PRD 08 clarifications were locked and A gate was available.
  - [x] ✅ UI consistency pre/post checks completed for F and G UI surfaces.
  - [x] ✅ Exit criteria met: F and G behavior implemented; migration semantics added.

- [x] ✅ **Step 5: Wave 4 - Integration And Merge Train**
  - [x] ✅ Merge/rebase train marked as single-chat N/A for implementation execution; final branch/PR merge remains manual operator action.
  - [x] ✅ Regression sweep executed for share + hierarchy surfaces (Debug + Release builds and full test rerun passed).
  - [x] ✅ Ownership conflicts reviewed; lane-owned files stayed within planned boundaries.

- [x] ✅ **Step 6: Program-Level Validation**
  - [x] ✅ Plan docs updated for lanes F and G with progress and status.
  - [x] ✅ UI lanes include pre/post `ui-consistency` evidence in plan docs.
  - [x] ✅ Control-plan blockers remain empty.
  - [x] ✅ Final rollout summary and known limitations documented below.

## Suggested Parallel Start Commands (When You Decide To Start)

- Wave 1 kickoff: `START LANE A`, `START LANE C`
- Wave 2 kickoff: `START LANE B`, `START LANE D`, `START LANE E`
- Wave 3 kickoff: `START LANE F` then `START LANE G`

Master execution is ACTIVE in single-chat mode.

## Wave 4 Completion Summary (2026-02-11)

- Debug simulator build passed (`xcodebuild ... Debug build`).
- Release device build passed (`xcodebuild ... Release CODE_SIGNING_ALLOWED=NO build`).
- Full test rerun passed (`NotelayerInsightsTests` + `NotelayerScreenshotTests`; 1 screenshot test intentionally skipped, 0 failures).
- Wave 4 hardening fix applied:
  - Added stable accessibility identifier for header gear menu in `ios-swift/Notelayer/Notelayer/Views/Shared/AppTabHeaderComponents.swift`.
  - Updated screenshot tests to use stable menu lookup in `ios-swift/Notelayer/NotelayerScreenshotTests/ScreenshotGenerationTests.swift`.
  - Fixed `XCTSkip` usage warnings by throwing `XCTSkip`.
  - Reduced launch-time churn by de-duplicating shared-import scheduling and removing unused scroll offset update path in `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`.

## Known Limitations / Handoff

- True lane-by-lane merge train (A→G branches rebased and merged in order) is not executed inside single-chat unified mode.
- Final git merge/PR orchestration is a manual operator step after implementation completion.
