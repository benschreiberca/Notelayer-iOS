# PRD 02: Analytics Natural Language Insights

Last Updated: 2026-02-10
Status: Clarified
Feature Area: Analytics UX

## Purpose

Make analytics understandable and useful with plain-English labels, clearer chart context, and concise interpretation.

## Problem Statement

Current labels and metric language feel technical and hard to understand. Table-only sections are not self-explanatory enough.

## Decisions Locked (2026-02-10)

- Technical labels should be replaced with plain-English labels.
- Final label:
- `View open` -> `# of detailed Task views`
- helper text: `How many times you opened a task's details.`
- Final label:
- `Insights drilldown open` -> `# of Insight analytics views`
- helper text: `How many times you opened detailed insight analytics screens.`
- Time-of-day views must have explicit axis names.
- All chart sections should include:
- a chart,
- data values below,
- a plain-English takeaway summary.
- Preferred default chart style for table-like sections is horizontal 100% stacked, with data listed below.
- Raw counts should remain visible.
- Summary tone format is:
- first sentence = observation,
- second sentence = suggestion,
- overall style = reflective, droll, concise.

## Goals

- Replace developer-style terminology with user-readable language.
- Make each section interpretable without internal event knowledge.
- Pair numbers with visual context and short takeaways.

## Non-Goals

- No analytics collection taxonomy redesign.
- No BI dashboard behavior.

## In Scope

- User-facing label/copy rewrite.
- Chart axis naming standards.
- Presentation rule for all chart sections.

## Out Of Scope

- New metric families outside existing scope.
- Backend analytics architecture changes.

## Key Requirements (Draft)

1. Internal event-style names do not appear in end-user UI.
2. Ambiguous metrics are renamed to plain-English labels.
3. Time-of-day visuals include explicit x/y axis labels.
4. All chart sections include chart + visible data values + two-sentence takeaway.
5. Raw counts are retained alongside interpretation text.
6. Takeaway format is always:
- sentence 1 = observation,
- sentence 2 = suggestion.

## Risks

- "Droll" tone can read sarcastic if not carefully constrained.
- Overuse of charting can increase visual density.

## Acceptance Signals (Requirement Clarity Only)

- Ambiguous metrics are understandable by non-technical users.
- Time-of-day charts are self-explanatory via axis labels.
- All chart sections consistently provide chart context and takeaway text.
