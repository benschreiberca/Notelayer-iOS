# PRD Feature Set Index

Last Updated: 2026-06-06
Status: Updated with v1.5.0 Implementation
Scope: Notelayer expanded feature set (no new additions)

## Release Status Update (v1.5.0 — June 2026)

**SHIPPED IN v1.5.0:**
- ✅ PRD_01: Experimental Features Framework — **COMPLETED** (features now always-on, gate removed)
- ✅ PRD_06: First-Time User Onboarding — **COMPLETED** (4-step redesigned flow shipped)

**PARTIALLY SHIPPED IN v1.5.0:**
- ✅ PRD_02: Analytics Insights — **COMPLETED** (full analytics now available, category deep-links added)
- ✅ PRD_03: Insights Toggle — **COMPLETED** (removed, insights always visible)

**IN DEVELOPMENT:**
- 🟨 PRD_04: Voice Entry Structured Capture — Functional, ongoing optimization
- 🟨 PRD_05: Voice Entry Preview & Staging — Functional, ongoing optimization
- 🟨 PRD_08: Project-Based Tasks (Hierarchy) — Functional, ongoing optimization

**FUTURE WORK:**
- ⬜ PRD_07: Share to Notelayer System
- ⬜ PRD_09: Web App & Chrome Extension — In Planning

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
9. [PRD_09_Web_App_Chrome_Extension.md](PRD_09_Web_App_Chrome_Extension.md)

## Implementation Status (2026-06-06 — v1.5.0)

- `PRD_01`: ✅ **SHIPPED v1.5.0** — Experimental features gate completely removed. All features (Voice, Insights, Hierarchy, Onboarding) now standard for all users. Master toggle removed from gear menu.
- `PRD_02`: ✅ **SHIPPED v1.5.0** — Full analytics suite available. Chart+data+takeaway on all sections. Category deep-links added (click category in Insights → jump to To-Dos category view).
- `PRD_03`: ✅ **SHIPPED v1.5.0** — Insights no longer gated. Always visible and accessible. Hint banners removed.
- `PRD_04`: 🟨 Functional and in use. Voice entry with structured capture working. Granular multi-item split implemented. Floating FAB above tab bar active.
- `PRD_05`: 🟨 Functional and in use. Voice staging and preview working. Validation and background processing implemented.
- `PRD_06`: ✅ **SHIPPED v1.5.0** — Completely redesigned 4-step onboarding. Replaced video-placeholder flow with interactive Duolingo/Noom-inspired experience. Auto-triggers on first install. Replayable from gear menu.
- `PRD_07`: Not yet implemented.
- `PRD_08`: 🟨 Partially implemented. Task hierarchy and parent-child relationships working. Ongoing optimization.

## Dependency Notes (Updated for v1.5.0)

- `PRD_01` gate has been **REMOVED**. All features now standard. No dependency chains for visibility.
- `PRD_02` (Insights) and `PRD_03` (Insights visibility) are now fully integrated and always accessible.
- `PRD_05` (Voice staging) depends on parse output from `PRD_04` (Voice input). Both functional.
- `PRD_08` (Hierarchy) is independent; `PRD_04` and `PRD_05` can work with or without hierarchy enabled.

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
