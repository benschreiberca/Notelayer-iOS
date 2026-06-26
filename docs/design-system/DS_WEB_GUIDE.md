---
title: Design System — Web Guide (Swift → CSS/React)
last_updated: 2026-06-25
status: active
scope: web
group: design-system
tags: [web, react, css, tokens, bridge, published]
related: [DS_TOKENS.md, DS_THEMES.md, DS_COMPONENTS.md]
source_of_truth_for: [notelayer-web]
---

# DS Web Guide

Bridge document for implementing the Notelayer design system in React / CSS. Maps Swift tokens to CSS custom properties and React component patterns.

This is the primary reference when rebuilding `notelayer-web`.

---

## CSS Custom Properties

Use the token names from `DS_TOKENS.md` as CSS custom property names, prefixed with `--nl-`.

The full export is in `exports/css-variables.css`. Key mappings:

### Colors

```css
:root {
  /* Semantic — light mode defaults */
  --nl-background-base: #FFFFFF;
  --nl-background-elevated-1: #F5F5F5;
  --nl-background-elevated-2: #EBEBEB;

  --nl-text-primary: #111111;
  --nl-text-secondary: #666666;
  --nl-text-tertiary: #999999;

  --nl-interactive-primary: var(--nl-accent);   /* set by theme */
  --nl-interactive-destructive: #E53E3E;

  --nl-border-default: rgba(0,0,0,0.08);
  --nl-border-focus: var(--nl-accent);

  /* Accent — overridden by theme class */
  --nl-accent: #6366F1;   /* indigo default */
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --nl-background-base: #111111;
    --nl-background-elevated-1: #1C1C1E;
    --nl-background-elevated-2: #2C2C2E;
    --nl-text-primary: #F5F5F5;
    --nl-text-secondary: #ABABAB;
    --nl-text-tertiary: #6B6B6B;
    --nl-border-default: rgba(255,255,255,0.08);
  }
}
```

### Accent Themes

```css
.theme-indigo  { --nl-accent: #6366F1; }
.theme-purple  { --nl-accent: #9333EA; }
.theme-pink    { --nl-accent: #EC4899; }
.theme-blue    { --nl-accent: #3B82F6; }
.theme-green   { --nl-accent: #22C55E; }
.theme-amber   { --nl-accent: #F59E0B; }
.theme-red     { --nl-accent: #EF4444; }
```

### Spacing

```css
:root {
  --nl-space-xs:  4px;
  --nl-space-sm:  8px;
  --nl-space-md:  16px;
  --nl-space-lg:  24px;
  --nl-space-xl:  32px;
  --nl-space-xxl: 48px;
}
```

### Radius

```css
:root {
  --nl-radius-none: 0;
  --nl-radius-sm:   4px;
  --nl-radius-md:   8px;
  --nl-radius-lg:   12px;
  --nl-radius-xl:   16px;
  --nl-radius-full: 9999px;
}
```

---

## Typography

11 named type styles map to CSS classes:

```css
.nl-display-lg   { font-size: 32px; font-weight: 700; }
.nl-display-md   { font-size: 28px; font-weight: 700; }
.nl-heading-lg   { font-size: 24px; font-weight: 600; }
.nl-heading-md   { font-size: 20px; font-weight: 600; }
.nl-heading-sm   { font-size: 17px; font-weight: 600; }
.nl-body-lg      { font-size: 17px; font-weight: 400; }
.nl-body-md      { font-size: 15px; font-weight: 400; }
.nl-body-sm      { font-size: 13px; font-weight: 400; }
.nl-label-lg     { font-size: 13px; font-weight: 500; }
.nl-label-md     { font-size: 11px; font-weight: 500; }
.nl-label-sm     { font-size: 10px; font-weight: 500; }
.nl-code         { font-size: 13px; font-family: monospace; }
```

---

## React Component Equivalents

Match iOS component names where possible.

### PrimaryButton

```tsx
interface PrimaryButtonProps {
  label: string;
  onClick: () => void;
  isDestructive?: boolean;
  disabled?: boolean;
}

// iOS equivalent: PrimaryButtonStyle in SettingsComponents.swift
```

```css
.nl-btn-primary {
  background: var(--nl-interactive-primary);
  color: white;
  border-radius: var(--nl-radius-lg);
  padding: var(--nl-space-sm) var(--nl-space-md);
  font-size: 17px;
  font-weight: 600;
}

.nl-btn-primary.destructive {
  background: rgba(229, 62, 62, 0.1);
  color: var(--nl-interactive-destructive);
}
```

### TaskCategoryChip

```tsx
interface CategoryChipProps {
  label: string;
  color: string;   // hex or CSS color
}

// iOS equivalent: TaskCategoryChip in SettingsComponents.swift
```

```css
.nl-category-chip {
  background: color-mix(in srgb, var(--category-color) 12.5%, transparent);
  color: var(--category-color);
  border-radius: var(--nl-radius-full);
  padding: 5px 10px;
  font-size: 11px;
  font-weight: 500;
  white-space: nowrap;
}
```

### TaskCard

```css
.nl-task-card {
  background: var(--nl-background-elevated-1);
  border: 0.5px solid var(--nl-border-default);
  border-radius: var(--nl-radius-lg);
  padding: 10px;
}
```

---

## iOS Patterns Without Direct Web Equivalents

| iOS Pattern | Web Approach |
|-------------|-------------|
| `.insetGrouped` List | `<div>` with `border-radius`, `background: --nl-background-elevated-1`, grouped sections |
| `.safeAreaInset` bottom clearance | `padding-bottom` on scroll container |
| `NavigationStack` | React Router |
| `ThemeAppearanceModifier` | CSS class on `<body>` or root `<div>` |
| Haptic feedback | Not available on web |
| Shake to undo | Not applicable |

---

## Backend

Same Firebase project as iOS. Collections and auth methods are identical.

See `docs/architecture/BACKEND_AND_AUTH.md` for Firestore collection schema and Firebase auth setup.

---

## What NOT to Do

- Do not create new token names — use the names from `DS_TOKENS.md` with `--nl-` prefix
- Do not hardcode colors — all colors through CSS custom properties
- Do not deviate from the 11 typography styles — no new font sizes
- Do not use a different backend — same Firebase project as iOS
