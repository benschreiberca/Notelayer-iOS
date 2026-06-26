---
title: Design System — Themes
last_updated: 2026-06-25
status: active
scope: all-platforms
group: design-system
tags: [themes, accent, surface, wallpaper, published]
related: [DS_TOKENS.md, DS_COMPONENTS.md]
source_of_truth_for: [notelayer-ios]
---

# DS Themes

The theme system allows full runtime visual customization without code changes. Swift source: `Data/ThemeManager.swift` (994 lines).

---

## Theme Dimensions

Every theme is composed of four independent dimensions:

| Dimension | Options |
|-----------|---------|
| **Accent color** | Indigo, Purple, Pink, Blue, Green, Amber, Red |
| **Surface style** | Soft, Frosted, Gradient, Solid |
| **Mode** | Light, Dark, System |
| **Wallpaper** | Gradient / Pattern (Cheetah) / Designer / None |

Any combination is valid. Changes apply immediately at runtime.

---

## ThemeConfiguration

```swift
struct ThemeConfiguration {
    var id: String
    var name: String
    var description: String
    var category: ThemeCategory       // .traditional | .pattern
    var preferredMode: ThemeMode      // .light | .dark | .system
    var wallpaper: ThemeWallpaperKind
    var accent: ThemeAccent
    var sectionTint: Color
    var surfaceStyle: ThemeSurfaceStyle
    var intensity: Double             // background strength 0.0–1.0
    var surfaceOpacity: Double        // card transparency, default 0.85
}
```

---

## Accent Colors

| Name | Token | Swift enum |
|------|-------|-----------|
| Indigo | `indigo` scale | `.indigo` |
| Purple | `purple` scale | `.purple` |
| Pink | `pink` scale | `.pink` |
| Blue | `blue` scale | `.blue` |
| Green | `green` scale | `.green` |
| Amber | `amber` scale | `.amber` |
| Red | `red` scale | `.red` |

Accent overrides `SemanticTokens.brandPrimary` and `SemanticTokens.interactivePrimary` at runtime.

---

## Surface Styles

| Style | Description |
|-------|-------------|
| **Soft** | Subtle translucency; light backgrounds with gentle depth |
| **Frosted** | Glass-like blur effect; prominent depth cues |
| **Gradient** | Gradient background derived from accent color |
| **Solid** | Flat, no translucency; highest contrast |

`intensity` controls background strength (0.0–1.0). `surfaceOpacity` controls card transparency (default 0.85).

---

## Wallpapers

| Kind | Description |
|------|-------------|
| Gradient | Smooth color gradient, typically accent-derived |
| Pattern | Repeating pattern (e.g. Cheetah) |
| Designer | Curated artisanal backgrounds |
| None | Plain surface only |

Implemented in: `Views/Shared/CheetahBackground.swift`, `Views/Shared/CheetahCardPattern.swift`, `Views/Shared/ThemeBackground.swift`

---

## Adding a New Theme

1. Open `Data/ThemeManager.swift`
2. Add entry to `ThemeCatalog.themes` using `makeTheme(...)`
3. Provide all `ThemeConfiguration` fields
4. Validate both light and dark modes in the theme picker UI
5. Add `DS_THEMES.md` entry for the new theme

---

## Runtime Application

```swift
// Theme is provided as an EnvironmentObject from the app root
@EnvironmentObject var theme: ThemeManager

// Apply to a view
.modifier(ThemeAppearanceModifier())

// Access current theme values
theme.tokens.accent        // current accent color
theme.tokens.cardFill      // resolved card background for current mode
```

`ThemeAppearanceModifier` — `Views/Shared/ThemeAppearanceModifier.swift`
`ThemeBackground` — `Views/Shared/ThemeBackground.swift`

---

## Platform Notes

| Platform | Theme Support |
|----------|--------------|
| iOS | Full — all accents, surfaces, wallpapers, modes |
| Mac | Full — same token system; wallpapers TBD for Mac shell |
| Watch | None — Watch uses system appearance only |
| Web | Partial — accent + mode via CSS custom properties (see `DS_WEB_GUIDE.md`) |
