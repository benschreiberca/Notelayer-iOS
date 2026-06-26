# Migration Guide

## v1 Theme System -> v2 Design System

Migration rules implemented in ThemeManager:
- Existing themes without a themeId fall back to the default theme.
- Legacy presets map to a legacy gradient wallpaper with matching accent.
- New fields (surfaceOpacity) default to 0.85.

User impact:
- Existing customization values are preserved where possible.
- Light/dark mode is resolved explicitly at runtime via the root view.

