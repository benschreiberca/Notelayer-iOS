# PRD 04: Voice Entry Structured Capture

Last Updated: 2026-02-10
Status: Mostly Clarified
Feature Area: Voice Task Creation

## Purpose

Convert spoken English input into structured staged tasks with guessed tags.

## Problem Statement

Voice capture is faster than typing, but only valuable when parsing creates clear, reviewable staged tasks.

## Decisions Locked (2026-02-10)

- v1 language scope is English.
- One utterance can be split into multiple staged tasks.
- Split bias is toward granular tasks.
- Unknown category guesses must map to existing categories only.
- Low-confidence guesses should be visibly indicated in preview.
- Parser must produce a title; fallback title uses first 6 words.
- Fallback title should also cap to 55 visible characters (truncate with ellipsis if needed).

## Title Fallback Best-Practice Basis

- Keep fallback titles concise enough for list scanning.
- Keep wording front-loaded and avoid filler words where possible.
- Preserve user language in fallback instead of rewriting intent.

## Goals

- Parse spoken input into clear staged tasks.
- Infer title/notes/date/priority/category (category from existing set only).
- Maximize editability and reviewability before save.

## Non-Goals

- No continuous dictation.
- No background recording.
- No non-English parsing in v1.

## In Scope

- English voice-to-structured parsing.
- Multi-task splitting behavior.
- Guess behavior for category/date/priority.

## Out Of Scope

- Multilingual NLP.
- Always-on assistant behavior.

## Key Requirements (Draft)

1. Parser accepts English speech input and outputs staged task objects.
2. Parser can generate multiple staged tasks per utterance.
3. Unknown category mentions map only to existing categories.
4. Low-confidence guesses are visibly flagged in preview.
5. Fallback title uses first 6 words and max 55 characters.
6. Output feeds mandatory preview flow in `PRD_05`.

## Risks

- Granular split bias may over-fragment some user inputs.
- Guess quality may vary for ambiguous speech.

## Open Questions

1. What parse-quality threshold should mark an item as `Needs Review` in v1?
2. Should low-confidence flags use one level (`Needs Review`) or multiple confidence tiers?

## Acceptance Signals (Requirement Clarity Only)

- Granular splitting and fallback rules are deterministic.
- Confidence signaling is explicit enough for UX and QA validation.
