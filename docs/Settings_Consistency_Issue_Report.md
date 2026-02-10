# Settings Consistency & UI Polish

**Status:** 🟡 In Progress  
**Priority:** High  
**Effort:** Medium  

## TL;DR
The settings flow currently suffers from visual inconsistency in buttons, alignments, and card styles. This issue aims for "extreme consistency" by standardizing UI elements, reorganizing the information hierarchy, and fixing simulator/build errors.

## Current State vs Expected Outcome

### 1. Information Hierarchy & Structure
- **Current**: Account is at the top; Sign Out is on the main page; About is expanded.
- **Expected**: 
  - **Pending Nags** moved to the very top of the settings page.
  - **Sign Out** moved inside the "Manage Account" sub-page.
  - **About** section should be collapsed in an accordion by default.

### 2. Visual Consistency
- **Sync Button**: Currently inline with text. **Expected**: Right-aligned, matching the chevron alignment (see reference image).
- **Buttons**: "Sign Out" and "Export Data" use different styles. **Expected**: 100% consistent button styling across the entire app.
- **Nag Cards**: "Upcoming Nags" uses a unique style. **Expected**: Must match regular Task cards. The "bell" icon should replace the checkbox position.

### 3. Functional & Build Fixes
- **Firebase Initialization**: Logs indicate "default Firebase app has not yet been configured" despite appearing twice. Need to unify initialization in `@main`.
- **Missing Symbols**: `bell.badge.exclamationmark.fill` is missing in the current iOS target. Replace with a valid symbol (e.g., `exclamationmark.bell.fill`).
- **Retroactive Conformance**: Fix build warning in `ManageAccountView.swift` by adding `@retroactive` to `URL: Identifiable`.
- **View Hierarchy Warnings**: Investigate `_UIReparentingView` warnings related to `UIHostingController` and `ActivityView`.

## Relevant Files
- `ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift`
- `ios-swift/Notelayer/Notelayer/Views/ManageAccountView.swift`
- `ios-swift/Notelayer/Notelayer/Views/RemindersSettingsView.swift`
- `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`

## Risk/Notes
- Ensure the "About" accordion doesn't break the ScrollView behavior.
- Button standardization must reference the global `ThemeManager`.

---
**Type:** Improvement/Bug Fix  
**Labels:** UI/UX, Consistency, Build-Fix, Firebase
