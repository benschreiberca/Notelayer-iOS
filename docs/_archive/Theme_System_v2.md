# Notelayer — Theme System v2
## Presets-First Theme Selection with Optional Customization

---

## 1. Purpose

Redesign Notelayer’s theming system to:
- Preserve **one-tap theme selection** (speed, clarity)
- Introduce **powerful but optional customization**
- Eliminate UI overload in the default experience
- Maintain **live preview at all times**
- Support **saved custom themes** without corrupting presets

This system explicitly separates **choosing a theme** from **designing a theme**.

---

## 1.1 Reference Material & Consistency Principles

- Concept reference: `~/Users/bens/Notelayer/App-Icons-&-screenshots/Concept images`
- Ensure all UI decisions adhere to the principles in `.codex/prompts/ui-consistency.md`.

---

## 2. Mental Model (Non-Negotiable)

**Themes operate in two modes:**

1. **Preset Mode**
   - “I just want a look”
   - One tap applies everything

2. **Customize Mode**
   - “I want to tune this”
   - Sliders, options, save

These modes **must not share the same sheet**.

---

## 3. Pages / Sheets Required (Minimum)

### Page 1 — `Themes`
- Type: Half-height bottom sheet
- Purpose: Pick a full preset instantly
- No scrolling
- Live preview always visible

### Page 2 — `Customize Theme`
- Type: Expanded bottom sheet (70–85% height)
- Purpose: Full control + save
- Scroll allowed
- Live preview always visible

### Modal — `Save Theme`
- Type: Alert or mini-sheet
- Purpose: Name and confirm saved theme
- Not a full page

**Minimum surface area: 2 sheets + 1 modal**

---

## 4. Page 1 — Themes (Preset Picker)

### Purpose
Allow users to apply a **complete, opinionated theme with one tap**, without exposing complexity.

### Sheet Characteristics
- Height: ~50% of screen
- No vertical scroll
- Background content visible
- One preset always selected

### Layout (Minimum)
- **Appearance Mode** segmented control (System / Light / Dark)
- **Preset Grid** with 4–6 curated tiles
- **CTA**: “Customize This Theme”

### Appearance Mode
- Applies immediately
- Stored as part of:
  - Presets
  - Saved custom themes

### Preset Behavior
Selecting a preset applies, in one tap:
- Wallpaper
- Accent color
- Surface style
- Intensity
- Appearance mode (System / Light / Dark)

Presets are:
- Curated
- Immutable
- Never overwritten
- Always available

### Canonical Presets

#### 1. Iridescent Flow (Default)
- Wallpaper: Bold iridescent gradient
- Accent: Cool blue-violet
- Surfaces: Frosted
- Intensity: Medium (~60%)
- Mode: System

#### 2. Focus Dark
- Wallpaper: Subtle dark gradient
- Accent: Muted blue / graphite
- Surfaces: Solid
- Intensity: Low (~25%)
- Mode: Dark

#### 3. Playful Pattern
- Wallpaper: Patterned (cheetah / dots)
- Accent: Bright (pink / teal / yellow)
- Surfaces: Soft
- Intensity: High (~75%)
- Mode: Light

#### 4. Designer Calm
- Wallpaper: Designer texture (monogram / marble / fabric)
- Accent: Warm neutral
- Surfaces: Gradient
- Intensity: Medium-low (~40%)
- Mode: System or Light

### CTA — Customize This Theme
- Explicit opt-in to advanced controls
- Opens **Customize Theme**
- Uses current preset as base state

---

## 5. Page 2 — Customize Theme

### Purpose
Provide full control over the active theme while maintaining live preview.

### Sheet Characteristics
- Height: ~70–85% of screen
- Scrollable
- Background visible
- Explicit save action required

### Layout (Core Controls)

#### Wallpaper
- Categories:
  - Gradients
  - Patterns
  - Designer
  - Images
- Applies to background only
- “More Wallpapers” allows:
  - Browsing all categories
  - Uploading an image
  - Uploading a pattern

#### Accent
- iOS-style color grid
- One global accent
- Affects focus, actions, selection states

#### Surfaces (Slider-Based)
- Single slider controlling surface treatment
- Internally maps to:
  - Soft → Frosted → Gradient → Solid
- User perceives this as “more / less structure”

#### Intensity (Global Slider)
Controls overall visual loudness:
- Wallpaper opacity
- Pattern contrast
- Gradient strength

Single mental model. No per-layer controls.

---

## 6. Customization State Logic

### Entry State
- Label: `Based on: <Preset Name>`
- Save button disabled

### On Any Change
- State becomes: `Custom Theme • Unsaved`
- Save button enabled

---

## 7. Save Theme Flow

### Save Theme
- Captures:
  - Wallpaper
  - Accent
  - Surfaces
  - Intensity
  - Appearance mode
- Opens naming modal

### Save Theme Modal
- Default auto-name (editable)
- Confirm / Cancel

Saved themes:
- Are user-owned
- Can be applied with one tap
- Are editable, renamable, deletable
- Never overwrite presets

---

## 8. Default & Migration Rules

- New users:
  - Default theme = **Iridescent Flow**
- Existing users:
  - If never customized → migrate to Iridescent Flow
  - If customized → preserve current selection

---

## 9. Product Framing (Internal)

**“Pick a theme instantly. Customize only if you want.”**

---

## 10. Summary

This system:
- Preserves one-tap theming
- Introduces powerful customization safely
- Keeps UI compact and intentional
- Maintains live preview everywhere
- Scales without becoming a settings nightmare

This document is the **single source of truth** for Theme System v2.
