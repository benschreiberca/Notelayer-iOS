# Data Row Patterns Reference Guide

This guide defines a single, reusable row system for drilldown and analytics pages.

## Goal
- Reduce row-style variations across data-heavy drilldown views.
- Keep row rendering platform-standard (`List` + `Section` + `.insetGrouped`).
- Centralize styling so new sections do not invent one-off row patterns.

## Standard Row Contract
Use one canonical row contract:
- Primary: required, left-aligned title text.
- Secondary: optional, displayed below primary.
- Trailing value: optional, right-aligned numeric/text value.
- Leading icon: optional, included in primary label when needed.

## Allowed Row Types
Only these row types should be used in drilldown views:
1. Value Row
- Primary + trailing value.
- Example: `Tasks Left per Category`, `Most Used Features`, `Oldest Open Tasks`.

2. Value + Secondary Row
- Primary + secondary + trailing value.
- Example: `Calendar Export by Category`.
- Rule: export count is trailing value; rate remains secondary text under the title.

3. Empty State Row
- Single supporting message when no data exists.
- Example: `All caught up. No open tasks waiting right now.`

## Prohibited Variations
- No custom per-section row padding/spacing tweaks unless accessibility requires it.
- No switching value alignment by section (always right-aligned).
- No duplicate value semantics in both trailing and secondary text.
- No custom wrapper cards inside drilldown `List` sections.

## Reuse Plan
For implementation, reuse one shared row API for all drilldown sections:
- Suggested model: `DataRowModel`
- Suggested view: `DataRowView`
- Suggested section helper: `DataRowsSection`

This keeps future sections data-driven and minimizes manual styling.

## Current Usage in Insights
Insights drilldown sections that should adopt this contract:
- `Tasks Left per Category`
- `Calendar Export by Category`
- `Most Used Features`
- `Least Used Features`
- `Most Active Hours`
- `Least Active Hours`
- `Oldest Open Tasks`
- `Unused`
- `Underused`
- `Used`

## Design System Decision
- Prioritize consistency and reuse over section-specific styling.
- New drilldown row sections must conform to one of the three allowed row types.
