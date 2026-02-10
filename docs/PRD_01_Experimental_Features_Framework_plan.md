# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Implement a single user-controlled experimental features switch in the gear dropdown (`Enable Experimental Features`) that gates experimental UI visibility (Insights only in v1), with deterministic local + account-synced state behavior.

## Critical Decisions
- Decision 1: Master control only (no per-feature controls in v1).
- Decision 2: UI-only gating (control hides/shows UI, does not hard-disable backend capability).
- Decision 3: Default state is off and available to any user.
- Decision 4: If disabled while on experimental UI, transition out and return to list view.
- Decision 5: State persists both locally and via account sync.

## Dependency Gates
- Gate A: Final signoff on local-vs-synced conflict resolution policy at launch.
- Gate B: Confirm exact location/style in gear menu matches existing control patterns.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift`

## UI Consistency Integration
- Before UI edits, run `.codex/prompts/ui-consistency.md` in read-only mode against:
- Standard-Bearer: `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
- Deviators: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
- Keep control implementation platform-standard (native menu/toggle/label patterns).
- If custom UI is required, document why and line-count impact.
- After implementation, run a second consistency pass and record deltas.

## Tasks:

- [ ] 🟥 **Step 1: Finalize Feature State Contract**
  - [ ] 🟥 Lock state machine: `off`, `on`, `pending-sync-reconcile`.
  - [ ] 🟥 Lock source priority at app launch (local immediate vs synced value).
  - [ ] 🟥 Lock reconciliation strategy for divergence (`last-write-wins` timestamp or approved alternative).
  - [ ] 🟥 Define expected behavior when sync cannot complete (offline/error state).

- [ ] 🟥 **Step 2: Add Master Experimental Control In Gear Menu**
  - [ ] 🟥 Add `Enable Experimental Features` control in gear dropdown.
  - [ ] 🟥 Ensure default state renders as off/deselected for first-time users.
  - [ ] 🟥 Ensure control style matches existing gear action-sheet/menu conventions.

- [ ] 🟥 **Step 3: Apply UI Visibility Gating (v1 = Insights Only)**
  - [ ] 🟥 Hide all Insights UI entry points when state is off.
  - [ ] 🟥 Show Insights UI entry points when state is on.
  - [ ] 🟥 Ensure gating is centralized so future experimental surfaces can plug into same rule.

- [ ] 🟥 **Step 4: Implement Disable-While-Viewing Transition**
  - [ ] 🟥 Detect toggle-off action when user is currently inside experimental surface.
  - [ ] 🟥 Trigger approved genie-style transition.
  - [ ] 🟥 Route user to default landing screen (list view) with no dead-end state.
  - [ ] 🟥 Confirm transition remains stable during rapid toggles.

- [ ] 🟥 **Step 5: Implement Local Persistence**
  - [ ] 🟥 Persist current experimental state locally for immediate cold-start rendering.
  - [ ] 🟥 Ensure persisted state survives force-quit and relaunch.
  - [ ] 🟥 Validate state integrity across account sign-out/sign-in transitions.

- [ ] 🟥 **Step 6: Implement Account Sync Persistence**
  - [ ] 🟥 Sync experimental state with account profile payload.
  - [ ] 🟥 Reconcile local and remote values using finalized policy.
  - [ ] 🟥 Record last-updated metadata to support deterministic conflict resolution.

- [ ] 🟥 **Step 7: Route/Navigation Safety**
  - [ ] 🟥 Block or reroute stale navigation paths into hidden experimental UI.
  - [ ] 🟥 Ensure hidden-state behavior cannot crash tab selection or deep navigation.
  - [ ] 🟥 Keep behavior deterministic across app restart.

- [ ] 🟥 **Step 8: Verification And Release Gate**
  - [ ] 🟥 Unit tests for state transitions and conflict-resolution behavior.
  - [ ] 🟥 Integration tests for hide/show, relaunch, and cross-device sync.
  - [ ] 🟥 Manual QA matrix: first install, offline launch, account switch, rapid toggle, while-on-screen disable.
  - [ ] 🟥 Run post-implementation UI consistency review and attach findings.
  - [ ] 🟥 Verify no visible regression in non-experimental default flows.
