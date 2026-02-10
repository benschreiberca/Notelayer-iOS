# Settings UI & Nag Card Consistency Fix

**Status:** 🔴 To Do  
**Priority:** Critical  
**Effort:** Medium  

## TLDR
The previous implementation failed to respect the requirement for "extreme consistency." Settings headers remain inconsistent, and the "Pending Nags" cards use a custom layout instead of reusing the exact styles from the main To-Do list. This issue aims to enforce 100% visual parity between task cards across all views.

## Current State vs Expected Outcome

### 1. Settings Headers
- **Current**: Headers use mixed styles (some standard, some custom).
- **Expected**: All section headers in the settings flow must use an identical, unified style.

### 2. Nag Card UI (Extreme Parity)
- **Current**: "Upcoming Nags" uses a unique card layout.
- **Expected**: 
  - Must use the **identical chip style** as the main To-Do list (rounded, single-line, no text wrapping).
  - **Priority labels** must match the regular To-Do list card style exactly.
  - **Bell icon** remains in the checkbox position.
  - **Nag Details**: Keep the inset, slightly colored "reminder card within a card" style from the task details view.

### 3. Interaction
- **Expected**: Tapping the card must continue to open the Nag picker directly (this part was correct).

## Relevant Files
- `ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift`
- `ios-swift/Notelayer/Notelayer/Views/RemindersSettingsView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TaskItemView.swift` (Reference for parity)

## Risk/Notes
- Do not attempt to "improve" or "rearrange" data. Use the existing components from the main list to ensure 1:1 parity.

---
**Type:** Bug Fix / UI Consistency  
**Labels:** UI/UX, Consistency, Regression
