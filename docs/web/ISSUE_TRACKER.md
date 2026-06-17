# Notelayer Chrome Extension — Issue Tracker

**Branch:** `claude/notelayer-chrome-extension-0pwV8`
**Last Updated:** 2026-06-17

---

## Status Key
- ✅ Done — fixed and pushed
- ⚠️ Partial — partially addressed; gaps remain
- 🔴 Active — confirmed root cause, fix in progress
- ❌ Not started
- 🔧 Requires user action (console/account config, not code)

---

## Issues from Initial Screenshot Review

| # | Issue | Status | Notes |
|---|---|---|---|
| 1 | "Continue with Google" does nothing | ✅ | Replaced chrome.identity with offscreen+hosted web auth flow |
| 2 | No "Sign in with Apple" button | ✅ | Added Apple button; backend config needed (see AUTH_SETUP.md) |
| 3 | Onboarding flow not appropriate for existing users | ✅ | Existing iOS users (have categories) skip onboarding entirely |
| 4 | "Invalid Date" on all tasks | ✅ | iOS stores dueDate as Firestore Timestamp; web now normalizes on read |
| 5 | Done tasks not syncing | ✅ | iOS uses `completedAt` field, not `isCompleted` boolean; mapping added |
| 6 | Categories not showing on tasks / not syncing | 🔴 | Two bugs: (a) iOS uses `"order"` not `"orderIndex"` → web query excludes all iOS categories; (b) iOS doesn't store `"id"` field in category data (doc ID is the ID) → web lookup returns undefined |
| 7 | No theme customization in menu | ❌ | |
| 8 | Font looks different | ⚠️ | Tokens updated to iOS scale; Space Grotesk/Work Sans load via Google Fonts CDN — if extension CSP blocks it, will fall back to system font |
| 9 | No sub-categories in List/Priority/Category views | ❌ | Subtask (`parentTaskId`) rendering not implemented |
| 10 | Notes as global bottom tab (wrong) | ✅ | Removed from tab bar; now opens as full overlay from To-Dos header icon |
| 11 | No task entry on Priority/Category/Date views | ✅ | FAB (+) added; tapping opens quick-add sheet |
| 12 | Insights has wrong structure / no double-click | ❌ | InsightsView needs full rewrite to match iOS |
| 13 | Insights not accurate / not synced with iOS | ❌ | Insights computed from tasks data; needs review of aggregation logic |
| 14 | OAuth popup shows "notelayer-c7bba" (unprofessional) | 🔧 | Fix: Google Cloud Console → APIs & Services → OAuth consent screen → change App name to "Notelayer" |

---

## Issues from Second Review (current session)

| # | Issue | Status | Notes |
|---|---|---|---|
| 15 | Categories not available per task / not syncing | 🔴 | Same root cause as #6 — being fixed now |
| 16 | Section headers are not collapsible (forces scrolling) | ❌ | GroupHeader needs expand/collapse toggle + state per group |
| 17 | Add task not available in group headers/subheaders | ❌ | Each group header should have an inline add affordance |
| 18 | No theming (accent colour / wallpaper picker) | ❌ | Need a ThemeSheet component; save to chrome.storage.local |
| 19 | Many features missing: calendar sync, voice, reminders, web capture | ❌ | Phase 3–6 in build order (PRD_09) |

---

## Future Phase Features (not bugs)

| Feature | Phase | Status |
|---|---|---|
| Right-click / text-selection web capture | 3 | ❌ |
| Web Push reminders | 4 | ❌ |
| Google Calendar sync | 5 | ❌ |
| Apple Calendar `.ics` feed | 5 | ❌ |
| Voice capture (Web Speech API) | 6 | ❌ |
| Full settings + theme sync | 7 | ❌ |
| Chrome Web Store publish | 8 | ❌ |

---

## What's Working

- Google sign-in (offscreen + Firebase hosted popup) ✅
- Firestore real-time sync — tasks appear within seconds ✅
- Doing/Done toggle (iOS three-part layout) ✅
- 4 lens views: List / Priority / Category / Date ✅
- Task creation (List view input + FAB on other views) ✅
- Task edit sheet ✅
- Category manager ✅
- Notes view (overlay, not bottom tab) ✅
- Indigo theming + iOS design tokens ✅
- Iridescent gradient background ✅
- FAB for task entry on non-list views ✅
