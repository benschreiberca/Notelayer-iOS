# Analytics Events Reference

This document lists all analytics event tags currently used in the app, what they measure, and key parameters.

## Insights Telemetry Mirror

- Production analytics events are mirrored into a local, per-device Insights telemetry store.
- Local telemetry is scoped by signed-in user ID to avoid cross-account mixing on shared devices.
- App usage history in Insights starts when this local telemetry is available on that device.

## Navigation + Views

- `tab_selected`
  - Measures: user switches app tabs (Notes ↔ To-Dos ↔ Insights)
  - Params: `tab_name`, `previous_tab`

- `view_open`
  - Measures: a view/screen/sheet becomes visible
  - Params: `view_name`, `tab_name`, `source_view`

- `view_duration`
  - Measures: time spent in a view before leaving
  - Params: `view_name`, `duration_s`

## Todos Filters

- `todos_filter_changed`
  - Measures: Doing/Done toggle switched
  - Params: `showing_done`, `view_name`

## Tasks

- `task_created`
  - Measures: task creation
  - Params: `priority`, `category_count`, `has_due_date`, `has_reminder`, `category_ids_csv`

- `task_completed`
  - Measures: task marked complete (includes time-to-complete)
  - Params: `completion_latency_s`, `category_count`, `priority`, `had_due_date`, `had_reminder`, `category_ids_csv`

- `task_restored`
  - Measures: completed task restored to active
  - Params: `category_count`, `priority`, `category_ids_csv`

- `task_deleted`
  - Measures: task deletion
  - Params: `has_due_date`, `has_reminder`, `category_count`

- `task_edited`
  - Measures: task edited (fields changed)
  - Params: `title_changed`, `categories_changed`, `priority_changed`, `due_date_changed`, `notes_changed`

- `task_reordered`
  - Measures: task list reordered
  - Params: `task_count`

- `task_due_date_set`
  - Measures: due date added
  - Params: `category_count`, `priority`

- `task_due_date_cleared`
  - Measures: due date removed
  - Params: `category_count`, `priority`

- `task_reminder_set`
  - Measures: reminder set on task
  - Params: `lead_time_minutes`, `has_due_date`, `category_count`, `category_ids_csv`

- `task_reminder_cleared`
  - Measures: reminder cleared from task
  - Params: `category_count`, `has_due_date`, `category_ids_csv`

## Categories

- `category_created`
  - Measures: category created
  - Params: `category_count`

- `category_renamed`
  - Measures: category renamed or icon/color changed
  - Params: `name_changed`, `icon_changed`, `color_changed`

- `category_deleted`
  - Measures: category deleted
  - Params: `reassigned_task_count`, `category_count`

- `category_reordered`
  - Measures: categories reordered
  - Params: `category_count`

- `category_assigned_to_task`
  - Measures: categories added/removed from a task
  - Params (create): `category_count`, `source_view`
  - Params (edit): `added_count`, `removed_count`, `source_view`

## Reminders + Permissions

- `reminder_permission_prompted`
  - Measures: system permission prompt shown

- `reminder_permission_denied`
  - Measures: permission denied

- `reminder_scheduled`
  - Measures: reminder scheduled
  - Params: `lead_time_minutes`, `category_ids_csv`

- `reminder_cleared`
  - Measures: reminder cancelled/cleared
  - Params: `category_ids_csv`

## Calendar Export

- `calendar_export_initiated`
  - Measures: user starts calendar export
  - Params: `view_name`, `has_due_date`, `has_reminder`, `task_id`, `category_ids_csv`

- `calendar_export_permission_denied`
  - Measures: calendar access denied
  - Params: `view_name`

- `calendar_export_presented`
  - Measures: calendar editor shown
  - Params: `view_name`, `task_id`

## Insights

- `insights_drilldown_opened`
  - Measures: user drills deeper from Insights overview cards
  - Params: `view_name`, `tab_name`, `source_view` (when present)

## Themes

- `theme_changed`
  - Measures: theme mode/preset/configuration changed
  - Params: `change_type` (`mode` | `preset` | `configuration`), plus `mode` or `preset_id` when applicable

## View Names (`view_name`)

- `Notes`
- `Todos / List`
- `Todos / Priority`
- `Todos / Category`
- `Todos / Date`
- `Task Edit`
- `Category Manager`
- `Appearance`
- `Profile & Settings`
- `Reminder Picker`
- `Calendar Export`
- `Welcome`
- `Reminders Settings`
- `Insights / Overview`
- `Insights / Trend Detail`
- `Insights / Category Detail`
- `Insights / Usage Detail`
- `Insights / Gap Detail`

## Tab Names (`tab_name`)

- `Notes`
- `Todos`
- `Insights`
