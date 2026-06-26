---
title: Changelog — v1.5.0
last_updated: 2026-06-06
status: active
scope: notelayer-ios
group: operations
---

# Changelog — Notelayer 1.5.0

**Release Date:** June 6, 2026  
**Version:** 1.5.0  
**App Store Commit:** `b1aee8f`

---

## Highlights

1. **Streamlined Navigation** — Two-tab interface (To-Dos + Insights). Notes tab hidden (code preserved).
2. **Features Graduated** — Experimental features gate removed. Voice, Insights, Hierarchy now always-on.
3. **Redesigned Onboarding** — 4-step Duolingo/Noom-inspired flow. First task in 60 seconds.
4. **Actionable Insights** — Category rows and oldest-task rows are now tappable deep-links to To-Dos.

---

## Changed Files

### `RootTabsView.swift`
- `visibleTabs = [.todos, .insights]` — Notes tab removed from navigation
- Removed `showInsightsHintBanner`, `showLockedInsightsMessage` state
- Removed genie-transition animations (`scaleEffect`, `opacity`, `offset`)
- Removed `experimentalFeaturesDidChange` observer
- Added observers for `navigateToCategoryInTodos` and `OpenTaskFromNotification` deep-link notifications
- Added `pendingCategoryJump` state

### `WelcomeView.swift`
- Complete rewrite — 4-step flow replaces 3-step placeholder flow
- `OnboardingStep` enum: `welcome | categories | taskEntry | done`
- New: category preset selection, task entry with category chips, celebration screen
- `addFirstTask()` includes selected categories

### `InsightsView.swift`
- Category breakdown rows → tappable, post `navigateToCategoryInTodos`
- Oldest Open Tasks rows → tappable, post `OpenTaskFromNotification`
- Chevron icons added as tappable affordance
- Fixed: incorrect optional binding on `categoryIcon`

### `TodosView.swift`
- Added `@Binding var categoryJump: String?`
- Added `@State private var categoryScrollTarget: String?`
- `.onChange(of: categoryJump)` switches view mode to `.category`
- Removed dead `.onChange(of: store.experimentalFeaturesPreference)` observer

### `LocalStore.swift`
- `experimentalFeaturesEnabled` now returns `true` unconditionally
- `setExperimentalFeaturesEnabled()` converted to no-op
- Removed `experimentalFeaturesDidChange` from `Notification.Name`
- Added `navigateToCategoryInTodos` to `Notification.Name`

### `AppTabHeaderComponents.swift`
- Removed Experimental Features toggle from gear menu
- "Onboarding Guide" button no longer gated — visible to all users

---

## Metrics

| Metric | Value |
|--------|-------|
| Files changed | 6 |
| Lines added | ~450 |
| Lines removed | ~250 |
| Net change | +200 |
| Build warnings | 0 |

---

## Rollback Commits (if needed)

```
1dbaa20 Update F3: Don't pre-select categories in task entry
b688b8c Enhance F3: Add category selection chips to task entry
7306de1 Fix: Remove incorrect optional binding on categoryIcon
5bec244 Fix: Make setExperimentalFeaturesEnabled a no-op
eb44f79 F4: Insights drilldown deep links
02272be F3: 4-step onboarding overhaul
64c5d45 F2: Graduate experimental features to always-on
ee04d00 F1: Hide Notes tab from navigation
```
