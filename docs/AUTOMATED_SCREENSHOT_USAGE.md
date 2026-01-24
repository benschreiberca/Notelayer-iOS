# Automated Screenshot Generation Usage Guide

This guide explains how to use the automated screenshot generation system for NoteLayer App Store screenshots.

## Overview

The automated screenshot system uses XCUITest to:
- Seed the app with quirky but relatable tasks
- Navigate through different views automatically
- Capture screenshots programmatically
- Save screenshots to your backup directory

**IMPORTANT**: Screenshot generation uses an isolated data store - your production data is NEVER touched or overwritten.

## Prerequisites

1. **Xcode** installed (latest version recommended)
2. **iPhone 17 Pro** simulator (or any iPhone Pro simulator)
3. **Ruby** available (macOS system Ruby is fine)

## Quick Start

### Option 1: One-Command Setup + Run (Recommended)

```bash
cd /Users/bens/Notelayer/Notelayer-iOS-1
./scripts/setup-screenshot-system.sh
```

The script will:
1. Install the xcodeproj gem if needed
2. Add/update the `NotelayerScreenshotTests` UI test target
3. Create/update the "Screenshot Generation" scheme
4. Verify the setup
5. Find and boot the iPhone 17 Pro simulator
6. Configure simulator state (time, battery, etc.)
7. Build the app with screenshot generation mode
8. Run the XCUITest suite
9. Collect and copy screenshots to the backup location

### Option 2: Run Only (After Setup)

```bash
cd /Users/bens/Notelayer/Notelayer-iOS-1
./scripts/generate-screenshots.sh
```

To skip running tests during setup:

```bash
./scripts/setup-screenshot-system.sh --skip-generate
```

### Verification

```bash
./scripts/verify-screenshot-setup.sh
```

## Screenshot Storage Locations

Screenshots are saved to two locations:

1. **Temporary/Test Location**: `ios-swift/Notelayer/Screenshots/`
   - Used during test execution
   - May be cleaned up

2. **Backup/Permanent Location**: `/Users/bens/Notelayer/App-Icons-&-screenshots`
   - Permanent storage on your hard drive
   - All screenshots are copied here automatically

## Generated Screenshots

The system generates 6 screenshots:

1. **screenshot-1-todos-list.png** - Main Todos List View
2. **screenshot-2-sign-in.png** - Sign-in Screen
3. **screenshot-3-task-edit.png** - Task Edit View
4. **screenshot-4-category-view.png** - Category View Mode
5. **screenshot-5-appearance.png** - Appearance/Theme Selector
6. **screenshot-6-priority-view.png** - Priority View Mode

## Data Isolation

**CRITICAL**: Screenshot generation uses a completely isolated data store:

- **Production Data**: Uses `group.com.notelayer.app` (your real data)
- **Screenshot Data**: Uses `group.com.notelayer.app.screenshots` (isolated)

Your real tasks, notes, and categories are **NEVER** touched or modified during screenshot generation.

## Modifying Task Data

To change the quirky tasks shown in screenshots:

1. Edit `docs/SCREENSHOT_TASK_DATA.md` to see available tasks
2. Edit `ios-swift/Notelayer/Notelayer/Utils/ScreenshotDataSeeder.swift`
3. Modify the task creation code in `seedData()` method
4. Re-run screenshot generation

## Adding New Screenshots

To add a new screenshot:

1. Add a new test method in `ScreenshotGenerationTests.swift`:
   ```swift
   func testScreenshot7_NewView() throws {
       // Navigation code
       try captureScreenshot(name: "screenshot-7-new-view")
   }
   ```

2. Update the automation script if needed
3. Run screenshot generation

## Troubleshooting

### Simulator Not Found

**Error**: "No iPhone Pro simulator found"

**Solution**:
- Open Xcode > Window > Devices and Simulators
- Create iPhone 17 Pro simulator (or any iPhone Pro)
- Or modify script to use a different simulator name

### Tests Fail to Run

**Error**: Test target not found

**Solution**:
1. Re-run `./scripts/setup-screenshot-system.sh`
2. Confirm `./scripts/verify-screenshot-setup.sh` passes

### Screenshots Not Appearing

**Error**: Screenshots not in backup directory

**Solution**:
- Check DerivedData folder: `./DerivedData/`
- Check temp directory: `ios-swift/Notelayer/Screenshots/`
- Verify test attachments in Xcode test results
- Check script output for errors

### App Crashes on Launch

**Error**: App crashes in screenshot mode

**Solution**:
- Ensure Firebase is configured (may need GoogleService-Info.plist)
- Check console logs for errors
- Verify screenshot mode detection in `NotelayerApp.swift`

### Data Appears in Production App

**Error**: Screenshot tasks appear in real app

**Solution**:
- This should NOT happen - screenshot mode uses isolated data store
- Verify `LocalStore.swift` uses correct app group identifier
- Check that `SCREENSHOT_MODE` environment variable is set
- Ensure you're not running screenshot mode in production

## Manual Screenshot Generation

If automation doesn't work, you can generate screenshots manually:

1. Launch app with screenshot mode:
   ```bash
   xcrun simctl launch --env SCREENSHOT_MODE=true <SIMULATOR_UDID> com.notelayer.app
   ```

2. Navigate to each screen manually
3. Take screenshots using Xcode: Device > Screenshot (⌘+S)
4. Screenshots save to Desktop by default

## Best Practices

1. **Run on Clean Simulator**: Reset simulator before generating screenshots
2. **Consistent Appearance**: Use same theme/appearance for all screenshots
3. **Check Quality**: Verify screenshots are readable and properly formatted
4. **Version Control**: Don't commit screenshots to git (add to .gitignore)
5. **Regular Updates**: Regenerate screenshots when UI changes

## File Structure

```
ios-swift/Notelayer/
├── Notelayer/
│   ├── App/
│   │   └── NotelayerApp.swift          # Screenshot mode detection
│   ├── Data/
│   │   └── LocalStore.swift            # Isolated data store support
│   └── Utils/
│       └── ScreenshotDataSeeder.swift  # Task seeding logic
├── NotelayerScreenshotTests/
│   └── ScreenshotGenerationTests.swift # XCUITest tests
└── Screenshots/                        # Temporary screenshot storage

scripts/
├── generate-screenshots.sh             # Screenshot run script
├── setup-screenshot-system.sh          # End-to-end setup + run
└── verify-screenshot-setup.sh          # Verification checks

docs/
├── AUTOMATED_SCREENSHOT_PLAN.md       # Implementation plan
├── AUTOMATED_SCREENSHOT_USAGE.md      # This file
└── SCREENSHOT_TASK_DATA.md            # Quirky task definitions
```

## Support

For issues or questions:
1. Check this documentation
2. Review `AUTOMATED_SCREENSHOT_PLAN.md` for implementation details
3. Check Xcode console logs for errors
4. Verify simulator state and configuration

## Summary

The automated screenshot system provides a safe, repeatable way to generate App Store screenshots without affecting your production data. Simply run the script and screenshots will be automatically generated and saved to your backup directory.
