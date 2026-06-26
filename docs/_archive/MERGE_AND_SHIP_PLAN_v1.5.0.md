# Merge & Ship Plan — Notelayer 1.5.0

**Branch:** `prd-navigation-experimental-onboarding-deeplinks`  
**Target:** Merge to `main` → Tag `v1.5.0` → Ship to App Store  
**Status:** Ready for merge

---

## Summary of Changes

**4 Major Features + 3 Build Fixes:**

| # | Feature | Status | Commits | Impact |
|---|---|---|---|---|
| F1 | Hide Notes tab | ✅ Done | 1 | Navigation simplification |
| F2 | Graduate experimental features | ✅ Done | 1 (+2 fixes) | Feature gate removal |
| F3 | Onboarding overhaul (4-step) | ✅ Done | 1 (+1 enhancement) | New user experience |
| F4 | Insights deep links | ✅ Done | 1 (+1 fix) | Analytics→Action bridge |

**Commits on branch:**
```
1dbaa20 Update F3: Don't pre-select categories in task entry
b688b8c Enhance F3: Add category selection chips to task entry screen
7306de1 Fix: Remove incorrect optional binding on categoryIcon
5bec244 Fix: Make setExperimentalFeaturesEnabled a no-op
eb44f79 F4: Make Insights drilldowns actionable with deep links
02272be F3: Overhaul onboarding with 4-step flow
64c5d45 F2: Graduate experimental features to always-on
ee04d00 F1: Hide Notes tab from bottom navigation bar
```

---

## Pre-Merge Checklist

- [ ] All commits reviewed and approved
- [ ] Branch builds cleanly (no warnings)
- [ ] Tested on physical device(s)
  - [ ] iPhone 15 (or latest)
  - [ ] iPhone SE (or smallest available)
  - [ ] iOS 15 (oldest supported)
  - [ ] Light mode & dark mode
- [ ] No regressions in existing features
- [ ] Analytics tracking still working
- [ ] Sync & persistence working

---

## Merge Strategy

### Option A: Squash Merge (Recommended)
**Pros:** Clean history, single commit on main  
**Cons:** Loses individual feature commits

```bash
git checkout main
git pull origin main
git merge --squash prd-navigation-experimental-onboarding-deeplinks
git commit -m "v1.5.0: Navigation simplification, feature graduation, onboarding overhaul, insights deep links

Features:
- F1: Hide Notes tab from bottom navigation
- F2: Graduate experimental features to always-on (remove feature gate)
- F3: Redesigned onboarding with 4-step Duolingo/Noom-inspired flow
- F4: Make Insights drilldowns actionable with deep links to To-Dos

Includes:
- Category selection chips in task entry
- Removed experimental features toggle
- Simplified RootTabsView logic
- Actionable Insights: tap categories/tasks to jump to To-Dos

Breaking changes:
- Notes tab removed from navigation (code preserved)
- Experimental Features toggle removed (all features now standard)

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
```

### Option B: Rebase & Merge
**Pros:** Preserves individual commits  
**Cons:** More cluttered history

```bash
git checkout main
git pull origin main
git rebase --interactive origin/main prd-navigation-experimental-onboarding-deeplinks
# Clean up commit messages if needed
git merge --ff-only prd-navigation-experimental-onboarding-deeplinks
```

### Recommended: Option A (Squash)
**Reason:** These 8 commits represent one cohesive feature release. A single squashed commit on main tells a cleaner story.

---

## Post-Merge Steps

### 1. Create Release Tag
```bash
git tag -a v1.5.0 -m "Release v1.5.0: Navigation simplification and onboarding overhaul"
git push origin v1.5.0
```

### 2. Update CHANGELOG
- Add 1.5.0 section at top of `CHANGELOG.md`
- Copy content from `RELEASE_NOTES_v1.5.0.md`
- Commit as: `chore: Update CHANGELOG for v1.5.0`

### 3. Update Version in Xcode
- Set `MARKETING_VERSION` to `1.5.0`
- Increment `CURRENT_PROJECT_VERSION` (e.g., 42 → 43)
- Commit as: `chore: Bump version to 1.5.0 (build 43)`

### 4. Create Release in GitHub
```bash
# Navigate to GitHub repo
# Go to Releases → Create new release
# Tag: v1.5.0
# Title: Notelayer 1.5.0 — Navigation Simplification & Onboarding Overhaul
# Description: (copy from RELEASE_NOTES_v1.5.0.md)
```

---

## Testing After Merge

- [ ] Clean build from main branch
- [ ] Run full testing cycle (see APP_STORE_LAUNCH_CHECKLIST_v1.5.0.md)
- [ ] Verify no merge conflicts
- [ ] Confirm CI/CD pipeline passes

---

## App Store Submission

1. Follow **APP_STORE_LAUNCH_CHECKLIST_v1.5.0.md**
2. Build & archive from main (tag v1.5.0)
3. Upload to App Store Connect
4. Add release notes
5. Submit for review

---

## Rollback Plan (If Needed)

If critical issue discovered after merge but before App Store submission:

```bash
# Revert the merge commit
git revert -m 1 <merge-commit-hash>
git push origin main

# Fix issue in new branch
git checkout -b hotfix/1.5.0
# ... make fixes ...
git push origin hotfix/1.5.0

# Create PR for hotfix
# Merge hotfix to main
# Re-tag and resubmit to App Store
```

---

## Team Responsibilities

| Task | Owner | Due |
|---|---|---|
| Code review | [Code Reviewer] | Before merge |
| QA testing | [QA Lead] | Before merge |
| Version bumping | [Release Manager] | After merge |
| App Store submission | [Release Manager] | [Date] |
| Social announcement | [Marketing] | [Date] |

---

## Communication Plan

### Internal
- [ ] Slack announcement: "Merging 1.5.0 to main"
- [ ] Slack announcement: "1.5.0 submitted to App Store"
- [ ] Slack announcement: "1.5.0 approved and releasing"

### External
- [ ] Blog post (optional)
- [ ] Email to beta testers
- [ ] Social media announcement (Twitter, etc.)

---

## Success Criteria

✅ All tests passing  
✅ No App Store review rejections  
✅ App Store approval within 48 hours  
✅ 0 critical bugs in first 24 hours post-release  
✅ Positive user sentiment in reviews  

---

**Last Updated:** 2026-06-06  
**Status:** Ready for merge approval
