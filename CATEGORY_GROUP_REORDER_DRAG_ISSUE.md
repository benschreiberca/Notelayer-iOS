# Issue: Category Group Drag Reorder Not Working

## TL;DR
Category group headers do not reorder on drag, show no divider drop indicator, and require a longer long‑press than task drag. The entire header row is not reliably draggable. Same issue occurs in Manage Categories.

## Current Behavior
- Category tab:
  - Long‑press works only when holding the header title area, not the full header row.
  - Long‑press duration feels longer than task drag.
  - No drop divider line appears, and group reordering does not happen.
- Manage Categories:
  - Long‑press triggers but no divider line and no functional reorder.

## Expected Behavior
- Entire header row (icon/title/count/chevron width) is draggable.
- Long‑press timing matches task drag.
- Standard iOS divider drop indicator appears while dragging.
- Dragging reorders groups in both Category tab and Manage Categories.

## Repro Steps
1. Open Todos → Category tab.
2. Long‑press and drag a category group header.
3. Observe drag does not reorder and no divider line appears.
4. Open Manage Categories.
5. Long‑press and drag a category row.
6. Observe the same missing divider line and no reorder.

## Relevant Files (Top 3)
- ios-swift/Notelayer/Notelayer/Views/TodosView.swift
- ios-swift/Notelayer/Notelayer/Views/CategoryManagerView.swift
- ios-swift/Notelayer/Notelayer/Views/Shared/CategoryGroupDragPayload.swift

## Labels
- Type: bug
- Priority: normal
- Effort: medium

## Notes / Risks
- Ensure header drag gesture doesn’t conflict with task drag.
- May need to adjust gesture precedence and drag activation timing to match task drag.
- Drop indicator may require different drop target configuration to display.
