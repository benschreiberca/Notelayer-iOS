# Header Consistency + Keyboard Tab Visibility - Issue

Status: Active
Last Updated: 2026-02-09
Feature: Cross-tab header consistency and keyboard/tab interaction
Related:
- [Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md](Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md)
- [INSIGHTS_DISCUSSION_SUMMARY.md](Insights_Requirements_Summary.md)
- [010-features-hub.md](010_Docs_Features_Hub.md)

**Type:** Improvement (UX/Consistency) + Bug (Keyboard/Tab Visibility)  
**Priority:** High  
**Effort:** Medium  
**Created:** February 9, 2026

---

## TL;DR

Two linked UI issues need to be resolved together:
1. Header interaction and visual language are inconsistent across `Notes`, `To-Dos`, and `Insights`.
2. Bottom tab pill remains visible when keyboard is open, but it should not be visible during text entry.

Target outcome:
- Shared header interaction model across all top-level tabs.
- Same Notelayer logo on the left and same Insights-style gear menu on the right across all tabs.
- Middle header content remains tab-specific (for example: `Doing/Done` toggle remains only in `To-Dos`).
- Bottom tab pill hides while keyboard is open.

---

## Current State vs Expected Outcome

### 1. Header Interaction Is Not Consistent Across Tabs

**Current State:**
- `To-Dos` uses a custom dynamic/squeezing header with logo + center controls + gear.
- `Notes` uses a nav title plus an overlaid top-right gear button.
- `Insights` uses a navigation toolbar trailing gear button.

**Expected Outcome:**
- All three tabs use a shared header interaction structure:
  - Left: Notelayer logo (same visual treatment as `To-Dos` logo)
  - Center: tab-specific content
  - Right: same gear menu pattern as `Insights`
- User interaction model should feel uniform when switching tabs.

### 2. Gear Button Should Be Standardized

**Current State:**
- Gear icon/menu is implemented separately in each tab with different container behavior and spacing.

**Expected Outcome:**
- Use the `Insights` gear button/menu look-and-feel as the baseline for all tabs.
- Keep the same menu actions and sync-status badge behavior.
- Apply a single shared visual definition to avoid drift.

### 3. Tab-Specific Middle Header Content Must Stay Unique

**Current State:**
- `To-Dos` has center controls that are valuable and unique.

**Expected Outcome:**
- Header shell is shared, but middle content stays tab-specific.
- `To-Dos` keeps the `Doing/Done` control in the middle.
- `Notes` and `Insights` can keep their own middle content patterns.

### 4. Bottom Tabs Still Visible With Keyboard Open

**Current State:**
- Bottom tab bar remains visible while keyboard is presented.
- Existing behavior currently relies on keyboard overlay semantics, which do not meet UX expectation.

**Expected Outcome:**
- Bottom tab pill is hidden whenever keyboard is visible.
- Behavior applies globally to top-level tabs (Notes, To-Dos, Insights).

---

## Recommended Implementation Direction (Lower Risk)

Use a **shared base header container with tab-specific center slots**.

Why this is lower risk:
- Preserves existing tab logic and interactions (especially `To-Dos` behavior).
- Standardizes only the common shell and affordances (logo + gear + interaction model).
- Avoids a high-risk full rewrite to force all tabs into an identical container implementation.

---

## Scope

### In Scope
- Create a reusable header shell for top-level tabs.
- Standardize left logo and right gear affordance across tabs.
- Preserve tab-specific center region behavior.
- Hide bottom tab pill while keyboard is open.

### Out of Scope
- Redesigning feature-level content in Notes/Todos/Insights.
- Changes to settings menu destinations or business logic.
- Major visual restyling outside header and keyboard/tab behavior.

---

## Primary Files to Touch

1. `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
- Keyboard visibility handling and bottom tab visibility rules.

2. `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Integrate shared header shell while preserving To-Dos middle controls.

3. `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
- Replace overlay-specific header behavior with shared header shell.

Note:
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` is the visual reference for gear style and may be touched only if extraction/refactor of shared gear component is required.

---

## Acceptance Criteria

1. Header consistency:
- Notes, To-Dos, Insights all show Notelayer logo at left.
- Notes, To-Dos, Insights all show same Insights-style gear affordance at right.
- Menu actions and sync badge behavior are consistent across tabs.

2. Tab-specific middle behavior:
- To-Dos retains `Doing/Done` middle control.
- Notes/Insights keep their own middle content without breaking feature flows.

3. Keyboard/tab behavior:
- Bottom tab pill is not visible when keyboard is open in any top-level tab.
- Bottom tab pill returns when keyboard is dismissed.

4. Regression safety:
- No loss of navigation title clarity.
- No regression in settings menu entry points.
- No regression in analytics flows tied to tab switching/header menu entry.

---

## Risks / Notes

- **Moderate layout risk in To-Dos:** current squeeze/collapse header behavior is custom and sensitive to scroll state.
- **Badge positioning risk:** sync-status badge offset may need tuning when gear component becomes shared.
- **Keyboard edge cases:** verify behavior with software keyboard, hardware keyboard attached, and sheet-driven text fields.

---

## Validation Plan

- Manual UI pass on all tabs with keyboard open/closed:
  - Notes text input scenarios
  - To-Dos task entry scenarios
  - Insights (if any input/search in future)
- Confirm consistent header appearance on different device sizes.
- Build validation via existing app scheme after UI changes.

---

## Reference Evidence

User-provided screenshots show:
- Different header behavior and gear placement across tabs.
- Bottom tab pill still visible while keyboard is open.

