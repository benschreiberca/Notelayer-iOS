---
title: PRD 10 — Chrome Extension Side Panel
last_updated: 2026-06-27
status: In Progress — v0.1 built
scope: Chrome
group: product
tags: [chrome, extension, web, side-panel, capture]
related: [REPOS.md, BACKEND_AND_AUTH.md, DS_WEB_GUIDE.md, FEATURE_INVENTORY.md]
---

# PRD 10: Chrome Extension — Side Panel

**Last Updated:** 2026-06-27  
**Status:** In Progress — v0.1 built (`chrome-extension/`), pending OAuth client setup + Web Store submission  
**Scope:** Chrome Browser (desktop)  
**Group:** Product  
**Tags:** chrome, extension, side-panel, web, capture  
**Related:** `REPOS.md`, `BACKEND_AND_AUTH.md`, `DS_WEB_GUIDE.md`

---

## Purpose

Give Notelayer a persistent, always-available capture surface inside Chrome. A side panel extension lets users capture tasks, browse their list, and complete items without leaving the web page they're on — no tab switching, no app context switch. This is the fastest possible web capture surface short of a keyboard shortcut, and it runs in the Chrome Web Store distribution channel (dev account confirmed).

---

## Goals

- Instant task capture from any Chrome tab, without leaving the page.
- View, complete, and triage the active task list from the side panel.
- Authenticate with the same Firebase account as the iOS app — data is unified.
- Visual identity matches the Notelayer design system (tokens, typography, accent colors).
- Publish to the Chrome Web Store.

## Non-Goals

- Full feature parity with iOS (no Insights, no voice capture, no reminders).
- Offline-first / local cache — network required for this version.
- Cross-browser support (Firefox, Safari) — Chrome only for v1.
- Replacing the existing Chrome extension (if one exists — see Open Decisions).

---

## In Scope

### Capture
- Quick-add task input: title, optional category chip selection, optional priority
- "Add" submits to Firestore `users/{userId}/tasks` directly
- Keyboard shortcut to open panel (browser-level shortcut, configurable)

### Task List
- Show active (Doing) tasks — title, category chips, priority badge
- Mark complete inline — checkbox tap completes task and removes from Doing list
- View Done tasks (collapsed section, expandable)

### Authentication
- Sign in with Google (Firebase Auth) — same account as iOS
- Sign in with Email/Password
- Persistent session — stay signed in across browser sessions
- Sign out

### Design
- Side panel layout using Chrome's `chrome.sidePanel` API (Chrome 114+)
- Design system tokens applied via CSS custom properties — `--nl-*` prefix (see `DS_WEB_GUIDE.md`)
- Support Light and Dark mode (respects OS preference)
- Accent color: default Indigo — no theme switcher in v1

### Distribution
- Chrome Web Store — ready for submission with dev account
- Manifest V3 (required by Chrome Web Store)
- Permissions: `sidePanel`, `storage`, `identity` (for Google auth)

---

## Open Decisions

| # | Decision | Options | Resolved? |
|---|---------|---------|-----------|
| 1 | Existing Chrome extension — new repo or enhancement of existing? | A) Enhance existing `notelayer-web` extension codebase / B) New repo | ❌ |
| 2 | Firebase auth in extension — use `firebaseui-web` or custom flow? | A) FirebaseUI / B) Custom Google OAuth via `chrome.identity` API | ❌ |
| 3 | Category chip selection in add flow — show all categories or recently used first? | All / recently used first (consistent with iOS PRD 11) | ❌ |
| 4 | Real-time listener or poll-on-open? | A) Firestore `onSnapshot` listener (real-time) / B) Fetch on panel open | ❌ |
| 5 | Share-to-Notelayer integration — right-click context menu? | A) Add context menu "Save to Notelayer" for selected text/links / B) Manual paste only | ❌ |

---

## Acceptance Criteria

- [ ] Panel opens via toolbar icon and via keyboard shortcut
- [ ] User can sign in with Google using the same account as the iOS app
- [ ] Task added in extension appears in iOS app within 5 seconds
- [ ] Task completed in iOS app is reflected in extension on next open (or in real-time if listener implemented)
- [ ] Add task: title is required, category and priority are optional
- [ ] Design matches Notelayer tokens — not a generic extension UI
- [ ] Manifest V3 — no Manifest V2 APIs used
- [ ] Passes Chrome Web Store automated review (no disallowed APIs)
- [ ] Installs cleanly from the Chrome Web Store

---

## Implementation Notes

- **Chrome Side Panel API:** `chrome.sidePanel.setPanelBehavior({ openPanelOnActionClick: true })` — supported Chrome 114+.
- **Manifest V3:** Service workers replace background pages. Firebase SDK works in MV3 with `firebase/app` + `firebase/auth` + `firebase/firestore` imports via bundler (Vite or esbuild).
- **Firebase Auth in extensions:** Google Sign-In requires `chrome.identity.launchWebAuthFlow` — standard `signInWithPopup` does NOT work in extensions. Use `firebase/auth` with `signInWithCredential(GoogleAuthProvider.credential(...))` after getting the token via `chrome.identity`.
- **Same Firebase project:** Use the same `GoogleService-Info.plist` project — the web config (`firebaseConfig`) is available from Firebase Console → Project Settings → Web apps.
- **Token bridge:** `DS_WEB_GUIDE.md` defines all CSS custom properties. Copy the `docs/design-system/exports/css-variables.css` into the extension.
- **Firestore collections:** `users/{userId}/tasks` and `users/{userId}/categories` — same schema as iOS (see `BACKEND_AND_AUTH.md`).

---

## Status

| Item | Status |
|------|--------|
| Open decisions | Resolved — Chrome Web Store (not Safari) |
| Chrome extension scaffold | ✅ Built — `chrome-extension/` (MV3, side panel) |
| Firebase Auth (extension) | ✅ Built — `chrome.identity` → Identity Toolkit → Firebase ID token |
| Task list + capture UI | ✅ Built — capture current tab, list/complete open tasks, recents-first categories |
| OAuth client setup | ⏳ Manual — create Chrome-Extension OAuth client, set `manifest.json` `oauth2.client_id` |
| Chrome Web Store listing | Not started |

---

## Implementation notes (v0.1)

Built under `chrome-extension/` as a **zero-build** Manifest V3 project. The
approach differs from the early technical notes above in two deliberate ways:

- **Firestore via REST, not a bundled SDK.** MV3's CSP forbids remote scripts and
  bundling the Firebase SDK would add a build step. The Firestore REST API +
  Identity Toolkit cover all needs and keep the extension plain ES modules. See
  `lib/firestore.js`.
- **Auth via `chrome.identity.getAuthToken`** (Google access token) exchanged for
  a Firebase ID token through `accounts:signInWithIdp`, rather than
  `launchWebAuthFlow` + `signInWithCredential`. Simpler for Google accounts. See
  `lib/auth.js`.

Documents are written with the exact iOS field layout (`users/{uid}/tasks`,
`users/{uid}/categories`) so records round-trip across devices. Setup, OAuth
client creation, and Web Store publishing steps are in `chrome-extension/README.md`.
