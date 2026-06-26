# Bug Fix Pass — April 2026

**Branch:** `bug-fixes-claude-april`
**Issue:** benschreiberca/Notelayer-iOS#10
**Date:** 2026-04-10

---

## Overview

Five issues addressed in this pass — four bugs and one feature request — ordered lowest to highest impact.

---

## 1. UI Jitter — ScreenEdgeGlow animation loop

**File:** `Views/TodosView.swift`

**Problem:** `ScreenEdgeGlow` used `.animation(..., value: UUID())` to drive its pulse effect. Because `UUID()` generates a new value on every SwiftUI render pass, the animation restarted on every redraw — causing visible jitter whenever the task list updated.

**Fix:** Replaced with a `@State var glowPhase: Bool` toggled in `.onAppear` using `.easeInOut(duration: 1.2).repeatForever(autoreverses: true)`. The animation now runs once, loops smoothly, and is decoupled from view redraws. Respects `@Environment(\.accessibilityReduceMotion)`.

---

## 2. Category chip contrast in dark mode

**Files:** `Views/Shared/CategoryChipGridView.swift`, `Views/TaskInputView.swift`, `Views/Shared/TagChipsView.swift`

**Problem:** All three chip components used the raw category hex color as foreground text. Light category colors (yellow, light green, etc.) became unreadable on dark backgrounds. `CategoryChipGridView` also had a copy-paste bug where both selected and unselected states returned identical foreground colors.

**Fix:**
- `CategoryChipButton` (CategoryChipGridView): unselected foreground → `.primary`; selected foreground keeps `categoryColor` (readable on the 0.22 opacity fill). Fixed the dead-code identical-branch bug. Fallback color changed from hardcoded `.blue` to `.accentColor`.
- `CategoryChip` (TaskInputView): same pattern — unselected → `.primary`, selected → `categoryColor`.
- `TagChipsView`: foreground switched to `.primary`; background opacity increased from `0.12` to `0.18` for better visual separation.

---

## 3. Dark mode font contrast — task list views

**Files audited:** `Views/TodoListModeView.swift`, `Views/TodoCategoryModeView.swift`, `Views/Shared/TaskEditorSections.swift`

**Outcome:** No changes required. `TaskItemView.categoryBadge` and `TaskCategoryChip` already use semantic tokens (`theme.tokens.textSecondary`, `badgeTokens.text`) for all foreground text. Category color is only used for the background tint and border, which is appropriate.

---

## 4. First-launch crash loop hardening

**Files:** `Services/FirebaseBackendService.swift`, `Data/LocalStore.swift`, `App/NotelayerApp.swift`

**Problem:** App crashes 3–4 times on fresh install before stabilizing. The code structure (auth guard, error handling) was already correct. Most likely cause is a Firestore SDK offline persistence SQLite initialization on first run — a known Firebase cold-start behavior.

**Fix:** Added `NSLog` checkpoints throughout the initialization chain. Unlike `#if DEBUG` print statements, `NSLog` writes to the system log and is visible in Console.app on a physical device even in release builds. This enables the crash timeline to be read directly from device logs.

Checkpoints added:
- `NotelayerApp.init` — before and after Firebase configure
- `LocalStore.load()` — start and completion (with task/note/category counts)
- `FirebaseBackendService.handleUserChange` — on entry (with user UID)
- `FirebaseBackendService` — before and after `syncInitialData`
- `syncInitialData` catch block — now logs to `NSLog` instead of `#if DEBUG` print

**To diagnose on device:** Connect device to Mac, open Console.app, filter by process name `Notelayer`, delete and reinstall the app, and observe the log sequence across crash cycles.

---

## 5. Inline search (new feature)

**Files:** `Views/RootTabsView.swift`, `Views/TodosView.swift`

**Design:** A floating search button (58×58, `magnifyingglass` SF Symbol, accent fill, matching shadow) stacked directly above the voice entry button. Tapping it opens a search bar inline in the Todos header — no new screen or sheet. Tasks filter live as the user types.

**RootTabsView changes:**
- Added `@State private var isSearchActive: Bool`
- Added `shouldShowSearchButton` computed property: `selectedTab == .todos && !isKeyboardVisible` (always available on todos tab, no experimental features gate)
- Replaced the single voice button block with a `VStack(spacing: 16)` containing the search button (top) and voice button (bottom, existing, unchanged)
- `isSearchActive` resets to `false` when switching away from the todos tab
- Added `.animation(.easeInOut(duration: 0.2), value: shouldShowSearchButton)` to match existing animation modifiers

**TodosView changes:**
- Added `@Binding var isSearchActive: Bool` parameter
- Added `@State private var searchQuery: String`
- Added `@FocusState private var isSearchFieldFocused: Bool`
- `filteredTasks` now applies a secondary search filter when `searchQuery` is non-empty, matching `task.title` and `task.taskNotes` via `localizedCaseInsensitiveContains`
- Search bar row (icon + TextField + clear button + Cancel) renders below the segmented picker when `isSearchActive` is true
- `onChange(of: isSearchActive)` auto-focuses the field on activation and clears state on deactivation
- Dismissal: Cancel button, keyboard submit, or switching tabs — all reset state cleanly

---

## Files changed

| File | Change |
|------|--------|
| `Views/TodosView.swift` | Jitter fix + search binding + search bar UI + filtered tasks |
| `Views/RootTabsView.swift` | Search button + `isSearchActive` state + tab switch reset |
| `Views/Shared/CategoryChipGridView.swift` | Contrast fix + fallback color |
| `Views/TaskInputView.swift` | Contrast fix for `CategoryChip` |
| `Views/Shared/TagChipsView.swift` | Contrast fix |
| `Services/FirebaseBackendService.swift` | NSLog checkpoints |
| `Data/LocalStore.swift` | NSLog checkpoints in `load()` |
| `App/NotelayerApp.swift` | NSLog checkpoints in `init()` |
