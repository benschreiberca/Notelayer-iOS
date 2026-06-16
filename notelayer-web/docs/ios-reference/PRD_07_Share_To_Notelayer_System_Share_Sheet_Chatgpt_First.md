# PRD 07: Share To Notelayer System Share Sheet (ChatGPT-First)

Last Updated: 2026-02-11
Status: Locked
Feature Area: External Capture Ingestion

## Purpose

Enable fast capture from ChatGPT into Notelayer using the iOS system share sheet with minimal friction.

## Problem Statement

Users creating task-relevant content in ChatGPT need a direct capture path into Notelayer without manual copy/paste workflows.

## Goals

- Support native share sheet ingestion optimized for ChatGPT output.
- Convert shared text into task or note while preserving structure where possible.
- Minimize context switching and friction.

## Non-Goals

- No broad source expansion is defined beyond ChatGPT-first scope.
- No advanced multi-source ingestion orchestration is defined in this PRD.

## In Scope

- System share sheet flow into Notelayer.
- ChatGPT-formatted text handling.
- Task/note conversion behavior and structure preservation principles.

## Out Of Scope

- File/image/media ingestion.
- Non-ChatGPT source optimization requirements.
- Long-term ingestion automations beyond share action.

## Key Requirements (Draft)

1. Native iOS share sheet path must support fast capture into Notelayer.
2. Shared text can become task or note.
3. Structure from source text should be preserved where practical.
4. Flow should minimize user friction and app switching overhead.

## Decisions Locked (2026-02-11)

- Priority input patterns for v1: plain prose, bullets, numbered lists, and markdown headings.
- Ambiguous destination defaults to note.
- Destination is inferred automatically in v1 (no forced chooser each time).
- Structure preservation rule:
- preserve headings, bullets/numbering, and checklist semantics where possible,
- normalize links/code blocks to plain text for readability.
- Long content rule: accept up to 10,000 characters, then truncate with a warning.
- List mapping rule: multiple list items become multiple staged tasks.
- Source attribution rule: store source app + import timestamp.
- Offline/unavailable store rule: queue import locally as pending and offer retry.
- Conversion failure rule: keep pending draft, show recovery action, never silently drop.
- Duplicate detection is out of scope for v1.
- Minimal friction benchmark:
- p95 import preparation time <= 2 seconds for typical shares,
- no more than one required confirmation step before saving.

## Dependencies

- Can be rollout-gated through `PRD_01` if needed.
- May intersect with task hierarchy behavior in `PRD_08` for future structure mapping.

## Risks

- ChatGPT output formats vary significantly and can challenge parsing consistency.
- Aggressive structure preservation may create noisy data.
- Ambiguous task-versus-note mapping can reduce user trust.

## Open Questions

None.

## Acceptance Signals (Requirement Clarity Only)

- Priority ChatGPT input patterns are explicitly defined for v1.
- Destination and structure-preservation behavior is deterministic for QA.
- Failure states and user recovery expectations are clearly specified.
