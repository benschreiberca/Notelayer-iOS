# Feature Implementation Plan (v2)

**Overall Progress:** `95%`

## TLDR
Implement a new `Insights` root tab as `Notes / To-Dos / Insights` with Apple Health-inspired, Swift Charts-based analytics that combine:
- all-time + rolling-window task history (including done tasks),
- forward-tracked local app-usage telemetry,
- progressive drill-down exploration,
- iOS-consistent UI with top-right gear icon and theme alignment.

This v2 plan reorders execution to reduce bug risk: data contract and telemetry reliability are finalized before chart-heavy UI work.

## Critical Decisions
- Decision 1: App usage analytics are local-only per device in v1 and begin at feature rollout date.
- Decision 2: Multi-category attribution uses full-credit counting (each assigned category gets a count).
- Decision 3: Longest incomplete task is the open task with oldest `createdAt`.
- Decision 4: Metrics are labeled by fidelity type (`Event-Exact`, `Snapshot-Estimated`, `Mixed`) to avoid misleading claims.
- Decision 5: Gear/settings icon remains in top-right in Insights, matching existing app behavior patterns.
- Decision 6: Swift Charts is mandatory for primary visualizations.
- Decision 7: Zero-count categories are included (not optional) in tasks-left-by-category outputs.

## Reassessed Sequence (Risk-First)
1. Metric semantics + reliability rules.
2. Telemetry persistence and data isolation.
3. Missing instrumentation.
4. Aggregation engine with deterministic tests.
5. Root tab integration and Insights shell states.
6. Overview charts.
7. Drill-down views.
8. Accessibility and UX hardening.
9. Performance and integrity hardening.
10. End-to-end validation and release docs.

## Known Bug and Risk Vectors (Addressed by This Plan)
- Historical reconstruction gaps from mutable task snapshot data (deletions, category changes, complete/restore cycles).
- Account switching causing mixed-user telemetry.
- DST/timezone boundary errors in daily buckets.
- UI regressions in custom floating tab bar and gear menu consistency.
- Expensive chart model recomputation causing main-thread jank.
- Over-claiming "all-time" app usage for periods before telemetry rollout.
- Misleading rate metrics when denominator is underspecified.

## Requirement Traceability Matrix
| Req | Requirement | Covered In Steps | Acceptance Gate |
| --- | --- | --- | --- |
| `R1` | Root tabs are `Notes / To-Dos / Insights` | 5, 10 | Tab order and selection behavior verified manually and in UI checks |
| `R2` | Include app usage analytics | 2, 3, 4, 6, 7 | Feature usage charts populated from local telemetry |
| `R3` | All-time + `365/180/60/30/7` tasks added/completed | 1, 4, 6, 10 | Window toggles and all-time trend validation tests pass |
| `R4` | Completion timing includes trend + time-of-day | 1, 4, 6, 7 | Completion trend and hour histograms present and correct |
| `R5` | Category analytics for both added and completed | 1, 4, 6, 7 | Added vs completed category views render with expected values |
| `R6` | Longest incomplete uses oldest `createdAt` | 1, 4, 6, 10 | Deterministic unit test for oldest-open selection passes |
| `R7` | Category-level Add to Calendar usage | 3, 4, 7, 10 | Calendar export category comparison chart validated |
| `R8` | Gap analysis covers all major features | 1, 2, 3, 4, 7 | Feature catalog coverage checklist complete |
| `R9` | Time-of-day insights for tasks added/completed/app usage | 1, 4, 6, 7 | Three separate time-of-day analytics outputs present |
| `R10` | Most/least used across features/categories/time buckets | 1, 4, 7 | Ranking views and tie-break determinism tests pass |
| `R11` | Tasks left per category include uncategorized and zero-count | 1, 4, 6 | Table/chart includes all categories + uncategorized |
| `R12` | Progressive drill-down learning flow | 6, 7 | Overview-to-detail navigation works for each chart family |
| `R13` | New Insights tab after To-Dos, top-right gear, iOS style/theme | 5, 6, 8, 10 | Visual QA checklist and consistency benchmark pass |
| `R14` | Use Swift Charts | 6, 7, 8 | All primary insights charts implemented via Swift Charts |
| `R15` | Historical task metrics include done and task additions | 1, 4, 6, 10 | Added/completed all-time series includes done tasks |

## Data Fidelity Model (Prevents Misleading Analytics)
- `Event-Exact`: metric can be computed directly from persisted telemetry events for covered period.
- `Snapshot-Estimated`: metric inferred from current `Task` snapshot and may miss deleted/history transitions.
- `Mixed`: combines event and snapshot signals.

### Required UI Disclosure
- Insights includes a short "Data coverage" note:
- task history uses all available task records (including done tasks),
- app usage history starts when Insights telemetry is enabled on that device.

## Metric Definitions (Locked Formulas)

### Task Metrics
- `task_total_all_time`: `count(tasks)`.
- `task_open_count`: `count(tasks where completedAt == nil)`.
- `task_done_count`: `count(tasks where completedAt != nil)`.
- `tasks_added_daily[d]`: `count(tasks where localDay(createdAt) == d)`.
- `tasks_completed_daily[d]`: `count(tasks where completedAt != nil and localDay(completedAt) == d)`.
- `added_time_of_day[h]`: `count(tasks where localHour(createdAt) == h)`.
- `completion_time_of_day[h]`: `count(tasks where completedAt != nil and localHour(completedAt) == h)`.
- `category_added_count[c]`: sum full-credit for each task containing category `c`.
- `category_completed_count[c]`: sum full-credit for completed tasks containing category `c`.
- `oldest_open_task`: open task with minimum `createdAt`; display age in days.
- `tasks_left_per_category[c]`: open tasks containing `c`.
- `tasks_left_uncategorized`: open tasks with `categories.isEmpty`.
- `zero-count categories`: included explicitly in output lists/charts.

### App Usage Metrics
- `feature_event_count[f]`: count telemetry events with `feature == f`.
- `feature_usage_daily[f][d]`: count telemetry events per feature per day.
- `usage_time_of_day[h]`: count telemetry events by local hour.
- `calendar_export_by_category[c]`: count `calendar_export_initiated` events where `categoryIds` contains `c`.
- `calendar_export_rate_by_category[c,w]`:
- numerator: `calendar_export_by_category[c]` in window `w`.
- denominator: unique tasks in category `c` that were active in window `w` (created on/before window end and not completed before window start).
- formula: `100 * numerator / max(1, denominator)` (clicks per 100 active tasks).
- `most_used_*` and `least_used_*`:
- ranked by count descending/ascending,
- tie-break 1: most recent activity,
- tie-break 2: stable key lexicographic order.

### Window and Time Rules
- Windows: `7`, `30`, `60`, `180`, `365` days + all-time.
- Bin size: daily.
- Time storage: UTC timestamp + `timezoneOffsetMinutesAtEvent`.
- Day/hour calculations:
- task timestamps use local calendar interpretation.
- telemetry uses offset-at-event for stable historical bucketing across timezone changes.
- DST edge cases explicitly covered by tests.

## Feature Catalog for Gap Analysis (v1 Required Set)
- Task lifecycle: add, edit, complete, restore, delete, reorder.
- Scheduling: due-date set/clear, reminder set/clear, reminder permission prompted/denied.
- Calendar: export initiated/presented/permission denied.
- Category management: create, rename, reorder, delete, assign-to-task.
- Navigation: tab selected, todos mode selected, key view open/duration.
- Notes: notes view usage, note-count growth signal.
- Appearance: theme and appearance interactions.
- Settings/account: profile/settings access.

Gap classification:
- `Unused`: zero events in analysis period.
- `Underused`: default rule for 30-day window is `eventCount < max(3, p25(featureCounts))`.
- `Used`: above underuse threshold.

## Detailed Tasks

- [x] 🟩 **Step 1: Finalize Metric Semantics and Reliability Contract**
  - [x] 🟩 Add an `InsightsMetricDefinitions` source file with authoritative definitions and fidelity tags.
  - [x] 🟩 Document formulas for every metric and chart, including ranking/tie-break behavior.
  - [x] 🟩 Define mandatory inclusion of zero-count categories and uncategorized bucket.
  - [x] 🟩 Define "all-time" wording and data-coverage disclosure language.
  - [x] 🟩 Define acceptance data fixtures for edge cases:
  - [x] 🟩 task deleted after completion,
  - [x] 🟩 category renamed,
  - [x] 🟩 complete-restore-complete cycles,
  - [x] 🟩 tasks without categories.

- [x] 🟩 **Step 2: Implement Local Telemetry Persistence and Isolation**
  - [x] 🟩 Add telemetry store with schema fields:
  - [x] 🟩 `id`, `eventName`, `featureKey`, `timestampUTC`, `timezoneOffsetMinutesAtEvent`, `tabName`, `viewName`, `categoryIds`, `taskIdPolicyField`, `metadata`.
  - [x] 🟩 Add `userScopeKey` to prevent mixing analytics across accounts.
  - [x] 🟩 Add account lifecycle handling:
  - [x] 🟩 sign out and account switch policy (segregate by scope; optionally clear current scope cache).
  - [x] 🟩 Add screenshot-mode isolation parity with current store behavior.
  - [x] 🟩 Add migration/versioning strategy for telemetry schema.
  - [x] 🟩 Add retention/compaction policy:
  - [x] 🟩 keep raw events up to cap (for example `120000`),
  - [x] 🟩 compact oldest raw events into daily aggregates once cap exceeded,
  - [x] 🟩 preserve aggregate all-time accuracy.

- [x] 🟩 **Step 3: Add Missing Instrumentation**
  - [x] 🟩 Mirror existing analytics hooks to local telemetry for required feature catalog.
  - [x] 🟩 Ensure task-add and task-complete events are emitted for Insights computation path.
  - [x] 🟩 Add category attribution to `calendar_export_initiated` telemetry.
  - [x] 🟩 Add reminder interaction context with categories where available.
  - [x] 🟩 Add Insights tab/view open and duration events.
  - [x] 🟩 Add drill-down navigation telemetry for progressive exploration quality checks.

- [x] 🟩 **Step 4: Build Aggregation Engine Before UI**
  - [x] 🟩 Implement deterministic aggregation service merging task snapshot + telemetry.
  - [x] 🟩 Produce typed view models for:
  - [x] 🟩 totals and status splits,
  - [x] 🟩 windowed trend series,
  - [x] 🟩 category added/completed/left distributions,
  - [x] 🟩 time-of-day distributions (added/completed/usage),
  - [x] 🟩 most/least rankings,
  - [x] 🟩 feature gap outputs,
  - [x] 🟩 oldest open task summary.
  - [x] 🟩 Add "confidence" metadata to outputs (`Event-Exact`, `Snapshot-Estimated`, `Mixed`).
  - [x] 🟩 Add deterministic golden tests with fixed clocks/timezones.

- [x] 🟩 **Step 5: Integrate Root Tab and Insights Shell**
  - [x] 🟩 Extend root tab enum/switch to include `Insights` after `To-Dos`.
  - [x] 🟩 Add floating-pill tab button with existing animation/selection style.
  - [x] 🟩 Add Insights analytics tab/view naming.
  - [x] 🟩 Implement Insights shell with:
  - [x] 🟩 loading state,
  - [x] 🟩 no-data state,
  - [x] 🟩 partial-data coverage banner,
  - [x] 🟩 gear icon top-right menu consistent with existing views.

- [x] 🟩 **Step 6: Implement Overview Charts (Swift Charts)**
  - [x] 🟩 Overview cards/charts:
  - [x] 🟩 all/open/done task totals,
  - [x] 🟩 tasks added/completed with window selector (`365/180/60/30/7`),
  - [x] 🟩 category performance overview (added vs completed),
  - [x] 🟩 app feature usage overview,
  - [x] 🟩 time-of-day overview across all dimensions.
  - [x] 🟩 Ensure visuals use theme tokens and iOS-native spacing/typography conventions.

- [x] 🟩 **Step 7: Implement Progressive Drill-Down Flows**
  - [x] 🟩 Historical trend drill-down:
  - [x] 🟩 expanded series, deltas, rolling averages, peak/trough annotations.
  - [x] 🟩 Category drill-down:
  - [x] 🟩 added, completed, left, reminder distribution, calendar-export comparisons.
  - [x] 🟩 Usage drill-down:
  - [x] 🟩 feature timelines, most/least lists, hourly usage distribution.
  - [x] 🟩 Gap analysis drill-down:
  - [x] 🟩 used/underused/unused sections with counts and trend context.
  - [x] 🟩 Ensure drill-down sequence is progressive and learnable from overview.

- [ ] 🟨 **Step 8: Accessibility and UI Consistency Hardening**
  - [x] 🟩 UI standard-bearer review against:
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
  - [x] 🟩 `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
  - [x] 🟩 shared settings components.
  - [ ] 🟨 Accessibility checks:
  - [x] 🟩 Dynamic Type,
  - [ ] 🟨 contrast ratios,
  - [x] 🟩 distinguish without color,
  - [x] 🟩 reduced motion behavior,
  - [x] 🟩 VoiceOver chart summaries and focus order.
  - [x] 🟩 Tufte guardrails:
  - [x] 🟩 minimize non-data ink,
  - [x] 🟩 remove decorative effects that do not improve reading.

- [x] 🟩 **Step 9: Performance and Data Integrity**
  - [x] 🟩 Prevent heavy recomputation on main thread.
  - [x] 🟩 Add memoization/incremental recompute strategy for large datasets.
  - [x] 🟩 Set performance budgets:
  - [x] 🟩 initial Insights load target: `<= 350ms` p95 for `5000` tasks + `50000` telemetry events.
  - [x] 🟩 window-toggle response target: `<= 120ms` p95 on same dataset profile.
  - [x] 🟩 drill-down navigation target: `<= 180ms` p95 view push/render.
  - [x] 🟩 Add stress fixtures for high task/event volumes.

- [ ] 🟨 **Step 10: Validation, Regression, and Release Readiness**
  - [x] 🟩 Unit tests for formulas, window boundaries, DST/timezone correctness.
  - [x] 🟩 Unit tests for account scoping and telemetry isolation.
  - [x] 🟩 Unit tests for ranking determinism and denominator correctness.
  - [ ] 🟨 Manual QA:
  - [ ] 🟨 historical done tasks reflected correctly,
  - [ ] 🟨 add/complete updates reflected promptly,
  - [ ] 🟨 category A vs B calendar-export scenario demonstrated,
  - [ ] 🟨 tab order and top-right gear placement confirmed,
  - [ ] 🟨 light/dark/system theme checks.
  - [x] 🟩 Document known limitations and rollout notes:
  - [x] 🟩 app usage analytics start at rollout date on each device,
  - [x] 🟩 local-only analytics scope.
  - [x] 🟩 Update release notes and internal developer docs.

## Apple References to Add as Execution Aids
- Swift Charts dashboard patterns: [Creating a data visualization dashboard with Swift Charts](https://developer.apple.com/documentation/charts/creating-a-data-visualization-dashboard-with-swift-charts)
- Swift Charts fundamentals: [Hello Swift Charts (WWDC22)](https://developer.apple.com/videos/play/wwdc2022/10136/)
- Swift Charts advanced composition: [Swift Charts: Raise the bar (WWDC22)](https://developer.apple.com/videos/play/wwdc2022/10137/)
- Chart interaction and drill-down ideas: [Explore pie charts and interactivity in Swift Charts (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10037/)
- Chart design quality guidance: [Design an effective chart (WWDC22)](https://developer.apple.com/videos/play/wwdc2022/110340/)
- Product-level chart UX guidance: [Design app experiences with charts (WWDC22)](https://developer.apple.com/videos/play/wwdc2022/110342/)
- Platform design baseline: [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- Chart-specific HIG: [HIG Charts](https://developer.apple.com/design/human-interface-guidelines/charts)
- Accessibility baseline: [HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- Chart accessibility implementation: [Bring accessibility to charts in your app (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10122/)

## Gap Review (v2)
- Gap fixed: requirement mapping now has explicit step coverage and acceptance gate for every requirement (`R1`-`R15`).
- Gap fixed: sequence reordered to test data math before high-complexity UI work.
- Gap fixed: telemetry now includes user scoping, migration, retention, and isolation safeguards.
- Gap fixed: calendar-export category rate denominator is explicitly defined.
- Gap fixed: zero-count category inclusion is now mandatory, matching confirmed requirement.
- Gap fixed: DST/timezone correctness and accessibility criteria are now explicit validation gates.
