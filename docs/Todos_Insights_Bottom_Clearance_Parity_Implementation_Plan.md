# To-Dos Insights Bottom Clearance Parity - Implementation Plan

Status: In Progress
Last Updated: 2026-02-12
Feature: To-Dos bottom scrolling behavior parity with Insights
Related:
- [Insights_Global_Bottom_Clearance_And_Oldest_Open_Tasks_Implementation_Plan.md](Insights_Global_Bottom_Clearance_And_Oldest_Open_Tasks_Implementation_Plan.md)
- [Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md](Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md)

**Overall Progress:** `85%`

## TL;DR
Update To-Dos so its content area behaves like Insights: cards can use full screen height while scrolling, and extra bottom clearance appears only at the end of scroll. Implement this with ScrollView-level bottom inset handling (not container-level inset), while preserving existing To-Dos header, toggle, and mode behavior.

## Critical Decisions
- Decision 1: Match the Insights pattern by applying bottom clearance at the `ScrollView` level in each To-Dos mode view (List/Priority/Category/Date).
- Decision 2: Remove To-Dos container-level `.safeAreaInset(edge: .bottom)` from the root `NavigationStack` content to avoid always-on viewport shrink.
- Decision 3: Keep one shared spacing constant (`AppBottomClearance.contentBottomSpacerHeight`) so To-Dos and Insights remain aligned with the same tab-pill clearance rule.
- Decision 4: Consolidate repeated scroll/inset behavior into a reusable To-Dos mode wrapper to reduce future styling drift.

## UI Consistency Guardrail (Standard-Bearer)
- Platform-standard first: use existing SwiftUI `ScrollView` + `.safeAreaInset(edge: .bottom)` pattern, same as Insights.
- Standard-bearer file: `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (main screen and drilldowns).
- Target file: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift` (all four mode views + root container).
- Deviation check: no new custom container system; only a light shared wrapper for repeated To-Dos mode scroll scaffolding.
- Expected line-count impact: small net reduction by removing duplicated per-mode scroll boilerplate.

## Definition of Done
- PASS 1: To-Dos no longer has a permanently reduced visible content height from bottom spacer logic.
- PASS 2: In all To-Dos modes (`List`, `Priority`, `Category`, `Date`), the final card/list content can scroll fully above the floating tab pill.
- PASS 3: Extra bottom clearance appears at max scroll, matching Insights behavior.
- PASS 4: Existing To-Dos header layout (`logo`, `Doing/Done` toggle + counts, `gear`) and segmented mode picker behavior remain unchanged.

## Tasks

- [x] 🟩 **Step 1: Establish Parity Contract Against Insights**
  - [x] 🟩 Confirm the exact Insights placement pattern: `.safeAreaInset(edge: .bottom)` attached directly to each relevant `ScrollView`.
  - [x] 🟩 Document current To-Dos mismatch: root-level inset on container view, not mode scroll views.
  - [x] 🟩 Freeze non-goals for this change (no toggle logic, no card styling redesign, no tab-pill geometry changes).

- [x] 🟩 **Step 2: Introduce Reusable To-Dos Scroll Scaffold**
  - [x] 🟩 Add a small reusable wrapper/helper used by all To-Dos mode views to host common scroll behaviors.
  - [x] 🟩 Include common behaviors in one place: keyboard dismissal, tap-to-dismiss background, and bottom safe-area inset spacer.
  - [x] 🟩 Ensure wrapper consumes `AppBottomClearance.contentBottomSpacerHeight` (no new spacing constants).

- [x] 🟩 **Step 3: Migrate All To-Dos Modes To Scroll-Level Inset**
  - [x] 🟩 Apply the shared scaffold to `TodoListModeView`.
  - [x] 🟩 Apply the shared scaffold to `TodoPriorityModeView`.
  - [x] 🟩 Apply the shared scaffold to `TodoCategoryModeView`.
  - [x] 🟩 Apply the shared scaffold to `TodoDateModeView`.

- [x] 🟩 **Step 4: Remove Root-Level To-Dos Bottom Inset**
  - [x] 🟩 Remove `.safeAreaInset(edge: .bottom)` from the root To-Dos container in `TodosView`.
  - [x] 🟩 Verify no duplicate spacer remains after migration.
  - [x] 🟩 Keep all existing toolbar/header/menu wiring intact.

- [ ] 🟨 **Step 5: Validate Behavior Across Modes**
  - [x] 🟩 Automated build pass: `xcodebuild -workspace ios-swift/Notelayer/Notelayer.xcworkspace -scheme Notelayer -destination 'platform=iOS Simulator,name=iPhone 17' build`.
  - [ ] 🟥 Manual visual pass on small and large iPhone simulators for all four To-Dos modes.
  - [ ] 🟥 Confirm bottom behavior matches Insights pattern: full viewport while scrolling + extra clearance only near bottom end.
  - [ ] 🟥 Confirm no regression in keyboard behavior, drag/drop interactions, and mode switching.
