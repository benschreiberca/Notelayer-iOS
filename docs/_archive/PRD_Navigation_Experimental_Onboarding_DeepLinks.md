# PRD: Navigation Simplification, Experimental Feature Graduation, Onboarding Overhaul & Insights Deep Links

**Date:** 2026-06-06  
**Status:** Approved for Implementation  
**Owner:** TBD  
**Implementation Plan:** See `docs/PRD_Nav_Onboarding_Insights_DeepLinks_Plan.md`

---

## Executive Summary

Four focused changes to Notelayer iOS:
1. Hide the Notes tab (keep the code) → two-tab interface (To-Dos + Insights only)
2. Remove the Experimental Features toggle → treat advanced features as standard for all users
3. Rebuild the onboarding flow → Duolingo/Noom-inspired 4-step experience (value-first, one idea per screen, clear progress, celebratory finish)
4. Make Insights drilldowns actionable → tap category/task rows to jump directly to the right place in To-Dos

These changes remove friction, simplify the codebase, and meaningfully improve first-time user experience while respecting the app's existing design system.

---

## Overview

Three core problems this PRD addresses:
- **Navigation clutter:** Three tabs (Notes, To-Dos, Insights) where two are the real product; Notes distracts without payoff.
- **Feature fragmentation:** Gating voice input, task hierarchy, and Insights behind an opt-in toggle creates two UX tiers; new users hit friction before discovering value.
- **Weak onboarding:** The current 3-step flow has a dead-video placeholder, static text cues, and a feature-gate; it fails to show the app working or build momentum.
- **Dead-end analytics:** Insights surfaces stale tasks and category bottlenecks but leaves users hunting manually in To-Dos to act on them.

---

## Feature 1: Remove "Notes" Tab from Navigation

### Problem
The Notes tab clutters the tab bar with a surface that isn't central to Notelayer's core value loop (capture → organise → complete tasks). With the goal of a clean two-tab experience (To-Dos + Insights), Notes should be hidden.

### Approach
- Filter `.notes` out of `visibleTabs` in `RootTabsView.swift` — **do not delete the `AppTab.notes` case, `NotesView`, or the `Note` model**
- The tab bar will always show exactly two tabs: **To-Dos** and **Insights**. This is the fixed pattern — no revisiting.
- The `visibleTabs` computed property becomes:
  ```swift
  private var visibleTabs: [AppTab] {
      [.todos, .insights]
  }
  ```
- Notes data in `LocalStore` is preserved as-is; the feature is simply unreachable from the UI

### Out of scope
- Deleting `NotesView.swift`, `Note` model, or related store logic
- Any data migration or user communication about Notes removal

---

## Feature 2: Graduate Experimental Features — Always On

### Problem
`experimentalFeaturesEnabled` gates key product features (Insights tab, voice input, task hierarchy, onboarding) behind an opt-in toggle. This creates a fragmented two-tier experience where basic workflows are hidden. The toggle should be removed and all features treated as standard.

### Approach
- **Hardcode `experimentalFeaturesEnabled` to `true`** in `LocalStore`. The simplest implementation: make the property return `true` unconditionally, ignoring any stored `UserDefaults` value.
- Remove the `Toggle` for "Experimental Features" from the gear menu in `AppTabHeaderComponents.swift`
- Remove the `"flask"` menu item entirely
- Remove the `showLockedInsightsMessage` and `showInsightsHintBanner` banner states from `RootTabsView` — these messages reference the old toggle and are no longer needed
- Remove the `experimentalFeaturesDidChange` notification post and all its observers across `RootTabsView`
- The `"Onboarding Guide"` menu item (currently gated on `experimentalFeaturesEnabled`) becomes unconditionally visible in the gear menu
- Update the Insights overview card title from `"Notelayer Data Insights (Experimental Feature)"` to `"Notelayer Data Insights"`

### What is NOT changing
- Sync status badge on the gear icon — unrelated, stays
- `ExperimentalFeaturePreference` model and `UserDefaults` keys can remain in code but the computed `experimentalFeaturesEnabled` property should simply return `true` without reading from storage — a minimal, safe change
- No need to notify users; this is a silent simplification

---

## Feature 3: Onboarding Overhaul

### Problem
The current `WelcomeView.swift` is a 3-step sheet:
1. A video placeholder with no actual content
2. A bullet-point cue list with no interactivity
3. A category preset picker

This flow fails in several ways:
- The video step is a dead placeholder — no value shown
- Cues are static text, not memorable or actionable
- The entire flow is gated behind `experimentalFeaturesEnabled` (removed by Feature 2)
- One cue references experimental features as a future opt-in — now false
- There is no sense of progress or momentum
- The flow cannot be replayed without digging into debug settings

### Inspiration & Principles

Research across Duolingo and Noom teardowns surfaces clear playbook principles:

**What works (apply these):**
- **Value before commitment** — Duolingo lets users complete a lesson before asking them to create an account. Show the app working before asking anything of the user.
- **One idea per screen** — Noom's flow is disciplined: one question, one decision, one action per screen. No wall-of-text screens.
- **Always explain "why"** — When Noom asks for sensitive info, the reason appears on the same screen. If Notelayer asks users to pick categories, explain why it matters in the same moment.
- **Show a progress indicator** — Noom's research shows users silently ask *"how long is this going to take?"* immediately. Answer that question upfront.
- **Celebrate completion** — Duolingo's micro-animations and "You did it!" moments are psychologically effective. Use Notelayer's accent color and animation system to land a brief moment of delight at the end.
- **Set expectations early** — "This takes about 60 seconds" reduces abandonment more than any other single change.
- **Personalization that feels real** — Chosen categories should feel like they shaped the experience, not just been recorded.

**What to avoid (learn from their weaknesses):**
- Noom's 113-screen, 10-15 minute flow is extreme — keep Notelayer's flow to **4 focused steps, under 90 seconds**
- Noom's worst flaw: users finish onboarding with no preview of what the app actually looks like. Every Notelayer step should feel like the real app.
- Duolingo's onboarding can feel manipulative through aggressive push notification prompts — avoid premature permission asks
- Generic info dumps (the current cues step) — replace with one concrete, visual, interactive moment per screen

### Design constraints
- Adhere strictly to Notelayer's design system: `ultraThinMaterial` backgrounds, `theme.tokens.accent` for primary actions, `RoundedRectangle(cornerRadius: 12, style: .continuous)` card shapes, capsule tab/button styles
- Minimal custom iconography — use SF Symbols throughout
- All screens use the existing `ThemeBackground` + `theme.tokens.screenBackground` pattern
- Animations should use existing SwiftUI spring/easeInOut conventions already in the codebase

### New onboarding flow (4 steps)

#### Step 1 — Welcome  
*Goal: Orient the user in under 5 seconds. Set expectations.*

- Full-sheet, no navigation chrome
- Notelayer logo (existing `AppHeaderLogo`) centered, large
- One-line value prop headline: **"Your tasks. Actually organised."**
- Brief sub-line: **"Takes about 60 seconds to get set up."**
- Single primary CTA button: **"Get Started"** (`.borderedProminent`, accent color)
- No skip. This screen is instant — there's nothing to skip.

#### Step 2 — Choose your starting categories  
*Goal: First personalisation moment. User makes a meaningful choice.*

- Progress indicator at top: step 2 of 4 (pill/dots — use accent color for filled state)
- Heading: **"What does your life look like?"**
- Sub-copy: **"Pick a starting point — you can always customise later."**
- The existing three preset cards (`Everyday Balance`, `Life Admin`, `Growth and Projects`) — keep them, they're good
- Add a fourth option: **"Start blank"** — plain card, no categories preset, selected state same as others
- Selected card gets accent border + accent checkmark (existing pattern from current `WelcomeView`)
- Single CTA: **"This looks right"** (changes label based on selection, e.g. "Start with Everyday Balance")
- No skip button on this screen — the choice is fast and required

#### Step 3 — Add your first task  
*Goal: Interactive moment. User does the core action before leaving onboarding.*  
*Inspired by Duolingo's "complete a lesson before sign-up" principle.*

- Progress indicator: step 3 of 4
- Heading: **"Add something on your mind"**
- Sub-copy: **"Even one task. You can add more anytime."**
- A real-looking task input field (styled as the app's standard input) with placeholder: *"e.g. Call the dentist"*
- Category chips from the chosen preset shown below the field (tappable, same `CategoryChipGridView` component)
- On submit: brief animation — task "flies" into position (simple scale + opacity), then advance automatically
- Skip option: small, secondary text link **"Skip for now"** — subtle, below the input

#### Step 4 — Done  
*Goal: Celebrate. Close the loop. Land in the app with momentum.*

- Progress indicator: step 4 of 4 (all filled)
- Animated checkmark or accent-colored success icon (SF Symbol `checkmark.circle.fill`, animated with scale spring)
- Heading: **"You're set up."**
- If a task was added in Step 3: **"Your first task is waiting."** If skipped: **"Your categories are ready."**
- Single CTA: **"Let's go"** — dismisses onboarding, lands in To-Dos tab
- No skip, no back navigation on this screen

### Replaying onboarding

- The gear menu **"Onboarding Guide"** item is always visible (no experimental gate — removed by Feature 2)
- Tapping it re-presents the `WelcomeView` sheet from Step 1
- `WelcomeCoordinator.resetWelcomeState()` already exists for this — call it, then post `.openOnboardingRequested`
- On replay, Step 3 pre-populates with existing categories (not the preset picker output — use live `store.categories`)
- A task added during replay saves to the real store (same as first-run)

### Trigger logic (unchanged)
- `WelcomeCoordinator.shouldShowWelcome()` controls auto-show on first launch
- Auto-show fires in `checkAndShowWelcome()` in `RootTabsView` — logic stays the same, just remove the `experimentalFeaturesEnabled` guard

### Implementation notes
- `OnboardingStep` enum in `WelcomeView.swift` replaces current `video | cues | presets` with `welcome | categories | taskEntry | done`
- Remove the cue referencing `"flask"` / experimental features from the old `cuesStep`
- `interactiveDismissDisabled()` stays on the sheet — consistent with current behaviour
- The `"Skip"` toolbar button from the current flow is removed; skip is only available in Step 3

---

## Feature 4: Insights Drilldown Deep Links → Main Experience

### Problem
Insights drilldowns surface genuinely useful data — stale categories with piling open tasks, oldest-lingering to-dos — but the information is a dead end. The user reads it, then has to manually navigate back to To-Dos and hunt for what they just saw. There is no connection between the insight and the action.

### Two deep-link entry points

#### 4a. Category rows in `InsightsCategoryDetailView`
In the "Tasks Left per Category" `DataRowsSection`, each row shows a category name, icon, and open task count. Currently these are static `DataRowView` items inside a plain `ForEach`.

**Desired behaviour:** Tapping a category row switches the user to the To-Dos tab in **Category view mode** (`TodoViewMode.category`), with the tapped category visually highlighted or scrolled into view.

#### 4b. Task rows in `InsightsOldestOpenTasksDetailView`
In the "Oldest Open Tasks" `DataRowsSection`, each row shows a task title and age in days. Currently static.

**Desired behaviour:** Tapping a task row switches the user to the To-Dos tab and opens that task's edit sheet (`TaskEditView`) directly.

### Cross-tab navigation mechanism

`InsightsView` lives in its own `NavigationStack` and has no reference to `RootTabsView`'s `selectedTab`. The cleanest pattern — consistent with how the codebase already handles cross-component coordination (see `experimentalFeaturesDidChange`, `openOnboardingRequested`) — is `NotificationCenter`.

**New notifications (add to `LocalStore`'s `Notification.Name` extension):**
```swift
static let navigateToCategoryInTodos = Notification.Name("Notelayer.Navigation.CategoryInTodos")
static let navigateToTaskInTodos     = Notification.Name("Notelayer.Navigation.TaskInTodos")  // optional; see below
```

**Posting (from Insights drilldown views):**
- Category row tap: post `.navigateToCategoryInTodos` with `userInfo: ["categoryId": category.id]`
- Task row tap: post the existing `"OpenTaskFromNotification"` with `userInfo: ["taskId": task.id]` — the app already has this mechanism

**Receiving in `RootTabsView`:**
- On `.navigateToCategoryInTodos`: switch `selectedTab = .todos`, then pass `categoryId` down to `TodosView` (via a `@State` binding or environment value)
- On `"OpenTaskFromNotification"`: switch `selectedTab = .todos` first, then let the existing `TodosView` observer open the editor

**In `TodosView`:**
- Add an optional `jumpToCategoryId: String?` input — when set, switch `viewMode = .category` and scroll/highlight that group
- The existing `"OpenTaskFromNotification"` observer already opens tasks by id; no new code needed for that path

### UI treatment for tappable rows
- Rows in both drilldown sections need a visual affordance that they are tappable. Use a `chevron.right` SF Symbol trailing icon (consistent with iOS convention) or a subtle accent foreground on the row
- Wrap rows in `Button { ... } label: { DataRowView(...) }` with `.buttonStyle(.plain)`, matching the existing pattern used for `NavigationLink` cards in `InsightsView`
- On tap, also dismiss the Insights navigation stack back to root before switching tabs — so returning to Insights later shows the overview, not a stale drilldown

### Scope boundary
- **Only** the "Tasks Left per Category" and "Oldest Open Tasks" rows are deep-linked in this pass
- Other `DataRowsSection` instances (calendar export by category, feature usage rankings, etc.) are out of scope for this feature
- Scroll-to-exact-position within the category view is a nice-to-have, not required; switching to category mode and showing the correct tab is the minimum bar

### Files affected (this feature)
| File | Change |
|---|---|
| `LocalStore.swift` | Add one new `Notification.Name` constant (for categories; reuse existing `OpenTaskFromNotification` for tasks) |
| `InsightsView.swift` | Wrap category rows and oldest-task rows in tappable `Button`; post notifications on tap; add chevron affordance |
| `RootTabsView.swift` | Observe the new notification; switch tab + pass jump state to `TodosView` |
| `TodosView.swift` | Accept `jumpToCategoryId`; handle scroll/mode-switch on receive |

---

## Files affected (full summary)

| File | Feature(s) |
|---|---|
| `RootTabsView.swift` | 1, 2, 3, 4 |
| `AppTabHeaderComponents.swift` | 2 |
| `LocalStore.swift` | 2, 4 |
| `InsightsView.swift` | 2, 4 |
| `WelcomeView.swift` | 3 |
| `WelcomeCoordinator.swift` | 3 |
| `TodosView.swift` | 4 |

---

## Design System Guardrails

All UI changes (Features 3 & 4) must adhere to Notelayer's design system:

- **Backgrounds:** `theme.tokens.screenBackground` + `ThemeBackground(configuration: theme.configuration)` on root views; `.ultraThinMaterial` for cards or overlays
- **Cards & containers:** `RoundedRectangle(cornerRadius: 12, style: .continuous)` filled with `.ultraThinMaterial`, OR reuse the existing `InsetCard` component
- **Primary action color:** `theme.tokens.accent`. Secondary text: `theme.tokens.textSecondary` or `.secondary`
- **Button styles:** Primary = `.borderedProminent`; row/card taps = `Button { } label: { }` with `.buttonStyle(.plain)`; default tint = `theme.tokens.accent`
- **Icons:** SF Symbols only. No custom image assets except the existing `AppHeaderLogo` and themed brand assets
- **Light/dark mode:** Both must render correctly; test on light and dark before marking a feature complete
- **Animations:** Use `withAnimation(.spring(...))` or `.easeInOut(duration:)` consistent with existing patterns in the codebase

---

## Implementation Sequence

Implement in this order; each is independently shippable:
1. **Feature 1** — Remove Notes tab (smallest, zero risk)
2. **Feature 2** — Experimental features always-on (moderate, mid-size refactor)
3. **Feature 3** — Onboarding overhaul (largest, isolated to one view)
4. **Feature 4** — Insights deep links (medium, cross-file but additive)

See `docs/PRD_Nav_Onboarding_Insights_DeepLinks_Plan.md` for detailed step-by-step implementation checklist with validation criteria for each feature.

---

## Success Criteria

- ✅ Tab bar shows To-Dos + Insights only; Notes code preserved.
- ✅ All users can access voice input, task hierarchy, Insights, and onboarding replay without a toggle.
- ✅ New users see the 4-step onboarding; can replay it from the gear menu.
- ✅ Insights drilldown rows jump correctly to To-Dos.
- ✅ Build succeeds with zero new compiler warnings.
- ✅ No performance regression in scroll responsiveness or interaction latency (iOS 15+, iPhone 12+ validated).
- ✅ Design system consistently applied across all new screens.

---

## Appendix: Research Sources

The onboarding flow was informed by teardowns of Duolingo and Noom:
- [Duolingo User Onboarding — Appcues](https://goodux.appcues.com/blog/duolingo-user-onboarding)
- [Duolingo UX & Onboarding Breakdown — UserGuiding](https://userguiding.com/blog/duolingo-onboarding-ux)
- [Noom Web-to-App Onboarding Funnel Teardown — RevenueCat](https://www.revenuecat.com/blog/growth/web-to-app-onboarding-funnel/)
- [Noom UX Case Study — Justinmind](https://www.justinmind.com/blog/ux-case-study-of-noom-app-gamification-progressive-disclosure-nudges/)

Key principles extracted:
- Show value before asking for commitment (Duolingo: complete a lesson before sign-up).
- Keep flow to 4–5 focused steps, <2 minutes total.
- One idea per screen; always explain "why"; show progress upfront.
- Celebrate completion with animation and positive language.
