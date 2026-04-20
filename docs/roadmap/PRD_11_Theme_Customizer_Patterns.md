# PRD 11: Theme Customizer with Real Pattern Backgrounds

Last Updated: 2026-04-20
Status: Draft
Feature Area: Personalization / Themes
Priority: Medium

## Purpose

Make the theme customizer actually apply the decorative backgrounds users select (e.g., Cheetah), so the visual experience matches what is advertised.

## Problem Statement

The current theme system includes named themes like "Cheetah" that imply a pattern background but do not actually render one. The customizer is visually incomplete and feels like a broken promise. Users who try to personalize are left disappointed.

## Goals

- Make every named theme render its intended background pattern.
- Patterns should tile or position correctly across all screen sizes.
- Patterns must not harm readability of text or task content.
- Allow users to preview themes before applying.

## Non-Goals

- Custom image upload from camera roll (too much scope for v1).
- Animated / live wallpapers.
- Pattern editor or color picker for patterns.

## In Scope

- Fix existing named themes (Cheetah and any others) to apply their intended backgrounds.
- Add 4–6 additional curated pattern backgrounds (geometric, subtle textures, minimal).
- Live preview in the theme picker sheet before applying.
- Pattern opacity/intensity slider so users can dial down busy backgrounds.
- Patterns stored as lightweight SVG or PNG assets in the app bundle.

## Pattern Design Direction

- Patterns must work in both light and dark mode (separate light/dark variants or overlay approach).
- Cheetah: actual cheetah-spot texture, muted/subtle.
- Additional suggestions: linen, dot grid, chevron stripe, blueprint grid, watercolor wash.
- Keep file sizes small — no pattern asset over 100KB.

## Technical Notes

- Evaluate: SwiftUI `background` modifier with a tiling `Image` vs. `UIColor(patternImage:)`.
- Pattern assets should be in the asset catalog, not loaded from disk at runtime.
- Pattern rendering should not cause scroll jank — test on iPhone SE (oldest supported hardware).

## Acceptance Criteria

- [ ] Cheetah theme applies a visible cheetah-pattern background.
- [ ] At least 4 other pattern themes are available.
- [ ] Live preview works in the theme picker before applying.
- [ ] Opacity/intensity slider is functional.
- [ ] Light and dark mode both look correct for each pattern.
- [ ] No scroll performance regression on iPhone SE.
- [ ] Theme persists across force-quit and relaunch (existing bug area — see `Theme_Persistence_Force_Quit_Plan`).

## Related

- `Theme_System_v2.md`
- `Theme_Persistence_Force_Quit_Plan_2026_01_29.md`
- `THEME_UI_INCONSISTENCIES_PLAN.md`
