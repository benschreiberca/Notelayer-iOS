# Feature Implementation Plan

Status: In Progress (Code Complete, QA Pending)
Last Updated: 2026-02-10
Feature: Theme sheet full-height expansion
Plan Type: Planning only (not execution order)
Related:
- [Theme_Action_Sheet_Full_Height_Issue_Report.md](Theme_Action_Sheet_Full_Height_Issue_Report.md)

**Overall Progress:** `70%`

## TLDR
Fix only the Theme sheet interaction for now: allow full-height expansion from `Notes`, `To-Dos`, and `Insights` by replacing the fixed half-height detent with standard iOS sheet detents.

## Critical Decisions
- Decision 1: Scope is limited to Theme sheet detents only; no broader sheet-system standardization in this pass.
- Decision 2: Use platform-standard detents (`.medium`, `.large`) to align with existing app patterns and iOS conventions.
- Decision 3: Apply the same detent behavior in all three top-level entry points to prevent tab-to-tab inconsistency.
- Decision 4: Keep `AppearanceView` content/layout unchanged; adjust presentation behavior only.

## Tasks:

- [x] 🟩 **Step 1: Confirm Theme-Sheet-Only Scope**
  - [x] 🟩 Confirm affected call sites are only the `showingAppearance` sheets in:
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
  - [x] 🟩 Explicitly mark global sheet codification as out-of-scope for this plan.

- [x] 🟩 **Step 2: Define Minimal Change**
  - [x] 🟩 Replace `.presentationDetents([.fraction(0.5)])` with `.presentationDetents([.medium, .large])` in each Theme sheet entry point.
  - [x] 🟩 Keep `.presentationDragIndicator(.visible)` as-is.
  - [x] 🟩 Do not introduce new custom components, wrappers, or visual redesign.

- [ ] 🟨 **Step 3: Validate Behavior**
  - [ ] 🟥 Verify Theme sheet opens from Notes, To-Dos, and Insights.
  - [ ] 🟥 Verify user can drag Theme sheet to full height and back down.
  - [ ] 🟥 Verify nested `Customize Theme` flow still presents correctly.
  - [x] 🟩 Verify no regressions in analytics tracking hooks tied to sheet open/close.

- [ ] 🟨 **Step 4: Acceptance + Wrap-up**
  - [ ] 🟥 Acceptance: full-height expansion is available for Theme sheet in all 3 tabs.
  - [x] 🟩 Acceptance: no changes outside Theme sheet presentation behavior.
  - [x] 🟩 Update issue report with implementation status after code change is complete.
