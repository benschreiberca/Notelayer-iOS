# PRD Parallel Chat Launch Pack

Last Updated: 2026-02-10
Purpose: Copy-paste prompts to start each lane in separate Codex chats on demand.

## How To Use

1. Open one new chat per lane.
2. Paste the corresponding kickoff prompt.
3. Keep lane scope strict to owned files in `PRD_Parallel_Execution_Control_Plan.md`.
4. Do not start until you decide to issue start command.

## Lane A Kickoff Prompt (PRD 01 + PRD 03)

```md
Execute only these plans:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_01_Experimental_Features_Framework_plan.md
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_03_Analytics_Insights_Toggle_plan.md

Constraints:
- Do not touch files owned by other lanes in /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_Parallel_Execution_Control_Plan.md.
- Run /Users/benmacmini/Documents/Notelayer-iOS/.codex/prompts/ui-consistency.md in read-only mode before UI edits and again after changes.
- Keep implementation scoped strictly to the plan and PRD decisions.
- Update the plan checkboxes and overall progress as you complete steps.
- Stop and report if blocked by unresolved requirement decisions.
```

## Lane B Kickoff Prompt (PRD 02)

```md
Execute only this plan:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_02_Analytics_Natural_Language_Insights_plan.md

Constraints:
- Treat /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_01_Experimental_Features_Framework_plan.md and /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_03_Analytics_Insights_Toggle_plan.md as upstream dependencies.
- Run /Users/benmacmini/Documents/Notelayer-iOS/.codex/prompts/ui-consistency.md read-only before and after UI changes.
- Keep copy/labels exactly aligned with PRD.
- Update plan progress and test notes before stopping.
```

## Lane C Kickoff Prompt (PRD 04)

```md
Execute only this plan:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_04_Voice_Entry_Structured_Capture_plan.md

Constraints:
- Scope to parser and parser-owned model/payload changes only.
- Do not implement staging UI owned by Lane D.
- Coordinate output contract so Lane D can consume without redesign.
- Run ui-consistency prompt only for preview-facing UI elements.
- Update plan progress continuously.
```

## Lane D Kickoff Prompt (PRD 05)

```md
Execute only this plan:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_05_Voice_Entry_Preview_Staging_plan.md

Constraints:
- Assume parser output contract from Lane C.
- Own staging UI/state/validation/persistence only.
- Run /Users/benmacmini/Documents/Notelayer-iOS/.codex/prompts/ui-consistency.md pre and post implementation.
- Do not change parser logic except interface glue.
- Update plan progress and performance validation notes.
```

## Lane E Kickoff Prompt (PRD 06)

```md
Execute only this plan:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_06_First_Time_User_Onboarding_plan.md

Constraints:
- Honor approved preset names/categories and non-time-based grouping requirement.
- Run /Users/benmacmini/Documents/Notelayer-iOS/.codex/prompts/ui-consistency.md pre and post implementation.
- Keep onboarding lightweight and within duration target.
- Update plan progress and unresolved decisions at end.
```

## Lane F Kickoff Prompt (PRD 07)

```md
Execute only this plan:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First_plan.md

Constraints:
- If unresolved PRD clarifications block deterministic behavior, stop and request decision.
- Keep scope ChatGPT-first text ingestion only.
- Run ui-consistency prompt for share confirmation/edit UI before and after changes.
- Update plan progress with explicit blocker notes if blocked.
```

## Lane G Kickoff Prompt (PRD 08)

```md
Execute only this plan:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_08_Project_Based_Tasks_Parent_Subtasks_plan.md

Constraints:
- If hierarchy semantics are unresolved, stop and request decision before coding.
- Keep scope to parent/subtasks (no timeline/deadline expansion).
- Run ui-consistency prompt pre and post hierarchy UI changes.
- Update plan progress and migration-test outcomes.
```

## Start-All Protocol

When you are ready, run the kickoff prompts in separate chats and then issue:

`START ALL PRD LANES`

Recommended launch order:

1. Lane A
2. Lane B
3. Lane C
4. Lane D
5. Lane E
6. Lane F
7. Lane G

This keeps dependencies stable and reduces merge conflicts.
