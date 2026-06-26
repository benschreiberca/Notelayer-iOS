---
title: Design System — Tokens
last_updated: 2026-06-25
status: active
scope: all-platforms
group: design-system
tags: [tokens, primitives, semantic, component, published]
related: [DS_OVERVIEW.md, DS_THEMES.md, DS_COMPONENTS.md]
source_of_truth_for: [notelayer-ios, notelayer-web]
---

# DS Tokens

All token values, organized by the four-level pipeline. Swift source: `Data/DesignSystem.swift`.

---

## Level 1 — PrimitiveTokens

Raw values with no semantic meaning. Never use directly in components.

### Color Scales

Each scale runs from 50 (lightest) to 900 (darkest).

| Scale | Use |
|-------|-----|
| `gray` | Backgrounds, borders, text, surfaces |
| `indigo` | Brand primary accent option |
| `purple` | Brand accent option |
| `pink` | Brand accent option |
| `blue` | Brand accent option |
| `green` | Brand accent option / success |
| `amber` | Brand accent option / warning |
| `red` | Destructive / error |

### Spacing

| Token | Value |
|-------|-------|
| `spacing.xs` | 4pt |
| `spacing.sm` | 8pt |
| `spacing.md` | 16pt |
| `spacing.lg` | 24pt |
| `spacing.xl` | 32pt |
| `spacing.xxl` | 48pt |

### Radius

| Token | Value |
|-------|-------|
| `radius.none` | 0 |
| `radius.sm` | 4pt |
| `radius.md` | 8pt |
| `radius.lg` | 12pt |
| `radius.xl` | 16pt |
| `radius.full` | 9999pt (pill) |

### Typography Sizes

| Token | Size |
|-------|------|
| `type.displayLarge` | 32pt |
| `type.displayMedium` | 28pt |
| `type.headingLarge` | 24pt |
| `type.headingMedium` | 20pt |
| `type.headingSmall` | 17pt |
| `type.bodyLarge` | 17pt |
| `type.bodyMedium` | 15pt |
| `type.bodySmall` | 13pt |
| `type.labelLarge` | 13pt |
| `type.labelMedium` | 11pt |
| `type.labelSmall` | 10pt |
| `type.code` | 13pt (monospace) |

### Shadows

`shadow.sm`, `shadow.md`, `shadow.lg`, `shadow.xl`

### Opacity

`opacity.transparent` (0) → `opacity.subtle` → `opacity.light` → `opacity.medium` → `opacity.heavy` → `opacity.opaque` (1)

---

## Level 2 — SemanticTokens

Map primitives to meaning. Separate light and dark palettes. Use these in ComponentTokens only.

```swift
SemanticTokens.defaultLight()
SemanticTokens.defaultDark()
```

### Background

| Token | Meaning |
|-------|---------|
| `backgroundBase` | Root screen background |
| `backgroundElevated1` | Cards, sheets, elevated surfaces |
| `backgroundElevated2` | Popovers, menus — highest elevation |

### Text

| Token | Meaning |
|-------|---------|
| `textPrimary` | Primary body text |
| `textSecondary` | Supporting/metadata text |
| `textTertiary` | Placeholder, disabled text |
| `textOnAccent` | Text on colored/accent backgrounds |

### Brand & Interactive

| Token | Meaning |
|-------|---------|
| `brandPrimary` | Primary brand color (current accent) |
| `brandSecondary` | Secondary brand color |
| `interactivePrimary` | Primary tappable element fill |
| `interactivePrimaryHover` | Hover state (Mac only) |
| `interactiveDestructive` | Destructive action color |

### Border

| Token | Meaning |
|-------|---------|
| `borderDefault` | Standard card/container border |
| `borderFocus` | Focused input border |
| `borderDestructive` | Error/destructive border |

---

## Level 3 — ComponentTokens

Consumed by view components only. Never used directly in layout code.

### ButtonTokens

| Token | Value source |
|-------|-------------|
| `primaryBackground` | `interactivePrimary` |
| `primaryText` | `textOnAccent` |
| `destructiveBackground` | `interactiveDestructive` at 10% opacity |
| `destructiveText` | `interactiveDestructive` |

### CardTokens (InsetCard)

| Token | Value source |
|-------|-------------|
| `background` | `backgroundElevated1` |
| `border` | `borderDefault` at 0.5pt |
| `cornerRadius` | `radius.lg` (12pt) |

### TaskItemTokens

| Token | Value source |
|-------|-------------|
| `background` | `backgroundElevated1` |
| `titleText` | `textPrimary` |
| `metaText` | `textSecondary` |
| `checkboxSize` | 24pt |
| `checkboxSpacing` | 12pt |

### BadgeTokens (CategoryChip / PriorityBadge)

| Token | Value source |
|-------|-------------|
| `selectedBackground` | Category color at 12.5% opacity |
| `unselectedBorder` | `borderDefault` |
| `text` | Category color (chip) / `textSecondary` (priority) |
| `cornerRadius` | `radius.full` (pill) |
| `paddingH` | 10pt |
| `paddingV` | 5pt |

### GroupHeaderTokens (Todos section headers)

| Token | Value source |
|-------|-------------|
| `titleText` | `textSecondary` |
| `countBackground` | `backgroundElevated2` |
| `countText` | `textTertiary` |

---

## Level 4 — DesignTokens (Runtime Access)

Single access point for the current theme's resolved tokens.

```swift
// Always access tokens through the theme environment object
@EnvironmentObject var theme: ThemeManager

// Examples
theme.tokens.cardFill              // → backgroundElevated1 resolved for current mode
theme.tokens.textPrimary           // → textPrimary resolved for current mode
theme.tokens.components.button.primaryBackground  // → ButtonTokens.primaryBackground
```

Convenience accessors on `DesignTokens`:
- `.accent` — current accent color (brand primary)
- `.sectionTint` — current section tint
- `.textPrimary`, `.textSecondary`, `.textTertiary`
- `.cardFill`, `.cardStroke`, `.groupFill`

---

## Migration History

### v1 Theme System → v2 Design System

- Existing themes without a `themeId` fall back to the default theme.
- Legacy presets map to a legacy gradient wallpaper with matching accent.
- New field `surfaceOpacity` defaults to `0.85`.
- User customization values are preserved where possible.
- Light/dark mode is now resolved explicitly at runtime via the root view (not inferred).

---

## Export Files

| File | Format | Use |
|------|--------|-----|
| `exports/tokens.json` | JSON | Programmatic token consumption |
| `exports/figma-tokens.json` | Figma Tokens JSON | Figma library sync |
| `exports/css-variables.css` | CSS custom properties | Web integration |

> ⚠️ Verify export files match current `DesignSystem.swift` before using in production. Last confirmed: TBD.
