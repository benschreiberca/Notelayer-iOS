---
title: Development Setup
last_updated: 2026-06-25
status: active
scope: notelayer-ios
group: architecture
tags: [build, xcode, setup, dsym]
related: [BACKEND_AND_AUTH.md, GIT_STRATEGY.md]
---

# Development Setup

How to build and run Notelayer iOS locally.

---

## Xcode Project

**Correct project to open:**

```
ios-swift/Notelayer/Notelayer.xcodeproj
```

```bash
# From terminal (repo root)
open ios-swift/Notelayer/Notelayer.xcodeproj
```

⚠️ Do NOT open these (wrong projects):
- ❌ `NoteLayer.xcodeproj` at repo root (legacy Capacitor project)
- ❌ `ios/App/App.xcodeproj` (Capacitor iOS project)

---

## Dependencies

The project uses **CocoaPods** for Firebase dependencies.

```bash
cd ios-swift/Notelayer
pod install
open Notelayer.xcworkspace    # always open .xcworkspace, not .xcodeproj after pod install
```

> **Multiplatform note:** CocoaPods is path-relative and does not work across git worktrees cleanly. SPM migration is a prerequisite for Mac/Watch development. See `docs/product/MULTIPLATFORM_PRD.md` §Wave 1.

---

## Build Targets

| Target | Purpose |
|--------|---------|
| `Notelayer` | Main iOS app |
| `NotelayerShareExtension` | Share extension |
| `NotelayerInsightsTests` | Unit tests — insights, voice parser |
| `NotelayerScreenshotTests` | Automated screenshot generation |

---

## App Groups

App group: `group.com.notelayer.app`

Used for data sharing between the main app and `NotelayerShareExtension`. Required for the share extension to write tasks that the main app can read.

Both targets must have the app group entitlement configured. See `App_Group_Setup_Fix_Summary.md` in `_archive/` if troubleshooting.

---

## dSYM / Crash Reporting

dSYM files are required for symbolicated crash reports in Firebase Crashlytics.

- dSYM upload is configured as a build phase script in the Xcode project
- Verify the build phase exists: Xcode → Target → Build Phases → "Upload dSYMs"
- If missing, re-add the Crashlytics run script from the Firebase console

---

## Environment

No `.env` file required. Firebase configuration is in `GoogleService-Info.plist` (not committed — add from Firebase console).

If `GoogleService-Info.plist` is missing:
1. Open Firebase console
2. Project Settings → iOS app → Download `GoogleService-Info.plist`
3. Add to `ios-swift/Notelayer/Notelayer/` (do not add to git)

---

## Quick Checks Before Building

- [ ] `Notelayer.xcworkspace` open (not `.xcodeproj`)
- [ ] Scheme set to `Notelayer`
- [ ] `GoogleService-Info.plist` present
- [ ] Signing: your Apple Developer account in Xcode → Signing & Capabilities
- [ ] Simulator or device selected
