---
title: Backend and Auth Architecture
last_updated: 2026-06-25
status: active
scope: all-platforms
group: architecture
tags: [firebase, firestore, auth, backend, sync, app-group]
related: [DEVELOPMENT_SETUP.md, ANALYTICS.md]
source_of_truth_for: [notelayer-ios, notelayer-web]
---

# Backend and Auth

Firebase/Firestore is the backend. This document covers auth architecture, data sync, and the share extension data contract.

---

## Stack

| Layer | Technology |
|-------|-----------|
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Crash reporting | Firebase Crashlytics |
| Analytics | Firebase Analytics (mirrored locally for Insights) |
| Hosting | Firebase Hosting (placeholder only — no web app in this repo) |

**Not used:** Supabase. Any document referencing Supabase describes an architecture that was never built.

---

## Auth Flow

### Initialization Chain

```
NotelayerApp.init()
  → configureFirebaseIfNeeded()
  → AuthService.init()
    → Firebase.configure()
    → Auth.auth().addStateDidChangeListener()
  → FirebaseBackendService.init(authService)
  → RootTabsView
    → TodosView
      → SignInSheet (presented as sheet on tap)
```

### Auth Methods

| Method | Status |
|--------|--------|
| Email sign-in | ✅ Implemented |
| Phone + SMS verification | ✅ Implemented |
| Apple Sign-In | ✅ Implemented |
| Google Sign-In | ✅ Implemented |
| Guest / anonymous | ✅ Implemented — full app access, local data only |

### Sign-In Sheet Architecture

`Views/SignInSheet.swift` + `Services/AuthService.swift`

Known timing issues (from `AUTH_ARCHITECTURE_REVIEW.md`):
- Sheet buttons should be disabled for ~300ms after presentation to avoid race conditions with sheet animation
- `waitForPresenter()` uses exponential backoff (max 10 attempts) to find the presentation anchor
- Presentation anchor must be the key window — not a background window
- Concurrent auth attempts are guarded by `isBusy` state

---

## Data Sync

### Guest Mode

All data stored locally via `LocalStore.swift` (UserDefaults + Codable, with app group support). No Firestore writes.

### Signed-In Mode

`FirebaseBackendService.swift` handles all Firestore CRUD.

On sign-in: local data merges with Firestore (local-first, last-write-wins per field).
On sign-out: local data retained on device. Firestore listener detached.

### Firestore Collections

| Collection | Contents |
|-----------|---------|
| `users/{userId}/tasks` | Task documents |
| `users/{userId}/categories` | Category documents |
| `users/{userId}/notes` | Note documents (code exists, tab hidden) |

### Task Document Schema

```
{
  id: string
  title: string
  notes: string?
  priority: "high" | "medium" | "low" | "deferred"
  categoryIds: [string]
  dueDate: Timestamp?
  isComplete: boolean
  completedAt: Timestamp?
  createdAt: Timestamp
  updatedAt: Timestamp
  parentTaskId: string?          // subtask hierarchy (experimental)
  reminderDate: Timestamp?
}
```

### Category Document Schema

```
{
  id: string
  name: string
  emoji: string?
  colorHex: string
  sortOrder: number
  createdAt: Timestamp
}
```

---

## App Group and Share Extension

App group identifier: `group.com.notelayer.app`

The share extension (`NotelayerShareExtension`) writes shared items to the app group container. The main app reads them on foreground.

Data contract via `SharedItem.swift`:

```swift
struct SharedItem: Codable {
  let title: String
  let url: String?
  let text: String?
  let sourceApp: String?
  let destination: SharedImportDestination   // .task | .note
  let taskDrafts: [SharedTaskDraft]
  let importTimestamp: Date
}
```

Both the main app and extension must have `group.com.notelayer.app` in their entitlements.

---

## Local Analytics Mirror

`Services/InsightsTelemetryStore.swift` maintains a local copy of analytics events for the Insights feature. This is separate from Firebase Analytics.

- Scoped by signed-in user ID (prevents cross-account mixing on shared devices)
- Insights history starts when local telemetry is available on that device
- Events are also sent to Firebase Analytics in parallel

See `docs/architecture/ANALYTICS.md` for the full event catalog.

---

## Platform Notes

| Platform | Backend |
|----------|---------|
| iOS | Full Firebase — auth + Firestore + Crashlytics + Analytics |
| Mac | Same Firebase — same project, same collections |
| Watch | WatchConnectivity bridge from iPhone — no direct Firestore on Watch |
| Web (notelayer-web) | Same Firebase project — same auth, same Firestore collections |
