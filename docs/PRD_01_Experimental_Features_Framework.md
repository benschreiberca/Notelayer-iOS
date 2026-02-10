# PRD 01: Experimental Features Framework (Feature Flags)

Last Updated: 2026-02-10
Status: Mostly Clarified
Feature Area: Platform Foundation

## Purpose

Define a user-controlled experimental features switch that exposes or hides experimental UI entry points.

## Problem Statement

You want experimental capabilities available to any user, but only when the user explicitly opts in from the gear menu.

## Decisions Locked (2026-02-10)

- Any user can opt into experimental features.
- Control entry point is the gear icon dropdown.
- Label is `Enable Experimental Features`.
- Control UI should be simple and stylistically matched to existing gear menu controls.
- Interaction should be checkbox/toggle-like and default state is off/deselected.
- v1 experimental scope is Insights analytics UI only.
- v1 uses one master toggle (no per-feature sub-toggles).
- Toggle controls UI visibility only; it does not hard-disable backend capability.
- If user turns toggle off while on an experimental screen:
- show a genie-style transition back to the gear icon,
- navigate immediately to default landing screen (list view).
- Persistence model is both:
- device-local state for immediate behavior,
- account-level sync for cross-device continuity.

## Goals

- Provide one predictable on/off mechanism for experimental UI exposure.
- Keep the control simple, user-selected, and easy to find.
- Use the same mechanism to gate multiple experimental UI surfaces over time.

## Non-Goals

- No cohort/remote experiment assignment model in v1.
- No backend kill-switch behavior in this PRD.
- No instrumentation policy changes.

## In Scope

- Gear dropdown control and default state.
- Visibility behavior for experimental surfaces.
- Transition behavior when disabling experimental mode.
- Hybrid persistence expectations (local + account sync).

## Out Of Scope

- Server-side feature shutdown behavior.
- Per-feature experimentation strategy.
- Detailed implementation architecture.

## Key Requirements (Draft)

1. Gear dropdown includes `Enable Experimental Features` master control.
2. Any user can enable/disable the control.
3. Control default is off.
4. In v1, control affects only Insights analytics UI visibility.
5. Disabling while viewing an experimental screen returns user to list view.
6. State supports local persistence and account sync.

## Recommended Sync Conflict Policy (Needs Signoff)

- Immediate UX behavior: apply local value at app launch for fast, deterministic rendering.
- Reconciliation behavior: apply last-write-wins by timestamp once synced value arrives.
- If resolved value differs from currently displayed state, update UI and show compact state-change hint.

## Risks

- "UI-only" gating can be misunderstood as full feature disable.
- Hybrid local/sync model needs deterministic conflict handling.

## Open Questions

1. Approve recommended conflict policy above, or choose a different precedence model?

## Acceptance Signals (Requirement Clarity Only)

- Product and engineering can list exactly which UI elements are controlled in v1.
- On/off transitions and launch behavior are deterministic.
