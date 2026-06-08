# Changelog — Notelayer 1.5.0

**Release Date:** June 6, 2026  
**Version:** 1.5.0  
**Build:** TBD  
**Status:** Ready for App Store submission

---

## 🎯 Highlights

Four major features shipped in this release:

1. **Streamlined Navigation** — Two-tab interface (To-Dos + Insights). Cleaner, more focused UX.
2. **All Features Now Standard** — Experimental features gate removed. Voice, Insights, Hierarchy available to everyone.
3. **Redesigned Onboarding** — 4-step Duolingo/Noom-inspired flow. Users add first task in 60 seconds.
4. **Actionable Insights** — Click categories or tasks in Insights to jump to To-Dos and take action.

---

## ✨ Features

### Navigation Simplification
- **Removed Notes tab** from bottom navigation (code preserved for future use)
- Two-tab interface: To-Dos and Insights
- Fixed, intentional pattern (no revisiting)

### Experimental Features Graduation
- **Removed Experimental Features toggle** from gear menu
- **All features now standard** for all users:
  - ✅ Voice input (always available)
  - ✅ Insights & analytics (always visible)
  - ✅ Task hierarchy (always enabled)
  - ✅ Onboarding guide (always in gear menu)
- Simplified codebase: removed 40+ lines of conditional branching
- Simplified `RootTabsView` by removing genie-transition animations

### Onboarding Overhaul
**Complete redesign of first-time user experience:**

- **Step 1: Welcome** — Hero splash, 60-second promise, Get Started CTA
- **Step 2: Category Selection** — Choose preset (Everyday Balance, Life Admin, Growth & Projects) or start blank
- **Step 3: Add First Task** — Interactive moment with optional category chip selection
- **Step 4: Celebration** — Checkmark animation, momentum-building closure

**Features:**
- Progress dots on steps 2–4 show user progress
- One idea per screen (inspired by Duolingo/Noom research)
- Interactive task entry — users do the core action during onboarding
- Category selection chips with toggle behavior (all deselected by default)
- Task created with selected categories
- Replayable anytime from gear menu "Onboarding Guide"
- Design system maintained throughout (theme tokens, SF Symbols, animations)

### Insights Deep Links
- **Category rows** in Category Insights now tappable → jump to To-Dos in Category view
- **Oldest Open Tasks rows** now tappable → jump to To-Dos and open task editor
- Visual affordance: chevron (>) icon on tappable rows
- Smooth navigation via NotificationCenter (consistent with existing patterns)

---

## 🔧 Technical Changes

### RootTabsView.swift
- Removed `showInsightsHintBanner` and `showLockedInsightsMessage` state
- Removed genie-transition `.scaleEffect`, `.opacity`, `.offset` modifiers from InsightsView
- Removed `.onReceive(... .experimentalFeaturesDidChange ...)` observer
- Removed `experimentalFeaturesDidChange` notification post
- Removed `.onChange(of: store.experimentalFeaturesPreference)` handler
- Removed `handleExperimentalVisibilityChange()`, `refreshInsightsHintBanner()`, `transitionToDefaultListView()`, `bannerRow()` helpers
- Simplified `checkAndShowWelcome()` (removed experimental guard)
- Added observers for deep-link notifications:
  - `navigateToCategoryInTodos` — switches to To-Dos in category mode
  - `OpenTaskFromNotification` — switches to To-Dos and opens editor
- Added `pendingCategoryJump` state for category deep-linking

### WelcomeView.swift
- **Complete rewrite** with 4-step flow (replace 3-step flow)
- `OnboardingStep` enum: `welcome | categories | taskEntry | done` (was: `video | cues | presets`)
- New state: `presetCategories`, `selectedTaskCategories`
- New UI elements:
  - Welcome splash with logo and value prop
  - Category preset selection (keep existing 3 presets + add "Start blank")
  - Task entry field with category chips (deselected by default)
  - Celebration screen with checkmark animation
- New helper: `addFirstTask()` includes selected categories
- Task creation now includes optional categories from chip selection

### InsightsView.swift
- Made "Tasks Left per Category" rows tappable (posts `navigateToCategoryInTodos`)
- Made "Oldest Open Tasks" rows tappable (posts `OpenTaskFromNotification`)
- Added chevron (>) icons as visual affordance
- Both use `Button { } label: { }` with `.buttonStyle(.plain)` pattern
- Fixed: Removed incorrect optional binding on `categoryIcon`

### TodosView.swift
- Added `@Binding var categoryJump: String?` parameter
- Added `@State private var categoryScrollTarget: String?`
- Added `.onChange(of: categoryJump)` handler to switch view mode to `.category`
- Removed dead `.onChange(of: store.experimentalFeaturesPreference)` observer

### LocalStore.swift
- Changed `experimentalFeaturesEnabled` property to return `true` unconditionally
- Removed `experimentalFeaturesDidChange` from `Notification.Name` extension
- Added `navigateToCategoryInTodos` to `Notification.Name` extension
- Converted `setExperimentalFeaturesEnabled()` to no-op (deprecated, kept for backward compatibility)

### AppTabHeaderComponents.swift
- Removed entire Experimental Features `Toggle` from gear menu
- Removed `"flask"` system image
- Unwrapped "Onboarding Guide" button (no longer gated on `experimentalFeaturesEnabled`)
- Now always visible for all users

---

## 🧪 Testing

### Tested On
- iPhone 15 simulator
- iPhone SE simulator
- Light mode & dark mode

### Test Coverage
- ✅ Fresh install: onboarding auto-shows
- ✅ All 4 onboarding steps progress correctly
- ✅ Task entry with category selection works
- ✅ Task persists after onboarding completion
- ✅ Tab bar shows only To-Dos and Insights
- ✅ Voice input works (no gate)
- ✅ Insights tab always visible (no gate)
- ✅ Category/task deep-links work
- ✅ Gear menu "Onboarding Guide" replays
- ✅ No crashes or warnings
- ✅ Scrolling is smooth

---

## 📊 Metrics

| Metric | Value |
|---|---|
| Files changed | 6 |
| Lines added | ~450 |
| Lines removed | ~250 |
| Net change | +200 |
| Commits | 8 feature + 3 fix + 1 docs |
| Build warnings | 0 |
| Test failures | 0 |

---

## 🚀 Migration Notes for Users

**For New Users:**
- Onboarding auto-appears on first launch
- 4-step walkthrough guides them to adding first task
- No experimental toggle to enable — everything is ready

**For Existing Users:**
- Tab bar changes: Notes tab removed (no data loss; code preserved)
- All features automatically enabled (no toggle needed)
- Onboarding replay available in gear menu for reference

---

## 🔙 Rollback

If needed, revert commits:
```
1dbaa20 Update F3: Don't pre-select categories in task entry
b688b8c Enhance F3: Add category selection chips to task entry screen
7306de1 Fix: Remove incorrect optional binding on categoryIcon
5bec244 Fix: Make setExperimentalFeaturesEnabled a no-op
eb44f79 F4: Make Insights drilldowns actionable with deep links
02272be F3: Overhaul onboarding with 4-step flow
64c5d45 F2: Graduate experimental features to always-on
ee04d00 F1: Hide Notes tab from bottom navigation bar
```

---

## 📝 Documentation

- [Release Notes](RELEASE_NOTES_v1.5.0.md) — Feature details and testing checklist
- [App Store Description](APP_STORE_DESCRIPTION_v1.5.0.md) — Copy for App Store and social media
- [App Store Launch Checklist](APP_STORE_LAUNCH_CHECKLIST_v1.5.0.md) — Step-by-step QA and submission
- [Merge & Ship Plan](MERGE_AND_SHIP_PLAN_v1.5.0.md) — Git strategy and version bumping
- [PRD Documentation](PRD_Navigation_Experimental_Onboarding_DeepLinks.md) — Original feature specification
- [Implementation Plan](PRD_Nav_Onboarding_Insights_DeepLinks_Plan.md) — Detailed step-by-step implementation

---

**Generated:** 2026-06-06  
**Status:** Ready for App Store submission
