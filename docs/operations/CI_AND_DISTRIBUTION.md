---
title: CI and Distribution
last_updated: 2026-06-26
status: active
scope: notelayer-ios
group: operations
tags: [ci, github-actions, testflight, signing, distribution]
related: [RELEASE_CHECKLIST.md, DEVELOPMENT_SETUP.md]
---

# CI and Distribution

GitHub Actions setup, TestFlight workflow, and code signing reference.

---

## GitHub Actions

Workflow files live in `.github/workflows/`. Current state: minimal CI — no full automated build pipeline yet.

**What exists:**
- Manual archive + upload via Xcode Organizer (primary path for releases)
- No automated test runner on push (planned)

**Planned for multiplatform (PRD 09):**
- Automated `xcodebuild test` on PR for iOS scheme
- Automated archive + TestFlight upload on merge to `main`
- Mac scheme build validation

---

## TestFlight

**Internal distribution:** Use Xcode Organizer → Distribute → TestFlight (internal only) for pre-release testing.

**External distribution:** Not currently used. All public releases go direct to App Store.

**Build numbers:** Increment build number for every TestFlight upload. Version number only changes for App Store releases.

---

## Code Signing

**Method:** Automatic signing via Xcode (recommended for development). Manual signing required for App Store distribution.

**Bundle IDs:**
| Target | Bundle ID |
|--------|-----------|
| Main app | `com.benschreiber.notelayer` |
| Share extension | `com.benschreiber.notelayer.shareextension` |

**App Group:** `group.com.notelayer.app` — must be enabled on both main app and share extension targets. Required for share extension data handoff.

**Provisioning:** Managed via App Store Connect. Certificates stored in Keychain on build machine — not committed to repo.

---

## Fastlane

Not currently configured. Future option for automating screenshots, signing, and TestFlight uploads. See `APP_STORE_ASSETS.md` for current screenshot approach.

---

## dSYM Upload

Crashlytics requires dSYM files for symbolicated crash reports.

1. In Xcode: Build Settings → `DEBUG_INFORMATION_FORMAT` = `DWARF with dSYM File` for Release builds
2. In the Run Script phase: `${PODS_ROOT}/FirebaseCrashlytics/run` must be present
3. Input files must list `${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}`

If crashes appear unsymbolicated in Crashlytics, verify the Run Script phase is present and input files are correct.

---

## Archive and Upload Process

```bash
# 1. Clean
xcodebuild clean -workspace ios-swift/Notelayer/Notelayer.xcworkspace -scheme Notelayer

# 2. Archive (Xcode Organizer is preferred over CLI for App Store uploads)
# Product → Archive in Xcode, then Distribute App → App Store Connect

# 3. Verify
# App Store Connect → TestFlight → confirm build appears
```

**Do not use `xcodebuild -exportArchive` for App Store uploads** — Xcode Organizer handles notarization and entitlements validation correctly.
