---
title: Analytics Events Reference
last_updated: 2026-06-25
status: active
scope: notelayer-ios
group: architecture
tags: [analytics, firebase, events, telemetry]
related: [BACKEND_AND_AUTH.md]
---

# Analytics Events

All Firebase Analytics events and parameters. Events are also mirrored locally into `InsightsTelemetryStore` for the Insights feature.

---

## Navigation & Views

| Event | Measures | Parameters |
|-------|---------|-----------|
| `tab_selected` | User switches tabs | `tab_name`, `previous_tab` |
| `view_open` | Screen/sheet becomes visible | `view_name`, `tab_name`, `source_view` |
| `view_duration` | Time in view before leaving | `view_name`, `duration_s` |

---

## Todos

| Event | Measures | Parameters |
|-------|---------|-----------|
| `todos_filter_changed` | Doing/Done toggle | `showing_done`, `view_name` |

---

## Tasks

| Event | Measures | Parameters |
|-------|---------|-----------|
| `task_created` | Task creation | `priority`, `category_count`, `has_due_date`, `has_reminder`, `category_ids_csv` |
| `task_completed` | Task marked complete | `completion_latency_s`, `category_count`, `priority`, `had_due_date`, `had_reminder`, `category_ids_csv` |
| `task_restored` | Completed task restored | `category_count`, `priority`, `category_ids_csv` |
| `task_deleted` | Task deletion | `has_due_date`, `has_reminder`, `category_count` |
| `task_edited` | Task fields changed | `title_changed`, `categories_changed`, `priority_changed`, `due_date_changed`, `notes_changed` |
| `task_reordered` | List reordered | `task_count` |
| `task_due_date_set` | Due date added | `category_count`, `priority` |
| `task_due_date_cleared` | Due date removed | `category_count`, `priority` |
| `task_reminder_set` | Reminder set | `lead_time_minutes`, `has_due_date`, `category_count`, `category_ids_csv` |
| `task_reminder_cleared` | Reminder cleared | `category_count`, `has_due_date`, `category_ids_csv` |

---

## Categories

| Event | Measures | Parameters |
|-------|---------|-----------|
| `category_created` | Category created | `category_count` |
| `category_renamed` | Name/icon/color changed | `name_changed`, `icon_changed`, `color_changed` |
| `category_deleted` | Category deleted | `reassigned_task_count`, `category_count` |
| `category_reordered` | Categories reordered | `category_count` |
| `category_assigned_to_task` | Categories added/removed from task | `category_count` / `added_count`, `removed_count`, `source_view` |

---

## Reminders & Permissions

| Event | Measures | Parameters |
|-------|---------|-----------|
| `reminder_permission_prompted` | System permission shown | — |
| `reminder_permission_denied` | Permission denied | — |
| `reminder_scheduled` | Reminder scheduled | `lead_time_minutes`, `category_ids_csv` |
| `reminder_cleared` | Reminder cancelled | `category_ids_csv` |

---

## Calendar Export

| Event | Measures | Parameters |
|-------|---------|-----------|
| `calendar_export_initiated` | User starts export | `view_name`, `has_due_date`, `has_reminder`, `task_id`, `category_ids_csv` |
| `calendar_export_permission_denied` | Calendar access denied | `view_name` |
| `calendar_export_presented` | Calendar editor shown | `view_name`, `task_id` |

---

## Insights

| Event | Measures | Parameters |
|-------|---------|-----------|
| `insights_drilldown_opened` | User drills from overview | `view_name`, `tab_name`, `source_view` |

---

## Themes

| Event | Measures | Parameters |
|-------|---------|-----------|
| `theme_changed` | Theme mode/preset/config changed | `change_type` (`mode` \| `preset` \| `configuration`), `mode` or `preset_id` |

---

## Enum Values

### `view_name`

`Notes`, `Todos / List`, `Todos / Priority`, `Todos / Category`, `Todos / Date`, `Task Edit`, `Category Manager`, `Appearance`, `Profile & Settings`, `Reminder Picker`, `Calendar Export`, `Welcome`, `Reminders Settings`, `Insights / Overview`, `Insights / Trend Detail`, `Insights / Category Detail`, `Insights / Usage Detail`, `Insights / Gap Detail`

### `tab_name`

`Notes`, `Todos`, `Insights`

> Note: `Notes` tab is hidden in v1.5.0 (`visibleTabs = [.todos, .insights]`) but the event values are preserved in case the tab is re-surfaced.
