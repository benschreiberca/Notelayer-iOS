# PRD 15: Task Export and Import (Todoist-First)

Last Updated: 2026-04-20
Status: Draft
Feature Area: Data Portability
Priority: Medium

## Purpose

Make it trivially easy to get tasks into and out of Notelayer — particularly from Todoist, which is the primary migration source for target users.

## Problem Statement

Switching productivity apps is painful. If importing from Todoist requires more than a few taps, most potential users will not bother. Export is equally important: users need to trust they can always get their data out.

## Goals

- Todoist import: user can move their entire task library in under 2 minutes.
- Export: user can get all tasks as a standard file format in 3 taps.
- No data loss on import or export.

## Non-Goals

- Real-time sync with Todoist or other apps (too complex for v1).
- Import from every possible app (Todoist-first, then evaluate).
- Collaborative sharing via import/export.

## In Scope

### Export

- Export all tasks as:
  - **CSV** (universal, works in Excel / Sheets / every app).
  - **JSON** (for developers and power users).
  - **Markdown checklist** (for notes apps like Obsidian).
- Export triggered from Settings → "Export My Data".
- Uses iOS Share Sheet so user can AirDrop, email, or save to Files.
- Export includes: task title, category, completion state, due date, reminder, date created.

### Import — Todoist

- User exports their Todoist data as CSV (Todoist supports this natively).
- User opens that CSV file with Notelayer (via Files app or Share Sheet).
- Notelayer parses Todoist CSV format and maps fields to Notelayer schema.
- Preview screen shows: N tasks found, mapped to X categories. User confirms.
- Duplicate detection: if a task with the same title already exists, skip (don't duplicate).
- Import progress indicator for large libraries.

### Import — Generic CSV

- Accept any CSV with at least a "title" or "content" column.
- Column mapping UI: user drags columns to match Notelayer fields.
- This covers migration from other apps that export CSV.

## Todoist CSV Field Mapping

| Todoist Field | Notelayer Field |
|---------------|-----------------|
| TYPE | (filter: only import TASK rows) |
| CONTENT | Task title |
| DESCRIPTION | Task notes (if notes supported) |
| PRIORITY | (map to flagged if P1 or P2) |
| INDENT | (ignore for v1 — no subtask support yet) |
| AUTHOR | (ignore) |
| RESPONSIBLE | (ignore) |
| DATE | Due date |
| DATE_LANG | (ignore) |
| TIMEZONE | (use for due date parsing) |
| PROJECT | Category (create category if it doesn't exist) |
| SECTION | (append to category name or ignore) |
| LABEL | (ignore for v1) |

## Acceptance Criteria

- [ ] Export as CSV works, file opens correctly in Numbers / Excel.
- [ ] Export as JSON works, schema is documented.
- [ ] Export as Markdown checklist works.
- [ ] Todoist CSV (standard export format as of 2026) imports correctly.
- [ ] Preview screen shows task count and category mapping before confirming.
- [ ] Import of 500 tasks completes in under 10 seconds.
- [ ] Duplicate tasks are skipped, not duplicated.
- [ ] Generic CSV import with column mapping works for at least 2 other app formats (Things 3, TickTick).
- [ ] Export button accessible from Settings without experimental features enabled.

## Related

- PRD 13: Freemium Model (advanced export formats may be Pro-only).
- `Calendar_Export_Implementation_Plan.md`
