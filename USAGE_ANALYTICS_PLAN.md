# Feature Implementation Plan

**Overall Progress:** `88%`

## TLDR
Add a Firebase Analytics wrapper and instrument readable view usage (including the 4‑part Todos toggle), key task/category actions, and time‑in‑view so you can understand real usage on device.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Use a single `view_open` event with readable `view_name` plus `view_duration` to measure time‑in‑view; this keeps reporting consistent and flexible.
- Decision 2: Centralize interaction logging in `LocalStore` and a thin analytics service to ensure coverage and avoid duplicate hooks.
- Decision 3: Track both tabs and the Todos 4‑part toggle as separate events so you can analyze overall navigation and specific list‑mode usage.

## Tasks:

- [x] 🟩 **Step 1: Finalize event taxonomy + parameters**
  - [x] 🟩 Enumerate readable `view_name` strings for: Notes, Todos (List/Priority/Category/Date), Task Edit, Category Manager, Appearance, Profile & Settings, Reminder Picker, Calendar Export, Welcome
  - [x] 🟩 Define navigation events: `tab_selected`, `view_open`, `view_duration`
  - [x] 🟩 Define task events: `task_created`, `task_completed`, `task_restored`, `task_deleted`, `task_edited`, `task_reordered`, `task_due_date_set/cleared`, `task_reminder_set/cleared`
  - [x] 🟩 Define category events: `category_created`, `category_renamed`, `category_deleted`, `category_reordered`, `category_assigned_to_task`
  - [x] 🟩 Confirm safe params (no PII): `priority`, `category_count`, `has_due_date`, `has_reminder`, `source_view`, `completion_latency_s`, `tab_name`, `view_name`

- [x] 🟩 **Step 2: Add Analytics service layer**
  - [x] 🟩 Create `AnalyticsService` with Firebase imports and a single `log(event:params:)`
  - [x] 🟩 Add convenience helpers: `trackViewOpen(viewName:tab:source:)`, `trackViewDuration(viewName:duration:)`
  - [x] 🟩 Add guard for screenshot mode to avoid polluted metrics

- [x] 🟩 **Step 3: Instrument tab + view tracking**
  - [x] 🟩 Track `tab_selected` in `RootTabsView` when the tab changes
  - [x] 🟩 Track `view_open` for Notes and Todos at tab switch
  - [x] 🟩 Track `view_open` for each Todos mode change (`List`, `Priority`, `Category`, `Date`)
  - [x] 🟩 Track `view_duration` for Todos modes when switching or leaving
  - [x] 🟩 Track `view_open` for sheets: Category Manager, Appearance, Profile & Settings, Reminder Picker, Calendar Export, Welcome

- [x] 🟩 **Step 4: Instrument task interactions (centralized)**
  - [x] 🟩 In `LocalStore.addTask`: log `task_created` with params
  - [x] 🟩 In `LocalStore.completeTask`: log `task_completed` with `completion_latency_s`
  - [x] 🟩 In `LocalStore.restoreTask`: log `task_restored`
  - [x] 🟩 In `LocalStore.updateTask`: detect changes and log `task_edited`, `task_due_date_set/cleared`, `task_reminder_set/cleared`
  - [x] 🟩 In `LocalStore.deleteTask`: log `task_deleted`
  - [x] 🟩 In `LocalStore.reorderTasks`: log `task_reordered`

- [x] 🟩 **Step 5: Instrument category interactions (centralized)**
  - [x] 🟩 In `LocalStore.addCategory`: log `category_created`
  - [x] 🟩 In `LocalStore.updateCategory`: log `category_renamed`
  - [x] 🟩 In `LocalStore.deleteCategory`: log `category_deleted` and `category_reassigned` count if applicable
  - [x] 🟩 In `LocalStore.reorderCategories`: log `category_reordered`
  - [x] 🟩 When categories are assigned to tasks (task create/edit): log `category_assigned_to_task`

- [x] 🟩 **Step 6: Instrument reminders + calendar export flows**
  - [x] 🟩 In reminder scheduling/clearing paths: log `reminder_scheduled`, `reminder_cleared`, and permission‑denied events
  - [x] 🟩 In calendar export flow: log `calendar_export_initiated`, `calendar_export_permission_denied`, `calendar_export_presented`

- [x] 🟩 **Step 7: Build check + fix errors**
  - [x] 🟩 Run a clean build for the iOS target
  - [x] 🟩 Fix any compile errors or warnings introduced by analytics hooks

- [ ] 🟥 **Step 8: Validate analytics on device**
  - [ ] 🟥 Run app on device with DebugView enabled
  - [ ] 🟥 Verify `view_open` and `view_duration` for tab + Todos toggle
  - [ ] 🟥 Verify task/category events in Firebase DebugView
