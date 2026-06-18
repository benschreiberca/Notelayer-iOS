# Notelayer Chrome Extension — Issue Tracker

**Branch:** `claude/notelayer-chrome-extension-0pwV8`
**Last Updated:** 2026-06-18

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
| 4 | "Invalid Date" on all tasks | ✅ | iOS stores dueDate as Firestore Timestamp; web now normalizes on read via `tsToString()` |
| 5 | Done tasks not syncing | ✅ | iOS uses `completedAt` Timestamp (absent = incomplete); mapped in both directions |
| 6 | Categories not showing on tasks / not syncing | ✅ | Fixed: (a) removed `orderBy("orderIndex")` — iOS uses `"order"` field; (b) `normalizeCategory()` now uses `snap.id` not `data.id` |
| 7 | No theme customization in menu | ✅ | ThemeSheet with 7 accent presets; saved to chrome.storage.local; menu item wired |
| 8 | Font looks different | ✅ | Space Grotesk / Work Sans via Google Fonts; manifest CSP allows `fonts.googleapis.com` + `fonts.gstatic.com` |
| 9 | No subtasks in List view | ✅ | TaskRow shows subtask count badge + expand toggle; collapsed subtasks render indented below parent |
| 10 | Notes as global bottom tab (wrong) | ✅ | Removed from tab bar; opens as full-screen overlay from To-Dos header icon |
| 11 | No task entry on Priority/Category/Date views | ✅ | FAB (+) shown on non-list views; tapping opens quick-add sheet |
| 12 | Insights has wrong structure | ✅ | Restructured to single scrollable page: stat cards → open task snapshot → activity chart → category breakdown → oldest tasks |
| 13 | Insights not accurate / not synced with iOS | ✅ | Aggregation uses normalized Firestore data (Timestamps converted, completedAt mapped); all task data is live Firestore |
| 14 | OAuth popup shows "notelayer-c7bba" (unprofessional) | 🔧 | Fix: Google Cloud Console → OAuth consent screen → change App name to "Notelayer" |

---

## Issues from Second Review

| # | Issue | Status | Notes |
|---|---|---|---|
| 15 | Categories not available per task / not syncing | ✅ | Same root cause as #6 — fixed in `firestore.ts` `normalizeCategory()` |
| 16 | Section headers not collapsible | ✅ | GroupHeader renders as `<button>` with animated chevron; per-group collapse state in TodosView |
| 17 | Add task not available in non-list views | ✅ | FAB (floating +) on Priority / Category / Date views opens bottom-sheet task input |
| 18 | No theming | ✅ | ThemeSheet component with 7 accent colours; persisted in chrome.storage.local; applied to CSS custom properties |
| 19 | Calendar sync, voice, reminders, web capture | ❌ | Phase 3–6 in build order (PRD_09) |

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
- Real-time Firestore sync — tasks appear within seconds, full iOS data compatibility ✅
- Doing/Done toggle (iOS three-part layout) ✅
- 4 lens views: List / Priority / Category / Date ✅
- Collapsible group headers on Priority / Category / Date views ✅
- Subtask expand/collapse in List view ✅
- Task creation: List view inline input + FAB sheet on other views ✅
- Task edit sheet ✅
- Category manager ✅
- Notes view (overlay, not bottom tab) ✅
- Theme picker: 7 accent colours, persisted across sessions ✅
- iOS design tokens: Space Grotesk / Work Sans fonts, indigo400 accent, gray900 bg ✅
- Iridescent gradient background ✅
- Insights: stat cards, activity chart, category breakdown, oldest tasks ✅
