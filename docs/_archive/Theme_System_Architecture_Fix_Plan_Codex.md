# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Refactor the theme system to explicit light/dark palettes and wallpaper variants, make ThemeTokens the single resolver, split background vs surface intensity, and update presets + UI so light/dark modes never mix.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Use explicit `lightColors` + `darkColors` palettes per theme, no adaptive mixing in components - eliminates mode ambiguity.
- Decision 2: Resolve all UI styling through `ThemeTokens` (no direct configuration access) - centralizes mode handling and prevents drift.
- Decision 3: Keep UI components platform-standard where possible; use Standard-Bearer `ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift` as consistency reference and justify any deviations (note line-count impact).

## Tasks:

- [ ] 🟥 **Step 1: Model + Persistence Overhaul**
  - [ ] 🟥 Introduce `ColorPalette`, `WallpaperDefinition`, and update `ThemeConfiguration` to dual palettes + light/dark wallpaper variants.
  - [ ] 🟥 Version persistence and define migration for existing presets/saved themes (including defaults for missing palettes).

- [ ] 🟥 **Step 2: Token Resolution + Mode Propagation**
  - [ ] 🟥 Update `ThemeTokens` to resolve palette and wallpaper variant by resolved `ColorScheme`.
  - [ ] 🟥 Update `ThemeManager` to track resolved scheme and emit tokens as the single source of truth.
  - [ ] 🟥 Ensure root view propagates `.light/.dark/.system` correctly and updates resolved scheme.

- [ ] 🟥 **Step 3: Wallpaper Rendering + Intensity Split**
  - [ ] 🟥 Update `ThemeBackground` to render light/dark wallpaper variants.
  - [ ] 🟥 Split intensity into `backgroundIntensity` and `surfaceOpacity` and apply to wallpaper vs cards.

- [ ] 🟥 **Step 4: Preset Catalog Rebuild**
  - [ ] 🟥 Define all presets with explicit light + dark palettes and wallpaper variants.
  - [ ] 🟥 Update preset preview logic to render in current mode without filtering/mixing errors.

- [ ] 🟥 **Step 5: Component Token Enforcement**
  - [ ] 🟥 Update components to use tokens only (TaskItemView, TodoGroupCard, chips, buttons, headers, etc.).
  - [ ] 🟥 Implement badge selected/unselected styling (filled when selected, outline when unselected).

- [ ] 🟥 **Step 6: Customize UI Adjustments**
  - [ ] 🟥 Add separate sliders for background strength and card transparency.
  - [ ] 🟥 Ensure selection indicators and previews use resolved tokens/variants.

- [ ] 🟥 **Step 7: Verification**
  - [ ] 🟥 Validate light/dark switching across wallpaper, text, cards, chips, buttons.
  - [ ] 🟥 Confirm no light/dark mixing and presets render correctly in both modes.
  - [ ] 🟥 Run build/tests and document any regressions or follow-ups.
