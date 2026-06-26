# PRD 03: Analytics Insights Toggle

Last Updated: 2026-02-11
Status: Locked
Feature Area: Analytics Visibility Control

## Purpose

Gate Insights visibility through `Enable Experimental Features` in the gear dropdown.

## Problem Statement

Insights should remain hidden unless the user turns on experimental features.

## Decisions Locked (2026-02-10)

- Insights visibility is controlled by `Gear -> Enable Experimental Features`.
- Insights is hidden while toggle is off.
- Insights appears when toggle is on.
- Persistence is both:
- local per-device,
- synced at account level.
- If user turns toggle off while on Insights:
- play genie-style transition back toward gear icon,
- navigate to default landing screen (list view).
- For hidden Insights route attempts, show message:
- `Enable this feature in Experimental Features.`
- First-time Insights visibility should show a small hint cue.
- Do not use snackbars.
- Local-vs-synced conflict policy inherits `PRD_01` directly.
- Hint frequency state is account-synced.

## Hint Frequency Best-Practice Policy (Recommended)

Based on Apple TipKit guidance to show tips sparingly and avoid repetitive tips:

1. Show hint once the first time Insights becomes visible.
2. If dismissed without interaction, allow at most one reminder after at least 24 hours.
3. Never show again after meaningful interaction with Insights details.
4. Keep feature discoverable later through a persistent non-intrusive help affordance.

## Goals

- Keep visibility behavior simple and deterministic.
- Ensure Insights exposure is explicitly user-controlled.

## Non-Goals

- No separate Settings `Insights` toggle in v1.
- No instrumentation policy definition in this PRD.

## In Scope

- Visibility behavior based on experimental toggle state.
- On/off transition behavior while inside Insights.
- First-time visibility cue pattern (non-snackbar).
- Hidden-route handling copy.
- This PRD defines Insights-specific behavior; other experimental surfaces are governed by `PRD_01`.

## Out Of Scope

- Analytics storage architecture.
- Legal/privacy policy language.

## Key Requirements (Draft)

1. Insights is hidden by default.
2. Insights appears only when experimental features are enabled.
3. Disabling experimental features from within Insights exits to list view.
4. First-time visible state presents compact non-snackbar hinting.
5. Hidden Insights route attempts show enable-in-experimental messaging.
6. State is persisted locally and synced across account devices.

## Risks

- Ambiguity in local-vs-synced conflict handling.
- Hint pattern can become noisy if frequency limits are not enforced.

## Open Questions

None.

## Acceptance Signals (Requirement Clarity Only)

- One unambiguous control path governs Insights visibility.
- On/off transitions and hidden-route behavior are deterministic.
