# Issue: Theme Sheet Does Not Update with Light/Dark Mode Selection

Status: In Progress (Code Updated, Runtime QA Pending)
Last Updated: 2026-02-10

## TL;DR
Inside the Theme sheet, changing `Appearance Mode` (Light/Dark/System) does not update sheet colors live. The sheet should immediately reflect the selected mode.

## Current State vs Expected Outcome
- **Current State**: In `AppearanceView`, selecting Light or Dark mode updates the picker value, but the Theme sheet visuals do not change to the selected color scheme while the sheet is open.
- **Expected Outcome**: Theme sheet colors should update immediately when `Appearance Mode` changes, without requiring dismiss/reopen.

## Steps to Reproduce
1. Open `Notes`, `To-Dos`, or `Insights`.
2. Open gear menu → `Colour Theme`.
3. In `Appearance Mode`, switch between `Light` and `Dark`.
4. Observe the sheet colors do not update to match the selected mode.

## Relevant Files
- `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`
- `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift`
- `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`

## Risk/Notes
- This is likely a theme state propagation issue between `theme.mode` / resolved scheme and the presented sheet environment.
- If not fixed, users can select a mode but receive delayed or misleading visual feedback in the same interaction flow.
- Validate both directions (Light → Dark and Dark → Light), and `System` behavior while the sheet remains presented.

## Labels
- **Type**: Bug (UX)
- **Priority**: Normal
- **Effort**: Medium

## Implementation Status
- Code update applied on 2026-02-10 in:
  - `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
  - `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
  - `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- Change made: Added `.preferredColorScheme(theme.preferredColorScheme)` to each presented `AppearanceView` sheet so mode changes can re-render sheet appearance live.
- Build validation: `xcodebuild -workspace Notelayer.xcworkspace -scheme Notelayer -destination 'platform=iOS Simulator,name=iPhone 17' build` completed with `BUILD SUCCEEDED`.
- Simulator smoke validation: iPhone 17 simulator booted and app launched successfully via `xcrun simctl launch`.
- Remaining work: manual runtime verification of Light/Dark/System live updates while sheet is open, including nested `Customize Theme`.
