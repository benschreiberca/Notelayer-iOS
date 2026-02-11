# PRD 08: Project-Based Tasks (Parent To Subtasks)

Last Updated: 2026-02-10
Status: Draft For Clarification
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

## Dependencies

- May require migration strategy from flat tasks to optional hierarchical tasks.
- Could intersect with share ingestion (`PRD_07`) and voice capture output (`PRD_04`/`PRD_05`) in future phases.
- UI visibility for this feature is gated by `PRD_01`.

## Risks And Unknowns

- Hierarchy semantics can become confusing if completion rules are unclear.
- Existing task views may become cluttered without clear display rules.
- Migration from flat-only model can create edge cases for existing users.

## High-Level Clarification Questions

1. Should v1 hierarchy depth be exactly one level (parent -> subtasks only)?
2. Can a subtask itself have subtasks, or is that explicitly out of scope?
3. How should parent completion work: manual only, auto when all subtasks done, or both?
4. Can subtasks exist without a parent after creation (detach behavior)?
5. Should existing standalone tasks be convertible into parent tasks?
6. How should categories apply: on parent only, subtasks only, or independently on both?
7. What reordering behavior is expected within and across parent groups?
8. How should counts in current task views treat parent and subtasks to avoid double counting?
9. What is the expected behavior when parent is deleted: cascade delete, orphan subtasks, or prompt?
10. Should reminders/calendar integrations apply at parent, subtask, or both levels in v1?
11. What default expanded/collapsed behavior should hierarchy use in task lists?
12. What is the minimum viable UX that proves hierarchy solves the flat-model pain point?

## Acceptance Signals (Requirement Clarity Only)

- Hierarchy semantics are explicit enough to avoid contradictory implementations.
- Parent/subtask completion and deletion rules are unambiguous.
- Categories versus structure distinction is testable in product behavior.
