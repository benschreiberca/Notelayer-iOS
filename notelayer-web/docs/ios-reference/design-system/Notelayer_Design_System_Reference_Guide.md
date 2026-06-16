# Notelayer Design System (Theme-Applied Elements)

This is a plain-English inventory of the visual element classes that receive theme or color styling, plus a few concrete examples of where each shows up in the app.

## 1) App backgrounds (wallpaper)
What it is:
- The full-screen background behind primary screens. It can be a gradient, pattern, designer texture, or user image.

Examples:
- Root tabs background (Notes and Todos) use `ThemeBackground` to render the current wallpaper.
- Welcome screen background uses `ThemeBackground`.
- Customize Theme previews and tiles also render the wallpaper.

## 2) Accent color (global accent)
What it is:
- The primary highlight color for actions, selection, and emphasis across the UI.

Examples:
- Tab bar selection tint and general `tint` for controls in the root tab view.
- Primary action buttons (e.g., primary button style uses the accent color).
- Selection indicators in the theme picker (checkmarks/strokes in preset and wallpaper tiles).

## 3) Section/group tint
What it is:
- A secondary accent used for section or group labeling, especially where a subtle tint is desirable.

Examples:
- The count capsule in group headers (e.g., Todo group headers).
- Section-level UI chips that need a softer, non-primary accent.

## 4) Surface styles (cards and containers)
What it is:
- The fill and styling of cards and surfaces. The theme provides multiple styles (soft, frosted, gradient, solid).

Examples:
- Task cards (each task row background) use the current surface style.
- Inset cards in Notes view use the current surface style.
- Any reusable card or inset container (e.g., shared card components).

## 5) Card borders / strokes
What it is:
- Subtle strokes used to separate cards from the background.

Examples:
- Task cards use the theme stroke for borders.
- Inset cards use the theme stroke for borders.

## 6) Text colors
What it is:
- The theme exposes primary and secondary text colors that map to iOS semantic colors.

Examples:
- Task titles use primary or secondary text color (e.g., completed tasks).
- Metadata rows (dates, priority, secondary labels) use secondary text color.

## 7) Category chips and badges
What it is:
- Category chips use their category color if present, otherwise fall back to theme accent. They are also tinted for readability.

Examples:
- Task category chips in task rows.
- Reusable category chip components used in settings or other task lists.

## 8) Selection indicators and UI feedback
What it is:
- Selection rings, checkmarks, and small highlights that communicate selection state.

Examples:
- Preset tiles show a tinted checkmark and an accent stroke when selected.
- Wallpaper tiles show a tinted checkmark and accent stroke when selected.
- Segmented controls and toggles are tinted by the theme accent.

## 9) Appearance mode (light / dark / system)
What it is:
- The appearance mode is part of the theme and drives light/dark rendering across the app.

Examples:
- The root view applies the preferred color scheme from the theme.
- Wallpapers choose light vs dark palette sets based on the current appearance mode.
- System background and label colors automatically adapt to the selected appearance mode.

## 10) Intensity (global visual strength)
What it is:
- A single global slider that adjusts wallpaper strength, pattern contrast, and gradient opacity.

Examples:
- Gradient wallpaper opacity scales with intensity.
- Pattern foreground opacity scales with intensity.
- Image wallpaper opacity scales with intensity.

---

If you want this broken down further (for example: a table listing each UI component and its exact theme token), say the word and I will expand it.

---

# Theme Application Flow (Plain English)

This is a plain‑English summary of how a theme is applied in the app today.

1) **A ThemeConfiguration is the source of truth.**  
   It holds wallpaper selection, accent color, section tint, surface style, and intensity.

2) **ThemeManager owns the current configuration and mode.**  
   - When you pick a preset, ThemeManager swaps in that preset’s configuration.  
   - When you toggle Light/Dark/System, ThemeManager adjusts the configuration using its mode rules.

3) **Root screens render the wallpaper.**  
   The main screens (RootTabs, Todos header background, Welcome, etc.) place `ThemeBackground` behind their content, so the wallpaper is always present.

4) **Tokens translate the configuration into UI colors.**  
   `ThemeTokens` exposes things like accent, sectionTint, surface fills, text colors, and card stroke colors. Views use these tokens rather than ad‑hoc colors.

5) **Individual components read tokens to style themselves.**  
   Task cards, inset cards, buttons, chips, and text all use token colors (or category colors when available).

6) **Intensity controls wallpaper strength.**  
   The global intensity value drives gradient opacity, pattern contrast, and image opacity in `ThemeBackground`.

---

# Component Name Map (UI → Code)

This section lists the main components that receive theme styling and the exact names used in code.

- **Wallpaper / app background** → `ThemeBackground`
- **Theme state + tokens** → `ThemeManager`, `ThemeTokens`, `ThemeConfiguration`
- **Preset theme definitions** → `ThemePresetCatalog`, `ThemePresetDefinition`
- **Theme selection sheet** → `AppearanceView`
- **Customize theme sheet** → `CustomizeThemeView`
- **Wallpaper tile (Customize Theme)** → `WallpaperTile`, `WallpaperCategoryRow`
- **All wallpapers list** → `AllWallpapersView`, `WallpaperRow`
- **Task card** → `TaskItemView`
- **Group/section card** → `TodoGroupCard` (wraps `InsetCard`)
- **Card surface styling** → `InsetCard`
- **Group header (Todos)** → `TodoGroupCardHeader`
- **Category chip** → `TaskCategoryChip` (and inline `categoryBadge` in `TaskItemView`)
- **Priority badge** → `TaskPriorityBadge`
- **Primary action button style** → `PrimaryButtonStyle`
- **Root container (tabs + tint)** → `RootTabsView`
- **Welcome screen** → `WelcomeView`


---

# Reported Theme Issues (Updated)

## Full issue list (plain English)
- Theme selection and customization felt mixed together; you wanted a clear split between quick presets and deep customization.
- Presets lacked variety (too similar; not enough strong gradients, textures, patterns, or designer styles).
- Wallpaper choices felt too similar; you wanted more patterns and designer options.
- Wallpaper and section/group styling were coupled; you wanted them separately configurable.
- No global intensity/transparency control; you wanted a single slider.
- Default theme should be Iridescent for users who never customized; existing customizations should be preserved.
- Preset selection sheet felt too tall; reduce wasted space.
- Selected wallpaper wasn’t visually obvious in Customize Theme; add a stroke/indicator.
- Wallpapers sometimes didn’t apply to actual app backgrounds (bug).
- Two preset rows should scroll independently (traditional vs pattern) with more distinct presets.
- Rename “Customize this theme” to “Fully customize Notelayer.”
- Customize Wallpaper should have multiple scrolling rows (gradients, patterns, uploads).
- Add a separate section/group tint control.
- Presets should apply consistently across wallpaper, buttons, surfaces, sections, etc.
- Light/Dark mode behavior wasn’t tokenized; selector should drive all themed outputs.
- Light/Dark preset filtering was mixed; Light should show only light themes, Dark only dark themes.
- Group card spacing from the toggle regressed (too far from v1.2 baseline).
- Task card padding/spacing regressed (compressed vs v1.2).
- Wallpaper sub‑header labels (“Gradients”, “Patterns”) were clipped.
- Badge selection states lack distinction (selected should be filled; unselected should be outline only).

## Grouped by interpretation (problem type)
**A. Theme system design / structure**
- Preset vs customization flow felt mixed; needed clearer separation.
- Default theme behavior for new vs existing users.

**B. Visual variety / content gaps**
- Presets too similar; needed more gradients, patterns, designer styles.
- Wallpaper library lacked variety.

**C. Control / customization gaps**
- Wallpaper and section/group styling coupled; needed separate control.
- Missing global intensity control.
- Needed section/group tint control.
- Needed clearer selection indicator for wallpaper.

**D. Behavior bugs / incorrect application**
- Wallpapers not consistently applied to app backgrounds.
- Light/Dark selector not driving all theme outputs.
- Light/Dark preset filtering mixed up.

**E. UI clarity / selection feedback**
- Theme sheet too tall / wasted space.
- Wallpaper sub‑headers clipped.
- Badge states indistinct (selected vs unselected).

**F. Layout/spacing regressions**
- Group card spacing from toggle too large.
- Task card spacing compressed.

## Grouped by component
**Theme selection sheet (AppearanceView)**
- Sheet height/wasted space.
- Two independent horizontal preset rows.
- Light/Dark filtering of presets.
- More distinct preset themes.

**Customize sheet (CustomizeThemeView / AppearanceView sections)**
- Wallpaper selection indicator.
- Multiple wallpaper rows (gradients, patterns, uploads).
- Wallpaper label clipping.
- Section/group tint control.
- Global intensity control.

**Theme data/model (ThemeManager / ThemePresetCatalog / ThemeConfiguration)**
- Preset variety (gradients, patterns, designer).
- Default Iridescent for new users; preserve existing customizations.
- Tokenized Light/Dark behavior across all outputs.

**Wallpaper rendering (ThemeBackground + root screens)**
- Wallpaper not consistently applied behind primary screens.

**Task & group cards (TaskItemView / TodoGroupCard / InsetCard)**
- Task card spacing regression.
- Group card spacing regression.

**Badges / chips / selection indicators**
- Badge fill vs outline states need clearer selected/unselected distinction.

**Global UI consistency**
- Buttons, icons, accents, section styling should all follow theme tokens.
