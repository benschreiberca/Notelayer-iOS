---
title: Release Checklist
last_updated: 2026-06-26
status: active
scope: notelayer-ios
group: operations
tags: [release, checklist, app-store, testflight]
related: [CI_AND_DISTRIBUTION.md, APP_STORE_ASSETS.md, RELEASES.md]
---

# Release Checklist

Template checklist for every iOS release. Copy this list into the release PR or a release tracking note; check off as you go.

---

## Code & Build

- [ ] All feature commits merged to `main`
- [ ] Version number updated in Xcode (Marketing Version + Build Number)
- [ ] `Info.plist` marketing version matches
- [ ] Clean build: `xcodebuild -scheme Notelayer build` — no errors
- [ ] No compiler warnings (treat warnings as blockers)
- [ ] Archive builds successfully for distribution

---

## Testing — Physical Device

- [ ] Fresh install: onboarding auto-triggers on first launch
- [ ] All 4 onboarding steps complete without crash
- [ ] Task creation works (title, category, priority, due date)
- [ ] Task persists after app background/foreground
- [ ] Todos tab — Doing/Done toggle works
- [ ] Insights tab loads and shows data
- [ ] Category rows in Insights tap → jump to Todos category view
- [ ] Oldest task rows in Insights tap → open task editor
- [ ] Gear menu → Onboarding Guide replays flow
- [ ] Light mode: no visual glitches
- [ ] Dark mode: no visual glitches
- [ ] Smooth scroll throughout (no jank)
- [ ] No crashes during 10-minute typical use session
- [ ] Share extension: share plain text from Safari → task created
- [ ] Background sync: task created on one device shows on another

---

## Auth Checklist (any release touching auth)

- [ ] Tap Apple Sign-In immediately on sheet appear — no crash
- [ ] Tap Google Sign-In immediately on sheet appear — no crash
- [ ] Rapidly tap both auth buttons — only one flow starts
- [ ] Dismiss sheet during phone verification — graceful
- [ ] Sign in → sign out → sign back in — data preserved
- [ ] Guest mode → sign in — local data merges, no duplication
- [ ] Slow network — loading states show, no timeout crash

---

## Insights Checklist (any release touching Insights)

- [ ] Completion rate matches manual count
- [ ] Category percentages sum to 100%
- [ ] Streak resets after a missed day
- [ ] Oldest tasks sorted oldest-first
- [ ] Most Active Hours reflects actual task times
- [ ] All chart axes have plain-English labels
- [ ] Empty state shows when no data (not blank screen)
- [ ] Drilldown returns to correct parent
- [ ] Bottom clearance correct — last row visible above tab

---

## App Store Connect

- [ ] Version and build number match Xcode archive
- [ ] "What's New" text written (4000 char max) — see `releases/vX.Y.Z/APP_STORE.md`
- [ ] Full description reviewed (4000 char max)
- [ ] Keywords reviewed
- [ ] Screenshots updated if UI changed (see `APP_STORE_ASSETS.md`)
- [ ] Privacy policy URL current
- [ ] Support URL current
- [ ] Age rating correct

---

## Docs

- [ ] `docs/releases/RELEASES.md` — add version row
- [ ] `docs/releases/vX.Y.Z/` folder created with all 4 content files
- [ ] `FEATURE_INVENTORY.md` updated for any changed/added features
- [ ] `CLAUDE.md` updated if any new files or architecture changes

---

## Post-Submit

- [ ] Tag commit: `git tag vX.Y.Z && git push origin vX.Y.Z`
- [ ] TestFlight internal build distributed
- [ ] Confirm build passes Apple review pipeline (automated checks)
- [ ] Monitor Crashlytics for first 24 hours post-release
