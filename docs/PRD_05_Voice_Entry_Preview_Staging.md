# PRD 05: Voice Entry Preview And Staging

Last Updated: 2026-02-10
Status: Mostly Clarified
Feature Area: Voice Capture Quality Control

## Purpose

Require a mandatory preview stage for all voice input so users can correct low-trust transcription before tasks are added.

## Problem Statement

You do not trust voice-to-text reliability enough to allow direct save into the main task list.

## Decisions Locked (2026-02-10)

- Every voice input must pass through preview before task creation.
- Preview occurs before adding anything to main Notelayer tasks.
- User can add, override, edit, and delete prefilled tasks in preview.
- Users can reorder staged tasks before save.
- Save model: both.
- batch save is primary,
- per-item save quick actions are available.
- Exit without saving: prompt each time.
- Validation before save: block save if required fields are missing.
- Background behavior: staging persists through app background/foreground in same session.
- Performance target: preview appears in <= 2 seconds p95 from end of recording.

## Goals

- Prevent low-quality task saves from voice parsing errors.
- Give full user control before persistence.
- Keep staged editing flexible for multi-task captures.

## Non-Goals

- No bypass path that skips preview.
- No auto-save to main tasks without explicit user action.

## In Scope

- Mandatory pre-save staging state.
- Edit/add/delete/reorder operations in staging.
- Explicit confirmation before persistence.
- Validation and performance expectations.

## Out Of Scope

- Post-save automation workflows.

## Key Requirements (Draft)

1. Preview is mandatory for all voice captures.
2. Explicit user acceptance is required before persistence.
3. Save supports batch primary and per-item quick-save actions.
4. Exit without save always prompts for explicit discard/continue choice.
5. Missing required fields block save until corrected.
6. Staging state survives app backgrounding in-session.
7. p95 preview load meets <= 2 seconds target.

## Risks

- Strict validation can increase friction if guidance is unclear.
- In-session persistence requires robust state handling.

## Open Questions

1. Should there be a configurable timeout after which unsaved staging is auto-discarded?

## Acceptance Signals (Requirement Clarity Only)

- Preview flow cannot be bypassed.
- Save/exit/validation rules are explicit and testable.
- Performance target is measurable.
