# PRD 07: Share To Notelayer System Share Sheet (ChatGPT-First)

Last Updated: 2026-02-10
Status: Draft For Clarification
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

## Dependencies

- Can be rollout-gated through `PRD_01` if needed.
- May intersect with task hierarchy behavior in `PRD_08` for future structure mapping.

## Risks And Unknowns

- ChatGPT output formats vary significantly and can challenge parsing consistency.
- Aggressive structure preservation may create noisy data.
- Ambiguous task-versus-note mapping can reduce user trust.

## High-Level Clarification Questions

1. What exact ChatGPT output patterns are priority for v1 (bullets, numbered plans, markdown headings, plain prose)?
2. Should default destination be task or note when intent is ambiguous?
3. Do you want users to choose destination every time, or infer automatically with fallback?
4. How much markdown should be preserved versus normalized for readability in Notelayer?
5. Should long responses be truncated, chunked, or accepted as-is?
6. Should multiple list items in shared text become multiple tasks or one structured task/note?
7. What source attribution, if any, should be retained for shared content?
8. What should happen if share is initiated while app data store is unavailable/offline?
9. What error-recovery path should exist when share conversion fails?
10. Should duplicate share content detection exist in v1?
11. Are there privacy expectations for what shared content is persisted or transformed?
12. What is the success benchmark for "minimal friction" in this flow?

## Acceptance Signals (Requirement Clarity Only)

- Priority ChatGPT input patterns are explicitly defined for v1.
- Destination and structure-preservation behavior is deterministic for QA.
- Failure states and user recovery expectations are clearly specified.
