# Fix: App Group Configuration Issue

**Problem:** Share Extension cannot access App Group `group.com.notelayer.app`

**Error:** `Couldn't read values in CFPrefsPlistSource... Using kCFPreferencesAnyUser with a container is only allowed for System Containers`

**Root Cause:** The App Group is configured in code but NOT registered in Apple Developer Portal or provisioning profiles.

---

## Solution: Register App Group in Apple Developer Portal

### Step 1: Register the App Group

1. Go to: https://developer.apple.com/account
2. Click **"Certificates, Identifiers & Profiles"**
3. In the left sidebar, click **"Identifiers"**
4. At the top, change the dropdown from "App IDs" to **"App Groups"**
5. Click the **"+"** button to add a new App Group
6. Enter:
   - **Description:** `Notelayer App Group`
   - **Identifier:** `group.com.notelayer.app`
7. Click **"Continue"** then **"Register"**

### Step 2: Add App Group to Main App Identifier

1. Still in **"Identifiers"** section, switch back to **"App IDs"**
2. Find and click on: `com.notelayer.app` (or `Notelayer`)
3. Scroll to **"App Groups"** capability
4. If not checked, **check "App Groups"**
5. Click **"Configure"** (or "Edit")
6. Check the box next to: `group.com.notelayer.app`
7. Click **"Continue"** then **"Save"**

### Step 3: Add App Group to Share Extension Identifier

1. Still in **"Identifiers"** section
2. Find and click on: `com.notelayer.app.ShareExtension` (or similar)
   - **Note:** If this doesn't exist, you may need to create it:
     - Click **"+"** to add new App ID
     - Select: **"App IDs"**
     - Select: **"App"**
     - Description: `Notelayer Share Extension`
     - Bundle ID: `com.notelayer.app.ShareExtension`
     - Under Capabilities, check **"App Groups"**
     - Configure to include: `group.com.notelayer.app`
3. If it exists, edit it:
   - Check **"App Groups"** capability
   - Click **"Configure"**
   - Check: `group.com.notelayer.app`
   - Click **"Continue"** then **"Save"**

### Step 4: Regenerate Provisioning Profiles

After adding the App Group to your App IDs, you need to regenerate the provisioning profiles:

#### Option A: Automatic (Recommended)

1. In Xcode, select **Notelayer** project in Project Navigator
2. Select **Notelayer** target → **"Signing & Capabilities"** tab
3. Under **"Signing"**, uncheck **"Automatically manage signing"**
4. Wait a moment, then **re-check** "Automatically manage signing"
5. Xcode will automatically download new profiles with App Group
6. Repeat for **NotelayerShareExtension** target

#### Option B: Manual

1. Go to: https://developer.apple.com/account
2. Click **"Certificates, Identifiers & Profiles"**
3. Click **"Profiles"** in left sidebar
4. For each profile (Development, Ad Hoc, App Store):
   - Click **"Edit"**
   - Click **"Generate"** (or delete and recreate)
   - Download the new `.mobileprovision` file
5. In Xcode:
   - **Window → Devices and Simulators**
   - Right-click your device → **"Show Provisioning Profiles"**
   - Delete old profiles
   - Drag new `.mobileprovision` files into Xcode

### Step 5: Clean Build & Test

1. In Xcode: **Product → Clean Build Folder** (⇧⌘K)
2. **Product → Build** (⌘B)
3. Deploy to your device
4. Test the share extension:
   - Open Safari
   - Share a webpage to Notelayer
   - Check Console.app for errors

---

## Verification

After completing these steps, you should see in Console.app:

```
📤 [ShareViewController] View loaded, extracting shared content...
💾 [ShareViewController] Saving shared item: <title>
✅ [ShareViewController] Saved successfully to App Group
```

And when you open the main app:

```
📥 [LocalStore] Processing X shared item(s)
✅ [LocalStore] Created task from shared item: <title>
```

---

## Common Issues

### "App Group not available"
- Make sure you're logged in with the correct Apple ID in Xcode
- Check that your team has access to App Groups capability (requires paid developer account)

### "Provisioning profile doesn't include App Groups"
- Delete derived data: `~/Library/Developer/Xcode/DerivedData`
- Clean build folder: ⇧⌘K
- Toggle "Automatically manage signing" off and back on

### Still getting CFPrefs error
- Check that BOTH app and extension have the SAME App Group ID
- Verify in Xcode: **Signing & Capabilities → App Groups** is checked and shows `group.com.notelayer.app`
- Make sure you're building with the correct provisioning profile

---

## Quick Check: Is App Group Working?

Add this test code to `ShareViewController.swift` (line 46, right after `viewDidLoad`):

```swift
// Test App Group access
if let defaults = UserDefaults(suiteName: "group.com.notelayer.app") {
    print("✅ App Group accessible!")
    defaults.set("test", forKey: "test")
    defaults.synchronize()
} else {
    print("❌ App Group NOT accessible!")
}
```

If you see "✅ App Group accessible!" in Console.app, the issue is fixed.
If you see "❌ App Group NOT accessible!", continue with the steps above.
