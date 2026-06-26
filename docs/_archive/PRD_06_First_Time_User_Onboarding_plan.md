# Feature Implementation Plan

**Overall Progress:** `70%`

## TLDR
Implement first-install onboarding with video-first orientation, contextual cues, and approved non-time-based starting category presets that include finance/banking/investing in each preset.

## Critical Decisions
- Decision 1: Trigger onboarding on first install.
- Decision 2: Orientation order is video first, then contextual cues.
- Decision 3: Preset selection is not one-click reversible, but users can edit later in `Manage Categories`.
- Decision 4: Recommended preset must be visibly indicated.
- Decision 5: Onboarding should remain lightweight (target 60-90s, hard cap <=2 minutes).
- Decision 6: Onboarding UI visibility is gated by `Enable Experimental Features`.

## Dependency Gates
- Gate A: LOCKED - video skip becomes available after a 3-second intro segment.
- Gate B: LOCKED - `Everyday Balance` is pre-selected and visually marked recommended.
- Gate C: LOCKED - onboarding UI visibility is gated by `PRD_01`.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Views/WelcomeView.swift`
- `ios-swift/Notelayer/Notelayer/Services/WelcomeCoordinator.swift`
- `ios-swift/Notelayer/Notelayer/Views/CategoryManagerView.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Data/Models.swift`

## UI Consistency Integration
- Before implementation, run `.codex/prompts/ui-consistency.md` in read-only mode:
- Standard-Bearer: `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
- Deviator: `ios-swift/Notelayer/Notelayer/Views/WelcomeView.swift`
- Keep onboarding screens aligned with platform-standard section/list/text controls.
- Avoid custom wrappers and decorative cards unless needed for orientation video surface.
- Run post-implementation consistency review and capture line-count impact if deviations exist.

### UI Consistency Evidence (2026-02-11)
- Pre-check completed against `NotesView.swift` standard patterns.
- Post-check completed: onboarding uses native `NavigationStack`, toolbar actions, and lightweight sectioned content.

## Tasks:

- [ ] 🟥 **Step 1: Implement First-Install Trigger Contract**
  - [ ] 🟥 Detect first install and launch onboarding flow.
  - [ ] 🟥 Ensure returning users are not re-forced through onboarding.
  - [ ] 🟥 Persist completion/skip state robustly.

- [ ] 🟥 **Step 1.5: Integrate Experimental Visibility Gate**
  - [ ] 🟥 Show onboarding experimental UI only when `Enable Experimental Features` is on.
  - [ ] 🟥 Define fallback behavior when gate is off on first install.
  - [ ] 🟥 Ensure gated visibility does not break app first-run path.

- [ ] 🟥 **Step 2: Add Settings Re-entry Path**
  - [ ] 🟥 Add clear entry point to re-open onboarding guidance from Settings.
  - [ ] 🟥 Ensure re-entry does not reset user categories unless explicitly requested.

- [ ] 🟥 **Step 3: Build Orientation Sequence**
  - [ ] 🟥 Implement lightweight video-first introduction.
  - [ ] 🟥 Implement contextual cues immediately after video.
  - [ ] 🟥 Respect final skip-timing decision (immediate vs delayed).

- [ ] 🟥 **Step 4: Implement Preset Selection UX**
  - [ ] 🟥 Render approved presets with previewable category lists.
  - [ ] 🟥 Mark `Everyday Balance` as recommended.
  - [ ] 🟥 Respect final selection behavior decision (pre-selected vs highlighted).

- [ ] 🟥 **Step 5: Seed Category Data**
  - [ ] 🟥 Apply selected preset categories at onboarding completion.
  - [ ] 🟥 Confirm no time-based group labels are introduced.
  - [ ] 🟥 Confirm each preset includes finance/banking/investing grouping.

- [ ] 🟥 **Step 6: Preserve Post-Onboarding Editability**
  - [ ] 🟥 Ensure users can modify categories later via `Manage Categories`.
  - [ ] 🟥 Ensure onboarding selection itself is not treated as one-click reversible preset switch.

- [ ] 🟥 **Step 7: Duration And Friction Validation**
  - [ ] 🟥 Measure average onboarding completion duration.
  - [ ] 🟥 Ensure path can complete within 60-90s typical, <=2m hard cap.
  - [ ] 🟥 Remove unnecessary steps or copy if duration exceeds target.

- [ ] 🟥 **Step 8: Verification And Acceptance**
  - [ ] 🟥 Unit/integration tests for first-install trigger and completion state.
  - [ ] 🟥 Manual QA for skip/re-entry/preset selection behavior.
  - [ ] 🟥 Regression QA for existing users and category persistence.
  - [ ] 🟥 Post-change UI consistency review of onboarding surfaces.
