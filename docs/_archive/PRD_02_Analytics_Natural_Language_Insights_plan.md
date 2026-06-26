# Feature Implementation Plan

**Overall Progress:** `65%`

## TLDR
Refactor Insights presentation into plain-English language with explicit chart context and interpretation: every chart section includes chart + visible values + two-sentence takeaway (observation then suggestion), while preserving raw counts.

## Critical Decisions
- Decision 1: Final label mappings are locked:
- `View open` -> `# of detailed Task views`
- `Insights drilldown open` -> `# of Insight analytics views`
- Decision 2: All chart sections must include chart + data values + two-sentence takeaway.
- Decision 3: Summary format is fixed: sentence 1 observation, sentence 2 suggestion.
- Decision 4: Time-of-day charts must include explicit axis labels.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- `ios-swift/Notelayer/Notelayer/Services/InsightsAggregator.swift`
- `ios-swift/Notelayer/Notelayer/Data/InsightsMetricDefinitions.swift`
- `ios-swift/Notelayer/Notelayer/Services/AnalyticsService.swift`

## UI Consistency Integration
- Before implementation, run `.codex/prompts/ui-consistency.md` in read-only mode:
- Standard-Bearer: `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
- Deviator: `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`
- Favor platform-standard `List`, `Section`, `Label`, and default chart container styling.
- Avoid custom wrapper cards/dividers unless required by data readability.
- If custom container is required, document reason and line-count impact.
- Run second consistency pass after copy/chart layout updates.

## Tasks:

- [ ] 🟥 **Step 1: Build Label Migration Matrix**
  - [ ] 🟥 Inventory all current user-facing metric labels and helper texts in Insights.
  - [ ] 🟥 Map each internal/event-like term to approved plain-English wording.
  - [ ] 🟥 Ensure no raw event key naming leaks into user-facing UI.

- [ ] 🟥 **Step 2: Implement Label And Helper Text Replacements**
  - [ ] 🟥 Apply locked label replacements for the two clarified metrics.
  - [ ] 🟥 Add concise helper text where interpretation is not obvious.
  - [ ] 🟥 Ensure helper text typography hierarchy is subtle and readable.

- [ ] 🟥 **Step 3: Standardize Time-Of-Day Chart Clarity**
  - [ ] 🟥 Add explicit x-axis label and y-axis label to every time-of-day chart.
  - [ ] 🟥 Validate axis naming consistency across sections.
  - [ ] 🟥 Ensure axis text remains legible under Dynamic Type.

- [ ] 🟥 **Step 4: Enforce Section Presentation Contract**
  - [ ] 🟥 For each chart section, render chart first, then data values table/list below.
  - [ ] 🟥 Use horizontal 100% stacked visual style for table-like distributions.
  - [ ] 🟥 Retain raw counts next to interpreted text.

- [ ] 🟥 **Step 5: Implement Two-Sentence Takeaway Pattern**
  - [ ] 🟥 Create reusable takeaway formatter/template:
  - [ ] 🟥 sentence 1 observation,
  - [ ] 🟥 sentence 2 suggestion.
  - [ ] 🟥 Keep voice reflective, droll, concise without sarcasm drift.

- [ ] 🟥 **Step 6: Wire Data Confidence Into Copy (If Available)**
  - [ ] 🟥 If metric confidence is low, soften suggestion assertiveness while preserving observation.
  - [ ] 🟥 Ensure uncertainty language is plain and non-technical.

- [ ] 🟥 **Step 7: Accessibility And Readability Hardening**
  - [ ] 🟥 Verify VoiceOver can read labels, axis names, and takeaway text logically.
  - [ ] 🟥 Ensure high-contrast readability and no color-only distinction.

- [ ] 🟥 **Step 8: Verification And Acceptance**
  - [ ] 🟥 Content QA pass for terminology clarity and tone consistency.
  - [ ] 🟥 UX QA pass: every chart section has chart + values + takeaway.
  - [ ] 🟥 Accessibility QA: axis labels/readability with Dynamic Type and VoiceOver summaries.
  - [ ] 🟥 Run post-implementation UI consistency review and capture findings.
  - [ ] 🟥 Regression QA: raw numeric counts remain visible across Insights sections.

## UI Consistency Evidence (2026-02-11)
- Pre-check completed against existing `InsightsView.swift` section/list patterns.
- Post-check completed after label, chart-axis, and takeaway updates:
- kept native `List`, `Section`, and `Chart` patterns,
- avoided snackbar-style messaging,
- retained raw counts under each visualization.
