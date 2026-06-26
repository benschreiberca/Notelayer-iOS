# XCUITest Target Setup Instructions

The test file has been created, but you need to add the UI Test Target in Xcode. Follow these steps:

## Step 1: Open Project in Xcode

1. Open `ios-swift/Notelayer/Notelayer.xcodeproj` in Xcode

## Step 2: Add UI Test Target

1. In Xcode, go to **File > New > Target**
2. Select **iOS** tab
3. Choose **UI Testing Bundle**
4. Click **Next**
5. Configure:
   - **Product Name**: `NotelayerScreenshotTests`
   - **Team**: (select your team)
   - **Organization Identifier**: (should match your app)
   - **Language**: Swift
   - **Target to be Tested**: `Notelayer`
6. Click **Finish**

## Step 3: Add Test File to Target

1. In Xcode Project Navigator, find `NotelayerScreenshotTests/ScreenshotGenerationTests.swift`
2. If file shows red (missing), right-click and select **Add Files to "Notelayer"...**
3. Navigate to the file and add it
4. Make sure **"Add to targets: NotelayerScreenshotTests"** is checked
5. Click **Add**

## Step 4: Configure Test Target

1. Select the **NotelayerScreenshotTests** target in Project Navigator
2. Go to **Build Settings** tab
3. Ensure:
   - **Test Host**: `$(BUILT_PRODUCTS_DIR)/Notelayer.app/Notelayer`
   - **Bundle Loader**: `$(TEST_HOST)`

## Step 5: Create Screenshot Generation Scheme

1. Go to **Product > Scheme > Manage Schemes...**
2. Click **+** to add new scheme
3. Configure:
   - **Name**: `Screenshot Generation`
   - **Target**: `Notelayer`
4. Click **OK**
5. Select the new scheme and click **Edit...**
6. Go to **Run** section > **Arguments** tab
7. Add launch argument: `--screenshot-generation`
8. Add environment variable:
   - **Name**: `SCREENSHOT_MODE`
   - **Value**: `true`
9. Click **Close**

## Step 6: Verify Setup

1. Select **Screenshot Generation** scheme
2. Select **iPhone 17 Pro** simulator (or any iPhone Pro)
3. Run tests: **Product > Test** (⌘+U)
4. Check that tests run and screenshots are generated

## Troubleshooting

### Test Target Not Found
- Make sure UI Test Target was created successfully
- Verify target appears in Project Navigator

### Tests Don't Run
- Check that scheme is set to "Screenshot Generation"
- Verify launch arguments are set correctly
- Check Build Settings for Test Host configuration

### App Doesn't Launch in Screenshot Mode
- Verify environment variable `SCREENSHOT_MODE=true` is set
- Check `NotelayerApp.swift` for screenshot mode detection
- Review console logs for errors

## Alternative: Use Automation Script

If setting up in Xcode is complex, you can use the automation script which handles most of this:

```bash
./scripts/generate-screenshots.sh
```

The script will attempt to run tests even if the target isn't fully configured, but you may need to complete the Xcode setup for best results.
