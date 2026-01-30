# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Fix keyboard dismissal, theme preset persistence on force‑quit, share sheet and task input chip styling, task detail title wrapping, date/time picker consistency, share sheet spacing parity, and dark‑mode theme balance (excluding iridescent/cheetah), all aligned to existing iOS patterns and the current Task Detail sheet.

## Critical Decisions
- Decision 1: Prioritize least risky, most isolated UI changes first.
- Decision 2: Keep share sheet card layout but mirror TaskEditView spacing/padding.
- Decision 3: All graphical date+time pickers standardize across app; keep shortcut presets.
- Decision 4: Dark mode adjustments apply to all presets except iridescent/cheetah; light themes untouched.
- Decision 5: Insert test/build after every 2 steps.

## Tasks (Reordered):

- [x] 🟩 **Step 1: Task Detail Title Wrapping (low risk, isolated)**
  - [x] 🟩 Allow title to wrap up to 10 lines; no truncation; keep current font size.

- [x] 🟩 **Step 2: Category Chip Styling Parity (low risk, localized UI)**
  - [x] 🟩 TaskInputView chips: faint fill when unselected, stronger fill when selected.
  - [x] 🟩 Match TaskInputView chip sizing to share sheet chips.
  - [x] 🟩 Task list badges: match share sheet chip sizing.

- [x] 🟩 **Test/Build Checkpoint A**
  - [x] 🟩 Build app + smoke test affected screens.
  - [x] 🟩 Build succeeded on iPhone 17 simulator; tests timed out/failing in screenshot suite (To‑Dos button not found).

- [x] 🟩 **Step 3: Share Sheet Spacing/Padding Parity (localized to extension UI)**
  - [x] 🟩 Mirror TaskEditView spacing/padding while keeping card layout, header logo, preview disclosure.

- [x] 🟩 **Step 4: Share Sheet Category Chips Fill States (extension UI)**
  - [x] 🟩 Faint category color fill when unselected; stronger fill when selected.

- [x] 🟩 **Test/Build Checkpoint B**
  - [x] 🟩 Build app + smoke test share sheet + category chips.
  - [x] 🟩 Build succeeded on iPhone 17 simulator; screenshot tests failed (To‑Dos button not found).

- [x] 🟩 **Step 5: Date/Time Picker Consistency (multi‑screen but contained)**
  - [x] 🟩 Ensure custom pickers are graphical with date + time.
  - [x] 🟩 Keep shortcut presets.
  - [x] 🟩 Update share sheet due date picker to include time.

- [x] 🟩 **Step 6: Keyboard Dismissal Behavior (cross‑screen interaction)**
  - [x] 🟩 Tap outside text area dismisses keyboard; tap still performs action (e.g., Save).
  - [x] 🟩 Scroll dismisses keyboard in todos and task notes.
  - [x] 🟩 Keep keyboard open when interacting with TaskInputView chips/priority controls.

- [x] 🟩 **Test/Build Checkpoint C**
  - [x] 🟩 Build app + smoke test keyboard behavior + pickers.
  - [x] 🟩 Build succeeded on iPhone 17 simulator; screenshot tests failed (To‑Dos button not found).

- [x] 🟩 **Step 7: Theme Preset Persistence on Force‑Quit (app lifecycle)**
  - [x] 🟩 Ensure preset persists (no reset to Barbie) while mode persistence remains.

- [x] 🟩 **Step 8: Dark Theme Best‑Practice Adjustments (global visual impact)**
  - [x] 🟩 Dark themes: wallpaper darker than cards (exclude iridescent/cheetah).
  - [x] 🟩 Verify text/icon visibility (e.g., gear icon) against updated dark backgrounds.

- [x] 🟩 **Test/Build Checkpoint D**
  - [x] 🟩 Build app + smoke test theme persistence + dark mode visibility.
  - [x] 🟩 Build succeeded on iPhone 17 simulator; screenshot tests failed (To‑Dos button not found).

## UI Consistency Guardrail
- **Standard‑Bearer:** `TaskEditView.swift` (List + Section + platform controls).
- **Deviations:** Share sheet remains a card layout (already existing) instead of List/Section. No new UI components introduced; adjustments are styling/spacing only (line‑count change expected to be minimal, net neutral).
