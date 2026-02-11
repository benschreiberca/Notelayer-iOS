# Feature Implementation Plan

**Overall Progress:** `0%`

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

- [ ] 🟥 **Step 1: Wave 0 - Decision Lock (Hard Gate)**
  - [ ] 🟥 Lock PRD 01/03 local-vs-synced conflict policy.
  - [ ] 🟥 Lock PRD 06 video skip timing and preset default behavior.
  - [ ] 🟥 Lock PRD 07 mapping and structure-preservation rules.
  - [ ] 🟥 Lock PRD 08 hierarchy semantics (depth/completion/deletion/counting).
  - [ ] 🟥 Exit criteria: no open blocker in `PRD_Parallel_Execution_Control_Plan.md`.

- [ ] 🟥 **Step 2: Wave 1 - Foundations (Run In Parallel: A + C)**
  - [ ] 🟥 Lane A: implement gating contract and experimental visibility foundation.
  - [ ] 🟥 Lane C: implement parser contract/fixtures and stable output payload.
  - [ ] 🟥 UI consistency pre-check for A before edits.
  - [ ] 🟥 Exit criteria: A state contract frozen and experimental surface set gating available; C parser payload frozen.

- [ ] 🟥 **Step 3: Wave 2 - Dependent Lanes (Run In Parallel: B + D + E)**
  - [ ] 🟥 Lane B starts only after A merges visibility-gating surfaces.
  - [ ] 🟥 Lane D starts only after C parser payload is frozen.
  - [ ] 🟥 Lane E starts after A gating foundation is available (onboarding visibility gate dependency).
  - [ ] 🟥 Prevent cross-edit collisions on `InsightsView.swift`, staging surfaces, and onboarding visibility paths.
  - [ ] 🟥 UI consistency pre/post checks for B, D, and E.
  - [ ] 🟥 Exit criteria: B UX acceptance checks pass; D validation/performance checks pass; E onboarding flow and visibility-gate behavior pass.

- [ ] 🟥 **Step 4: Wave 3 - Clarified Late Lanes (Sequential: F then G)**
  - [ ] 🟥 Lane F starts only after PRD 07 clarifications are locked.
  - [ ] 🟥 Merge F before G to reduce overlap risk on `LocalStore.swift`.
  - [ ] 🟥 Lane G starts only after PRD 08 clarifications are locked, A gate is available, and F merge completes.
  - [ ] 🟥 UI consistency pre/post checks for F and G UI surfaces.
  - [ ] 🟥 Exit criteria: F and G behavior and migration semantics validated.

- [ ] 🟥 **Step 5: Wave 4 - Integration And Merge Train**
  - [ ] 🟥 Merge in order: A -> B -> C -> D -> E -> F -> G.
  - [ ] 🟥 Rebase each lane on latest main before merge.
  - [ ] 🟥 Run regression sweep for Insights, voice capture/staging, onboarding, share, hierarchy.
  - [ ] 🟥 Confirm no unresolved ownership conflicts remain.

- [ ] 🟥 **Step 6: Program-Level Validation**
  - [ ] 🟥 Confirm each plan doc has accurate progress/status updates.
  - [ ] 🟥 Confirm all UI lanes have both pre and post `ui-consistency` evidence.
  - [ ] 🟥 Confirm blockers section in control plan is empty before declaring done.
  - [ ] 🟥 Publish final rollout summary and known limitations.

## Suggested Parallel Start Commands (When You Decide To Start)

- Wave 1 kickoff: `START LANE A`, `START LANE C`
- Wave 2 kickoff: `START LANE B`, `START LANE D`, `START LANE E`
- Wave 3 kickoff: `START LANE F` then `START LANE G`

This plan stays in HOLD until explicit start command.
