# UI Consistency Fixes - Implementation Plan

**Branch:** `ui-consistency-fixes`  
**Target:** Fix remaining visual inconsistencies in settings/nags UI  
**Overall Progress:** `100%`

---

## Tasks

- [x] 🟩 **Step 1: Fix Header Styling in RemindersSettingsView**
  - [x] 🟩 Replace plain `Text("Upcoming Nags")` with `SettingsSectionHeader(title: "Upcoming Nags")`
  - [x] 🟩 Verify visual match with Profile & Settings page header

- [x] 🟩 **Step 2: Reposition Bell Icon in TaskItemView**
  - [x] 🟩 Move bell icon out of title HStack
  - [x] 🟩 Add bell to the far right of the main HStack (after Spacer)
  - [x] 🟩 Align with accordion chevron position
  - [x] 🟩 Keep conditional rendering logic intact

- [x] 🟩 **Step 3: Fix Nag Details Row Wrapping**
  - [x] 🟩 Add `.lineLimit(1)` to nag details text elements
  - [x] 🟩 Add `.fixedSize(horizontal: false, vertical: true)` to prevent vertical expansion
  - [x] 🟩 Ensured single-line rendering

- [x] 🟩 **Step 4: Increase Nag Card Vertical Padding**
  - [x] 🟩 Change `.padding(.vertical, 1)` to `.padding(.vertical, 12)` in NagCardView
  - [x] 🟩 Equal spacing at top and bottom of card

- [x] 🟩 **Step 5: Verification**
  - [x] 🟩 Check linter errors (none found)
  - [x] 🟩 All fixes applied successfully

---

## Implementation Order

1. Header fix (trivial, 1-line change)
2. Bell icon repositioning (structural layout change)
3. Nag details wrapping fix (add constraints)
4. Vertical padding fix (trivial, 1-value change)
5. Full UI verification pass

---

## Expected Outcome

- All section headers across Profile & Settings and Pending Nags pages use identical styling
- Bell icon on task cards aligns with accordion chevron (far right)
- Nag details row remains single-line, truncates if needed
- Nag cards have balanced vertical padding for a polished look
