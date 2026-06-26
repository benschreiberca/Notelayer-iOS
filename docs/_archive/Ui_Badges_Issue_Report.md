# UI Badges: Selected/Unselected Chip Contrast

## TL;DR
- Selected/unselected category chips are hard to distinguish across the app.
- Require clear, accessible states: selected = filled; unselected = outlined with no fill.
- Must be consistent everywhere; task-row badges can be smaller but otherwise match.
- Follow UI consistency rules: keep styling centralized and minimize per-view customization.

## Current State
- Category chips often use similar filled backgrounds for both selected and unselected states, with only opacity differences.
- Text/icon color doesn’t consistently adapt for contrast between light/dark themes or selected/unselected states.
- Different chip implementations diverge across views (task input, editor, task rows).

## Expected Outcome
- Selected chips: filled with category color; text/icon uses accessible contrast (light/dark theme aware).
- Unselected chips: no fill; outline stroke uses category color; text/icon uses neutral color (white/black/gray) that meets contrast guidelines.
- Consistent styling across the app; task-row badges may be smaller in size only.

## Global Consistency Path (UI Consistency Approach)
- **Assessment-first (read-only):** Identify a *Standard-Bearer* chip implementation that best aligns with platform standards, then compare all *Deviator* implementations against it. Document differences before changing code.
- **Single source of truth:** Consolidate chip/badge visuals into one shared component or style layer so selection/outline/fill/text-contrast logic lives in one place.
- **Reduce custom wrappers:** Remove per-view styling differences that only adjust padding/spacing/foreground/background when a shared component can handle it.
- **User Flow narrative:** Capture where users see chips (task create, task edit, share sheet, task rows, settings) and verify consistent selection affordance in each.
- **Metrics:** Track lines removed when consolidating (📉 Lines saved), or label any added lines as “Quality Trade-off.”

## Most Relevant Files (max 3)
- `ios-swift/Notelayer/Notelayer/Views/Shared/CategoryChipGridView.swift` (shared selection chips)
- `ios-swift/Notelayer/Notelayer/Views/TaskInputView.swift` (CategoryChip used in task input)
- `ios-swift/Notelayer/Notelayer/Views/TaskItemView.swift` (display-only category badge in task rows)

## Notes / Risks
- Ensure text/icon contrast meets accessibility guidelines for both light and dark themes.
- Align any other badge implementations (e.g., `TaskCategoryChip` in Settings) with the same visual system.
- Be careful about dynamic colors from category data and theme tokens.

## Labels
- Type: improvement
- Priority: normal
- Effort: medium
