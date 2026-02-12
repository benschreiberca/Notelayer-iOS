# Low Risk Responsiveness Optimization - Implementation Plan

Status: In Progress
Last Updated: 2026-02-12
Feature: Low-risk UI responsiveness and interaction stability optimization
Related:
- [App_Launch_Hang_Untappable_And_Watchdog_Crash_Implementation_Plan.md](App_Launch_Hang_Untappable_And_Watchdog_Crash_Implementation_Plan.md)
- [PRD_Unified_Execution_Master_plan.md](PRD_Unified_Execution_Master_plan.md)

**Overall Progress:** `78%`

## TLDR
Apply a minimal-risk optimization pass focused on runtime responsiveness (not redesign): reduce avoidable UI update churn, stabilize interaction handlers, and lower noisy warning paths that may correlate with perceived freezing, while preserving current behavior and layout.

## Critical Decisions
- Decision 1: Constrain scope to low-risk, localized changes only (no architecture rewrite, no data model migration, no feature redesign).
- Decision 2: Prioritize high-signal hotspots from recent logs and runtime observations: keyboard/focus churn in To-Dos, context-menu + drag interaction conflict, and repeated navigation state updates.
- Decision 3: Keep UI unchanged unless required for stability; prefer internal guardrails/debouncing over visual changes.
- Decision 4: Ship only after measurable responsiveness validation on physical device and regression checks across Notes, To-Dos, and Insights.

## UI Consistency Guardrail (Standard-Bearer)
- Platform-standard first: use existing SwiftUI patterns (`NavigationStack`, `ScrollView`, `List`, `ToolbarItem`) and avoid introducing new custom container primitives.
- Standard-bearer files:
  - `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
  - `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Deviation rule: if any new custom interaction wrapper is required, document why native SwiftUI behavior is insufficient and keep the change isolated.
- Expected line-count impact: small net-positive helper guards with neutral-to-negative repeated logic in To-Dos event handlers.

## Scope
### In Scope
- To-Dos focus/keyboard update stabilization.
- To-Dos row interaction conflict hardening (menu/drag coexistence).
- Navigation update-throttle guard for redundant per-frame updates.
- Validation and log-delta comparison for responsiveness improvements.

### Out of Scope
- Header redesign, tab bar redesign, or new UI sections.
- Analytics schema changes.
- Firebase/Auth startup architecture changes.
- Large refactors unrelated to observed responsiveness signals.

## Definition Of Done
- PASS 1: No visible freeze/untappable state during normal To-Dos interactions (edit, toggle, drag, menu open/close).
- PASS 2: Warning frequency for interaction churn (focus/navigation/context conflicts) is materially reduced in console logs from baseline.
- PASS 3: No regressions in existing behavior across Notes, To-Dos, and Insights navigation/scroll/edit flows.
- PASS 4: Build succeeds on simulator target and app remains responsive in physical-device sanity run.

## Tasks

- [x] 🟩 **Step 1: Baseline Capture And Guardrail Setup**
  - [x] 🟩 Capture a short baseline log set for To-Dos interaction flows (edit, drag, context menu, tab switching).
  - [x] 🟩 Record current warning signatures/frequency so post-fix comparison is objective.
  - [x] 🟩 Confirm test matrix and freeze non-goals before edits.

- [x] 🟩 **Step 2: Reduce To-Dos Focus And Keyboard Churn**
  - [x] 🟩 Audit repeated focus mutations and keyboard dismiss calls in `TodosView.swift`.
  - [x] 🟩 Consolidate to a single path per interaction lifecycle (start edit, commit, cancel) to avoid redundant state flips.
  - [x] 🟩 Add lightweight guard checks to skip no-op focus updates.

- [ ] 🟨 **Step 3: Harden Row Interaction Coexistence (Context Menu + Drag)**
  - [x] 🟩 Audit interaction ordering in `RowContextMenu.swift` and To-Dos row gesture wiring.
  - [x] 🟩 Prevent conflicting simultaneous states for menu presentation and drag reordering.
  - [ ] 🟥 Verify drag/drop + context actions remain functionally unchanged.

- [ ] 🟨 **Step 4: Prevent Redundant Navigation State Updates**
  - [x] 🟩 Identify repeated per-frame navigation request writes in root navigation state observers.
  - [x] 🟩 Add minimal debounce/equality guard so unchanged state does not republish.
  - [ ] 🟥 Validate tab switching and drilldown navigation still behave identically.

- [x] 🟩 **Step 5: Low-Risk Warning Cleanup (Opportunistic)**
  - [x] 🟩 Review recurring non-fatal connection warnings for obvious no-risk mitigations (configuration/ordering only).
  - [x] 🟩 Apply only if behavior-neutral and easily testable; otherwise document deferment.
  - [x] 🟩 Preserve existing network/auth/user flows.

- [ ] 🟨 **Step 6: Validation, Comparison, And Closure**
  - [ ] 🟥 Re-run the same interaction matrix and collect post-fix logs.
  - [x] 🟩 Compare baseline vs post-fix warning counts and responsiveness notes in one summary table.
  - [x] 🟩 Update linked issue/plan docs with PASS/FAIL results for each Definition of Done item.

## Baseline Signals (Pre-Change)
- Source: `/Users/benmacmini/Documents/Error Logs Notelayer/PRD v8.rtf`
- Parsed text snapshot: `/tmp/PRD_v8_execute_baseline.txt` (`4964` lines)
- Observed counts:
  - `Update NavigationRequestObserver tried to update multiple times per frame`: `1`
  - `nw_connection_copy_connected_* on unconnected nw_connection`: `12`
  - `Invalid sample AnimatablePair`: `0`
  - `UIKeyboardLayoutStar`: `0`
  - `perform input operation requires a valid sessionID`: `0`
  - `System gesture gate timed out`: `0`

## Execution Notes
- Implemented guarded keyboard dismissal path (`dismissIfNeeded`) and routed To-Dos keyboard dismiss calls through it.
- Consolidated To-Dos editor open behavior to a single guarded path in each mode (`openEditor(for:)`) to avoid redundant state writes.
- Added drag-session-aware context-menu gating so row context menus are disabled while task drag sessions are active.
- Added no-op guards in tab selection flows to prevent redundant `selectedTab` writes.
- Reviewed `nw_connection_copy_connected` warnings; these appear framework/network-layer-originated with no safe app-level behavior-neutral fix identified in this pass, so deferred.
- Validation:
  - ✅ Simulator build succeeded:
    - `xcodebuild -workspace ios-swift/Notelayer/Notelayer.xcworkspace -scheme Notelayer -destination 'platform=iOS Simulator,name=iPhone 17' build`
  - ✅ Simulator quick-launch log sample captured:
    - Log file: `/tmp/notelayer_postfix_sim_log.txt`
    - Launch method: `xcrun simctl launch "iPhone 17" com.notelayer.app` followed by `log show --last 2m`
  - ⏳ Physical-device interaction matrix + post-fix warning-delta capture still required for final closure.

## Baseline vs Post-Change (Quick Launch Sample)
- Scope note: this comparison covers simulator launch + idle only, not full manual edit/drag/menu interaction loops.
- `Update NavigationRequestObserver tried to update multiple times per frame`
  - Baseline: `1`
  - Post-change quick sample: `0`
- `nw_connection_copy_connected_* on unconnected nw_connection`
  - Baseline: `12`
  - Post-change quick sample: `10`
- `Invalid sample AnimatablePair`
  - Baseline: `0`
  - Post-change quick sample: `0`
- `UIKeyboardLayoutStar`
  - Baseline: `0`
  - Post-change quick sample: `0`
- `perform input operation requires a valid sessionID`
  - Baseline: `0`
  - Post-change quick sample: `0`
- `System gesture gate timed out`
  - Baseline: `0`
  - Post-change quick sample: `0`

## Current DoD Status
- PASS 1: ⏳ Pending on-device manual verification.
- PASS 2: ⏳ Pending post-fix console log capture and comparison.
- PASS 3: ⏳ Pending manual regression pass across Notes/To-Dos/Insights.
- PASS 4: ✅ Build succeeds on simulator; physical-device sanity run still pending.
