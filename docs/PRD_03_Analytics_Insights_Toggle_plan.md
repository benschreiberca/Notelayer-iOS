# Feature Implementation Plan

**Overall Progress:** `70%`

## TLDR
Make Insights visibility fully dependent on `Enable Experimental Features`, including hidden-route handling, first-time hint behavior, and consistent behavior across local and synced state.

## Critical Decisions
- Decision 1: No standalone Insights toggle in Settings.
- Decision 2: Hidden route message is `Enable this feature in Experimental Features.`
- Decision 3: First-time hint is compact, non-snackbar, and low-frequency.
- Decision 4: Mid-session disable from Insights exits to list view with genie-style transition.

## Dependency Gates
- Gate A: LOCKED - inherits PRD 01 local/sync conflict policy directly.
- Gate B: LOCKED - hint dismissal/interaction state is account-synced.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Services/InsightsTelemetryStore.swift`

## UI Consistency Integration
- Before implementation, run `.codex/prompts/ui-consistency.md` in read-only mode:
- Standard-Bearer: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Deviators: `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`, `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- Keep blocked-route and hint presentation native and minimal (no snackbar).
- Use standard label/icon/section patterns for any hint/blocked state messaging.
- Run post-implementation consistency pass for route states and hint UI.

### UI Consistency Evidence (2026-02-11)
- Pre-check completed against `TodosView.swift` (standard bearer) and `RootTabsView.swift`/`InsightsView.swift` (deviators).
- Post-check completed: hidden-route and first-time hint UX use native inline banner pattern (no snackbar).

## Tasks:

- [ ] 🟥 **Step 1: Define Effective Visibility State**
  - [ ] 🟥 Implement effective state function from PRD 01 control value.
  - [ ] 🟥 Ensure state is deterministic at launch and after sync updates.
  - [ ] 🟥 Ensure effective state changes propagate to tabs and routes immediately.

- [ ] 🟥 **Step 2: Gate All Insights Entry Points**
  - [ ] 🟥 Hide Insights tab/button/entry affordances when state is off.
  - [ ] 🟥 Show Insights entry affordances when state is on.
  - [ ] 🟥 Ensure hidden state cannot be bypassed via in-app navigation history.

- [ ] 🟥 **Step 3: Implement Hidden-Route Handling**
  - [ ] 🟥 Intercept stale route attempts to Insights while hidden.
  - [ ] 🟥 Show locked copy: `Enable this feature in Experimental Features.`
  - [ ] 🟥 Redirect to default list view after messaging path.

- [ ] 🟥 **Step 4: Implement Mid-Session Disable Handling**
  - [ ] 🟥 Detect disable event while user is inside Insights.
  - [ ] 🟥 Trigger genie-style transition and route out to list view.
  - [ ] 🟥 Ensure state update and route update are atomic to avoid flicker.

- [ ] 🟥 **Step 5: Implement First-Time Hint Policy**
  - [ ] 🟥 Show one initial hint the first time Insights becomes visible.
  - [ ] 🟥 If dismissed without engagement, allow at most one delayed reminder (>=24h).
  - [ ] 🟥 Stop showing hints after meaningful interaction with Insights details.
  - [ ] 🟥 Keep implementation non-snackbar and consistent with existing UI patterns.

- [ ] 🟥 **Step 6: Persist Hint And Visibility State**
  - [ ] 🟥 Persist visibility state according to PRD 01 policy.
  - [ ] 🟥 Persist hint-seen/dismissed/interacted state.
  - [ ] 🟥 Ensure state restores correctly after app relaunch and account switch.

- [ ] 🟥 **Step 7: Verification And Acceptance**
  - [ ] 🟥 Unit tests for state derivation and route guard behavior.
  - [ ] 🟥 Integration tests for on/off transitions and stale route attempts.
  - [ ] 🟥 Manual QA for hint frequency policy and no-snackbar requirement.
  - [ ] 🟥 Cross-device QA for synced visibility behavior.
  - [ ] 🟥 Run post-implementation UI consistency review and capture findings.
