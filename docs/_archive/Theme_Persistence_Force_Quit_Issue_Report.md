# Issue: Theme Preset Not Persisting After Force Quit

## TL;DR
Selected theme preset reverts (often to “Barbie”) after a force quit and relaunch. Theme selection should persist across force-quit relaunches.

## Current State vs Expected Outcome
- **Current State**: Selecting a non-default theme persists during normal background/foreground app switches, but after force quitting and relaunching, the theme resets (reported as reverting to “Barbie”), while light/dark mode remains.
- **Expected Outcome**: The chosen theme preset remains selected and applied after any relaunch, including force-quit scenarios.

## Steps to Reproduce
1. Open Appearance settings and select a non-default theme preset.
2. Force quit the app.
3. Relaunch the app.
4. Observe the theme has reverted to the default preset.

## Relevant Files
- `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift`
- `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`

## Risk/Notes
- Likely persistence timing or storage mismatch (e.g., app group vs standard defaults, or missing flush on termination).
- Verify behavior on device vs simulator and ensure both preset and mode are saved consistently.

## Labels
- **Type**: Bug
- **Priority**: High
- **Effort**: Medium
