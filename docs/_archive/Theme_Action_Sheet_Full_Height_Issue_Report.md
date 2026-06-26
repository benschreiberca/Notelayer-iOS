# Issue: Theme Action Sheet Cannot Expand to Full Height

Status: In Progress (Code Updated, QA Pending)
Last Updated: 2026-02-10

## TL;DR
The Theme sheet opened from `Colour Theme` is locked to half-height, so users cannot drag it to a full-height view for easier browsing and selection.

## Current State vs Expected Outcome
- **Current State**: `AppearanceView` is presented with `.presentationDetents([.fraction(0.5)])` from top-level tabs, which caps the sheet at 50% height.
- **Expected Outcome**: The Theme sheet should support a full-height state (for example `.large`) so users can expand it when needed.

## Steps to Reproduce
1. Open `Notes`, `To-Dos`, or `Insights`.
2. Tap the top-right gear menu.
3. Select `Colour Theme`.
4. Try to drag the sheet up to full height.
5. Observe the sheet does not expand past half-height.

## Relevant Files
- `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`

## Risk/Notes
- Theme customization contains many controls; half-height forces extra scrolling and reduces preview context.
- The same detent setup appears in multiple tabs, so fix should stay consistent across all entry points.
- Align this sheet behavior with other app sheets that already allow larger detents where content density is high.

## Labels
- **Type**: Bug (UX)
- **Priority**: Normal
- **Effort**: Low

## Implementation Status
- Code update applied on 2026-02-10 in:
  - `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
  - `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
  - `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- Change made: Theme sheet detents updated from `.fraction(0.5)` to `[.medium, .large]`.
- Remaining work: manual UI validation for drag behavior and nested `Customize Theme` presentation.
