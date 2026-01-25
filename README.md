Ben's app

# Notelayer iOS

Native iOS app for Notelayer, focused on notes and todos. This repo contains the SwiftUI project plus release automation and docs.

## Status

The current app is a prototype. You can view and delete notes and todos, but creating or editing items is not implemented yet. See `docs/STATUS_REPORT.md` for details.

## Quick start

1. Open `ios-swift/Notelayer/Notelayer.xcodeproj` in Xcode.
2. Select a simulator or device.
3. Run with Cmd+R.

Optional command-line open:

```sh
open ios-swift/Notelayer/Notelayer.xcodeproj
```

## Requirements

- macOS with Xcode installed
- Apple Developer account for running on a physical device

## Project layout

- `ios-swift/Notelayer/` SwiftUI app source
- `fastlane/` release automation
- `.github/workflows/` CI workflows
- `docs/` build notes and workflows
- `scripts/` helper scripts

## Docs

- `docs/QUICK_START.md` for running the app
- `docs/IMPLEMENTATION_PLAN.md` for the roadmap
- `RELEASE_CHECKLIST.md` for pre-submission checks
- `docs/BUILD_INSTRUCTIONS.md` for build guidance
- `docs/AUTOMATED_SCREENSHOT_USAGE.md` for screenshots
