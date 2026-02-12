# App Launch Hang, Untappable UI, And Watchdog Crash - Issue Report

Status: Active
Last Updated: 2026-02-12
Feature: App launch responsiveness and first-scene stability
Related:
- [/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift](../ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift)
- [/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/Data/LocalStore.swift](../ios-swift/Notelayer/Notelayer/Data/LocalStore.swift)
- [/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/Views/TodosView.swift](../ios-swift/Notelayer/Notelayer/Views/TodosView.swift)

**Type:** Bug (Performance / Stability)  
**Priority:** Critical  
**Effort:** Medium-Large  
**Created:** February 12, 2026

---

## TL;DR

On device launch, the app is slow to become interactive, the first screen appears untappable, and the session ends with watchdog-related termination behavior. Logs show scene lifecycle watchdog violations and repeated main-thread I/O diagnostics during launch.

---

## Current State vs Expected Outcome

### 1. Launch Is Slow And UI Feels Frozen

**Current State:**
- App startup is delayed.
- First loaded screen appears but does not respond to taps.
- Console shows launch-time watchdog pressure during scene creation.

**Expected Outcome:**
- App reaches interactive state quickly after launch.
- First screen accepts taps immediately after it appears.
- No scene-create watchdog provision violations.

---

### 2. Main-Thread I/O During Startup

**Current State:**
- Performance Diagnostics repeatedly report main-thread I/O patterns during startup (`dlopen`, `NSBundle bundleIdentifier`, database warnings).
- Logs indicate this can cause slow launch and hangs.

**Expected Outcome:**
- Launch-critical work is non-blocking on the main thread.
- No repeated main-thread I/O fault spam during initial scene creation.

---

### 3. Watchdog Termination Signals

**Current State:**
- Scene-create watchdog budget is exceeded (`3.45s`).
- A later termination request includes watchdog code `0x8BADF00D` after failed graceful termination.

**Expected Outcome:**
- No watchdog budget violations in launch or scene update paths.
- App does not hit watchdog-related forced termination sequences.

---

## Evidence From Attached Log

Source file:
- `/Users/benmacmini/Documents/Error Logs Notelayer/PRD Error v2 Phone tester.rtf`

Key signals:
- `20:07:01.227643` SpringBoard sends scene action with `watchdog: 3.45s`.
- `20:07:02.977966` "Watchdog for scene-create is still active after 1.7s."
- `20:07:05.302395` "Watchdog ... scene-create ... provision violated."
- Repeated Notelayer Performance Diagnostics faults: "Performing I/O on the main thread can cause slow launches/hangs."
- `20:07:28.032069` termination request includes watchdog violation `0x8BADF00D` after "Failed to terminate gracefully after 5.0s."

Note:
- Log also shows "process is being debugged" in watchdog handling, which can alter normal termination behavior while attached to debugger.

---

## Scope

### In Scope
- Capture and track launch-hang and untappable-first-screen behavior.
- Identify startup-stage blocking work on main thread.
- Validate scene lifecycle timing against watchdog budgets.

### Out of Scope
- Refactoring unrelated feature UI.
- PRD feature enhancements not required for launch responsiveness.
- Firebase product changes beyond launch-safety impact.

---

## Most Relevant Files (Max 3)

1. `/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`
- App startup path (`AppDelegate`, Firebase init, notification setup, launch flow).

2. `/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- Startup data load/migration and shared-import processing that may block UI thread.

3. `/Users/benmacmini/Documents/Notelayer-iOS/ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- First visible screen lifecycle and deferred shared-item import behavior on first appearance.

---

## Acceptance Criteria

1. Launch reaches tappable state consistently without perceived freeze.
2. No scene-create watchdog provision violation in launch logs.
3. Main-thread I/O diagnostics are reduced to non-blocking startup behavior.
4. No watchdog-related termination (`0x8BADF00D`) during normal launch-to-interaction flow.
5. First-screen interactions (tap, scroll, menu) are responsive within expected UX thresholds.

---

## Risks / Notes

- Some watchdog signals in this capture occur while debugger is attached; a non-debug device capture should be used for final validation.
- Firebase setup warning appears in the same session and may be additive to launch churn, but log evidence points primarily to startup responsiveness and main-thread blocking.
- Share-import and load/migration flow may compound launch load if large data exists.

---

## Labels

- Type: bug
- Priority: critical
- Effort: medium-large
- Area: launch-performance
- Area: stability
