# Web UI — iOS Parity Plan

**Branch:** `web/ui-ios-parity`
**Created:** 2026-06-16
**Status:** In Progress

---

## Objective

Align the Chrome extension side-panel UI with the iOS app's visual language. The current extension has correct data wiring (Firebase auth, Firestore live sync) but diverges from iOS on colour, typography, the Doing/Done control, and overall shell layout.

---

## Current State vs iOS Target

| Element | Current Web | iOS Target |
|---|---|---|
| **Primary accent** | Blue `#4F8EF7` | Indigo `#6366F1` |
| **Dark bg base** | `#0F0F0F` | `#111827` (near-black, matches iOS) |
| **Doing/Done control** | Small pill button top-right corner | Prominent centred toggle: `Doing (N)` ⟵ pill switch ⟶ `Done (N)` |
| **Wallpaper** | Solid dark background | Iridescent Flow gradient `#D8E5FF → #E6DAFE → #FDD9EC` with frosted-glass surfaces |
| **Typography** | System sans-serif | Space Grotesk (display/headings) + Work Sans (body) |
| **Tab bar icons** | Emoji (✓, 📝, 📊) | SVG icons matching iOS SF Symbol shapes |
| **Header app mark** | None | Indigo gradient checkmark roundrect |
| **Segmented lens** | Plain pill buttons | iOS-style segmented control with full-width fill |
| **Task rows** | Correct structure | Minor: priority badge shape, checkbox size |

---

## Changes — Step by Step

### Step 1 — Design tokens (tokens.css)

Update `packages/ui/src/tokens.css`:

- Change `--accent` from `#4F8EF7` → `#6366F1`
- Add `--accent-hover: #4F46E5`
- Add `--accent-dim: rgba(99, 102, 241, 0.18)`
- Add `--font-display: 'Space Grotesk', sans-serif`
- Add `--font-body: 'Work Sans', sans-serif`
- Add wallpaper gradient variable

**File:** `packages/ui/src/tokens.css`

---

### Step 2 — Google Fonts import

Add Space Grotesk + Work Sans to the sidepanel HTML entry point.

**File:** `extension/sidepanel.html` — add `<link>` to Google Fonts preconnect + stylesheet

---

### Step 3 — Doing/Done toggle (TodosView header)

Replace the current single pill button with the iOS three-part toggle layout:

```
┌────────────────────────────────────────────────┐
│  Doing                  ●────  Done             │
│  12 tasks              switch  3 tasks          │
└────────────────────────────────────────────────┘
```

**Exact spec from iOS (TodosView.swift):**
- Left label "Doing": bold when active, secondary when inactive; count below in caption
- Center: pill switch, 51×31px, indigo when right (Done), gray when left (Doing)
- Right label "Done": bold when active, secondary when inactive; count below in caption
- Container: full-width HStack, padding 14px horizontal, 12px vertical
- Tint: `#6366F1` (indigo)

**Files:** `extension/src/sidepanel/views/TodosView.tsx`, `TodosView.css`

---

### Step 4 — Wallpaper + frosted glass surfaces

The iOS app uses Iridescent Flow as the wallpaper background with frosted glass cards (`rgba(255,255,255,0.85)` + `backdrop-filter: blur(16px)` in light mode, dark-tinted surfaces in dark mode).

For the extension side panel (400px wide, dark by default):
- Wrap the full `.app` in a subtle gradient overlay: `linear-gradient(160deg, rgba(99,102,241,0.08) 0%, rgba(168,85,247,0.06) 50%, rgba(236,72,153,0.05) 100%)`
- Task card surfaces: `rgba(255,255,255,0.06)` with `backdrop-filter: blur(12px)`
- Header area: slightly elevated surface `rgba(255,255,255,0.04)`

**Files:** `extension/src/sidepanel/App.css`, `extension/src/sidepanel/views/TodosView.css`

---

### Step 5 — Tab bar SVG icons

Replace emoji with proper SVG icons matching iOS SF Symbol shapes:

- **To-Dos** (checkmark circle): `<circle>` + check path
- **Notes** (document lines): rect with horizontal lines
- **Insights** (bar chart): three ascending bars

**File:** `extension/src/sidepanel/App.tsx` — update `TabButton` icon prop to accept JSX, replace emoji strings

---

### Step 6 — App header mark

Add the Notelayer identity mark to the top of the shell — the indigo gradient roundrect checkmark that appears in the iOS navigation header.

Size in side panel: 28×28px (smaller than iOS 44pt since panel is narrow).

**File:** `extension/src/sidepanel/App.tsx` or `TodosView.tsx` header section

---

### Step 7 — Segmented lens control

Update `.todos__seg` to match iOS segmented style:
- Background: `rgba(255,255,255,0.08)` 
- Active pill: `rgba(255,255,255,0.18)` with subtle shadow
- Full-width fill (not gap-based)
- Transition: 150ms ease

---

### Step 8 — Typography application

Apply fonts to key elements:
- Page titles (To-Dos, Notes): `var(--font-display)`, 700 weight
- Body/tasks: `var(--font-body)`, 400/500 weight
- Labels and counts: `var(--font-body)`, smaller sizes

---

## Build & Install Instructions

See `WEB_EXTENSION_INSTALL_GUIDE.md` in this directory.

---

## Firestore Sync — Already Working

The extension already syncs with iOS via Firestore `onSnapshot`. No changes needed here. Tasks created on web appear on iOS in real-time and vice versa.

---

## Non-Goals (This PR)

- Voice capture
- Calendar sync
- Insights charts
- Settings screen redesign
- Light mode

---

## Definition of Done

- [ ] Doing/Done toggle matches iOS three-part layout
- [ ] Accent colour is indigo `#6366F1` throughout
- [ ] Space Grotesk applied to headings, Work Sans to body
- [ ] Tab bar uses SVG icons (no emoji)
- [ ] Subtle iridescent gradient overlay on app shell
- [ ] Task surfaces use frosted glass effect
- [ ] Extension loads and installs in Chrome without errors
- [ ] Firestore sync confirmed working after UI changes
