# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Plan for implementing Theme System v2: presets-first selection in a compact half-sheet, a separate expanded customization sheet with live preview, saved custom themes, and migration to the new default while preserving existing user choices.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Preset selection and customization live in separate sheets to avoid overload and preserve one-tap theming.
- Decision 2: Themes split into wallpaper, accent, surface style, intensity, and appearance mode for decoupled control.
- Decision 3: Default theme becomes Iridescent Flow for users who never customized; preserve existing customized selections.
- Decision 4: Global intensity slider controls wallpaper opacity, pattern contrast, and gradient strength (no per-layer controls).
- Decision 5: Follow `.codex/prompts/ui-consistency.md`; use platform-standard components unless explicitly justified with a line-count impact note.

## Tasks:

- [ ] 🟥 **Step 1: Baseline & Standards Alignment**
  - [ ] 🟥 Identify the Standard-Bearer file(s) for platform-consistent UI (use for comparison).
  - [ ] 🟥 Audit current appearance UI for deviations from `ui-consistency.md` and note line-count impact.
  - [ ] 🟥 Confirm constraints for sheet heights and live preview visibility in the current navigation stack.

- [ ] 🟥 **Step 2: Data Model & Persistence Design**
  - [ ] 🟥 Define Theme v2 model fields (wallpaper, accent, surfaces, intensity, appearance).
  - [ ] 🟥 Specify preset vs custom theme storage (immutable presets, user-owned customs).
  - [ ] 🟥 Plan migration logic: detect “never customized” and apply Iridescent Flow.

- [ ] 🟥 **Step 3: Preset Sheet (Themes) UX**
  - [ ] 🟥 Design half-height sheet layout (no vertical scroll, live preview).
  - [ ] 🟥 Define the canonical preset tiles and metadata.
  - [ ] 🟥 Include “Customize This Theme” CTA with base-state handoff.

- [ ] 🟥 **Step 4: Customize Sheet UX**
  - [ ] 🟥 Define layout for wallpaper categories, iOS-style accent grid, surface slider, intensity slider.
  - [ ] 🟥 Confirm “More Wallpapers” behavior (browse, upload image, upload pattern).
  - [ ] 🟥 Define state logic: “Based on” vs “Custom Theme • Unsaved.”

- [ ] 🟥 **Step 5: Save Theme Flow**
  - [ ] 🟥 Specify naming modal behavior (default name, confirm/cancel).
  - [ ] 🟥 Define saved theme management (apply, rename, delete).

- [ ] 🟥 **Step 6: Visual Assets & Pattern Strategy**
  - [ ] 🟥 Catalog pattern/texture requirements (patterns, gradients, designer, image-based).
  - [ ] 🟥 Validate where assets live and how they are referenced (ensure concept alignment).

- [ ] 🟥 **Step 7: Implementation Plan & Test Strategy**
  - [ ] 🟥 Map required files and ownership boundaries (ThemeManager, Appearance views, assets).
  - [ ] 🟥 Define UI verification steps (live preview, persistence, migration correctness).

