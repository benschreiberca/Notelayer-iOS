# Insights Global Bottom Clearance And Oldest Open Tasks - Implementation Plan

Status: In Progress
Last Updated: 2026-02-10
Feature: Global floating-tab clearance + data-cover accordion + oldest-open-task snapshot/drilldown
Related:
- [Insights_Feature_Usage_In_App_Section_Issue_Report.md](Insights_Feature_Usage_In_App_Section_Issue_Report.md)
- [Insights_Feature_Usage_In_App_Section_Implementation_Plan.md](Insights_Feature_Usage_In_App_Section_Implementation_Plan.md)
- [PRD_02_Analytics_Natural_Language_Insights.md](PRD_02_Analytics_Natural_Language_Insights.md)

**Overall Progress:** `88%`

## TL;DR
Fix bottom overlap consistently across all tabs by standardizing floating-tab clearance globally, then update the Insights top card to a compact accordion-style `Notelayer Data Insights (Experimental Feature)` card with consistent full-width padding, and expand Insights with a dedicated `Oldest Open Tasks` snapshot card (max 3 rows + happy empty message) plus a new drilldown (max 50 rows) with an age-bucket chart for open tasks.

## Critical Decisions
- Decision 1: Make bottom clearance a global tab-shell concern in `RootTabsView` so Notes, To-Dos, and Insights use the same bottom spacing behavior.
- Decision 2: Remove/avoid tab-specific bottom spacer drift for this concern (for example, Insights-local clearance) to prevent mismatched overlap behavior between tabs.
- Decision 3: Convert the top Insights data-coverage card into a compact accordion card with collapsed summary only and expandable explanatory text.
- Decision 4: Replace the single `oldestOpenTask` model with oldest-open-task list data to support both snapshot preview (top 3) and drilldown list (cap 50).
- Decision 5: Use non-overlapping age buckets for chart grouping while preserving your requested ranges: `0-7`, `8-14`, `15-30`, `31-60`, `61-90`, `90+`.

## UI Consistency Guardrail (Standard-Bearer)
- Platform-standard first: keep Insights drilldown in `List` + `Section` with a simple chart, matching existing drilldown patterns.
- Standard-bearer files: `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift` (global tab shell), `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (existing snapshot cards and drilldowns), and `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` category detail section structure.
- Deviation check: no custom nav container; use existing `NavigationLink`, `InsetCard`, `List`, and `Chart` patterns.
- Expected line-count impact: moderate increase in `InsightsView.swift` and small increase in `InsightsAggregator.swift`; net neutral/small decrease in per-tab bottom spacer code if globalized.

## Approved UI Copy (Exact Strings)
- Data cover card title (collapsed + expanded): `Notelayer Data Insights (Experimental Feature)`
- Data cover card collapsed line (when first usage exists): `App usage tracking started {date}.`
- Data cover card collapsed line (when first usage missing): `No usage telemetry has been captured yet on this device.`
- Data cover card expanded line 1: `Task totals and trends are calculated from tasks stored on this device.`
- Data cover card expanded line 2: `Feature and app usage metrics are captured while you use Notelayer on this device.`
- Oldest open tasks empty-state message: `All caught up. No open tasks waiting right now.`

## Tasks

- [x] 🟩 **Step 1: Standardize Bottom Clearance Across All Tabs**
  - [x] 🟩 Move floating-tab clearance sizing to a single global source in `RootTabsView` and tune it so the pill sits lower while content remains visible.
  - [x] 🟩 Ensure all three tabs (Notes, To-Dos, Insights) inherit identical bottom clearance behavior.
  - [x] 🟩 Remove/adjust tab-local bottom spacer logic that causes inconsistent overlap behavior across tabs.

- [x] 🟩 **Step 2: Convert Top Insights Card To Compact `Notelayer Data Insights (Experimental Feature)` Accordion**
  - [x] 🟩 Make the top card default to compact/collapsed state with only the approved title and the app-usage-started line visible.
  - [x] 🟩 Add tap-to-expand accordion behavior on the same card to reveal the two explanatory lines.
  - [x] 🟩 Ensure card width and horizontal padding exactly match other Insights cards (full-width consistency).
  - [x] 🟩 Keep current no-data fallback line when first usage date is unavailable.

- [x] 🟩 **Step 3: Add Dedicated `Oldest Open Tasks` Snapshot Card**
  - [x] 🟩 Add a new snapshot card section in Insights overview titled `Oldest Open Tasks`.
  - [x] 🟩 Show up to 3 oldest open tasks sorted by longest age first.
  - [x] 🟩 If there are no open tasks, show the approved happy success message instead of empty placeholders.
  - [x] 🟩 Keep this card separate from `Task Totals` (no longer embedded as a single-row subsection there).

- [x] 🟩 **Step 4: Extend Insights Data Model For Oldest-Task Views**
  - [x] 🟩 Replace single-item oldest-open-task snapshot data with list-based data that supports top-3 preview and full drilldown.
  - [x] 🟩 Add a capped drilldown data set limited to 50 oldest open tasks.
  - [x] 🟩 Add age-bucket aggregation counts for open tasks using buckets: `0-7`, `8-14`, `15-30`, `31-60`, `61-90`, `90+`.
  - [x] 🟩 Keep all computations deterministic and derived from existing task state (no analytics schema changes).

- [x] 🟩 **Step 5: Add `Oldest Open Tasks` Drilldown Page**
  - [x] 🟩 Add a new Insights navigation route and detail view for `Oldest Open Tasks`.
  - [x] 🟩 Include a chart showing counts of uncompleted tasks grouped by age bucket.
  - [x] 🟩 Include a list of oldest open tasks (max 50), ordered oldest first, with age-days metadata.
  - [x] 🟩 Align style with existing detail pages (similar to `Category Insights` structure and interactions).

- [ ] 🟨 **Step 6: Validation And Regression Checks**
  - [ ] 🟥 Manual visual pass on small and large iPhone simulators to confirm bottom card/tab overlap is resolved in all tabs.
  - [ ] 🟥 Verify `Features You're using in the App` is fully visible and not covered by the floating tab bar.
  - [ ] 🟥 Verify `Notelayer Data Insights (Experimental Feature)` card stays compact by default, expands/collapses correctly on tap, and keeps full-width alignment with sibling cards.
  - [ ] 🟥 Verify `Oldest Open Tasks` snapshot behavior: max 3, fewer when limited data, happy message on zero open tasks.
  - [ ] 🟥 Verify drilldown behavior: opens correctly, chart bucket counts look correct, and list is capped at 50.
  - [ ] 🟥 Confirm no regression in existing Insights drilldowns, tab switching, and keyboard/tab interactions.
  - [x] 🟩 Automated validation: `Notelayer` Debug simulator build succeeded.
  - [x] 🟩 Automated validation: `NotelayerInsightsTests` passed (`10/10`).
