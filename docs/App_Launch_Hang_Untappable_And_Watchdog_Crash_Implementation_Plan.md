# App Launch Hang, Untappable UI, And Watchdog Crash - Implementation Plan

Status: In Progress
Last Updated: 2026-02-12
Feature: Launch responsiveness + first-scene stability
Related:
- [App_Launch_Hang_Untappable_And_Watchdog_Crash_Issue_Report.md](App_Launch_Hang_Untappable_And_Watchdog_Crash_Issue_Report.md)
- [PRD_Unified_Execution_Master_plan.md](PRD_Unified_Execution_Master_plan.md)

**Overall Progress:** `78%`

## TL;DR
Resolve launch freeze/untappable startup and watchdog crashes by removing main-thread startup contention, deferring non-critical work until the first screen is interactive, and validating with repeatable release-style device runs and crash artifacts.

## Objectives (Measured)
1. Eliminate launch freeze behavior and restore reliable first-screen interactivity.
2. Remove watchdog violations (`scene-create`, `scene-update`, `0x8BADF00D`) from normal launch flow.
3. Reduce launch-time main-thread I/O fault noise to non-blocking levels.
4. Preserve existing user-facing behavior (no feature UX redesign).

## Scope
### In Scope
- Launch-path analysis and fixes for startup responsiveness.
- Main-thread work reduction and startup sequencing changes.
- Validation across normal and high-data launch scenarios.
- Crash/watchdog evidence collection and closure criteria.

### Out of Scope
- New features or visual redesign.
- Analytics schema redesign.
- Unrelated refactors outside launch/freeze/watchdog behavior.

## Critical Decisions
- Decision 1: Start with `NotelayerApp.swift`, `LocalStore.swift`, and `TodosView.swift` as primary suspects.
- Decision 2: Scope expansion is allowed if profiling shows meaningful startup cost outside these files.
- Decision 3: Non-critical startup work must run after first interactive frame whenever safe.
- Decision 4: Final validation requires non-debug release-style device runs; debugger-attached runs are supporting evidence only.
- Decision 5: The Firebase startup warning (`I-COR000003`) must be explicitly validated as resolved or intentionally tolerated with rationale.
- Decision 6: `AnalyticsService` and `ThemeBackground` are now in scope due newly identified main-thread startup risk.

## Scope Expansion Rule (Prevents False Closure)
If any source outside the initial three files contributes either:
- >= 15% of launch-to-interactive time in profiling, or
- direct involvement in watchdog/freeze traces,
then that source is added to scope immediately and documented in this plan.

## UI Consistency Guardrail (Standard-Bearer)
- Platform-standard first: no custom UI additions for this fix unless strictly required for diagnostics.
- Standard-bearer files:
  - `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
  - `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- If temporary diagnostics UI is required, use standard SwiftUI patterns (`List`, `Section`, `Text`) and remove before closure unless intentionally retained.
- Expected line-count impact: neutral to slightly negative (removal of redundant startup side effects).

## Evidence And Artifacts (Required)
- Baseline and post-fix console logs from physical device.
- Crash/termination artifacts if app exits (watchdog or other kill path).
- One profiling trace set (launch path) showing before/after deltas.
- Validation matrix covering:
  - Debugger-attached run
  - Release-style run (not attached)
  - High-data startup case (large local store and/or pending shared import queue)

## Definition of Done (All Must Pass)
- PASS 1: In 10 consecutive cold launches on device, app becomes interactable without untappable freeze.
- PASS 2: No `scene-create` or `scene-update` watchdog provision violation in release-style validation logs.
- PASS 3: No termination with `0x8BADF00D` in normal launch-to-first-interaction flow.
- PASS 4: Launch-time main-thread I/O faults are materially reduced versus baseline and no longer correlate with visible freeze.
- PASS 5: Firebase startup warning `I-COR000003` is absent in validated runs, or documented as non-blocking with explicit rationale and follow-up issue.
- PASS 6: Shared imports, Firebase startup, tabs, and first-screen behavior regressions are not introduced.

## Tasks

- [ ] 🟨 **Step 1: Baseline Reproduction, Timing, And Artifact Capture**
  - [x] 🟩 Baseline launch/freeze/watchdog signals captured from attached device log and documented in issue report.
  - [ ] 🟥 Record launch-to-first-interaction timings across 10 runs.
  - [ ] 🟥 Capture crash/termination artifacts when force-close occurs; keep evidence paths in docs.
  - [ ] 🟥 Run both debugger-attached and release-style non-debug captures.

- [x] 🟩 **Step 2: Launch Path Audit And Cost Attribution**
  - [x] 🟩 Audited startup path in `NotelayerApp.swift` for synchronous work in `init` and `didFinishLaunching`.
  - [x] 🟩 Audited `LocalStore.swift` (`load`, `migrateIfNeeded`, shared import queue checks) for blocking work on first render.
  - [x] 🟩 Audited `TodosView.swift` first `onAppear` for launch contention and re-trigger risk.
  - [x] 🟩 Identified top launch contention candidates: repeated Firebase bootstrap calls, launch-time shared import processing on main thread, immediate migration work in `LocalStore` init, synchronous Insights telemetry store first-load, and synchronous wallpaper disk image reads in `ThemeBackground`.

- [x] 🟩 **Step 3: Remediation Design And Sequencing**
  - [x] 🟩 Moved non-critical startup work behind first interactive state where safe (deferred APNS registration + deferred migration).
  - [x] 🟩 Moved shared import processing off first-frame critical path and onto utility queue with batching.
  - [x] 🟩 Implemented guarded single-pass Firebase bootstrap calls across app lifecycle entry points.
  - [x] 🟩 Prevented repeated shared-import startup work with import-processing gate.
  - [x] 🟩 Moved Insights telemetry recording off main thread in `AnalyticsService` to prevent singleton decode/migration blocking first interaction.
  - [x] 🟩 Replaced synchronous `UIImage(contentsOfFile:)` wallpaper loads in `ThemeBackground` with cached background decoding to remove launch-time disk I/O from view rendering.

- [ ] 🟨 **Step 4: Implement, Then Validate In Layers**
  - [x] 🟩 Implementation completed in target files (`NotelayerApp.swift`, `LocalStore.swift`, `TodosView.swift`, `AnalyticsService.swift`, `ThemeBackground.swift`).
  - [ ] 🟨 Validate interactivity first (tappable/scrollable immediately after render) on physical device.
  - [x] 🟩 Simulator sanity validation: app builds, launches, and remains alive post-launch.
  - [ ] 🟥 Validate watchdog stability (`scene-create`, `scene-update`, termination paths) on physical device.
  - [ ] 🟥 Validate high-data startup scenarios (large task/category datasets and pending share queue).
  - [ ] 🟥 Validate no regressions in shared imports, tabs, and Firebase startup behavior.

- [ ] 🟥 **Step 5: Closure, Documentation, And Follow-Ups**
  - [ ] 🟥 Compare baseline vs post-fix metrics in one summary table.
  - [ ] 🟥 Update issue report status with evidence-backed resolution notes.
  - [ ] 🟥 Update release/changelog docs if user-visible behavior changed.
  - [ ] 🟥 Create focused follow-up issue for any deferred non-blocking startup warnings.

## Execution Notes (Current Run)
- Code changes were applied for launch-path remediation and non-blocking shared import processing.
- Additional launch contention fixes were implemented:
  - `AnalyticsService` now queues Firebase analytics + Insights telemetry writes off main thread.
  - `ThemeBackground` now uses cached background-decoded wallpaper images instead of synchronous disk image loads in `body`.
- Build validation status:
  - `xcodebuild` workspace build succeeds on simulator destination (`iPhone 17`, iOS 26.2) after fixes.
  - Remaining warnings are pod/tooling warnings (no app-target compile errors).
- Runtime sanity:
  - App launches on simulator and remains alive after launch sequence.
- Physical-device validation and final watchdog confirmation remain required.
