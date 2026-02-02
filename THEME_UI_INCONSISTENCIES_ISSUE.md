# Issue: Theme UI Consistency + Tokenized Light/Dark Mode

## TL;DR
After Theme System v2 changes, spacing and styling are inconsistent (group toggles, task cards, sub-headers), and light/dark mode + wallpapers + accents are not behaving as a unified token system. Capture problems and define lowest-risk fixes first.

## Current State
- Group toggle spacing is inconsistent: Category groups sit farther from the toggle than other group modes (List/Date/Priority).
- Task card padding/spacing looks reduced vs prior requirements.
- Customize Theme UI improved but still inconsistent:
  - Light/Dark mode not reliably tokenized across all theme elements.
  - Wallpaper application is inconsistent (background not always reflecting selection).
  - Group/section tinting is inconsistent across UI.
  - Task cards, buttons, icons, accents are not consistently themed.
  - Wallpaper sub-header labels ("Gradients", "Patterns") get visually clipped by rounded tiles.

## Expected Outcome
- Consistent spacing between the group toggle and the first group card across all group modes (List/Date/Category/Priority).
- Task card padding/spacing restored to the **v1.2 baseline** (none of the current modes match; all are too far from the toggle).
- Theme system acts like a tokenized pipeline:
  - Light/Dark mode toggle updates all theme outputs (wallpaper colors, surface styles, accents, section tints, button/icon tinting).
  - Wallpaper selection is always reflected in app backgrounds (all relevant screens).
  - Section/group visuals are consistently tinted or styled.
  - Button/icon/accent treatments are unified.
- Wallpaper section labels are fully visible and not clipped.

## Scope (Least Risk / Most Independent First)
1) Group toggle → first group spacing: restore v1.2 distances (all modes currently too far from the toggle).
2) Task card spacing regression: restore v1.2 padding/spacing.
3) Wallpaper section label clipping fix.
4) Background/wallpaper application audit across screens.
5) Light/Dark tokenization pass for theme outputs (walls/surfaces/accents/icons/buttons/section tints).

## Relevant Files (max 3)
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- `ios-swift/Notelayer/Notelayer/Views/Shared/TaskItemView.swift`
- `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`

## Notes / Risks
- Risk: fixing spacing may affect screenshot tests if visuals shift; plan to update snapshots if needed.
- Light/Dark best practices: prefer semantic/dynamic colors and assets; avoid hand-rolled colorScheme branching in many views.
- Ensure wallpaper rendering is consistently applied in all root screens (e.g., Tabs, Welcome, notes/todos background layers).

## Clarifications From Product
- Baseline for spacing/padding is **v1.2** (not current list/date/category).
- All current group modes place the first group **too far** from the toggle.
- Fix order should follow least-risk / most independent first.

## Research Notes (Best Practices for Light/Dark)
- Use semantic system colors where possible (`label`, `systemBackground`, etc.), and rely on dynamic colors (asset catalog or dynamic provider) so UI updates automatically when appearance changes.
- Avoid manual `colorScheme == .dark` checks everywhere; instead, resolve via dynamic colors or centralized tokens.
- Test both appearances for contrast and legibility; avoid overly low opacity in dark mode.

## Type / Priority / Effort
- Type: Bug + Improvement
- Priority: High (theme impacts every surface)
- Effort: Medium
