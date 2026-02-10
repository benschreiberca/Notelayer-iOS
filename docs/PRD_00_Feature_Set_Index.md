# PRD Feature Set Index

Last Updated: 2026-02-10
Status: Draft For Clarification
Scope: Notelayer expanded feature set (no new additions)

## Purpose

Provide one index for the PRD set so each feature area can be clarified and executed in parallel later.

## PRD Files

1. [PRD_01_Experimental_Features_Framework.md](PRD_01_Experimental_Features_Framework.md)
2. [PRD_02_Analytics_Natural_Language_Insights.md](PRD_02_Analytics_Natural_Language_Insights.md)
3. [PRD_03_Analytics_Insights_Toggle.md](PRD_03_Analytics_Insights_Toggle.md)
4. [PRD_04_Voice_Entry_Structured_Capture.md](PRD_04_Voice_Entry_Structured_Capture.md)
5. [PRD_05_Voice_Entry_Preview_Staging.md](PRD_05_Voice_Entry_Preview_Staging.md)
6. [PRD_06_First_Time_User_Onboarding.md](PRD_06_First_Time_User_Onboarding.md)
7. [PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First.md](PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First.md)
8. [PRD_08_Project_Based_Tasks_Parent_Subtasks.md](PRD_08_Project_Based_Tasks_Parent_Subtasks.md)

## Clarification Snapshot (2026-02-10)

- `PRD_01`: Mostly clarified. Master experimental checkbox in gear, default off, Insights-only v1 scope, UI-only gating.
- `PRD_02`: Clarified. Final label selections locked, mandatory chart+data+takeaway on all chart sections, observation-then-suggestion summaries.
- `PRD_03`: Mostly clarified. Insights tied directly to experimental control, explicit hidden-route copy, recommended hint frequency policy.
- `PRD_04`: Mostly clarified. English-only, granular multi-item split, existing-category-only guesses, fallback title rule defined.
- `PRD_05`: Mostly clarified. Recommended save/exit/validation/background/performance settings adopted.
- `PRD_06`: Mostly clarified. First-install trigger, video-then-cues flow, non-time-based finance-inclusive presets approved.
- `PRD_07`: Not yet clarified in this round.
- `PRD_08`: Not yet clarified in this round.

## Dependency Notes

- `PRD_01` is the master visibility gate for experimental UI.
- `PRD_03` uses `PRD_01` directly for Insights exposure.
- `PRD_05` depends on parse output from `PRD_04`.

## Suggested Clarification Sequence (Next Pass)

1. Finalize remaining conflict-resolution signoff in `PRD_01` and `PRD_03`.
2. Finalize remaining onboarding behavior details in `PRD_06`.
3. Clarify `PRD_07` and `PRD_08`.

## Parallelization Guidance (For Future Execution)

- Stream A: `PRD_01` + `PRD_03`
- Stream B: `PRD_02`
- Stream C: `PRD_04` + `PRD_05`
- Stream D: `PRD_06`
- Stream E: `PRD_07`
- Stream F: `PRD_08`

This is planning guidance only; no implementation is implied.
