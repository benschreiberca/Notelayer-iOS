# Settings UI Consistency Fix & Component Library

**Overall Progress:** `100%`

## TLDR
Fix the regression in settings UI by enforcing 1:1 parity with the main To-Do list card styles, then establish a reusable component library to prevent future inconsistencies. This ensures that all future settings/menus follow the exact same visual patterns.

## Critical Decisions
- **Zero Custom Layouts**: Any future settings page must reuse components from the shared library, not create new styles.
- **Component Extraction**: Extract existing patterns (headers, cards, chips, buttons) into a `Shared/` folder for universal reuse.
- **Style Guide Documentation**: Create a reference doc that shows which component to use for which purpose (task cards, section headers, buttons, etc.).
- **Single Source of Truth**: The main To-Do list card (`TaskItemView`) is the canonical design. All other cards must match it exactly.

## Tasks:

- [x] 🟩 **Step 1: Fix Immediate Regression**
  - [x] 🟩 Read `TaskItemView.swift` to understand the exact chip and priority label style
  - [x] 🟩 Replace custom `NagCardView` in `RemindersSettingsView.swift` with exact TaskItemView parity
  - [x] 🟩 Ensure chips are rounded, single-line, and identical to main list
  - [x] 🟩 Ensure priority labels use the exact same badge style
  - [x] 🟩 Keep the "nag details" inset card (orange clock + time)

- [x] 🟩 **Step 2: Standardize Headers Across Settings**
  - [x] 🟩 Audit all headers in `ProfileSettingsView.swift` and `ManageAccountView.swift`
  - [x] 🟩 Create `SettingsSectionHeader` component with unified style
  - [x] 🟩 Apply universally to all sections ("Pending Nags", "Account", "About")

- [x] 🟩 **Step 3: Extract Reusable Components**
  - [x] 🟩 Create `Shared/SettingsComponents.swift` with standard views:
    - `SettingsSectionHeader` - Unified header style
    - `TaskCategoryChip` - Reusable category chip (copied from `TaskItemView`)
    - `TaskPriorityBadge` - Reusable priority label (copied from `TaskItemView`)
    - `PrimaryButtonStyle` - Universal button style
  - [x] 🟩 Refactor existing views to use these shared components
  - [x] 🟩 Apply `PrimaryButtonStyle` to Phone Auth buttons ("Send Code", "Verify", "Back")

- [x] 🟩 **Step 4: Create Style Guide Documentation**
  - [x] 🟩 Create `docs/UI_COMPONENT_GUIDE.md` with usage rules and code examples
  - [x] 🟩 Document when to use each component
  - [x] 🟩 Add enforcement checklist for future features

- [x] 🟩 **Step 5: Final Verification**
  - [x] 🟩 Verify all cards use theme tokens
  - [x] 🟩 Verify chip/badge styles match between To-Do list and Pending Nags
  - [x] 🟩 Fix missing SF Symbol (`bell.badge.exclamationmark.fill` → `bell.badge.slash.fill`)
