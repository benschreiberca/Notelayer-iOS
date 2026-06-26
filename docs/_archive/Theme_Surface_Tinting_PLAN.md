# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Introduce derived surface tinting (Option B) so background, group, and card surfaces shift hue in concert with accent while preserving the brightness ladder. Add one “white cards” theme with neutral surfaces, and ensure both light and dark modes follow the same hierarchy.

## Critical Decisions
- Decision 1: Use **Option B (derived tinting)** for surfaces to keep surfaces in the same hue family as the accent while preserving a consistent ladder. 
- Decision 2: Add **one “white cards” theme** with neutral surfaces in both modes (light cards = pure white; group/background step down in lightness).

## Tasks:

- [x] 🟩 **Step 1: Confirm surface ladder + tint strengths (spec finalization)**
  - [x] 🟩 Lock neutral base ladder values for light/dark (card, group, background).
  - [x] 🟩 Define per-theme tint strength ranges for background/group/card.
  - [x] 🟩 Confirm “white cards” theme neutral stack (light + dark) and accent/sectionTint behavior.

- [x] 🟩 **Step 2: Extend design tokens for derived surfaces**
  - [x] 🟩 Add surface base ladder and tint strength parameters to theme definitions.
  - [x] 🟩 Derive `screenBackground`, `groupBackground`, `cardBackground` from accent hue + base ladder.
  - [x] 🟩 Keep section tint in concert with accent (reduced chroma/alpha).

- [x] 🟩 **Step 3: Update theme catalog/presets**
  - [x] 🟩 Apply tint derivation settings per theme (traditional/pattern/designer).
  - [x] 🟩 Add the one “white cards” theme configuration.
  - [x] 🟩 Ensure light/dark variants preserve the brightness ladder.

- [x] 🟩 **Step 4: Apply tokens consistently to surfaces**
  - [x] 🟩 Wire `ThemeBackground` to `screenBackground` derived token.
  - [x] 🟩 Ensure `InsetCard`, `TodoGroupCard`, and `TaskItemView` use `cardBackground` / `groupBackground` tokens.
  - [x] 🟩 Validate accent + surface harmony visually in light and dark.

- [x] 🟩 **Step 5: Theme previews + UI consistency check**
  - [x] 🟩 Update preset previews to reflect derived surface tinting.
  - [x] 🟩 UI Consistency Guardrail: no new UI components; reuse existing surface components (e.g., `InsetCard`, `TaskItemView`, `ThemeBackground`) as the standard-bearer set; note any deviations with line-count impact if changes are necessary.

- [x] 🟩 **Step 6: Build + verification**
  - [x] 🟩 Build and verify light/dark surface differentiation across presets.
  - [x] 🟩 Verify “white cards” theme keeps neutral ladder in both modes.
  - [x] 🟩 Confirm accents + section tints remain coordinated with surfaces.
