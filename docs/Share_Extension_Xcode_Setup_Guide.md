# Share Extension - Xcode Target Setup Guide

## ⚠️ Manual Step Required

The share extension files have been created programmatically, but the extension target must be added manually in Xcode to ensure proper project configuration.

## Files Already Created ✅

All necessary files have been created:
- `ios-swift/Notelayer/NotelayerShareExtension/ShareViewController.swift`
- `ios-swift/Notelayer/NotelayerShareExtension/Info.plist`
- `ios-swift/Notelayer/NotelayerShareExtension/ShareExtension.entitlements`
- `ios-swift/Notelayer/NotelayerShareExtension/Assets.xcassets/`
- `ios-swift/Notelayer/Notelayer/Data/SharedItem.swift`

## Step-by-Step Instructions

### Step 1: Open Project in Xcode
```bash
open ios-swift/Notelayer/Notelayer.xcodeproj
```

### Step 2: Add Share Extension Target

1. In Xcode, select the **Notelayer** project in the navigator (top-level item)
2. Click the **"+"** button at the bottom of the targets list
3. Select **"Share Extension"** from the template chooser
   - Filter by "Share" or look under "Application Extension"
4. Click **"Next"**

### Step 3: Configure Target Settings

In the dialog that appears, set:
- **Product Name:** `NotelayerShareExtension`
- **Team:** Select your development team (DPVQ2X986Z)
- **Organization Identifier:** `com.notelayer`
- **Bundle Identifier:** Will auto-fill as `com.notelayer.app.ShareExtension`
- **Language:** Swift
- **Include UI Tests:** Unchecked

Click **"Finish"**

When prompted "Activate 'NotelayerShareExtension' scheme?", click **"Cancel"** (we'll build with the main app scheme)

### Step 4: Replace Generated Files

Xcode will create some default files. Replace them with our pre-created ones:

1. **Delete** the auto-generated files:
   - `ShareViewController.swift` (in NotelayerShareExtension folder created by Xcode)
   - `MainInterface.storyboard` (if created)
   
2. **Add existing files** to the target:
   - Right-click on `NotelayerShareExtension` folder in Xcode
   - Select **"Add Files to 'Notelayer'..."**
   - Navigate to `NotelayerShareExtension` folder
   - Select `ShareViewController.swift`
   - Make sure **"NotelayerShareExtension"** target is checked
   - Click **"Add"**

3. **Replace Info.plist:**
   - Select `NotelayerShareExtension` target
   - Go to **"Build Settings"**
   - Search for "Info.plist File"
   - Set value to: `NotelayerShareExtension/Info.plist`

4. **Set Entitlements:**
   - Go to **"Signing & Capabilities"** tab
   - Click **"+ Capability"**
   - Add **"App Groups"**
   - Check the box for: `group.com.notelayer.app`
   - Make sure the entitlements file path is: `NotelayerShareExtension/ShareExtension.entitlements`

### Step 5: Configure Build Settings

Select `NotelayerShareExtension` target, then **"Build Settings"** tab:

1. **Deployment Target:**
   - Set "iOS Deployment Target" to: `16.0` (match main app)

2. **Swift Version:**
   - Confirm "Swift Language Version" is: `5.0`

3. **Code Signing:**
   - Set "Code Signing Style" to: `Automatic`
   - Set "Development Team" to your team

### Step 6: Add Shared Files to Extension Target

The share extension needs access to the `SharedItem.swift` model:

1. Select `SharedItem.swift` in the Project Navigator
2. Open the **File Inspector** (⌥⌘1)
3. Under **"Target Membership"**, check both:
   - ✅ Notelayer
   - ✅ NotelayerShareExtension

### Step 7: Embed Extension in Main App

1. Select **Notelayer** (main app) target
2. Go to **"General"** tab
3. Scroll to **"Frameworks, Libraries, and Embedded Content"** section
4. If `NotelayerShareExtension.appex` is not listed:
   - Click **"+"**
   - Select `NotelayerShareExtension.appex`
   - Set embed option to **"Embed & Sign"**

### Step 8: Build and Test

1. Select the **Notelayer** scheme (not NotelayerShareExtension)
2. Build the project: **⌘B**
3. Run on simulator or device: **⌘R**
4. Test the share extension:
   - Open Safari
   - Navigate to any webpage
   - Tap the Share button
   - Look for "Notelayer" in the share sheet
   - If not visible, tap "More" and enable Notelayer

## Troubleshooting

### Share Extension Not Appearing

1. **Check Activation Rules:**
   - Verify `Info.plist` has correct `NSExtensionActivationRule`
   
2. **Rebuild:**
   ```bash
   # Clean build folder
   # Product → Clean Build Folder (⇧⌘K)
   # Then rebuild (⌘B)
   ```

3. **Reset Simulator:**
   ```bash
   # iOS Simulator → Device → Erase All Content and Settings
   ```

### Build Errors

1. **"No such module" errors:**
   - Ensure `SharedItem.swift` has both targets checked

2. **Code signing errors:**
   - Check that App Groups capability is enabled for both targets
   - Verify bundle identifiers are correct

3. **Entitlements errors:**
   - Ensure both targets have `group.com.notelayer.app` in App Groups

## Verification Checklist

Once complete, verify:
- [ ] Project builds successfully
- [ ] Share extension appears in Safari share sheet
- [ ] Can share a URL and enter a title
- [ ] "Saved!" message appears
- [ ] Task appears in main Notelayer app with correct URL and attribution
- [ ] URL in task notes is clickable and opens Safari

## Next Steps

After completing this setup, the share extension should be fully functional!

Test scenarios:
1. Share URL from Safari
2. Share text from Notes app
3. Share URL from Chrome (if installed)
4. Verify tasks appear in main app
5. Verify URLs are clickable in task notes
