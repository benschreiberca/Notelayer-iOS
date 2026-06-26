---
title: Git Strategy
last_updated: 2026-06-25
status: active
scope: all-platforms
group: architecture
tags: [git, branches, worktrees, multiplatform]
related: [DEVELOPMENT_SETUP.md]
---

# Git Strategy

Branch strategy, worktree setup, and sequencing rules for Notelayer development. Especially relevant for multiplatform (Mac + Watch) work.

For the full worktree explanation (6 levels from beginner to expert), see the extended guide in `_archive/Git_Worktrees_Explained.md`.

---

## Branch Map

```
main                          ← always shippable; never develop directly
│
├── docs/audit                ← doc consolidation (merge soon)
│
└── feature/multiplatform     ← long-lived integration branch (when Mac work starts)
    ├── feature/mp-core-extraction   ← Wave 1: NotelayerKit + SPM migration
    ├── feature/mp-mac               ← Wave 3: Mac target
    ├── feature/mp-watch             ← Wave 4: Watch target
    └── feature/mp-app-intents       ← Wave 3: Siri / App Intents
```

Feature branches → PR → `main`. For multiplatform: feature branches → `feature/multiplatform` → `main` at milestones.

---

## Three Sizes of Branch

| Size | Branch prefix | Example | Doc system? |
|------|--------------|---------|------------|
| Bug / tweak | `fix/` | `fix/reminder-fires-twice` | No — just fix it |
| Exploration | `explore/` | `explore/watch-complication` | Yes — `/nl-explore` |
| Feature | `feature/` | `feature/subtask-ui` | Yes — PRD + FEATURE_INVENTORY |

---

## Push vs Pull Request

**Push** = upload commits to GitHub. Your branch only. Nothing merges.
```bash
git push -u origin fix/my-bug
```

**Pull Request** = request to merge your branch into main (or integration branch). One per feature/fix.

You push many times. You open one PR at the end when the work is done.

---

## Worktrees for Multiplatform

Worktrees let you have multiple branches checked out simultaneously in separate folders. Required for Mac + Watch development where you need both iOS and Mac Xcode windows open at the same time.

```bash
# Setup for multiplatform development
git worktree add ../nl-core feature/mp-core-extraction   # must land first
git worktree add ../nl-mac feature/mp-mac                # after core
git worktree add ../nl-watch feature/mp-watch            # after core

# See all worktrees
git worktree list

# Remove when done
git worktree remove ../nl-mac
```

**Critical constraint:** `project.pbxproj` is shared across all worktrees. Target additions (Mac app target, Watch app target) must be done on the integration branch and rebased onto — never added in parallel in two worktrees. Parallel `pbxproj` edits create brutal merge conflicts.

**CocoaPods + worktrees:** CocoaPods is path-relative; each worktree needs its own `pod install`. This is why SPM migration (Wave 1 of PRD 09) must happen before worktrees are used for multiplatform development.

---

## Multiplatform Sequencing (Enforce Before Coding)

1. `mp-core-extraction` merges to `feature/multiplatform` first — NotelayerKit extracted, SPM migration done
2. All other streams rebase onto `feature/multiplatform` before diverging
3. Target additions happen on `feature/multiplatform` directly
4. `feature/multiplatform` → `main` only when a milestone is release-ready

Violating step 1 means massive merge conflicts when extraction finally lands.

---

## Commit Message Convention

```
type(scope): short description

types: feat, fix, docs, refactor, test, chore
scope: optional — component or area affected

Examples:
feat(todos): add bulk category update
fix(reminders): prevent double notification on reschedule
docs(design-system): update DS_TOKENS with new radius values
```

---

## CLAUDE.md Branch Tracking

Update the "Active Branches / Worktrees" table in `CLAUDE.md` when new worktrees or long-lived branches are created. This keeps agents oriented across sessions.
