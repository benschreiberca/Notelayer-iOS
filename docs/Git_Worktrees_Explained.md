# Git Worktrees — Explained 6 Ways

**Created:** 2026-06-24
**Context:** Written for Notelayer multiplatform planning (PRD 09), but applies generally.

---

## Part 1: What Are Git Worktrees?

### As a Beginner Product Manager

Think of your codebase like a Word document. With normal branches you can only have one "draft" open at a time — you switch between them. A worktree is like printing out two copies and working on them side-by-side simultaneously. One copy stays open showing the working iOS app; another copy has Mac development happening next to it. When done, you staple the changes back together.

For Notelayer, this means the iOS app stays testable in Xcode while Mac and Watch work happens in separate folders, all from the same codebase. Nothing gets interrupted. Nothing gets lost.

---

### As an Intermediate Product Manager

A branch is a pointer to a line of development in one shared working directory — you `checkout` to switch context, which interrupts whatever you were doing. A worktree checks out a *different* branch into a *different* folder on disk, simultaneously, from the same repository.

In product terms: you can run regression tests on the shipping iOS branch in one Xcode window while a developer builds the Mac target in a second window — both from the same git history, neither stepping on the other. No stashing, no context switches.

The real benefit beyond convenience: it forces you to think clearly about **what is truly parallel vs. what has a dependency order**. A worktree for the Mac target won't compile until the shared `NotelayerKit` extraction lands. That's coordination made visible at the tooling level — which is exactly the governance discipline a multiplatform program needs.

---

### As an Expert Product Manager

Worktrees are a force-multiplier for parallel delivery streams with shared history and a common merge target. Each worktree is an independent working directory with its own `HEAD`, but all share the same object store — no repo duplication, no divergent object graphs.

The strategic property: you can keep a green iOS CI build artifact while the Mac target is in a broken intermediate state. Two streams, one repo, zero interference.

The governance implication is important: **worktrees don't eliminate coordination costs — they relocate them to rebase points**, which is where they belong. The critical dependency (shared library extraction before platform divergence) is enforced by the tooling, not by a process document. That's the difference between coordination that scales and coordination that relies on people remembering.

For a program like PRD 09, the sequencing rule becomes self-enforcing: you literally cannot compile the Mac worktree against an unextracted shared package. The architecture makes the dependency visible.

---

## Part 2: As a Developer

### As a Beginner Developer

You know `git branch` and `git checkout`. Normally you can only have one branch checked out at a time — one set of files on disk. `git worktree add` lets you have multiple branches checked out in multiple folders simultaneously from one repo:

```bash
# Your main iOS work stays here:
/Notelayer-iOS/                   ← main or feature/multiplatform

# Mac work in a parallel folder:
git worktree add ../nl-mac feature/mp-mac

# Watch work in another:
git worktree add ../nl-watch feature/mp-watch
```

Now `../nl-mac` has the `feature/mp-mac` branch checked out. You can open it in a second Xcode window. Changes you commit there don't touch your iOS working directory. Both share the same `.git` folder — git tracks them all.

To see all your worktrees:
```bash
git worktree list
```

To clean one up when you're done:
```bash
git worktree remove ../nl-mac
```

That's it. Same git, different folders, different branches, all at once.

---

### As an Intermediate Developer

Worktrees share one object store but have independent index, `HEAD`, and working tree. A few mechanics worth knowing for an Xcode project:

**Derived data isolation.** Xcode scopes derived data by working-directory path. Two worktrees at `../nl-ios` and `../nl-mac` get independent build caches automatically. Your iOS build cache won't corrupt when you're doing experimental `xcodebuild` work in the Mac worktree.

**CocoaPods is path-relative.** Each worktree needs its own `pod install` run because `Pods/` is resolved relative to the working directory. This is annoying but manageable. It's also one of the reasons the SPM migration is recommended — SPM's package cache is global and path-independent, so all worktrees share it.

**Branch exclusivity.** Git enforces that the same branch can't be checked out in two worktrees at once. If `feature/mp-mac` is checked out in `../nl-mac`, trying to check it out elsewhere will error. This is a feature — it prevents accidental divergence.

**Rebase workflow.** The sequencing matters more than the parallelism:

1. `mp-core-extraction` lands into `feature/multiplatform` first.
2. `feature/mp-mac`, `feature/mp-watch`, and `feature/mp-app-intents` all rebase onto `feature/multiplatform` before diverging further.
3. Each stream then develops independently in its worktree.
4. Each stream PRs back into `feature/multiplatform` when ready.

Worktrees make this easy — you rebase in the correct worktree without juggling stashes or losing work.

**The recommended setup for PRD 09:**
```bash
git worktree add ../nl-core feature/mp-core-extraction   # must land first
git worktree add ../nl-mac feature/mp-mac                # rebases on nl-core
git worktree add ../nl-watch feature/mp-watch            # rebases on nl-core
git worktree add ../nl-intents feature/mp-app-intents    # rebases on nl-core
```

---

### As an Expert Developer

The core invariant: a worktree is a fully isolated `GIT_INDEX_FILE` + `GIT_WORK_TREE` bound to a shared `GIT_OBJECT_DIRECTORY`. This gives you:

- No `.git/index` race conditions between parallel streams.
- Correct `git stash` scoping — stashes are per-worktree, not per-repo.
- Independent `git bisect` state — you can bisect a platform-specific regression in one worktree while the other streams continue.
- Independent `MERGE_HEAD`, `CHERRY_PICK_HEAD`, `REBASE_HEAD` — mid-operation state is isolated.

**The highest-risk coordination point for this Xcode project:** `project.pbxproj` is version-controlled and shared across all worktrees via the object store. Adding a new target (Mac app, Watch app) in *any* worktree makes that change immediately visible in all others on next fetch/merge. This means:

> **Target additions must be done on the integration branch and rebased onto — never done in parallel across worktrees.** If two worktrees independently add targets to `project.pbxproj`, the merge conflict is brutal (GUID-keyed plists don't diff cleanly).

The same applies to `Podfile.lock` — if one worktree changes Firebase SDK versions, all others diverge on next `pod install`. SPM eliminates this entirely since the `Package.resolved` file conflicts are readable and the package cache is global.

**Derived data path hashing.** Xcode resolves derived data by hashing `DTPlatformName` + absolute build path. Two worktrees at different absolute paths with the same project = independent derived data directories. Simulator cache is shared (at `~/Library/Developer/CoreSimulator`) but that's intentional and correct.

**Object pack sharing.** All worktrees share pack files. A `git gc` in any worktree compacts objects for all of them. A `git fetch` in any worktree makes new remote objects available in all of them immediately (no re-fetch needed in each worktree — just `git merge` or `git rebase` in the target worktree).

**Detached HEAD worktrees.** You can create a worktree in detached HEAD state for read-only reference (e.g., keep `main` checked out for comparison while developing on a feature branch):
```bash
git worktree add --detach ../nl-reference HEAD
```

---

## Part 3: Worktrees vs. Branches — What's Right for Notelayer, and the One-Repo Question

### Worktrees vs. Branches — Use Worktrees

For this specific project, worktrees are the right choice. Here's the reasoning:

The Mac, Watch, and Intents streams are **genuinely parallel** after the `NotelayerKit` extraction lands. All three need different Xcode targets open simultaneously, and all three are built and tested independently. Without worktrees you spend your time doing this:

```
stash iOS changes →
checkout mp-mac →
pod install →
open Xcode →
... work ...
checkout iOS again →
pod install again →
pop stash →
... repeat 10x per day
```

With worktrees you keep iOS green and open in one Xcode window and develop Mac in another. No switching, no stashing, no reinstalling pods.

**The one constraint:** `project.pbxproj` is shared. Adding new targets (the Mac app target, the Watch app target) must happen on the integration branch, not in parallel worktrees. Do it once, rebase everyone onto it, then let the streams diverge.

**When branches alone are better:** If you're doing short-lived solo work where you genuinely only need one thing open at a time, plain branches are simpler. Worktrees add directory management overhead that isn't worth it for a 2-day fix. The break-even point is roughly: "will I need more than one Xcode window open simultaneously, for more than a week?" If yes, worktrees.

---

### One Repo or Multiple Repos?

**One repo. This is not a close call for Notelayer.**

Here's the test: do the platforms share core logic?

- Data model (`Models.swift`) — shared entirely.
- Backend and sync (`FirebaseBackendService`, `LocalStore`) — shared entirely.
- Design system (`DesignSystem.swift`, `ThemeManager.swift`) — shared entirely, that's the whole point.
- Firebase project — the same one.
- Versioning — Watch ships alongside iOS; Mac uses the same Firebase backend.
- Team size — one person, possibly a small team.

Every one of those points to a single repo. Multi-repo is for:

- Truly independent products or organizations sharing a library.
- Open-source library separation (e.g., extracting `NotelayerKit` as a public package — possible later, not now).
- Radically different CI/CD pipelines with no shared code at all.

None of those apply here.

**Practically**, a single repo means:

- A single PR can carry a shared-layer change *and* all its platform consumers together. Reviewers see the full picture.
- One place to file issues, one PR history, one `git log`.
- `feature/multiplatform` as a long-lived integration branch off `main` — all platform streams merge there, and `main` only receives merges from integration when a milestone is shippable.
- TestFlight / Mac App Store / Watch App distribution are all cut from the same `main`.

**If `NotelayerKit` ever becomes a public library** (shared with other developers), extract it to its own repo at that point via `git subtree` or `git filter-repo`. Don't do it speculatively now.

---

### The Full Branch + Worktree Map for PRD 09

```
main                              ← always shippable; never develop directly
│
└── feature/multiplatform         ← long-lived integration branch
    │                                all streams merge here; merges to main at milestones
    │
    ├── feature/mp-core-extraction   ← Wave 1: NotelayerKit extraction
    │   (worktree: ../nl-core)          Must land FIRST. Everyone rebases on this.
    │
    ├── feature/mp-app-intents        ← Wave 2: App Intents / Siri
    │   (worktree: ../nl-intents)       Depends on nl-core.
    │
    ├── feature/mp-mac                ← Wave 3: Mac target
    │   (worktree: ../nl-mac)           Depends on nl-core.
    │
    └── feature/mp-watch              ← Wave 4: Watch target
        (worktree: ../nl-watch)         Depends on nl-core.
```

**Sequencing rule (enforce this before any coding):**
1. `mp-core-extraction` merges to `feature/multiplatform` first.
2. All other streams rebase onto `feature/multiplatform` before diverging.
3. Target additions (`project.pbxproj` changes) happen on `feature/multiplatform` directly.
4. `feature/multiplatform` → `main` only when a milestone is release-ready.

The sequencing matters more than the parallelism. Violating step 1 means massive merge conflicts when the extraction finally lands. Worktrees make the dependency visible — the Mac worktree literally won't build until `NotelayerKit` exists.

---

*Related: `docs/PRD_09_Mac_And_Watch_Multiplatform.md` — the full multiplatform PRD this was written alongside.*
