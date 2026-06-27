# Mac App Setup (Mac Catalyst)

The Notelayer Mac app ships as a **Mac Catalyst** build of the existing iOS
target — not a separate codebase. Every feature, bug fix, and design change in
the iOS app cascades to Mac automatically because it's the same source and the
same Firestore backend.

This doc is the one-time Xcode setup to turn the Mac destination on. It can't be
done from the Linux CI container; do it once on your Mac.

---

## Why Catalyst (not a native AppKit/SwiftUI-for-Mac app)

- The Firebase pods already vendor Mac Catalyst slices
  (`ios-arm64_x86_64-maccatalyst` in the xcframeworks), so no dependency work.
- The codebase uses UIKit interop (`UndoShakeHost`, keyboard notifications,
  `UIWindowScene`, GoogleSignIn `withPresenting:`) — all Catalyst-compatible.
- One target = one place to maintain. A native Mac target would fork the UI.

Verified Catalyst-safe during this pass:
- `UIImpactFeedbackGenerator` — compiles, no-ops without haptics hardware.
- Shake-to-undo (`UndoShakeHost`) — compiles; ⌘Z still drives the same
  `UndoManager` on Mac even though there's no accelerometer.
- Google / Apple sign-in — use window-scene presentation that works on Catalyst.

The app already includes a Mac-only window polish (`RootTabsView`
`configureMacWindowIfNeeded()`): a 480×660 minimum window size and a hidden
title bar.

---

## Enable the Mac destination

1. Open `ios-swift/Notelayer/Notelayer.xcworkspace` (the **workspace**, not the
   project — CocoaPods).
2. Select the **Notelayer** target → **General** tab.
3. Under **Supported Destinations**, click **+** and add **Mac (Mac Catalyst)**.
   - Prefer "Mac Catalyst" over "Designed for iPad" so the window-sizing and
     menu code applies and you get a proper Mac idiom.
4. Set the **Signing & Capabilities** team for the Mac destination (same Apple
   Developer team as iOS). Catalyst uses a `maccatalyst` bundle ID derived from
   the iOS one — keep the suggested default.

## Build & run

1. In the scheme/destination selector at the top, pick **My Mac (Mac Catalyst)**.
2. ⌘R.

If a pod complains about a missing Catalyst slice, run `pod install` again from
`ios-swift/Notelayer/` and reopen the workspace.

---

## Known follow-ups (not blockers)

- **App Group / push:** reminders use APNs + an App Group. On Mac these need the
  same App Group entitlement added to the Mac destination; local task data and
  Firestore sync work without it.
- **Menu bar:** Catalyst gives a default Mac menu bar. Custom menu commands
  (e.g. ⌘N = new task) can be added later via `.commands { }` on the `WindowGroup`
  or `UIMenuBuilder`; not required for a first build.
- **Share extension:** the iOS Share Extension doesn't run on Mac Catalyst; Mac
  uses the standard macOS share sheet, which is a separate (later) effort.

---

## Status

- Code: **Catalyst-ready** (no blockers found; window polish added).
- Remaining: the Xcode destination toggle above (manual, on your Mac).
