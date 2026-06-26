---
title: Design System Overview
last_updated: 2026-06-25
status: active
scope: all-platforms
group: design-system
tags: [design-system, tokens, published, portfolio]
related: [DS_TOKENS.md, DS_THEMES.md, DS_COMPONENTS.md, DS_ACCESSIBILITY.md, DS_WEB_GUIDE.md]
source_of_truth_for: [notelayer-ios, notelayer-web, notelayer-marketing]
---

# Notelayer Design System

A token-based design system targeting iOS, macOS, watchOS, and React web. Built in SwiftUI, exported for cross-platform use.

---

## Principles

1. **Token-first.** Every visual value — color, spacing, radius, shadow — is a named token. No hardcoded values anywhere in the codebase.
2. **Platform-aware.** Tokens resolve correctly on iOS, Mac, and Watch. Platform-specific patterns are explicitly labeled.
3. **Theme-able.** The entire system is overridable at runtime via the theme system. New themes require zero code changes to consuming components.
4. **Accessible by default.** Contrast, motion, and color-blindness considerations are built in, not bolted on.
5. **Agent-readable.** Every file in this system is structured for both human and AI consumption.

---

## Token Pipeline

```
PrimitiveTokens          Raw values — gray scales, brand palettes, spacing, radius
      ↓
SemanticTokens           Meaning — backgroundBase, textPrimary, interactivePrimary
      ↓
ComponentTokens          Usage — ButtonTokens, CardTokens, TaskItemTokens, BadgeTokens
      ↓
DesignTokens             Runtime access point — resolves current theme → correct values
```

No layer skips. Components consume `ComponentTokens` only. `ComponentTokens` consume `SemanticTokens` only. `SemanticTokens` consume `PrimitiveTokens` only.

---

## Files in This System

| File | What it covers |
|------|---------------|
| `DS_OVERVIEW.md` | This file — principles, pipeline, how to use |
| `DS_TOKENS.md` | All token values, names, and migration history |
| `DS_THEMES.md` | Theme system — accent, surface, mode, wallpaper |
| `DS_COMPONENTS.md` | Component patterns, usage rules, platform variants |
| `DS_ACCESSIBILITY.md` | Contrast, motion, color-blindness requirements |
| `DS_WEB_GUIDE.md` | Swift token → CSS custom property mapping for web |
| `exports/tokens.json` | Machine-readable token export |
| `exports/figma-tokens.json` | Figma-compatible token export |
| `exports/css-variables.css` | CSS custom properties for web |

---

## Swift Implementation

**Primary file:** `ios-swift/Notelayer/Notelayer/Data/DesignSystem.swift` (994 lines)

```swift
// Access pattern — always through DesignTokens
theme.tokens.cardFill          // ComponentToken
theme.tokens.textPrimary       // SemanticToken convenience accessor
theme.tokens.components.button.primaryBackground  // Direct ComponentToken
```

**Theme runtime:** `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift` (994 lines)

---

## Publishing

This design system is published as a portfolio asset. The `DS_*.md` files are written to be readable by external developers and designers without prior Notelayer knowledge. The `exports/` folder provides integration artifacts for Figma and web.

For React/web integration, start with `DS_WEB_GUIDE.md`.
