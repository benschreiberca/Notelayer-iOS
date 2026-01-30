# Feature Implementation Plan

**Overall Progress:** `75%`

## TLDR
Fix theme preset persistence so the selected theme survives force-quit relaunches by auditing storage paths and normalizing save/load behavior in `ThemeManager`.

## Critical Decisions
- Decision 1: Use `ThemeManager` as the single source of truth for preset + mode persistence.
- Decision 2: Write theme preset and mode to the same storage consistently (app group + standard defaults if needed) and load with a clear priority order.

## Tasks:

- [x] 🟩 **Step 1: Audit Current Persistence**
  - [x] 🟩 Identify where theme preset + mode are saved and loaded.
  - [x] 🟩 Confirm keys/suite names used by `ThemeManager` and `AppearanceView`.

- [x] 🟩 **Step 2: Normalize Save/Load Logic**
  - [x] 🟩 Ensure theme preset is saved on selection changes and flushed immediately.
  - [x] 🟩 Ensure load path prioritizes the correct storage and falls back safely.

- [x] 🟩 **Step 3: Guardrails + Fallbacks**
  - [x] 🟩 Add validation for invalid/missing presets (fallback to default without overwriting).

- [ ] 🟥 **Step 4: Verification**
  - [ ] 🟥 Manual device test: select theme → force quit → relaunch; verify preset persists.
  - [ ] 🟥 Manual simulator test: repeat to confirm parity.

## UI Consistency Guardrail
- **Standard-Bearer:** Not applicable (persistence-only change).
- **Deviations:** None (no UI components added).
