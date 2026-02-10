# Feature Implementation Plan

Status: In Progress (Code Complete, Runtime QA Pending)
Last Updated: 2026-02-10
Feature: Theme sheet live Light/Dark mode updates
Related:
- [Theme_Sheet_Light_Dark_Mode_Not_Applying_Issue_Report.md](Theme_Sheet_Light_Dark_Mode_Not_Applying_Issue_Report.md)

**Overall Progress:** `85%`

## TLDR
Ensure the Theme sheet (`AppearanceView`) updates colors immediately when `Appearance Mode` changes (Light/Dark/System), without requiring dismiss/reopen.

## Critical Decisions
- Decision 1: Keep scope limited to Theme sheet color-scheme update behavior only; no broader theme-system rewrite in this pass.
- Decision 2: Keep `ThemeManager` as the source of truth for mode and resolved scheme; fix propagation to the presented sheet rather than duplicating state.
- Decision 3: Standard-Bearer for sheet behavior is existing native presentation usage in app flows (`.sheet` + standard modifiers), not custom wrappers.
- Decision 4: UI consistency guardrail: no new custom UI components for this fix; expected line-count impact should be minimal (near-zero net).

## Tasks:

- [x] 🟩 **Step 1: Reproduce And Isolate The Propagation Gap**
  - [x] 🟩 Reproduce in all 3 entry points (`Notes`, `To-Dos`, `Insights`) while the Theme sheet remains open.
  - [x] 🟩 Trace update path: `AppearanceView` picker (`theme.updateMode`) → `ThemeManager` state → `RootTabsView` color-scheme application.
  - [x] 🟩 Confirm whether tokens update while sheet `colorScheme` environment remains stale.

- [x] 🟩 **Step 2: Define Minimal Fix Strategy**
  - [x] 🟩 Choose the smallest change that ensures presented Theme sheet receives live color-scheme updates.
  - [x] 🟩 Keep existing sheet structure and content in `AppearanceView` unchanged unless strictly required.
  - [x] 🟩 Document why selected approach is lower risk than broader sheet-standardization work.

- [x] 🟩 **Step 3: Apply Fix Across Theme Entry Points**
  - [x] 🟩 Update Theme sheet presentation behavior for:
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
  - [x] 🟩 Keep existing detents/drag-indicator behavior intact.

- [ ] 🟨 **Step 4: Validate Runtime Behavior**
  - [x] 🟩 Run simulator smoke validation (iPhone 17 booted + app launch succeeds).
  - [ ] 🟥 Verify Light → Dark and Dark → Light updates happen immediately while Theme sheet is open.
  - [ ] 🟥 Verify `System` mode behavior updates correctly with current system scheme.
  - [ ] 🟥 Verify nested `Customize Theme` flow still follows expected scheme and has no visual regressions.
  - [x] 🟩 Verify analytics hooks tied to theme changes remain intact.

- [ ] 🟨 **Step 5: Acceptance + Wrap-up**
  - [ ] 🟥 Acceptance: Theme sheet updates colors live for Light/Dark/System.
  - [ ] 🟥 Acceptance: behavior is consistent from all three top-level tab entry points.
  - [x] 🟩 Acceptance: no unrelated UI pattern/component changes introduced.
  - [x] 🟩 Update issue report and plan status after implementation validation.
