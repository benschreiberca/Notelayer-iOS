# PRD 09: Notelayer Web App & Chrome Extension

Last Updated: 2026-06-11
Status: In Planning
Feature Area: Cross-Platform Expansion

---

## Purpose

Extend Notelayer beyond iOS to the web and Chrome — giving users full access to their tasks and notes from any browser, with a Chrome extension that enables capture from any webpage.

---

## Problem Statement

Notelayer's task and note data lives in Firestore and is already accessible from any platform, but there is no web or desktop client. Users working in a browser have no way to view, create, or manage their tasks without switching to their iPhone. There is no capture path from web content (articles, emails, pages) into Notelayer.

---

## Goals

- Full task and note management from any browser, with real-time sync to the iOS app.
- Fast capture from any webpage via Chrome Side Panel, right-click menu, and text selection.
- Calendar integration (Google Calendar, Apple Calendar) for tasks with due dates.
- No new backend — use the same Firestore project as the iOS app.

---

## Non-Goals

- A separate native Android or desktop app (the webapp covers these platforms).
- Phone number authentication (APNS dependency, iOS-only).
- Native haptics or iOS-specific UI patterns.
- Wallpaper image upload (deferred).

---

## Architecture

The Chrome extension is a **shell** — it loads the webapp inside Chrome's Side Panel. There is no duplicate logic between the extension and the webapp. All Firebase auth, Firestore sync, and UI lives in the webapp.

```
Webapp (React + Firebase)
  ↕ Firestore real-time sync
iOS App (SwiftUI + Firebase)

Chrome Extension
  → manifest.json (~3KB)
  → service-worker.js (context menu, open side panel)
  → content.js (text selection capture button)
  → Side Panel = webapp URL
```

This means:
- Extension updates deploy instantly via Firebase Hosting — no Chrome Web Store resubmission required for feature changes.
- Android and desktop are covered by the webapp with zero additional work.

---

## Features

### 1. Notes
- Create, view, delete plain-text notes.
- Capture current page URL + title as a note source.
- Right-click any webpage → "Save to Notelayer as Note".
- Highlight text on any page → floating "Save" button appears.

### 2. Tasks
- Create tasks with: title, priority (High / Med / Low / Deferred), categories, due date, task notes.
- Subtasks one level deep (matches iOS).
- Completion toggle.
- Drag-to-reorder.
- Bulk select → edit categories.
- Due date badge + overdue highlighting.

### 3. Views (4 lenses — matches iOS)
- **List** — flat chronological.
- **Priority** — grouped High / Med / Low / Deferred.
- **Category** — grouped by category, collapsible.
- **Date** — grouped by due date.

### 4. Doing / Done Toggle
- Switch between active and completed tasks.

### 5. Quick Capture (web-native, extension-specific)
- Chrome Side Panel — persistent panel stays open while browsing.
- Right-click context menu — "Save to Notelayer as Note / Task".
- Text selection → floating mini-button on any page.
- Keyboard shortcut to open Side Panel.

### 6. Categories
- Create / edit / reorder / delete categories.
- Emoji icon + custom hex color per category.
- 8 default categories matching iOS defaults.
- Category changes sync in real-time to iOS.

### 7. Reminders
- Set reminder date/time on any task.
- Web Push Notifications (replaces APNS on web).
- "Complete" / "Open" actions on notification.

### 8. Calendar Sync

#### Google Calendar
- OAuth connection via Google Calendar API.
- Full bidirectional sync: tasks with due dates appear as Google Calendar events.
- Completing a task marks the calendar event done.
- Choose which categories sync to which calendars.

#### Apple Calendar / iCloud
- **Phase 1 — Subscribe (simpler):** Generate a live `.ics` feed URL. Users subscribe in Apple Calendar — tasks with due dates appear as read-only events, auto-refreshing.
- **Phase 2 — Full sync (later):** CalDAV bidirectional sync via iCloud app-specific password. Writes completions and edits back to Apple Calendar.

#### Any Calendar
- The `.ics` feed works with Outlook, Fastmail, Fantastical, or any app supporting calendar subscriptions.

> **Note:** Google Calendar OAuth is built first. Apple `.ics` feed ships alongside it. Full CalDAV bidirectional sync is a later phase based on user demand — Apple does not provide a clean OAuth flow for web apps.

### 9. Voice Capture
- Web Speech API — mic button in task input.
- Parsed into structured task (same logic as iOS VoiceTaskParser).
- Staging view before save — review and edit before committing.

### 10. Insights
- Task completion rate over time.
- Completion by category.
- Priority distribution.
- Time-of-day patterns.
- Due date adherence trends.

### 11. Themes / Appearance
- Light / dark / system mode.
- 10 theme presets (matches iOS: Iridescent Flow, Focus Dark, Midnight Bloom, etc.).
- 12 named accent colors.
- Theme selection syncs to Firestore — same theme on iOS and web.

### 12. Authentication
- Google Sign-In (OAuth popup).
- Email magic link (same Firebase flow as iOS).
- Sign out / delete account.

### 13. Settings
- Profile and account management.
- Category manager.
- Reminder preferences.
- Google Calendar connection.
- Apple Calendar feed URL.
- Appearance / theme.
- Experimental features toggle.

### 14. Real-Time Sync
- Bidirectional sync with iOS via Firestore `onSnapshot` listeners.
- Changes on web appear on iOS instantly and vice versa.
- Offline support — writes queued locally, synced on reconnect.

---

## Design System

The webapp uses the official Notelayer design system:
- **Typography:** Space Grotesk (display) + Work Sans (body).
- **Primary color:** Indigo `#6366F1`.
- **Site palette:** `#F4F7FC` background, `#2F7DF6` accent (matches marketing site).
- **Wallpaper:** Iridescent Flow gradient adapted for web (light pastel, `#D8E5FF → #E6DAFE → #FDD9EC`).
- **Surfaces:** frosted glass (`rgba(255,255,255,0.85)` + `backdrop-filter: blur(16px)`).
- **Tokens:** CSS custom properties matching `DesignSystem.swift` and `ThemeManager.swift`.
- **Icons:** Lucide React (SF Symbols substitute for web).

---

## Build Order

| Phase | What | Status |
|---|---|---|
| 1 | Scaffold — design system, components, pages, mock data | ✅ Done |
| 2 | Firebase auth + Firestore live sync | ⬜ Next |
| 3 | Chrome extension shell (manifest + service worker + Side Panel) | ⬜ |
| 4 | Quick capture — right-click context menu, text selection button | ⬜ |
| 5 | Web Push reminders | ⬜ |
| 6 | Google Calendar sync + Apple `.ics` feed | ⬜ |
| 7 | Voice capture (Web Speech API) | ⬜ |
| 8 | Full settings, theme sync, Insights | ⬜ |

---

## Repo

- **Branch:** `notelayer-chrome-extension`
- **Webapp source:** `webapp/` (React + Vite)
- **Extension shell:** `chrome-extension/` (manifest.json, service-worker.js, content.js)
- **Firebase Hosting output:** `firebase-hosting/app/`
- **Firebase project:** `notelayer-c7bba`
