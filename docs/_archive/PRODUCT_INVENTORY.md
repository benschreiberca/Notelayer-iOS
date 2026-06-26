# Notelayer iOS — Product Inventory

> **What this file is:** A living snapshot of every feature and function in the app. Updated automatically by the `release-ship` skill on each branch completion and merge to main. Edit in place — this is not a changelog.

**Last updated**: 2026-04-11
**Last release**: performance-updates-claude (branch)
**Platform**: iOS

---

## Navigation

Notelayer uses a floating pill-style tab bar with three tabs. The tab bar hides when the keyboard is visible.

| Tab | Icon | Notes |
|---|---|---|
| Notes | note.text | Always visible |
| To-Dos | checklist | Always visible |
| Insights | chart.xyaxis.line | Visible only when Experimental Features is enabled |

---

## Notes Tab

A simple scrollable list of captured text notes.

- **Note list** — displays all notes in a scrollable card layout
- **Share note** — share note text via the iOS share sheet (long-press context menu)
- **Copy note** — copy note text to clipboard (long-press context menu)

---

## To-Dos Tab

The primary task management screen.

### Task List

- **Task list** — scrollable list of active tasks, grouped and sorted by the selected view mode
- **Completed tasks toggle** — show/hide completed tasks via a "Done" toggle
- **Search** — full-text search across task titles and task notes; triggered via floating search button; dismisses on cancel or submit
- **Empty state** — friendly message when no tasks exist

### View Modes

Four segmented view modes selectable at the top of the screen:

- **List** — flat chronological list, manually reorderable via drag
- **Priority** — grouped by priority level (High → Medium → Low → Deferred)
- **Category** — grouped by assigned category
- **Date** — grouped by due date proximity

### Task Creation

- **Inline task input** — type-and-submit task entry at the bottom of the list
- **Voice task entry** — floating mic button (visible on To-Dos tab when Experimental Features enabled); records speech, transcribes, and parses into structured task drafts

### Task Item

Each task row shows title, category chips, priority indicator, and due date. Long-press opens a context menu.

- **Complete task** — tap checkbox to mark done; moves to completed section immediately
- **Restore task** — tap checkbox on a completed task to reopen it immediately
- **Edit task** — tap row to open full edit sheet
- **Delete task** — swipe-to-delete or context menu
- **Share task** — share task title via iOS share sheet (context menu)
- **Set reminder** — quick reminder shortcut from context menu
- **Reorder** — drag handle when in List mode

### Task Editor

Full-screen edit sheet with the following fields:

- **Title** — editable text field
- **Categories** — multi-select chip grid from the user's category list
- **Priority** — segmented picker: High / Medium / Low / Deferred
- **Due date** — date + time picker; clearable
- **Reminder** — notification-based reminder tied to a date/time; requires notification permission
- **Task notes** — freeform text field for additional context
- **Calendar export** — export task as a calendar event via EventKit; requires calendar permission
- **Parent task** — assign task as a subtask of another task (visible when Experimental Features enabled)
- **Subtask indicator** — shows when a task has subtasks; parent auto-closes when all subtasks complete; parent can be manually reopened

### Voice Task Entry (Experimental)

End-to-end voice-to-task workflow:

- **Voice capture sheet** — tap mic button → record speech → animated waveform during recording → transcribe on stop
- **AI task parsing** — transcript is parsed into structured drafts: title, categories, priority, due date, confidence score
- **Voice staging view** — review screen showing parsed drafts before saving; each draft is editable; drafts can be reordered, deleted, or added manually; "Save All" commits drafts to the task list
- **Recording indicator** — pulsing rings on the mic FAB while recording is active
- **Voice state isolation** — recording and staging state is fully decoupled from the task list; toggling tasks while a recording is in progress does not cause list redraws

---

## Insights Tab (Experimental)

Analytics dashboard for personal productivity patterns. Only accessible when Experimental Features is enabled.

- **Genie transition** — animated collapse into the tab bar corner when Insights is disabled while on the tab
- **Insights hint banner** — one-time contextual banner on other tabs prompting the user to discover Insights; dismisses after interaction

### Metrics and Views

- **Trend view** — task completion trends over a selectable rolling window (7D / 30D / 60D / 180D / 365D)
- **Category view** — task volume and completion breakdown by category
- **Usage view** — feature usage frequency across core actions
- **Gap analysis** — identifies unused or underused features with gap classification (Unused / Underused)
- **Oldest open tasks** — surfaces tasks that have been open the longest

### Data Fidelity

Insights data is labeled with a reliability indicator:
- **Event-Exact** — computed from persisted telemetry
- **Snapshot-Estimated** — inferred from current state, may miss historical transitions
- **Mixed** — combines both sources

---

## Categories

User-managed taxonomy applied to tasks.

- **Default categories** — 8 preset categories with emoji icons and distinct colors: House & Repairs, Garage & Workshop, 3D Printing, Vehicle & Motorcycle, Tech & Apps, Finance & Admin, Shopping & Errands, Travel & Health
- **Custom categories** — create categories with custom name, emoji icon, and color
- **Category manager** — full CRUD for categories; reorderable via drag
- **Category ordering** — custom sort order persisted; lower index = higher in list
- **Category colors** — per-category accent color used in chips and grouping headers
- **Category assignment** — tasks can belong to multiple categories simultaneously

---

## Reminders

Local notification-based reminders for tasks.

- **Reminder picker** — date/time selector for scheduling a task reminder
- **Reminder scheduling** — registers a local UNNotificationRequest on set
- **Reminder cancellation** — clears the notification when reminder is removed or task is deleted
- **Permission prompt** — requests notification permission on first reminder set; graceful handling of denied permission
- **Reminders settings** — dedicated settings screen for reminder preferences

---

## Appearance & Themes

- **Theme presets** — curated preset themes in two categories: Traditional and Patterns
- **Appearance mode** — Light / Dark / System (follows iOS setting)
- **Full customization** — custom theme builder for users who want full control over colors
- **Theme persistence** — selected theme and mode persisted across sessions and synced

---

## Sync & Account

- **Firebase backend sync** — tasks, categories, notes, and preferences sync to Firestore
- **Auth** — sign in via Firebase Auth; supports sign-in sheet from profile settings
- **Profile settings** — account management: view account info, sign out, manage account
- **Local-first** — app is fully functional offline; sync happens in the background when connected
- **Experimental features preference** — toggling experimental features syncs state across devices with conflict resolution

---

## Share Extension

- **Accept shared content** — Notelayer registers as a share target; shared text from other apps is captured and added as a note or task

---

## Onboarding

- **Welcome screen** — shown on first launch when Experimental Features is enabled; non-dismissible until completed
- **Welcome coordinator** — tracks whether the welcome flow has been seen; re-triggerable via a settings deep link

---

## Undo

- **Shake to undo** — shake gesture triggers undo for the most recent task mutation; uses `UndoShakeHost` overlaid on the main content

---

## Analytics (Internal)

Internal telemetry — not user-facing. Used to power Insights.

Tracked events include: task create/edit/complete/restore/delete/reorder, due date set/cleared, reminder set/cleared/permission, calendar export, category CRUD, tab selection, view open/duration, mode switches, theme changes, profile settings open, insights drilldown.

---

## Experimental Features

A single toggle in settings that gates access to:
- Insights tab
- Voice task entry
- Subtask / parent-task hierarchy
- Voice staging view

State is synced across devices. Disabling while on the Insights tab triggers the genie collapse transition back to To-Dos.
