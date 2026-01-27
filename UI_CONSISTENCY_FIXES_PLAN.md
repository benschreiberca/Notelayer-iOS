# UI Consistency Fixes - Implementation Plan

**Branch:** `ui-consistency-fixes`  
**Target:** Fix remaining visual inconsistencies in settings/nags UI  
**Overall Progress:** `0%`

---

## Tasks

- [ ] 🟥 **Step 1: Fix Header Styling in RemindersSettingsView**
  - [ ] 🟥 Replace plain `Text("Upcoming Nags")` with `SettingsSectionHeader(title: "Upcoming Nags")`
  - [ ] 🟥 Verify visual match with Profile & Settings page header

- [ ] 🟥 **Step 2: Reposition Bell Icon in TaskItemView**
  - [ ] 🟥 Move bell icon out of title HStack
  - [ ] 🟥 Add bell to the far right of the main HStack (after Spacer, before potential chevron)
  - [ ] 🟥 Align with accordion chevron position
  - [ ] 🟥 Keep conditional rendering logic intact

- [ ] 🟥 **Step 3: Fix Nag Details Row Wrapping**
  - [ ] 🟥 Add `.lineLimit(1)` to nag details text elements
  - [ ] 🟥 Add `.fixedSize(horizontal: false, vertical: true)` to prevent vertical expansion
  - [ ] 🟥 Test with long date formats to ensure truncation works

- [ ] 🟥 **Step 4: Increase Nag Card Vertical Padding**
  - [ ] 🟥 Change `.padding(.vertical, 1)` to `.padding(.vertical, 12)` in NagCardView
  - [ ] 🟥 Verify equal spacing at top and bottom of card

- [ ] 🟥 **Step 5: Verification**
  - [ ] 🟥 Test on light/dark mode
  - [ ] 🟥 Test with multiple themes
  - [ ] 🟥 Check linter errors
  - [ ] 🟥 Visual inspection: headers, bell alignment, padding, no wrapping

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
