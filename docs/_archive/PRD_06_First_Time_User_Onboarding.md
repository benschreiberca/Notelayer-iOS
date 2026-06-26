# PRD 06: First-Time User Onboarding (Composite)

Last Updated: 2026-02-11
Status: Locked
Feature Area: New User Activation

## Purpose

Provide a lightweight onboarding flow with orientation plus practical starting categories.

## Problem Statement

New users need a fast path to understanding and initial structure without setup friction.

## Decisions Locked (2026-02-10)

- Deterministic trigger for v1 is first install.
- Skipped onboarding can be re-opened from Settings.
- Orientation default is video first, then contextual cues.
- Preset selection itself is not reversible as one-click onboarding action.
- Users can still change categories later via `Manage Categories`.
- One preset should be marked as recommended.
- Recommended preset is `Everyday Balance`, visually marked and pre-selected by default.
- Video skip appears after a 3-second intro segment.
- Duration guidance:
- hard cap around 2 minutes,
- recommended target is 60 to 90 seconds.
- Starting categories should avoid time-based grouping labels.
- All three presets should include a finance/banking/investing grouping.
- Proposed preset names and categories are approved.
- Onboarding UI visibility is controlled by `Enable Experimental Features`.

## Goals

- Keep onboarding skippable and non-blocking.
- Seed users with realistic starting category structure.
- Maintain fast time-to-first-value.

## Non-Goals

- No heavy questionnaire.
- No freeform setup requirement during first-run onboarding.

## In Scope

- Intro orientation sequence (video + cues).
- Starting category preset selection.
- Re-entry path from Settings.

## Out Of Scope

- Long-form tutorial system.
- Advanced adaptive personalization engine.

## Proposed Starting Category Presets (v1 Draft)

1. `Everyday Balance` (Recommended)
- Personal
- Work
- Home
- Health
- Finance And Investing
- Someday

2. `Life Admin`
- Personal Admin
- Errands
- Family And Home
- Health And Wellness
- Banking And Bills
- Someday

3. `Growth And Projects`
- Work Projects
- Personal Projects
- Learning
- Relationships
- Finance And Investing
- Someday

## Key Requirements (Draft)

1. Onboarding triggers on first install.
2. Orientation is lightweight, skippable, and non-blocking.
3. Orientation sequence is video first, then contextual cues.
4. User selects one starting-category preset.
5. One preset is visibly marked recommended.
6. Users can re-open onboarding guidance from Settings.
7. Category changes remain available later via `Manage Categories`.
8. Presets avoid time-based labels and include financial grouping in each option.
9. Onboarding UI surface for this PRD is shown only when experimental features are enabled.

## Risks

- Preset names or category sets may still need brand-voice tuning.
- Two-minute cap can feel long if video pacing is slow.

## Open Questions

None.

## Acceptance Signals (Requirement Clarity Only)

- Trigger and sequence are deterministic.
- Preset definitions are concrete enough for preview UI and QA.
