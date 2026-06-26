# Prompt for Fully Automated XCUITest Screenshot System Setup

Use this prompt with an AI coding assistant to achieve 100% automated setup of the screenshot generation system, including the XCUITest target creation in Xcode.

---

## THE PROMPT

I need you to create a fully automated screenshot generation system for my iOS app with **zero manual steps required**. The system must:

### Core Requirements

1. **Add XCUITest UI Test Target to Xcode Project** - This is the critical blocker
   - Target name: `NotelayerScreenshotTests`
   - Must work without opening Xcode GUI
   - Must not break the existing project
   - Project path: `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`

2. **Implement Data Isolation**
   - Modify `LocalStore.swift` to use separate UserDefaults suite for screenshot mode
   - Production: `group.com.notelayer.app`
   - Screenshot: `group.com.notelayer.app.screenshots`
   - Detection: Check environment variable `SCREENSHOT_MODE` or launch argument `--screenshot-generation`

3. **Create Screenshot Data Seeder**
   - File: `ios-swift/Notelayer/Notelayer/Utils/ScreenshotDataSeeder.swift`
   - Seed 8 quirky, relatable tasks (see `docs/SCREENSHOT_TASK_DATA.md`)
   - Distribute across categories, priorities, due dates
   - Only affects isolated screenshot data store

4. **Integrate with App**
   - Modify `NotelayerApp.swift` to detect screenshot mode on launch
   - Call `ScreenshotDataSeeder.seedData()` when in screenshot mode

5. **Create XCUITest Suite**
   - File: `ios-swift/Notelayer/NotelayerScreenshotTests/ScreenshotGenerationTests.swift`
   - 6 test methods (one per screenshot)
   - Navigation logic for each screen
   - Screenshot capture and save to `/Users/bens/Notelayer/App-Icons-&-screenshots`

6. **Create Automation Script**
   - File: `scripts/generate-screenshots.sh`
   - Boot iPhone 17 Pro simulator
   - Configure simulator (time, battery, etc.)
   - Run tests
   - Copy screenshots to backup location

7. **Create Xcode Scheme**
   - Name: "Screenshot Generation"
   - Launch arguments: `--screenshot-generation`
   - Environment variable: `SCREENSHOT_MODE=true`

### Critical Challenge: Adding XCUITest Target

**This is the blocker.** You must implement ONE of these approaches (in order of preference):

#### Approach 1: Use xcodeproj Ruby Gem (PREFERRED)
```ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('ios-swift/Notelayer/Notelayer.xcodeproj')
target = project.new_target(:ui_test_bundle, 'NotelayerScreenshotTests', :ios)
# Configure target...
project.save
```

- Install xcodeproj gem: `gem install xcodeproj`
- Create Ruby script that:
  - Opens the project
  - Adds UI test target
  - Configures build settings
  - Adds test file reference
  - Links to app target
  - Saves project
- **Must work without user interaction**

#### Approach 2: Direct pbxproj Manipulation (If Ruby not available)
- Parse `project.pbxproj` file structure
- Generate unique IDs for all objects (24-char hex)
- Add all required sections:
  - PBXFileReference for test bundle
  - PBXNativeTarget for test target
  - PBXFrameworksBuildPhase
  - PBXSourcesBuildPhase
  - PBXResourcesBuildPhase
  - PBXTargetDependency
  - XCBuildConfiguration (Debug & Release)
  - XCConfigurationList
- Update existing sections:
  - Add to Products group
  - Add to targets list
  - Add to TargetAttributes
- **Validate after modification** - parse the file to ensure it's valid
- **Create backup** before modifying

#### Approach 3: AppleScript Automation (Fallback)
```applescript
tell application "Xcode"
    open "path/to/Notelayer.xcodeproj"
    tell project "Notelayer"
        make new target with properties {name:"NotelayerScreenshotTests", type:"UI Testing Bundle"}
    end tell
end tell
```
- Automate Xcode GUI
- Add target via AppleScript
- Configure via AppleScript
- Close Xcode when done
- **Must work without user watching**

#### Approach 4: Project Template (Last Resort)
- If all above fail, create instructions that use Xcode command-line tools
- But this is NOT fully automated, so avoid if possible

### Success Criteria

The setup is complete when:

1. ✅ Running `./scripts/generate-screenshots.sh` generates all 6 screenshots
2. ✅ Screenshots appear in `/Users/bens/Notelayer/App-Icons-&-screenshots`
3. ✅ No manual Xcode interaction required
4. ✅ No manual configuration required
5. ✅ Production data remains untouched
6. ✅ Tests can run via: `xcodebuild test -project "ios-swift/Notelayer/Notelayer.xcodeproj" -scheme "Screenshot Generation" -destination "platform=iOS Simulator,name=iPhone 17 Pro"`

### Testing the Solution

After implementation, verify by running:

```bash
# 1. Clean any existing setup
rm -rf ios-swift/Notelayer/NotelayerScreenshotTests/*.xctest

# 2. Run automation
./scripts/generate-screenshots.sh

# 3. Check screenshots exist
ls -lh /Users/bens/Notelayer/App-Icons-&-screenshots/screenshot-*.png

# 4. Verify count (should be 6)
ls /Users/bens/Notelayer/App-Icons-&-screenshots/screenshot-*.png | wc -l
```

Expected output: 6 screenshots in backup directory.

### Important Constraints

1. **No manual steps** - Must work start to finish without user interaction
2. **No GUI required** - Must work in headless/CI environment
3. **Idempotent** - Can be run multiple times safely
4. **Safe** - Must not break existing project
5. **Portable** - Should work on any Mac with Xcode installed
6. **Data isolation** - Production data must never be touched

### Existing Project Context

- Project format: Xcode 14+ (uses PBXFileSystemSynchronizedRootGroup)
- Main target ID: `BC2CCDD52F174A5100406D9A`
- Bundle identifier: `com.notelayer.app`
- Deployment target: iOS 16.0
- Language: Swift 5.0
- Development team: `DPVQ2X986Z`

### Files Already Created

The following files exist but are not integrated:
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift` (modified)
- `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift` (modified)
- `ios-swift/Notelayer/Notelayer/Utils/ScreenshotDataSeeder.swift` (new)
- `ios-swift/Notelayer/NotelayerScreenshotTests/ScreenshotGenerationTests.swift` (new)
- `scripts/generate-screenshots.sh` (new)

**The ONLY missing piece is adding the XCUITest target to the Xcode project.**

### Deliverables

1. **Working script** that adds the test target (Ruby, Python, or shell)
2. **Verification script** that confirms everything works
3. **Documentation** of what was done
4. **Error handling** for common issues
5. **Rollback capability** if something fails

### Additional Notes

- If you need to install dependencies (like xcodeproj gem), include that in the script
- If you need to check for prerequisites, include those checks
- If you need to create backup of project file, do it automatically
- Include clear error messages if something fails
- Test the solution end-to-end before considering it complete

### Example of Full Automation (What Success Looks Like)

```bash
# User runs ONE command:
./scripts/setup-screenshot-system.sh

# Script does EVERYTHING:
# 1. Installs dependencies if needed
# 2. Backs up project file
# 3. Adds test target
# 4. Creates scheme
# 5. Verifies setup
# 6. Runs test generation
# 7. Shows results

# Output:
# ✅ Dependencies installed
# ✅ Project backed up
# ✅ Test target added
# ✅ Scheme created
# ✅ Tests ran successfully
# ✅ 6 screenshots generated
# 📸 Screenshots: /Users/bens/Notelayer/App-Icons-&-screenshots/
```

**That's the goal. Zero manual intervention.**

---

## Additional Context

### Why Previous Attempt Failed

The previous attempt created a Python script to modify `project.pbxproj` directly, but:
1. The pbxproj format is complex and error-prone to modify directly
2. Xcode may not recognize manually-added entries
3. File system synchronized groups require special handling
4. The test file wasn't properly linked to the target
5. Still required opening Xcode to verify/fix

### What Would Make This Fully Automated

1. **Use xcodeproj Ruby gem** - This is the standard tool for programmatic Xcode project manipulation
2. **Include gem installation** - Auto-install if not present
3. **Validate after changes** - Ensure project can be opened/built
4. **Run actual tests** - Verify screenshots are generated
5. **Handle errors gracefully** - Rollback on failure

### Reference Implementation

Look for examples of:
- `fastlane` - Uses xcodeproj gem extensively
- `tuist` - Project generation tool
- `xcodegen` - YAML-based project generation
- `xcodeproj` documentation: https://github.com/CocoaPods/Xcodeproj

These tools successfully manipulate Xcode projects programmatically.

---

## TL;DR

Create a script that:
1. Uses xcodeproj Ruby gem (or equivalent) to add UI test target
2. Configures everything automatically
3. Runs end-to-end without user intervention
4. Generates screenshots successfully

**Success = Running one script and getting 6 screenshots with zero manual steps.**

