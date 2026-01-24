# Automated Screenshot Generation Plan

**Overall Progress:** `0%`

## TLDR
Create an automated system to generate App Store screenshots using XCUITest framework. The system will seed the app with quirky but relatable tasks, navigate through different views, and capture screenshots automatically. **CRITICAL**: Screenshot generation uses a completely isolated data store - user's production data is NEVER touched or overwritten. This replaces manual screenshot creation with a repeatable, scriptable process that is safe to run anytime.

## Critical Decisions
- **Automation Framework**: XCUITest (built into Xcode) - standard iOS UI testing framework, no external dependencies
- **Data Isolation**: Use separate UserDefaults suite for screenshot mode to ensure user's real data is NEVER overwritten - screenshots use isolated data store
- **Data Seeding Approach**: Create a dedicated `ScreenshotDataSeeder` class that populates LocalStore with predefined quirky tasks via `applyRemoteSnapshot()` method, but only when using isolated data store
- **Task Content Strategy**: Use quirky but relatable tasks that are memorable and demonstrate personality (e.g., "Figure out why the WiFi password is on a sticky note from 2018")
- **Screenshot Method**: Use XCUITest's `XCUIScreenshot` API to capture screenshots programmatically
- **Build Configuration**: Create a separate build scheme "ScreenshotGeneration" that uses isolated data store and seeder on launch
- **Simulator Management**: Use `xcrun simctl` commands to boot simulator, install app, and manage state
- **Data Safety**: User's production data remains completely untouched - screenshot generation uses separate app group identifier
- **Screenshot Storage**: Screenshots saved to `/Users/bens/Notelayer/App-Icons-&-screenshots` directory for backup and easy access

## Tasks:

- [ ] 🟥 **Step 1: Create Quirky Task Data Set**
  - [ ] 🟥 Research and compile list of quirky but relatable tasks across categories
  - [ ] 🟥 Create tasks that are:
    - [ ] 🟥 Memorable and personality-driven
    - [ ] 🟥 Relatable to common experiences
    - [ ] 🟥 Distributed across all categories
    - [ ] 🟥 Mix of priorities (High, Medium, Low, Deferred)
    - [ ] 🟥 Mix of due dates (today, tomorrow, this week, later, none)
    - [ ] 🟥 Some with notes, some without
  - [ ] 🟥 Examples to include:
    - [ ] 🟥 "Figure out why the WiFi password is on a sticky note from 2018"
    - [ ] 🟥 "Remember to water the plant that's somehow still alive"
    - [ ] 🟥 "Find where I put my 'important documents' folder"
    - [ ] 🟥 "Call mom (she knows I saw her text)"
    - [ ] 🟥 "Actually read those terms and conditions I agreed to"
    - [ ] 🟥 "Organize the drawer that eats single socks"
  - [ ] 🟥 Document task list in `docs/SCREENSHOT_TASK_DATA.md`

- [ ] 🟥 **Step 2: Create Isolated Data Store for Screenshots**
  - [ ] 🟥 Modify `LocalStore.swift` to support isolated data store mode
  - [ ] 🟥 Add property to `LocalStore` to use separate app group identifier when in screenshot mode
  - [ ] 🟥 Use app group: `group.com.notelayer.app.screenshots` (different from production `group.com.notelayer.app`)
  - [ ] 🟥 Ensure screenshot mode uses completely separate UserDefaults suite
  - [ ] 🟥 This ensures user's real data is NEVER touched or overwritten
  - [ ] 🟥 Add static flag or environment check to determine if in screenshot mode

- [ ] 🟥 **Step 3: Create ScreenshotDataSeeder Class**
  - [ ] 🟥 Create new file: `ios-swift/Notelayer/Notelayer/Utils/ScreenshotDataSeeder.swift`
  - [ ] 🟥 Implement `ScreenshotDataSeeder` class with static method `seedData()`
  - [ ] 🟥 Use `LocalStore.shared.applyRemoteSnapshot()` to populate data (only affects isolated screenshot data store)
  - [ ] 🟥 Suppress backend writes during seeding (already handled by `applyRemoteUpdate`)
  - [ ] 🟥 Create tasks with:
    - [ ] 🟥 Realistic timestamps (spread over past week)
    - [ ] 🟥 Proper orderIndex values for correct ordering
    - [ ] 🟥 Category assignments matching default categories
    - [ ] 🟥 Priority distribution (2 High, 3 Medium, 2 Low, 1 Deferred)
    - [ ] 🟥 Due date distribution (2 today, 2 tomorrow, 2 this week, 1 later, 1 none)
    - [ ] 🟥 Notes on 3-4 tasks for variety
  - [ ] 🟥 Ensure categories are initialized (use `Category.defaultCategories`)
  - [ ] 🟥 Clear any existing data in screenshot data store before seeding (to ensure clean state)

- [ ] 🟥 **Step 4: Create Build Configuration for Screenshot Generation**
  - [ ] 🟥 Add launch argument: `--screenshot-generation` or environment variable `SCREENSHOT_MODE=true`
  - [ ] 🟥 Modify `NotelayerApp.swift` to check for screenshot mode
  - [ ] 🟥 On launch in screenshot mode:
    - [ ] 🟥 Initialize LocalStore with isolated screenshot data store (separate app group)
    - [ ] 🟥 Call `ScreenshotDataSeeder.seedData()` immediately (only affects screenshot data)
    - [ ] 🟥 Ensure user is signed out (or handle signed-out state)
    - [ ] 🟥 Set appearance to light mode (or configurable)
  - [ ] 🟥 Create new Xcode scheme: "Screenshot Generation"
  - [ ] 🟥 Configure scheme to pass launch arguments/environment variables
  - [ ] 🟥 Add clear documentation that this mode NEVER touches production data

- [ ] 🟥 **Step 5: Create XCUITest Target and Test Suite**
  - [ ] 🟥 Add new UI Test Target to Xcode project: "NotelayerScreenshotTests"
  - [ ] 🟥 Create test file: `ScreenshotGenerationTests.swift`
  - [ ] 🟥 Implement test class `ScreenshotGenerationTests: XCTestCase`
  - [ ] 🟥 Set up test methods for each screenshot:
    - [ ] 🟥 `testScreenshot1_TodosListView()`
    - [ ] 🟥 `testScreenshot2_SignInSheet()`
    - [ ] 🟥 `testScreenshot3_TaskEditView()`
    - [ ] 🟥 `testScreenshot4_CategoryView()`
    - [ ] 🟥 `testScreenshot5_AppearanceView()`
    - [ ] 🟥 `testScreenshot6_PriorityView()`
  - [ ] 🟥 Each test method should:
    - [ ] 🟥 Launch app with screenshot generation mode
    - [ ] 🟥 Wait for app to load and data to seed
    - [ ] 🟥 Navigate to target screen/view
    - [ ] 🟥 Wait for UI to stabilize
    - [ ] 🟥 Capture screenshot using `XCUIScreenshot`
    - [ ] 🟥 Save screenshot with descriptive name

- [ ] 🟥 **Step 6: Implement Navigation Logic in Tests**
  - [ ] 🟥 Screenshot 1: Todos List View
    - [ ] 🟥 Ensure on Todos tab
    - [ ] 🟥 Ensure "Doing" toggle is selected
    - [ ] 🟥 Ensure "List" view mode is selected
    - [ ] 🟥 Scroll to show 5-7 tasks
  - [ ] 🟥 Screenshot 2: Sign-in Sheet
    - [ ] 🟥 Tap gear icon
    - [ ] 🟥 Tap "Authentication" menu item
    - [ ] 🟥 Wait for sheet to appear
  - [ ] 🟥 Screenshot 3: Task Edit View
    - [ ] 🟥 Navigate to Todos tab
    - [ ] 🟥 Tap on specific task (e.g., first task with notes)
    - [ ] 🟥 Wait for TaskEditView sheet to appear
  - [ ] 🟥 Screenshot 4: Category View
    - [ ] 🟥 Navigate to Todos tab
    - [ ] 🟥 Tap/swipe to "Category" view mode
    - [ ] 🟥 Scroll to show multiple category groups
  - [ ] 🟥 Screenshot 5: Appearance View
    - [ ] 🟥 Tap gear icon
    - [ ] 🟥 Tap "Appearance" menu item
    - [ ] 🟥 Wait for sheet to appear
  - [ ] 🟥 Screenshot 6: Priority View
    - [ ] 🟥 Navigate to Todos tab
    - [ ] 🟥 Tap/swipe to "Priority" view mode
    - [ ] 🟥 Scroll to show priority groups

- [ ] 🟥 **Step 7: Implement Screenshot Capture and Saving**
  - [ ] 🟥 Use `XCUIScreenshot` API to capture screenshots
  - [ ] 🟥 Create helper method `captureScreenshot(name: String) -> XCUIScreenshot`
  - [ ] 🟥 Save screenshots to designated folders:
    - [ ] 🟥 Primary location: `ios-swift/Notelayer/Screenshots/` directory (temporary/test location)
    - [ ] 🟥 Backup location: `/Users/bens/Notelayer/App-Icons-&-screenshots` directory (permanent storage)
    - [ ] 🟥 Save with naming convention: `screenshot-{number}-{name}.png`
  - [ ] 🟥 Handle file saving with proper error handling
  - [ ] 🟥 Ensure both directories exist before saving (create if needed)
  - [ ] 🟥 Copy screenshots from test location to backup location after capture
  - [ ] 🟥 Add timestamp or version to filenames (optional)
  - [ ] 🟥 Verify files are successfully saved to backup location

- [ ] 🟥 **Step 8: Create Automation Script**
  - [ ] 🟥 Create shell script: `scripts/generate-screenshots.sh`
  - [ ] 🟥 Script should:
    - [ ] 🟥 Boot iPhone 17 Pro simulator
    - [ ] 🟥 Build app with Screenshot Generation scheme
    - [ ] 🟥 Install app on simulator
    - [ ] 🟥 Run XCUITest suite
    - [ ] 🟥 Collect screenshots from test output
    - [ ] 🟥 Copy screenshots to backup location: `/Users/bens/Notelayer/App-Icons-&-screenshots`
    - [ ] 🟥 Ensure backup directory exists (create if needed)
    - [ ] 🟥 Organize screenshots in backup directory with proper naming
    - [ ] 🟥 Verify screenshots are successfully copied to backup location
    - [ ] 🟥 Clean up temporary test screenshots (optional)
    - [ ] 🟥 Clean up simulator state
  - [ ] 🟥 Use `xcrun simctl` commands for simulator management
  - [ ] 🟥 Use `xcodebuild test` for running tests
  - [ ] 🟥 Add error handling and logging
  - [ ] 🟥 Add confirmation message showing where screenshots were saved

- [ ] 🟥 **Step 9: Add Simulator State Management**
  - [ ] 🟥 Create helper methods to:
    - [ ] 🟥 Set simulator time to 10:00 AM
    - [ ] 🟥 Set battery to 100%
    - [ ] 🟥 Disable notifications
    - [ ] 🟥 Set appearance to light mode
    - [ ] 🟥 Ensure clean state before each screenshot
  - [ ] 🟥 Use `xcrun simctl` commands or UI test code
  - [ ] 🟥 Clear screenshot data store before each test run (not production data!)
  - [ ] 🟥 Ensure production app data is NEVER accessed or modified

- [ ] 🟥 **Step 10: Add Documentation and Usage Guide**
  - [ ] 🟥 Create `docs/AUTOMATED_SCREENSHOT_USAGE.md`
  - [ ] 🟥 Document:
    - [ ] 🟥 How to run screenshot generation
    - [ ] 🟥 Prerequisites and setup
    - [ ] 🟥 How to modify task data
    - [ ] 🟥 How to add new screenshots
    - [ ] 🟥 Troubleshooting common issues
    - [ ] 🟥 **IMPORTANT**: Data isolation - explain that user's real data is never touched
    - [ ] 🟥 How screenshot mode uses separate data store
    - [ ] 🟥 Screenshot storage locations:
      - [ ] 🟥 Test/temporary location: `ios-swift/Notelayer/Screenshots/`
      - [ ] 🟥 Backup/permanent location: `/Users/bens/Notelayer/App-Icons-&-screenshots`
  - [ ] 🟥 Update main README with screenshot generation info
  - [ ] 🟥 Add prominent warning that screenshot generation is safe and doesn't affect production data

- [ ] 🟥 **Step 11: Testing and Validation**
  - [ ] 🟥 Test screenshot generation end-to-end
  - [ ] 🟥 Verify all 6 screenshots are captured correctly
  - [ ] 🟥 Verify screenshot quality and content
  - [ ] 🟥 Verify quirky tasks appear correctly
  - [ ] 🟥 **CRITICAL**: Verify that production data is NOT affected
    - [ ] 🟥 Run screenshot generation with existing production data
    - [ ] 🟥 Verify production data remains unchanged after screenshot generation
    - [ ] 🟥 Verify screenshot data store is separate and isolated
  - [ ] 🟥 Test on different iOS versions if needed
  - [ ] 🟥 Validate screenshots meet App Store requirements
