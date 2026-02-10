# Settings Consistency & UI Polish Plan

**Overall Progress:** `100%`

## TLDR
Achieving "extreme consistency" across the settings flow by standardizing UI elements, reorganizing information hierarchy, and fixing critical build/runtime errors. This includes reordering sections, unifying button styles across the entire app (including auth), and re-styling Nag cards to match the core app experience.

## Critical Decisions
- **Hierarchy Flip**: Moving "Pending Nags" to the top to prioritize active user content over account management.
- **Universal Button Style**: Creating a single, unified button style (padding, corner radius, font, height) that all primary actions (Sign Out, Export, Send Code, etc.) must follow.
- **Nag Card Parity**: Re-styling "Upcoming Nags" to use the exact same card layout as regular Tasks, but replacing the checkbox with a bell icon. Tapping these cards will open the Nag picker directly.
- **Firebase Consolidation**: Unifying Firebase initialization in the app entry point to resolve double-init logs and simulator errors.
- **Standard Accordion**: Using standard SwiftUI `DisclosureGroup` for the "About" section to maintain platform consistency.

## Tasks:

- [x] 🟩 **Step 1: Reorganize Hierarchy & Structure**
  - [x] 🟩 Move "Pending Nags" section to the top of `ProfileSettingsView.swift`
  - [x] 🟩 Move "Sign Out" from main page into `ManageAccountView.swift`
  - [x] 🟩 Implement standard `DisclosureGroup` (collapsed by default) for the "About" section

- [x] 🟩 **Step 2: Visual Alignment & "Extreme Consistency"**
  - [x] 🟩 Right-align the manual Sync button in the account row (matching chevron alignment)
  - [x] 🟩 Create a universal `PrimaryButtonStyle` in a shared location
  - [x] 🟩 Apply universal style to "Sign Out", "Export Data", and "Send Code" (Phone Auth)
  - [x] 🟩 Re-style "Upcoming Nags" in `RemindersSettingsView.swift` to match regular Task cards (bell in checkbox position)
  - [x] 🟩 Update Nag card tap action to open the Nag picker directly instead of Task Edit

- [x] 🟩 **Step 3: Fix Build & Runtime Errors**
  - [x] 🟩 Unify Firebase initialization in `NotelayerApp.swift` to fix configuration logs
  - [x] 🟩 Replace missing `bell.badge.exclamationmark.fill` with `exclamationmark.bell.fill`
  - [x] 🟩 Add `@retroactive` to `URL: Identifiable` conformance in `ManageAccountView.swift`
  - [x] 🟩 Refactor `ActivityView` presentation to resolve `_UIReparentingView` hierarchy warnings

- [x] 🟩 **Step 4: Final Polish & Verification**
  - [x] 🟩 Verify all cards use consistent theme tokens (`cardFill`, `cardStroke`)
  - [x] 🟩 Test sync flow on simulator to ensure errors are resolved
  - [x] 🟩 Ensure all interactive rows use consistent chevrons and spacing
