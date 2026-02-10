# Theme Guide

## Adding a New Theme
1. Open `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift`.
2. Add a new entry to `ThemeCatalog.themes` using `makeTheme(...)`.
3. Provide:
   - id, name, description
   - category (traditional or pattern)
   - preferredMode (light or dark)
   - wallpaper selection (gradient/pattern/designer)
   - accent + section tint
   - surface style + intensity
4. Validate both light and dark modes in the theme picker.

## Customization
- Accents and section tints override semantic tokens at runtime.
- Wallpaper selection overrides the theme's default wallpaper.
- Background strength uses `configuration.intensity`.
- Card transparency uses `configuration.surfaceOpacity`.

