# Insights Feature Usage In App Section - Issue Report

Status: Active
Last Updated: 2026-02-10
Feature: Insights feature-usage snapshot + drilldown clarity
Related:
- [PRD_02_Analytics_Natural_Language_Insights.md](PRD_02_Analytics_Natural_Language_Insights.md)
- [PRD_02_Analytics_Natural_Language_Insights_plan.md](PRD_02_Analytics_Natural_Language_Insights_plan.md)
- [Insights_Implementation_Plan.md](Insights_Implementation_Plan.md)

**Type:** Bug (Layout) + Improvement (UX Copy)  
**Priority:** High  
**Effort:** Small-Medium  
**Created:** February 10, 2026

---

## TL;DR

The Insights section currently labeled `Feature Gap Analysis` needs four updates:
1. It can be hidden behind the floating bottom tabs.
2. It needs descriptive subtext between the section header and the data visualization.
3. It should be renamed to `Features You're using in the App`.
4. Its drilldown page needs explanatory text describing what is being measured.

---

## Current State vs Expected Outcome

### 1. Bottom Tabs Obscure The Section

**Current State:**
- The final Insights section can be visually overlapped by the floating tab pill near the bottom of the screen.

**Expected Outcome:**
- The section is fully visible and readable above the floating tab area on supported iPhone sizes.
- No key label, value, or interaction is hidden behind the tabs.

---

### 2. Missing Subtext In Snapshot Card

**Current State:**
- The card shows header + metrics only.
- There is no descriptive line between the heading and the data visualization region.

**Expected Outcome:**
- Add short explanatory subtext directly below the section heading and above the data visualization/metrics.
- Copy should clarify the high-level purpose of this section in plain language.

---

### 3. Rename `Feature Gap Analysis` To `Features You're using in the App`

**Current State:**
- Snapshot card title: `Feature Gap Analysis`
- Drilldown navigation title: `Feature Gap Analysis`

**Expected Outcome:**
- Snapshot card title: `Features You're using in the App`
- Drilldown title: `Features You're using in the App`

---

### 4. Missing Drilldown Measurement Description

**Current State:**
- Drilldown lists features by `Unused`, `Underused`, and `Used` without a top-level explanation.

**Expected Outcome:**
- Add descriptive text at the top of the drilldown page explaining what is measured:
  - `Window` count meaning
  - `All-time` count meaning
  - What `Unused`, `Underused`, and `Used` represent
- Explanation must align with current threshold logic in aggregation to avoid misleading wording.

---

## Scope

### In Scope
- Visibility fix for bottom overlap.
- Snapshot copy placement and label updates.
- Drilldown title rename.
- Drilldown explanatory text.

### Out of Scope
- Changes to analytics event names or event schema.
- Reworking feature usage thresholds/aggregation math.
- Any redesign outside this specific Insights section and its drilldown.

---

## Primary Files To Touch

1. `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- Snapshot section title + subtext insertion.
- Drilldown page title + explanatory text.
- Section-level bottom visibility behavior.

2. `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift` (verify only if needed)
- Confirm floating tab inset/overlay behavior does not obscure final Insights content.

3. `ios-swift/Notelayer/Notelayer/Services/InsightsAggregator.swift` (reference for copy accuracy)
- Source of `Window`/`All-time` semantics and `Unused/Underused/Used` classification logic.

---

## Acceptance Criteria

1. The Insights `Features You're using in the App` section is not obscured by bottom tabs.
2. Snapshot card includes descriptive subtext between heading and data region.
3. All user-facing occurrences of `Feature Gap Analysis` in this section are renamed to `Features You're using in the App`.
4. Drilldown page includes clear explanatory text describing what is measured and how status buckets are interpreted.
5. No regression in drilldown navigation or analytics event firing.

---

## Risks / Notes

- Copy must stay accurate to existing classification behavior to avoid mismatched expectations.
- If layout is adjusted globally for tab overlap, verify no side effects on other tabs’ scroll bottoms.

---

## Validation Plan

- Manual visual pass on iPhone simulator sizes with floating tabs visible:
  - Confirm section remains fully visible at bottom of Insights list.
  - Confirm subtext appears between header and data region.
  - Confirm updated naming in both snapshot and drilldown.
  - Confirm drilldown explanatory text appears before section lists.
- Regression check navigation to and from drilldown.
