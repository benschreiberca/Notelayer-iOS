# Insights Data Row Patterns - Implementation Plan

**Overall Progress:** `94%`

## TLDR
Standardize Insights drilldown data rows to one reusable design-system pattern so sections render consistently with less per-section styling. Use platform-standard `List` + `Section` behavior, move repeated row layout into shared row helpers, and enforce the documented contract from `docs/DesignSystem/Documentation/Data_Row_Patterns_Reference_Guide.md`.

## Critical Decisions
- Decision 1: Adopt one canonical drilldown row contract (primary left, optional secondary below, trailing value right) across all Insights drilldown row sections.
- Decision 2: Reuse shared row primitives (`DataRowModel`, `DataRowView`, `DataRowsSection`) instead of per-section `HStack` variations.
- Decision 3: Keep iOS-native list/table patterns (`List`, `Section`, `.insetGrouped`) as the standard-bearer and avoid custom wrapper UI in drilldowns.
- Decision 4: For `Calendar Export by Category`, place export count on the right and keep rate (`x.x per 100 active`) as secondary text under the category title.
- Decision 5: Normalize section/drilldown headers to Title Case for consistent naming and scanning.

## UI Consistency Guardrail
- Standard-Bearer: Existing native list sections in `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (`Tasks Left per Category`, `Most Used Features`) already follow platform-standard row behavior.
- Deviations to remove: Per-section row `HStack` variations that duplicate layout logic or mix value placement rules.
- Expected line-count impact: Quality trade-off; small helper additions with net reduction in repeated row code across sections.

## Tasks

- [x] ✅ **Step 1: Define Shared Drilldown Row Primitives**
  - [x] ✅ Add a shared row data model (`DataRowModel`) with fields for primary, optional secondary, optional trailing value, and optional icon.
  - [x] ✅ Add a shared row view (`DataRowView`) implementing canonical layout and typography.
  - [x] ✅ Add a shared section renderer/helper (`DataRowsSection`) to reduce repeated `ForEach + HStack` code.

- [x] ✅ **Step 2: Migrate Insights Drilldown Sections to Shared Rows**
  - [x] ✅ Migrate `Tasks Left per Category` to shared row rendering.
  - [x] ✅ Migrate `Calendar Export by Category` to shared row rendering with right-side export count and secondary rate line.
  - [x] ✅ Migrate `Most Used Features`, `Least Used Features`, `Most Active Hours`, and `Least Active Hours` to shared rows.
  - [x] ✅ Migrate `Oldest Open Tasks` drilldown rows to shared rows.
  - [x] ✅ Migrate `Unused`, `Underused`, `Used` (gap drilldown) to shared rows with secondary metadata.

- [x] ✅ **Step 3: Normalize Header Naming Consistency**
  - [x] ✅ Update Insights section and drilldown titles to Title Case where needed.
  - [x] ✅ Verify header text is consistent across overview + drilldown pages.

- [x] ✅ **Step 4: Remove Styling Drift and Duplicate Row Logic**
  - [x] ✅ Remove obsolete per-section row layout code after migration.
  - [x] ✅ Ensure no section keeps custom value placement that breaks the row contract.
  - [x] ✅ Keep row styling centralized in shared row primitives.

- [ ] 🟨 **Step 5: Validation and Regression Checks**
  - [x] ✅ Verify each migrated section renders with consistent left/secondary/right structure.
  - [x] ✅ Verify `Calendar Export by Category` rows show export count on the right and rate below title.
  - [x] ✅ Verify empty-state rows still appear correctly.
  - [x] ✅ Build app + run Insights tests to catch regressions.
  - [ ] 🟨 Manual UI pass on drilldown pages to confirm visual consistency and readability.
