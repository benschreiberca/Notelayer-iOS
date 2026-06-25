# /nl-explore — New Lab Exploration

Create a new exploration document. Ask me for the topic name, then create the file at:

`docs/lab/EXPLORE_[YYYY_MM_DD]_[topic-slug].md`

Also add an entry to `docs/lab/LAB_INDEX.md`.

**Rule**: Lab docs stay on a feature branch. They only merge to `main` when promoted to a real PRD. Never merge a lab doc to main alone.

---

## Template

```md
# Exploration: [Topic Name]

**Created:** [DATE]
**Status:** Exploring | Parked | Promoted to PRD [NUMBER] | Dropped
**Scope:** [platforms or areas this touches]
**Branch:** explore/[topic-slug]

---

## What I'm exploring

Free-form. What's the idea? What triggered this?

## What I've tried / found

Notes as you go. No need for polish.

## Open questions

- Question 1
- Question 2

## Decision

When you're done: promote to PRD, park, or drop. Update LAB_INDEX.md.

## References

- Related PRDs:
- Related code files:
- Figma / design files: docs/lab/explorations/
```
