# To-Dos Header Alignment Regression - Issue Report

Status: Active
Last Updated: 2026-02-10
Feature: To-Dos top header consistency
Related:
- [Header_Consistency_And_Keyboard_Tab_Visibility_Issue_Report.md](Header_Consistency_And_Keyboard_Tab_Visibility_Issue_Report.md)
- [Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md](Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md)
- [Todos_Header_Alignment_Regression_Implementation_Plan.md](Todos_Header_Alignment_Regression_Implementation_Plan.md)

**Type:** Regression (UI/Layout)  
**Priority:** High  
**Effort:** Small  
**Created:** February 10, 2026

---

## TL;DR

After restoring the `Doing/Done` toggle, it now appears as a separate row below the header.  
Expected behavior is a single aligned header row in To-Dos:
- Left: Notelayer logo
- Center: Doing/Done toggle + counters
- Right: gear icon

---

## Current State vs Expected Outcome

### 1) Header Alignment Regression

**Current State:**
- Logo and gear are in the navigation toolbar row.
- `Doing/Done` toggle + counters are in a second row below the toolbar.
- Visually, this reads as pushed-down content instead of a centered header control.

**Expected Outcome:**
- `Doing/Done` toggle + counters align horizontally with logo and gear in the same top header row.
- Header interaction should match the intended To-Dos pattern:
  - logo left
  - toggle center
  - gear right

---

## Scope

### In Scope
- Restore single-row header alignment for To-Dos.
- Keep `Doing/Done` toggle and counters intact.
- Preserve existing mode picker row (`List / Priority / Category / Date`) below the header.

### Out of Scope
- Changes to Notes/Insights header behavior.
- Changes to toggle logic, counts logic, or analytics behavior.

---

## Primary File To Touch

1. `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Move toggle rendering back into aligned header layout with logo + gear.
- Ensure spacing and vertical rhythm match other tabs’ top affordances.

---

## Acceptance Criteria

1. To-Dos top header renders as one aligned row: logo (left), Doing/Done toggle with counts (center), gear (right).
2. No second “pushed-down” toggle row under the header.
3. Mode picker remains pinned beneath the header and behaves as before.
4. No regression in toggle state behavior (`Doing` vs `Done`) or counts.

---

## Risks / Notes

- `ToolbarItem(placement: .principal)` can be constrained by nav bar width on smaller devices; validate center control does not clip.
- Verify alignment in dynamic type and smaller iPhone layouts.

---

## Validation Plan

- Manual check on at least one small and one large iPhone simulator:
  - Confirm one-row alignment for logo/toggle/gear.
  - Confirm toggle labels and counts remain legible.
  - Confirm segmented mode picker remains pinned below header.
  - Confirm toggle changes task list and counts correctly.
