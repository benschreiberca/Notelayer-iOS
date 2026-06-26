# Settings Overhaul & "Nag" System Plan

**Overall Progress:** `100%`

## TLDR
Redesigning the Profile & Settings page for visual consistency and professional "slickness" using theme-aware cards. We are also rebranding "Reminders" to "Nags" with a droll tone, implementing an energetic sync animation, and adding a progressive "Manage Data & Account" flow with CSV export for To-dos.

## Critical Decisions
- **Theme-Aware Cards**: All settings sections will use `cardFill` and `cardStroke` tokens from `ThemeManager` to ensure they match the user's global theme.
- **"Nag" Rebranding**: Renaming "Reminders" to "Nags" (e.g., "Nag me later", "Pending Nags") to establish a unique, droll app personality.
- **Progressive Deletion Flow**: Moving account deletion to a sub-page to prevent accidental data loss and provide a clear "speed bump" explanation.
- **Standard Share Sheet**: Using `UIActivityViewController` for CSV exports to ensure users can easily save or send their data.

## Tasks:

- [x] 🟩 **Step 1: Rebrand "Reminders" to "Nags"**
  - [x] 🟩 Update `RowContextMenu.swift`: Rename "Set Reminder" to "Nag me later"
  - [x] 🟩 Update `ReminderPickerSheet.swift`: Rename title to "Schedule a Nag"
  - [x] 🟩 Update `TaskEditView.swift`: Rename section and buttons to "Nag"
  - [x] 🟩 Update `RemindersSettingsView.swift`: Rename title to "Pending Nags"

- [x] 🟩 **Step 2: Implement Energetic Sync & Manual Refresh**
  - [x] 🟩 Add `forceSync()` to `FirebaseBackendService.swift`
  - [x] 🟩 Add manual refresh icon button to `ProfileSettingsView.swift`
  - [x] 🟩 Create energetic pulsing/bouncing animation for the sync status line

- [x] 🟩 **Step 3: Create "Manage Data & Account" Flow**
  - [x] 🟩 Implement `ManageAccountView.swift` with "Data Export" and "Delete Account" sections
  - [x] 🟩 Add CSV generation logic for To-dos (Tasks + Categories)
  - [x] 🟩 Integrate standard iOS Share Sheet for CSV export
  - [x] 🟩 Move account deletion logic and confirmation to this new view

- [x] 🟩 **Step 4: Redesign Profile & Settings UI**
  - [x] 🟩 Standardize all sections in `ProfileSettingsView.swift` to use theme-aware cards
  - [x] 🟩 Update section headers (e.g., "Pending Nags") to be consistent and droll
  - [x] 🟩 Ensure all interactive rows use consistent chevrons and styling
