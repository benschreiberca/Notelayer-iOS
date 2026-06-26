# Token Reference

This document summarizes the four-level token architecture in Notelayer:

1. PrimitiveTokens (raw values)
2. SemanticTokens (meaning)
3. ComponentTokens (usage)
4. DesignTokens (resolved access)

## PrimitiveTokens
- Colors: gray, indigo, purple, pink, blue, green, amber, red scales
- Spacing: xs, sm, md, lg, xl, xxl
- Typography: font sizes 10-32
- Radius: none, sm, md, lg, xl, full
- Shadows: sm, md, lg, xl
- Opacity: transparent, subtle, light, medium, heavy, opaque

## SemanticTokens
Semantic tokens map primitives to meaning. Examples:
- brandPrimary / brandSecondary
- interactivePrimary / interactivePrimaryHover
- backgroundBase / backgroundElevated1
- textPrimary / textSecondary / textTertiary
- borderDefault / borderFocus

Default palettes live in:
- SemanticTokens.defaultLight()
- SemanticTokens.defaultDark()

## ComponentTokens
Components consume semantic tokens only:
- ButtonTokens
- CardTokens
- TaskItemTokens
- BadgeTokens
- GroupHeaderTokens

## DesignTokens
DesignTokens is the unified access point for the current theme:
- semantic
- components
- wallpaper
- convenience accessors (accent, sectionTint, textPrimary)

