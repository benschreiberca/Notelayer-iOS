# /nl-prd — New PRD Template

Create a new PRD document using the template below. Ask me for the PRD number and feature name before generating, then create the file at:

`docs/product/PRD_[NUMBER]_[FEATURE_NAME].md`

Also update `docs/product/PRODUCT_OVERVIEW.md` to add the new PRD to the index.

---

## Template

```md
# PRD [NUMBER]: [Feature Name]

**Last Updated:** [DATE]
**Status:** Draft | Locked | Shipped | Archived
**Scope:** iPhone | Mac | Watch | iPad | All Platforms
**Group:** Product
**Tags:** [feature-area, platform]
**Related:** [other docs]

---

## Purpose

One paragraph. What problem does this solve?

## Goals

- Bullet list of outcomes, not features.

## Non-Goals

- What is explicitly out of scope.

## In Scope

- Feature list with enough detail to implement.

## Open Decisions (lock before coding)

| # | Decision | Options | Resolved? |
|---|---------|---------|-----------|
| 1 | | | ❌ |

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Implementation Notes

Key technical constraints or patterns to follow.

## Status

| Item | Status |
|------|--------|
| Design | Not started |
| iOS | Not started |
| Mac | Not started |
| Watch | Not started |
```
