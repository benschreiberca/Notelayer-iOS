# Floating Tab Bottom Clearance Reference Guide

This guide defines the standard for preventing floating tab overlap with bottom content.

## Goal
- Keep the viewport fully usable while scrolling.
- Ensure the last card/row can scroll above the floating tab pill.
- Avoid per-screen spacing drift.

## Standard Rule
1. Define tab geometry once in the tab shell.
- Source of truth: `AppBottomClearance` in `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`.
- Current values:
  - `tabRowHeight = 56`
  - `contentBottomSpacerHeight = tabRowHeight * 2`
  - `tabBottomPadding = 12`

2. Apply bottom clearance on the scrolling container, not the root non-scrolling container.
- Preferred target: `ScrollView` or `List` that owns the content.
- Pattern:
```swift
.safeAreaInset(edge: .bottom) {
    Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
}
```

3. Reuse the same clearance token everywhere.
- Do not introduce screen-specific spacer constants for this behavior.
- Use `AppBottomClearance.contentBottomSpacerHeight` across tab roots and drilldowns.

4. If a screen has multiple independent scroll surfaces, each surface owns its own bottom inset.
- Example: drilldown pages in Insights.

## Do / Don’t
- Do: attach `.safeAreaInset(edge: .bottom)` directly to the content scroll view.
- Do: keep bottom spacing behavior consistent across Notes, To-Dos, and Insights.
- Don’t: attach the spacer at a high-level container if child scroll views should retain full viewport height.
- Don’t: mix multiple competing bottom spacers on one screen.

## Validation Checklist
- Last card/row is fully visible above the tab pill at max scroll.
- No persistent “shrunk viewport” feeling during normal scrolling.
- Behavior is consistent on small and large iPhone simulators.
- Keyboard open state does not introduce overlap regressions.

## References
- Tab shell geometry: `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
- Insights reference implementation: `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- To-Dos parity plan: `docs/Todos_Insights_Bottom_Clearance_Parity_Implementation_Plan.md`
