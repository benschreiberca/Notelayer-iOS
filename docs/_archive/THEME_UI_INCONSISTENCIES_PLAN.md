# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Restore v1.2 spacing/visual baselines and resolve Theme System v2 inconsistencies by tackling independent, low‑risk fixes first (spacing/padding, label clipping), then auditing wallpaper application, then unifying light/dark tokenization across all theme outputs. Each part ends with a **stop + build + test** gate.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Sequence by least‑risk / most‑independent first to reduce regression surface area and isolate fixes.
- Decision 2: Use v1.2 as the canonical visual baseline for spacing/padding and align all current modes to it.
- Decision 3: Treat Light/Dark as a tokenized system (single source of truth) rather than scattered per‑view branching.
- Decision 4: Follow UI consistency guardrail (use standard components when possible; if deviating, justify and note line‑count impact) and benchmark against Standard‑Bearer (`ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift`).

## Tasks:

- [ ] 🟩 **Step 1: Restore Group Toggle → First Group Spacing (v1.2 baseline)**
  - [ ] 🟩 Identify the v1.2 reference (tag/commit/screenshots) and capture the toggle→first‑group spacing target.
  - [ ] 🟩 Audit spacing in all group modes (List/Date/Category/Priority) in `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`.
  - [ ] 🟩 Restore consistent spacing so **all modes** match v1.2 and none sit too far from the toggle.
  - [ ] 🟩 Validate consistency across sizes (regular, compact) and avoid introducing non‑standard UI.
  - [ ] 🟩 **Gate:** Stop, build, and run tests after Step 1.

- [ ] 🟩 **Step 2: Restore Task Card Padding/Spacing (v1.2 baseline)**
  - [ ] 🟩 Locate v1.2 task card spacing baseline (padding/row spacing) and note exact values.
  - [ ] 🟩 Audit current task card layout in:
    - `ios-swift/Notelayer/Notelayer/Views/TaskItemView.swift`
    - `ios-swift/Notelayer/Notelayer/Views/Shared/InsetCard.swift`
  - [ ] 🟩 Revert padding/spacing to v1.2 without changing visual styling (colors, borders, shadows).
  - [ ] 🟩 Confirm consistent appearance in List/Category/Priority/Date modes.
  - [ ] 🟩 **Gate:** Stop, build, and run tests after Step 2.

- [ ] 🟩 **Step 3: Fix Wallpaper Section Label Clipping (Customize Theme)**
  - [ ] 🟩 Reproduce clipping for “Gradients”/“Patterns” labels in `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`.
  - [ ] 🟩 Adjust layout/padding so labels are fully visible at all Dynamic Type sizes.
  - [ ] 🟩 Verify no visual regression in wallpaper tiles and selection indicators.
  - [ ] 🟩 **Gate:** Stop, build, and run tests after Step 3.

- [ ] 🟩 **Step 4: Wallpaper Application Audit (App Backgrounds)**
  - [ ] 🟩 Confirm wallpaper renders correctly in all primary screens:
    - Root tabs (Notes/Todos)
    - Todos header background
    - Welcome view
  - [ ] 🟩 Fix any missing background layering or incorrect opacity ordering.
  - [ ] 🟩 Ensure wallpaper selection always maps to `ThemeBackground` and updates on change.
  - [ ] 🟩 **Gate:** Stop, build, and run tests after Step 4.

- [ ] 🟩 **Step 5: Light/Dark Tokenization Pass (Unified Theme Outputs)**
  - [ ] 🟩 Inventory all theme‑affected surfaces: wallpaper, surfaces, section/group styles, task cards, buttons, icons, accents.
  - [ ] 🟩 Consolidate light/dark behavior in centralized tokens (avoid scattered `colorScheme` branching).
  - [ ] 🟩 Verify Light/Dark selector drives **all** theme outputs consistently.
  - [ ] 🟩 Validate contrast/legibility in both modes (match Apple best practices).
  - [ ] 🟩 **Gate:** Stop, build, and run tests after Step 5.

## Acceptance Criteria (Global)
- Spacing between group toggle and first group card matches v1.2 across all modes.
- Task cards match v1.2 padding/spacing (no compressed or extra‑tight layout).
- Wallpaper section labels are fully visible and not clipped.
- Wallpaper selection reflects correctly across all app backgrounds.
- Light/Dark selector acts as a tokenized switch for all theme outputs.

## Build/Test Gate (for each step)
- Build: `xcodebuild build -project Notelayer.xcodeproj -scheme Notelayer -destination 'platform=iOS Simulator,name=iPhone 17'`
- Tests: `xcodebuild test -project Notelayer.xcodeproj -scheme Notelayer -destination 'platform=iOS Simulator,name=iPhone 17'`
