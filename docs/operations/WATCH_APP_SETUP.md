# Apple Watch App Setup

The Notelayer Watch app is a companion that shows today's open tasks, lets you
complete them with a tap, and quick-adds a task (dictation/Scribble). The
**iPhone is the source of truth** — the watch talks to it over
**WatchConnectivity**, so there's no Firebase SDK on the watch and no separate
login. Anything completed or added on the watch flows through `LocalStore` on the
phone and syncs to Firestore like any other edit.

The source is written and committed. The watchOS **target** itself must be
created in Xcode (it can't be added from the Linux CI container). One-time steps:

---

## Source files (already in the repo)

Phone side (already in the iOS target):
- `Notelayer/Shared/WatchConnectivityShared.swift` — wire format (DTO + keys)
- `Notelayer/Services/WatchSessionProvider.swift` — phone-side bridge to LocalStore
- `Notelayer/App/NotelayerApp.swift` — calls `WatchSessionProvider.shared.activate()`

Watch side (ready to drop into the new target):
- `NotelayerWatch Watch App/NotelayerWatchApp.swift` — `@main` + priority colors
- `NotelayerWatch Watch App/WatchConnector.swift` — watch-side WCSession client
- `NotelayerWatch Watch App/WatchTasksView.swift` — today's task list + complete
- `NotelayerWatch Watch App/WatchQuickAddView.swift` — quick add (dictation)

---

## Create the watchOS target

1. Open `Notelayer.xcworkspace`.
2. **File → New → Target… → watchOS → Watch App** (App for an existing iOS app).
   - Product Name: **NotelayerWatch**
   - Interface: **SwiftUI**, Life Cycle: **SwiftUI App**
   - Make sure it's paired with the **Notelayer** iOS app when prompted.
3. Xcode generates a starter `NotelayerWatchApp.swift` and `ContentView.swift` in
   the new target folder. **Delete those generated Swift files** (move to trash).
4. **Add the committed watch files** to the target: right-click the watch group →
   *Add Files to "Notelayer"…* → select the four files in
   `NotelayerWatch Watch App/` above. Ensure **Target Membership = NotelayerWatch**.
5. **Share the wire format:** select
   `Notelayer/Shared/WatchConnectivityShared.swift`, open the File Inspector, and
   under **Target Membership** check **both** `Notelayer` *and* `NotelayerWatch`.

---

## Configure identifiers & signing

- Watch app bundle ID: `com.notelayer.app.watchkitapp` (Xcode's default suggestion
  for the companion is fine as long as `WKCompanionAppBundleIdentifier` =
  `com.notelayer.app`).
- Set the **Team** on the watch target's Signing & Capabilities to the same Apple
  Developer team as iOS.
- No extra capability is required for WatchConnectivity.

---

## Build & run

1. Select the **NotelayerWatch** scheme with a paired
   *iPhone + Apple Watch* simulator pair (or your devices).
2. ⌘R. Launch the iPhone app at least once so the session activates and pushes
   the first task snapshot.

You should see today's tasks on the watch. Tap a task to complete it; use **+**
to add one by voice or Scribble.

---

## How the sync works

- Phone pushes the open top-level task list to the watch via
  `updateApplicationContext` whenever `LocalStore.tasks` changes (debounced).
- Watch reads from that context immediately and also sends a `fetchTasks` message
  when it becomes reachable.
- Add/complete are sent as messages; the phone applies them to `LocalStore`
  (which writes through to Firestore) and replies with the refreshed list.

## Out of scope for v1

- Complications, independent (cellular) operation, categories/priority editing on
  the watch, and reminders. The watch is intentionally a glanceable companion.
