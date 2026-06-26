# PRD 08: Project-Based Tasks (Parent To Subtasks)

Last Updated: 2026-02-11
Status: Locked
Feature Area: Task Hierarchy

## Purpose

Introduce parent-to-subtask hierarchy to represent projects with multiple steps, addressing the current flat task model limitation.

## Problem Statement

All tasks are currently individual items with no internal step structure, making multi-step project tracking difficult.

## Goals

- Add a parent task model that can contain subtasks.
- Allow users to represent project steps under one parent.
- Keep clear distinction:
- Categories are grouping labels.
- Parent/subtasks are structural hierarchy.

## Non-Goals

- No timeline or deadline system defined in this PRD.
- No broader "Projects" product concept beyond parent/subtask structure.

## In Scope

- Parent task container behavior.
- Subtask relationship and representation.
- Hierarchy semantics relative to existing category grouping.

## Out Of Scope

- Gantt/timeline planning.
- Complex portfolio/project management features.
- New scheduling engines.

## Key Requirements (Draft)

1. Parent tasks can contain constituent subtasks.
2. Subtasks represent steps within a project-oriented task.
3. Hierarchy is structural, not a replacement for categories.
4. Feature solves inability to model multi-step work in a flat list.
5. Project-based tasks UI visibility is controlled by `Enable Experimental Features`.

## Decisions Locked (2026-02-11)

- v1 hierarchy depth is one level only: parent -> subtasks.
- Nested subtasks are out of scope in v1.
- Parent completion is auto-complete when all subtasks are complete, with manual reopen override.
- Parent deletion behavior prompts:
- delete parent + subtasks,
- detach subtasks to standalone tasks,
- cancel.
- Subtask detach/re-parent is allowed through edit controls.
- Category behavior:
- parent and subtasks can each have categories,
- subtasks inherit parent categories by default at creation.
- Count semantics in task totals:
- count parents + standalone tasks,
- do not count subtasks in top-level totals.
- Default list behavior: parent rows collapsed with subtask count chip.
- Reminders/calendar in v1 apply to both parent and subtasks independently.

## Dependencies

- May require migration strategy from flat tasks to optional hierarchical tasks.
- Could intersect with share ingestion (`PRD_07`) and voice capture output (`PRD_04`/`PRD_05`) in future phases.
- UI visibility for this feature is gated by `PRD_01`.

## Risks

- Hierarchy semantics can become confusing if completion rules are unclear.
- Existing task views may become cluttered without clear display rules.
- Migration from flat-only model can create edge cases for existing users.

## Open Questions

None.

## Acceptance Signals (Requirement Clarity Only)

- Hierarchy semantics are explicit enough to avoid contradictory implementations.
- Parent/subtask completion and deletion rules are unambiguous.
- Categories versus structure distinction is testable in product behavior.
