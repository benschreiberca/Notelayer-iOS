# PRD Parallel Execution Control Plan

Last Updated: 2026-02-10
Execution Mode: HOLD (No implementation work starts until explicit start command)

## Purpose

Coordinate parallel execution across PRD lanes with strict ownership, minimal merge conflicts, and explicit start/stop controls.

## Canonical Master Plan

- Primary execution source: `docs/PRD_Unified_Execution_Master_plan.md`
- This control file governs lane ownership, status, and merge hygiene.
- If this file and lane docs disagree on sequence, follow the master plan.
- Single-chat option: `docs/PRD_Single_Chat_One_Prompt_Execution_Guide.md`

## Start Protocol

Use one of these commands in Codex when you want to begin:

- `START ALL PRD LANES`
- `START LANE A`
- `START LANE B`
- `START LANE C`
- `START LANE D`
- `START LANE E`
- `START LANE F`
- `START LANE G`

Pause commands:

- `PAUSE ALL PRD LANES`
- `PAUSE LANE <LETTER>`

No lane should execute while global mode is HOLD.

## Lane Matrix

| Lane | Scope | Branch | Plan Docs | Status | Merge Slot |
| --- | --- | --- | --- | --- | --- |
| A | Feature gate core + experimental visibility gate set | `codex/prd01-03-gating` | `PRD_01_Experimental_Features_Framework_plan.md`, `PRD_03_Analytics_Insights_Toggle_plan.md` | 🟥 HOLD | 1 |
| B | Insights plain-language UX and chart readability | `codex/prd02-insights-language` | `PRD_02_Analytics_Natural_Language_Insights_plan.md` | 🟥 HOLD | 2 |
| C | Voice parser and structured extraction | `codex/prd04-voice-parser` | `PRD_04_Voice_Entry_Structured_Capture_plan.md` | 🟥 HOLD | 3 |
| D | Voice preview/staging workflow | `codex/prd05-voice-staging` | `PRD_05_Voice_Entry_Preview_Staging_plan.md` | 🟥 HOLD | 4 |
| E | First-install onboarding flow | `codex/prd06-onboarding` | `PRD_06_First_Time_User_Onboarding_plan.md` | 🟥 HOLD | 5 |
| F | Share sheet ChatGPT-first ingestion | `codex/prd07-share-chatgpt` | `PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First_plan.md` | 🟥 HOLD | 6 |
| G | Parent/subtask hierarchy | `codex/prd08-parent-subtasks` | `PRD_08_Project_Based_Tasks_Parent_Subtasks_plan.md` | 🟥 HOLD | 7 |

## Ownership Rules

Each lane can edit only its owned surfaces unless integration is explicitly scheduled.

### Lane A Owned Surfaces
- `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (visibility gating only)
- Voice entry trigger visibility gating surfaces
- Onboarding visibility gating surfaces
- Project-task visibility gating surfaces
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift` (feature-state persistence only)
- `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift` (sync state only)

### Lane B Owned Surfaces
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (labeling/chart copy/takeaways only)
- `ios-swift/Notelayer/Notelayer/Data/InsightsMetricDefinitions.swift`
- `ios-swift/Notelayer/Notelayer/Services/InsightsAggregator.swift`

### Lane C Owned Surfaces
- Voice parsing layer and parse contracts used by staging
- Parser-related model extensions in `ios-swift/Notelayer/Notelayer/Data/Models.swift` (parser payload only)

### Lane D Owned Surfaces
- Voice staging UI and staging-state handling
- Staging persistence behavior in `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift` (staging only)

### Lane E Owned Surfaces
- `ios-swift/Notelayer/Notelayer/Views/WelcomeView.swift`
- `ios-swift/Notelayer/Notelayer/Services/WelcomeCoordinator.swift`
- Onboarding preset application paths

### Lane F Owned Surfaces
- Share intake and normalization paths
- `ios-swift/Notelayer/Notelayer/Data/SharedItem.swift`
- Share conversion hooks in `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift` (share only)

### Lane G Owned Surfaces
- `ios-swift/Notelayer/Notelayer/Data/Models.swift` (hierarchy model changes)
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift` (hierarchy persistence)
- Task hierarchy UI surfaces in `TodosView.swift` and `TaskItemView.swift`

## Conflict Rules

1. Never edit another lane's owned files without explicit integration handoff.
2. If overlap is unavoidable, lane with earlier merge slot owns first implementation.
3. `RootTabsView.swift`, `InsightsView.swift`, `Models.swift`, and `LocalStore.swift` are high-risk overlap files; coordinate before touching.
4. All lanes rebase from latest `main` before opening merge PR.

## UI Consistency Rule (Mandatory)

Every lane with UI work must run `.codex/prompts/ui-consistency.md`:

1. Pre-implementation read-only assessment.
2. Post-implementation validation pass.
3. Document deviations and line-count impact.

## Merge Order

1. Lane A (`PRD_01` + `PRD_03`)
2. Lane B (`PRD_02`)
3. Lane C (`PRD_04`)
4. Lane D (`PRD_05`)
5. Lane E (`PRD_06`)
6. Lane F (`PRD_07`)
7. Lane G (`PRD_08`)

## Improved Start Waves (Risk-Reduced)

Use these starts (from the master plan) to reduce rework and collisions:

1. Wave 0: decision lock only (no code execution)
2. Wave 1: start lanes A + C
3. Wave 2: start lanes B + D + E (after wave-1 interfaces stabilize)
4. Wave 3: start lane F, then lane G

This separates start-order risk management from final merge order.

## Current Blockers

- Lane A: final signoff on local-vs-synced conflict behavior.
- Lane E: final decisions on video skip timing and recommended preset preselection behavior.
- Lane F: unresolved PRD clarifications around mapping and structure preservation.
- Lane G: unresolved PRD clarifications around hierarchy semantics.

## Execution Notes

- This file governs execution status only.
- Feature plans remain source-of-truth for implementation detail.
