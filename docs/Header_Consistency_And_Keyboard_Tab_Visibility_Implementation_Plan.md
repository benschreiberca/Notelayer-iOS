# Header Consistency + Keyboard Tab Visibility - Implementation Plan

Status: Active
Last Updated: 2026-02-10
Feature: iOS-standard top header consistency (Notes / To-Dos / Insights)
Related:
- [Header_Consistency_And_Keyboard_Tab_Visibility_Issue_Report.md](Header_Consistency_And_Keyboard_Tab_Visibility_Issue_Report.md)

**Overall Progress:** `90%`

## TL;DR
Move all top-level tabs to an iOS-standard navigation header model while preserving required tab-specific behavior: Notelayer logo on the left, Insights-style gear menu on the right, and unique center content per tab. For To-Dos specifically, remove the custom squeezing header, keep the mode picker pinned, and retain the Doing/Done toggle with counters.

## Critical Decisions
- Decision 1: Use iOS-standard `NavigationStack` + `toolbar` placements as the global pattern (`navigationBarLeading`, `navigationBarTrailing`, and `principal`) instead of a custom collapsing header.
- Decision 2: Keep the shared left/right affordances (`AppHeaderLogo`, `AppHeaderGearMenu`) across all top tabs; keep middle content tab-specific.
- Decision 3: In To-Dos, remove squeeze/collapse behavior entirely and pin the segmented mode control below the nav bar to keep behavior stable and predictable.
- Decision 4: Use default iOS title styling for Notes and Insights (no custom title font treatment).

## UI Consistency Guardrail (Standard-Bearer)
- Platform-standard first: reuse native `NavigationStack` toolbar behavior before adding custom containers.
- Standard-bearer files: `ios-swift/Notelayer/Notelayer/Views/NotesView.swift` and `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (toolbar-based inline navigation).
- Deviation check: only To-Dos center control requires a custom `principal` view (Doing/Done + counters), which is a scoped deviation to satisfy explicit product behavior.
- Expected line-count impact: net negative in `TodosView` due to removal of custom squeeze-state/header code; small positive for pinned-control wiring.

## Tasks

- [x] 🟩 **Step 1: Lock Shared Header Contract**
  - [x] 🟩 Confirm final left/right contract across tabs: `AppHeaderLogo` on left and `AppHeaderGearMenu` on right.
  - [x] 🟩 Confirm center contract: Notes/Insights use default title; To-Dos uses custom center toggle (`Doing` / `Done` + counts).

- [x] 🟩 **Step 2: Migrate To-Dos To iOS-Standard Nav Header**
  - [x] 🟩 Remove custom squeezing/collapsing header state and related animation logic in `TodosView`.
  - [x] 🟩 Remove `.navigationBarHidden(true)` in `TodosView` and adopt toolbar placements.
  - [x] 🟩 Place `AppHeaderLogo` in `navigationBarLeading` and `AppHeaderGearMenu` in `navigationBarTrailing`.
  - [x] 🟩 Add To-Dos center toggle in toolbar `principal` placement and preserve live counters.

- [x] 🟩 **Step 3: Keep To-Dos Mode Picker Pinned**
  - [x] 🟩 Keep the mode segmented control (`List`, `Priority`, `Category`, `Date`) pinned below the nav bar.
  - [x] 🟩 Ensure pinned control does not scroll away with task content.
  - [x] 🟩 Verify paging content in the To-Dos mode `TabView` remains behaviorally unchanged.

- [x] 🟩 **Step 4: Keep Notes/Insights On Default iOS Title Style**
  - [x] 🟩 Verify Notes and Insights keep default inline title appearance (no custom title font overrides).
  - [x] 🟩 Verify Notes and Insights continue using shared logo/gear affordances with consistent sizing/alignment.

- [ ] 🟨 **Step 5: Validation**
  - [x] 🟩 Build-check modified views using existing Notelayer iOS scheme.
  - [ ] 🟥 Manual pass for header consistency on Notes, To-Dos, and Insights (logo, center content, gear behavior).
  - [ ] 🟥 Manual pass for To-Dos center toggle behavior (Doing/Done switch + counters remain accurate).
  - [ ] 🟥 Manual pass for pinned segmented mode control behavior during scrolling and mode switching.
