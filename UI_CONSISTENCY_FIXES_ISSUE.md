# UI Consistency Fixes - Issue

**Type:** Bug (UI/UX Regression)  
**Priority:** High  
**Effort:** Small  
**Created:** January 27, 2026

---

## TL;DR

Multiple UI inconsistencies remain after the settings overhaul:
1. Section headers have different styling between pages
2. Bell icon needs repositioning on main task cards
3. Nag details row wraps into multiple lines
4. Nag cards have insufficient vertical padding

---

## Issues

### 1. Header Styling Inconsistency

**Current State:**
- **Profile & Settings page**: "Pending Nags" uses `SettingsSectionHeader` (`.caption.weight(.semibold)`, `.secondary` color)
- **Pending Nags detail page**: "Upcoming Nags" uses default List section header styling (system font/color)

**Expected:**
Both should use the same visual style.

**Location:**
- `Views/RemindersSettingsView.swift` line 85: Plain `Text("Upcoming Nags")` in List section header

---

### 2. Bell Icon Positioning

**Current State:**
Bell icon sits inline with the task title in an HStack, positioned to the right of the title text.

**Expected:**
Bell icon should move further right to align with the accordion chevron button (see screenshot).

**Location:**
- `Views/TaskItemView.swift` lines 24-40: Title row HStack with bell icon

**Notes:**
- Keep conditional logic (only show when `reminderDate != nil`)
- Maintain bell.fill vs bell.slash.fill behavior based on notification permission

---

### 3. Nag Details Row Wrapping

**Current State:**
The orange inset card showing nag details wraps into 2+ lines:
```
Jan 27, 2026 at
12:43PM • in 25 minutes
```

**Expected:**
Single line, no wrapping. Truncate if needed or reduce font size.

**Location:**
- `Views/RemindersSettingsView.swift` (NagCardView struct): Orange inset HStack with clock icon + date + relative time

**Affected Elements:**
- Date/time text: `nagDate.formatted(date: .abbreviated, time: .shortened)`
- Relative time: `relativeDateText(for:)`

---

### 4. Nag Card Vertical Padding

**Current State:**
Nag cards use `.padding(.vertical, 1)` (inherited from TaskItemView), causing content to sit too close to the top edge of the card.

**Expected:**
Equal vertical padding at top and bottom to give the card breathing room.

**Location:**
- `Views/RemindersSettingsView.swift` (NagCardView struct): `.padding(.vertical, 1)`

**Suggested Fix:**
Increase to `.padding(.vertical, 12)` to match horizontal padding of 10px.

---

## Files to Modify

1. **`ios-swift/Notelayer/Notelayer/Views/RemindersSettingsView.swift`**
   - Replace List section header with `SettingsSectionHeader`
   - Fix nag details row wrapping (single-line constraint)
   - Increase vertical padding on NagCardView

2. **`ios-swift/Notelayer/Notelayer/Views/TaskItemView.swift`**
   - Reposition bell icon to far right (align with chevron)

---

## Risk Assessment

**Low Risk:**
- All changes are visual tweaks with no logic modifications
- Bell icon repositioning only affects layout, not functionality
- Padding and text styling changes are isolated to nag cards

**Testing:**
- Verify bell icon alignment on tasks with reminders
- Test nag details row on various date formats (short/long)
- Check light/dark mode and multiple themes

---

## Screenshots

See attached:
1. Profile & Settings page showing "Pending Nags" header style
2. Pending Nags detail page showing "Upcoming Nags" header style (different)
3. Main to-do list showing bell icon position (needs right alignment)
4. Nag details row wrapping (needs single-line fix)
5. Nag card with tight vertical padding (needs breathing room)
