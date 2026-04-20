# ISSUE 01: Managed Categories Preset Overwrites Existing User Data

Last Updated: 2026-04-20
Type: Bug
Priority: High
Feature Area: Experimental Features / Manage Categories
Status: Open

## Problem

When an existing user navigates to Experimental Features → Manage Categories and selects a preset, the preset **overwrites their current category structure**. This is destructive for users who have been building their category setup over weeks or months.

The original intent (per PRD 06) was that preset selection during **first-run onboarding** is a one-way action — but that constraint should not apply to users revisiting the Manage Categories screen post-onboarding.

## Steps to Reproduce

1. Use Notelayer for several weeks; build a custom category structure.
2. Open Settings → Experimental Features → Manage Categories.
3. Tap any preset (e.g., "Everyday Balance").
4. Observe: existing categories are replaced by the preset.

## Expected Behavior

- Tapping a preset should offer a **confirmation dialog** before applying.
- Dialog should clearly warn: "This will replace your current categories. This cannot be undone."
- Alternatively, show a **merge option**: add preset categories without removing existing ones.
- Best option to evaluate: **merge by default, replace only on explicit confirmation**.

## Proposed Fix

In the Manage Categories view controller / SwiftUI view:
- Detect whether the user already has categories (`categories.count > 0`).
- If yes, show an `Alert` or `ActionSheet` before applying the preset.
- Copy the preset application logic out of onboarding into a shared helper so both paths use the same code with the guard added in one place.

## Acceptance Criteria

- [ ] Selecting a preset when categories already exist triggers a confirmation step.
- [ ] Confirmation clearly states data will be replaced.
- [ ] If user cancels, no categories are changed.
- [ ] First-run onboarding path (no existing categories) remains unchanged — no extra dialog.
- [ ] Unit test covers the "existing categories present" branch.

## Related

- PRD 06: First-Time User Onboarding — established the one-way preset rule for first-run only.
- Manage Categories screen (search: `ManageCategories` in `ios-swift/`).
