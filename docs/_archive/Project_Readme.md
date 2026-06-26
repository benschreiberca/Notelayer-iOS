Ben's app

# Notelayer iOS

Native iOS app for Notelayer, focused on notes and todos. This repo contains the SwiftUI project plus release automation and docs.

## Status

**Active Development** - Full-featured iOS app with notes, tasks, categories, Firebase sync, and notifications. Ready for TestFlight distribution.

## Features

- **Tasks & Notes**: Create, edit, complete, and organize with categories
- **Task Reminders**: Set notifications with preset or custom times
- **Calendar Export**: Send tasks to your calendar with all details
- **Firebase Sync**: Google, Apple, and Phone authentication with cloud backup
- **Themes**: 6 color presets including dynamic Cheetah wallpaper
- **Views**: List, Priority, Category, and Date grouping modes
- **Shake to Undo**: Restore deleted tasks
- **iOS 16+**: Native SwiftUI with modern iOS design patterns

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
