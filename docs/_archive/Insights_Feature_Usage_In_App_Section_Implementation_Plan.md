# Insights Feature Usage In App Section - Implementation Plan

Status: Active
Last Updated: 2026-02-10
Feature: Insights feature-usage snapshot + drilldown clarity
Related:
- [Insights_Feature_Usage_In_App_Section_Issue_Report.md](Insights_Feature_Usage_In_App_Section_Issue_Report.md)
- [PRD_02_Analytics_Natural_Language_Insights.md](PRD_02_Analytics_Natural_Language_Insights.md)
- [Insights_Implementation_Plan.md](Insights_Implementation_Plan.md)

**Overall Progress:** `85%`

## TL;DR
Apply a focused Insights update so the `Features You're using in the App` section is never obscured by the floating tabs, has descriptive snapshot subtext, uses the updated section name everywhere, and includes clear drilldown measurement guidance without changing analytics logic.

## Critical Decisions
- Decision 1: Keep this as a layout/copy-only change in Insights UI; do not change telemetry schema, event names, or aggregation math.
- Decision 2: Prefer a local visibility fix in `InsightsView` content spacing first; only touch `RootTabsView` if local inset cannot reliably prevent overlap.
- Decision 3: Align drilldown explanatory text strictly to current aggregator semantics (`windowCount`, `allTimeCount`, and existing `unused/underused/used` thresholds).

## UI Consistency Guardrail (Standard-Bearer)
- Platform-standard first: continue using existing `NavigationLink`, `InsetCard`, and `List` + `Section` patterns already used in Insights.
- Standard-bearer files: `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (existing snapshot cards with headline + supporting text) and `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift` (floating tab inset behavior).
- Deviation check: no new custom container/component; only add/adjust copy and safe bottom spacing where needed.
- Expected line-count impact: small positive increase in `InsightsView.swift`; `RootTabsView.swift` unchanged unless fallback adjustment is required.

## Tasks

- [x] 🟩 **Step 1: Rename Section To `Features You're using in the App`**
  - [x] 🟩 Update snapshot card title from `Feature Gap Analysis` to `Features You're using in the App`.
  - [x] 🟩 Update drilldown navigation title from `Feature Gap Analysis` to `Features You're using in the App`.
  - [x] 🟩 Verify no stale `Feature Gap Analysis` label remains in this section flow.

- [x] 🟩 **Step 2: Add Snapshot Subtext Between Header And Metrics**
  - [x] 🟩 Insert one concise explanatory line directly under the snapshot heading and above the metric pills.
  - [x] 🟩 Keep typography/spacing consistent with existing Insights supporting copy style.
  - [x] 🟩 Confirm the added text does not push metrics into overlap with floating tabs on smaller devices.

- [x] 🟩 **Step 3: Add Drilldown Measurement Description**
  - [x] 🟩 Add descriptive text at the top of `InsightsGapDetailView` that explains what `Window` and `All-time` counts represent.
  - [x] 🟩 Add brief explanation for `Unused`, `Underused`, and `Used` categories.
  - [x] 🟩 Validate wording against `InsightsAggregator` threshold logic (`unused == 0 in selected window`, `underused < threshold`, `used >= threshold`).

- [x] 🟩 **Step 4: Fix Bottom Visibility Above Floating Tabs**
  - [x] 🟩 Ensure the final Insights section remains fully visible and readable above the floating tab bar on supported iPhone sizes.
  - [x] 🟩 Implement the least-risk spacing/inset adjustment in `InsightsView` first.
  - [x] 🟩 Touch `RootTabsView` only if a local Insights fix cannot reliably prevent overlap.

- [ ] 🟨 **Step 5: Validate And Regressions**
  - [x] 🟩 Build-check updated `InsightsView` with the existing Notelayer iOS scheme.
  - [ ] 🟥 Manual visual pass on small and large iPhone simulators for bottom-section visibility.
  - [ ] 🟥 Confirm snapshot subtext placement is between heading and data region.
  - [ ] 🟥 Confirm updated naming in snapshot and drilldown.
  - [ ] 🟥 Confirm drilldown explanatory text appears before status sections.
  - [ ] 🟥 Confirm drilldown navigation and existing insights analytics events continue to fire.
