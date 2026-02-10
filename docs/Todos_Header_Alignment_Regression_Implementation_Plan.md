# To-Dos Header Alignment Regression - Implementation Plan

Status: Active
Last Updated: 2026-02-10
Feature: To-Dos top header single-row alignment
Related:
- [Todos_Header_Alignment_Regression_Issue_Report.md](Todos_Header_Alignment_Regression_Issue_Report.md)
- [Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md](Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md)

**Overall Progress:** `90%`

## TL;DR
Restore the To-Dos header to a single aligned top row so `Doing/Done` (with counters) sits centered between the left Notelayer logo and right gear icon, while keeping the mode picker pinned below and preserving existing toggle behavior.

## Critical Decisions
- Decision 1: Keep platform-standard navigation toolbar as the header shell and render `Doing/Done` as the centered header control to align with logo/gear.
- Decision 2: Keep the segmented mode picker as a pinned secondary row under the top header; do not merge it into the primary header row.
- Decision 3: Preserve existing toggle behavior and count logic; this change is layout-only.

## UI Consistency Guardrail (Standard-Bearer)
- Platform-standard first: continue using `NavigationStack` + toolbar for top-level header structure.
- Standard-bearer files: `ios-swift/Notelayer/Notelayer/Views/NotesView.swift` and `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` for logo/gear positioning consistency.
- Deviation check: To-Dos keeps a custom center control (`Doing/Done` + counts) because this interaction is feature-specific and explicitly required.
- Expected line-count impact: net neutral to slightly negative in `TodosView` by removing duplicate header rows and consolidating center control layout.

## Tasks

- [x] 🟩 **Step 1: Restore Single-Row To-Dos Header Alignment**
  - [x] 🟩 Move `Doing/Done` toggle + counters into the same top header row as logo and gear.
  - [x] 🟩 Ensure vertical alignment and spacing match the existing left/right header affordances.
  - [x] 🟩 Remove the extra pushed-down toggle row from screen content.

- [x] 🟩 **Step 2: Preserve Secondary Pinned Controls**
  - [x] 🟩 Keep the segmented mode picker (`List`, `Priority`, `Category`, `Date`) pinned below the top header.
  - [x] 🟩 Ensure the mode picker remains independent from scrollable task content.
  - [x] 🟩 Confirm no behavior changes in mode switching.

- [ ] 🟨 **Step 3: Validate Behavior And Layout**
  - [x] 🟩 Build-check `TodosView` changes with existing Notelayer iOS scheme.
  - [ ] 🟥 Manual UI pass on at least one small and one large iPhone simulator for one-row header alignment.
  - [ ] 🟥 Manual functional pass for `Doing/Done` toggle behavior and count updates.
  - [ ] 🟥 Confirm no regression in gear actions and menu presentation.
