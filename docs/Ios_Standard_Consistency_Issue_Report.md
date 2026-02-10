# iOS Standard Consistency - Issue

**Type:** Improvement (UX/Consistency)  
**Priority:** High  
**Effort:** Medium  
**Created:** January 27, 2026

---

## TL;DR

Settings and detail pages use custom layouts instead of iOS-standard List views. This creates:
1. Inconsistent card widths across pages
2. Custom header styles that don't match iOS conventions
3. Non-scalable patterns that require manual consistency enforcement

**Solution:** Refactor all settings/detail pages to use native iOS List + Section headers (like the default Settings app).

---

## Problem Statement

### Current State:
- **Profile & Settings**: Custom `ScrollView` + `VStack` with custom `SettingsSectionHeader` component
- **Pending Nags**: Custom List with custom header styling
- **Manage Account**: Custom layout
- **Task Edit Sheet**: ✅ Uses native iOS `List` + `Section` headers (correct reference)

### Expected State:
**ALL pages/sheets** accessed from the gear icon (and any future pages) should use:
- Native iOS `List` view
- Native `Section("Header Text")` for headers
- Standard iOS card widths and spacing
- No custom header components

---

## Issues Breakdown

### 1. Card Width Inconsistency

**Current:**
- Profile & Settings: Wider cards (padding: 20)
- Pending Nags: Narrower cards (different padding)
- Inconsistent visual rhythm

**Expected:**
- All pages use iOS-standard List card width
- No manual padding calculations
- System-managed layout

---

### 2. Header Style Inconsistency

**Current:**
- Custom `SettingsSectionHeader` component (`.caption.weight(.semibold)`, custom padding)
- Different styles across different pages
- Manual styling in each view

**Expected:**
- Native iOS `Section("Header")` syntax
- System font, size, spacing, and color
- Zero custom header components
- Matches iOS Settings app style

**Reference:** TaskEditView already uses correct pattern:
```swift
Section("Title") {
    // content
}
```

---

### 3. Non-Scalable Pattern

**Current:**
Adding a new settings page requires:
1. Remembering to use `SettingsSectionHeader`
2. Matching padding values
3. Manually ensuring consistency

**Expected:**
Adding a new page should be:
1. Use `List` wrapper
2. Use `Section("Header")` for sections
3. Consistency is automatic (iOS default)

---

## Affected Files

### To Refactor:

1. **`ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift`**
   - Replace `ScrollView` + `VStack` with `List`
   - Replace `SettingsSectionHeader` with `Section("Account")`, `Section("Pending Nags")`, etc.
   - Remove custom padding (20px)

2. **`ios-swift/Notelayer/Notelayer/Views/RemindersSettingsView.swift`**
   - Replace custom List section header with `Section("Upcoming Nags")`
   - Remove `.padding(.horizontal, 20)`
   - Use standard list row insets

3. **`ios-swift/Notelayer/Notelayer/Views/ManageAccountView.swift`**
   - Replace custom layout with `List` + `Section` headers
   - Use standard iOS sections for "Data" and "Danger Zone"

4. **`ios-swift/Notelayer/Notelayer/Views/Shared/SettingsComponents.swift`**
   - **DEPRECATE** `SettingsSectionHeader` component
   - Keep `TaskCategoryChip`, `TaskPriorityBadge`, `PrimaryButtonStyle` (these are legitimate reusable components)

### Reference (Already Correct):

- **`ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`** ✅
  - Uses `List` + `Section("Title")`, `Section("Categories")`, etc.
  - This is the gold standard for all future pages

---

## Implementation Strategy

1. **ProfileSettingsView:**
   - Wrap in `List`
   - Convert each section to native `Section("Header")` syntax
   - Remove custom padding and `SettingsSectionHeader` calls

2. **RemindersSettingsView:**
   - Replace header block with `Section("Upcoming Nags")`
   - Remove horizontal padding
   - Use `.listStyle(.plain)` for cleaner look

3. **ManageAccountView:**
   - Convert to `List` + `Section` structure
   - Use `Section("Data")` and `Section("Danger Zone")` for logical grouping

4. **Update UI Component Guide:**
   - Remove `SettingsSectionHeader` from documentation
   - Add new section: "Use Native iOS List + Section Headers"
   - Reference TaskEditView as the canonical pattern

---

## Benefits

1. **Automatic Consistency:** iOS handles all header styling, spacing, and widths
2. **Scalability:** Future pages automatically match by using standard components
3. **Maintainability:** Less custom code to maintain
4. **User Familiarity:** Matches iOS Settings app conventions
5. **Accessibility:** Native components have built-in VoiceOver support

---

## Risk Assessment

**Low Risk:**
- No logic changes, only layout refactoring
- Native List views are well-tested and reliable
- Easy to revert if needed

**Testing:**
- Visual inspection on all affected pages
- Test light/dark mode
- Test with multiple themes
- Verify navigation flows still work

---

## Example: Before & After

### Before (Custom):
```swift
VStack(alignment: .leading, spacing: 8) {
    SettingsSectionHeader(title: "Account")
    
    VStack(spacing: 0) {
        // custom card content
    }
}
.padding(20)
```

### After (iOS Standard):
```swift
List {
    Section("Account") {
        // content
    }
}
.listStyle(.plain)
```
