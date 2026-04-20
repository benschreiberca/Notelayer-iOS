# PRD 12: Search and Feature Intelligence

Last Updated: 2026-04-20
Status: Draft
Feature Area: Core UX / Search
Priority: Medium

## Purpose

Give users a fast, smart way to find tasks and surface relevant information — moving beyond a simple text filter toward something that feels intelligent.

## Problem Statement

Current search (if any) is basic text matching. Power users with large task libraries need to find things quickly across categories, dates, tags, and completion states. There is also no system that surfaces "what you probably care about right now."

## Goals

- Find any task in under 2 seconds regardless of library size.
- Support natural-language-style queries (e.g., "overdue work tasks", "added this week").
- Surface timely, relevant tasks proactively (smart suggestions, not just search).

## Non-Goals

- Full NLP model running on-device for v1 (too expensive, use heuristics).
- Search across external integrations (Todoist, calendar) — that is import/export scope.

## In Scope

### Search

- Global search bar accessible from all main tabs.
- Real-time filtering as user types.
- Filters: category, date range, completion state, reminder, tag.
- Recent searches stored locally (last 10).
- Empty state with suggested searches.

### Feature Intelligence (Heuristic v1)

- "Focus" surface: a smart list showing tasks that are overdue, due today, or flagged — surfaced on the main screen without the user asking.
- "You haven't looked at X category in 14 days" nudge (subtle, dismissible).
- Sort intelligence: default sort adapts based on which tasks the user actually completes (completions teach priority order).

## Acceptance Criteria

- [ ] Search bar accessible from Todos tab with one tap.
- [ ] Results update in real time as text is typed.
- [ ] At least 3 filter dimensions work (category, date, completion state).
- [ ] Focus list appears on main screen and reflects overdue + today's tasks.
- [ ] Search history persists across app launches.
- [ ] No visible lag on libraries with 500+ tasks.

## Related

- PRD 14: AI Analytics Intelligence (more advanced intelligence layer built on top of this).
- `Insights_Implementation_Plan.md`
