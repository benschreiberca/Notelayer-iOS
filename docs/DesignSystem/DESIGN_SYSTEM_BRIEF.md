# Notelayer Design System — Agent Brief

This document is the single source of truth for building any Notelayer surface (web, marketing site, extension) to match the iOS app's look and feel. Share this file plus `tokens.css` with any agent building a Notelayer UI.

---

## Brand Identity

**Product:** Notelayer — a fast, native iOS task and note capture app with a Chrome extension.  
**Personality:** Clean, focused, slightly premium. Not playful, not corporate. Feels like a well-made native app, not a SaaS dashboard.  
**Design language:** Frosted glass surfaces, soft gradient wallpapers, rounded corners, restrained animation.

---

## Typography

| Role | Font | Weight | Usage |
|------|------|--------|-------|
| Display / Headings | Space Grotesk | 600–700 | View titles, hero text, large numbers |
| Body / UI | Work Sans | 440–500 | Task titles, labels, body copy, buttons |

- Load both from Google Fonts CDN
- `font-synthesis: none` — never allow browser faux-bold
- Base body weight: **440** (between regular and medium — intentional)
- Task/content titles: **500 (medium)**
- `letter-spacing: 0.01em` on small UI labels

---

## Colour System

The system has two modes. Dark is the default.

### Dark Mode (default)

| Token | Value | Usage |
|-------|-------|-------|
| `--bg-base` | `#111827` | Page/app background (gray900) |
| `--bg-surface-1` | `rgba(31,41,55,0.88)` | Cards, list rows (gray800) |
| `--bg-surface-2` | `rgba(55,65,81,0.90)` | Elevated surfaces, inputs (gray700) |
| `--bg-surface-3` | `rgba(75,85,99,0.92)` | Highest elevation (gray600) |
| `--text-primary` | `#FFFFFF` | Main content |
| `--text-secondary` | `#D1D5DB` | Labels, metadata (gray300) |
| `--text-tertiary` | `#9CA3AF` | Hints, timestamps (gray400) |
| `--text-disabled` | `#4B5563` | Disabled states (gray600) |
| `--accent` | `#818CF8` | Buttons, active states (indigo400) |
| `--accent-hover` | `#A5B4FC` | Hover/pressed (indigo300) |
| `--accent-dim` | `rgba(129,140,248,0.18)` | Active tab bg, chip fill |

### Light Mode

| Token | Value | Usage |
|-------|-------|-------|
| `--bg-base` | `#F3F4F6` | Page background (gray100) |
| `--bg-surface-1` | `rgba(249,250,251,0.92)` | Cards (gray50) |
| `--bg-surface-2` | `rgba(255,255,255,0.96)` | Elevated (white) |
| `--bg-surface-3` | `rgba(229,231,235,0.95)` | Highest (gray200) |
| `--text-primary` | `#111827` | Main content (gray900) |
| `--text-secondary` | `#374151` | Labels (gray700) |
| `--text-tertiary` | `#6B7280` | Hints (gray500) |
| `--accent` | `#6366F1` | Buttons, active states (indigo500) |
| `--accent-hover` | `#4F46E5` | Hover (indigo600) |
| `--accent-dim` | `rgba(99,102,241,0.12)` | Active tab bg |

Toggle light/dark: set `data-theme="light"` on `<html>`. Omit for dark (default).

---

## Priority Colours

| Priority | Dark text | Dark bg | Light text | Light bg |
|----------|-----------|---------|------------|----------|
| High | `#F87171` | `rgba(248,113,113,0.16)` | `#EF4444` | `rgba(239,68,68,0.12)` |
| Medium | `#FBBF24` | `rgba(251,191,36,0.16)` | `#F59E0B` | `rgba(245,158,11,0.12)` |
| Low | `#4ADE80` | `rgba(74,222,128,0.16)` | `#22C55E` | `rgba(34,197,94,0.12)` |
| None/Deferred | `#9CA3AF` | `rgba(156,163,175,0.12)` | `#6B7280` | `rgba(107,114,128,0.10)` |

---

## Spacing Scale

```
--space-1: 4px    (xs)
--space-2: 8px    (sm)
--space-3: 12px
--space-4: 16px   (md)
--space-5: 20px
--space-6: 24px   (lg)
--space-8: 32px   (xl)
```

---

## Border Radius Scale

```
--radius-sm:   4px
--radius-md:   8px
--radius-lg:   12px   ← cards, task rows
--radius-xl:   16px   ← sheets, modals
--radius-pill: 9999px ← tabs, chips, badges
```

---

## Shadows

Dark mode shadows are stronger (darker bg = more contrast needed):

```
--shadow-sm:  0 1px 2px rgba(0,0,0,0.30)
--shadow-md:  0 2px 4px rgba(0,0,0,0.40)
--shadow-lg:  0 4px 8px rgba(0,0,0,0.50)
```

Light mode:
```
--shadow-sm:  0 1px 2px rgba(0,0,0,0.07)
--shadow-md:  0 2px 8px rgba(0,0,0,0.10)
--shadow-lg:  0 4px 16px rgba(0,0,0,0.12)
```

---

## Wallpaper / Gradient Overlay

Every Notelayer surface has a subtle gradient overlay on top of the base background, giving depth without being distracting. Apply it as a `::before` pseudo-element fixed to the viewport at `z-index: 0`, with `pointer-events: none`.

**Default dark overlay (Iridescent — default preset):**
```css
linear-gradient(
  150deg,
  rgba(129, 140, 248, 0.10) 0%,
  rgba(168, 85, 247, 0.07) 35%,
  rgba(236, 72, 153, 0.05) 70%,
  transparent 100%
)
```

**Default light overlay:**
```css
linear-gradient(
  150deg,
  rgba(0, 210, 255, 0.18) 0%,
  rgba(123, 47, 247, 0.13) 40%,
  rgba(255, 79, 216, 0.10) 75%,
  transparent 100%
)
```

The full theme system has 5 wallpaper presets and 12 accent colours (see ThemeSheet.tsx in the Chrome extension for all values).

---

## Surfaces & Frosted Glass Pattern

Surfaces use **semi-transparent backgrounds** so the wallpaper gradient bleeds through cards. This is the iOS frosted glass effect translated to the web.

```css
/* Card / list row */
background: var(--bg-surface-1);  /* rgba — intentionally transparent */
border: 1px solid var(--border-default);
border-radius: var(--radius-lg);
backdrop-filter: blur(12px);
-webkit-backdrop-filter: blur(12px);
```

Never use fully opaque white/gray backgrounds on cards — the transparency is the look.

---

## Component Patterns

### Buttons
- Primary: `background: var(--accent)`, `color: white`, `border-radius: var(--radius-pill)`, `font-weight: var(--weight-semibold)`
- Secondary/ghost: `background: var(--bg-surface-2)`, `border: 1px solid var(--border-default)`, `color: var(--text-secondary)`
- Hover: darken background by one step, no scale transform on primary

### Chips / Badges
- Selected: `background: var(--accent-dim)`, `border: 1px solid var(--accent)`, `color: var(--accent)`
- Unselected: `background: transparent`, `border: 1px solid var(--border-default)`, `color: var(--text-secondary)`, `opacity: 0.75`
- Shape: `border-radius: var(--radius-pill)`

### Cards / List Rows
- `background: var(--bg-surface-1)`, `border: 1px solid var(--border-default)`, `border-radius: var(--radius-lg)`
- Hover: `background: var(--bg-surface-2)`
- Active/selected: accent border `1px solid var(--accent)`

### Tab Bar (Navigation Pill)
- Outer container: `background: rgba(17,24,39,0.88)` dark / `rgba(243,244,246,0.90)` light, `backdrop-filter: blur(24px)`, `border-radius: var(--radius-pill)`
- Active tab: `background: var(--accent-dim)`, `color: var(--accent-light)` dark / `color: var(--accent)` light
- Inactive tab: `color: var(--text-tertiary)`

### Section Headers
- `font-size: var(--font-sm)`, `font-weight: var(--weight-semibold)`, `color: var(--text-secondary)`, `text-transform: uppercase`, `letter-spacing: 0.06em`

---

## Animation

- Fast interactions (hover, toggle): `120ms ease`
- Standard transitions (panel open, expand): `200ms ease`
- Never exceed 300ms for UI feedback
- Prefer opacity + transform over layout-triggering properties
- Respect `prefers-reduced-motion`

---

## Accessibility

- Text primary must meet WCAG AA contrast against `--bg-base`
- Never rely on colour alone to convey selection — pair with fill, border, or icon change
- Minimum touch/click target: 44×44px
- `font-synthesis: none` across the board

---

## Files to Reference

| File | What it contains |
|------|-----------------|
| `docs/DesignSystem/DESIGN_SYSTEM_BRIEF.md` | This file — full written brief |
| `notelayer-web/packages/ui/src/tokens.css` | **Complete CSS custom properties** — the implementation source of truth. Import this. |
| `docs/DesignSystem/Exports/tokens.json` | Primitive + semantic tokens as JSON (Figma/Style Dictionary compatible) |
| `docs/DesignSystem/Exports/figma-tokens.json` | Figma Tokens plugin format |
| `docs/DesignSystem/Documentation/Token_Reference_Guide.md` | 4-level token architecture explained |
| `docs/DesignSystem/Documentation/Component_Library_Reference_Guide.md` | Component token mapping |
| `docs/DesignSystem/Documentation/Theme_Reference_Guide.md` | Theming / wallpaper / accent system |
| `docs/DesignSystem/Documentation/Accessibility_Guide.md` | Contrast, motion, colour-blindness rules |

**For a new agent building a web surface:** share this brief + `tokens.css`. Everything else is supplementary.
