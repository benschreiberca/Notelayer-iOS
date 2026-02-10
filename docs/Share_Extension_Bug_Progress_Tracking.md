# Bug: Shared Items Not Appearing in Notelayer

**Type:** Bug  
**Priority:** High (Core functionality broken)  
**Effort:** Low-Medium  
**Status:** ROOT CAUSE IDENTIFIED - Needs Apple Developer Portal Setup  
**Branch:** `share-sheet-feature`

---

## TL;DR

When sharing a URL from Safari to Notelayer via the share sheet, the confirmation modal appears but the task never shows up in the main Notelayer app.

## Current Behavior

1. User shares URL from Safari
2. Notelayer share sheet appears
3. User edits title and taps "Save"
4. "Saved!" confirmation modal appears
5. **Bug:** Task never appears in Notelayer
   - Tried with app already open (then reopening)
   - Tried with app closed, then opening
   - Neither scenario works

## Expected Behavior

1. User shares URL from Safari
2. Share sheet appears, user saves
3. Task appears in Notelayer's task list with:
   - Title (from webpage or edited)
   - URL in notes (clickable)
   - Source attribution ("Shared from Safari")

## ROOT CAUSE IDENTIFIED ✅

**Console Error:**
```
Couldn't read values in CFPrefsPlistSource<...> (Domain: group.com.notelayer.app, User: kCFPreferencesAnyUser, ByHost: Yes, Container: (null), Contents Need Refresh: Yes): Using kCFPreferencesAnyUser with a container is only allowed for System Containers, detaching from cfprefsd
```

**Problem:** The App Group `group.com.notelayer.app` is configured in the entitlements files but is **NOT registered in Apple Developer Portal** or **NOT included in provisioning profiles**.

**Evidence:**
- No debug logs from ShareViewController appear (not even "View loaded")
- Extension fails during UserDefaults initialization (line 290 of ShareViewController.swift)
- CFPrefs error specifically indicates App Group container access failure

## Solution

See: `APP_GROUP_SETUP_FIX.md` for complete step-by-step instructions.

**Summary:**
1. Register App Group in Apple Developer Portal: https://developer.apple.com/account
2. Add App Group capability to BOTH App IDs:
   - `com.notelayer.app` (main app)
   - `com.notelayer.app.ShareExtension` (extension)
3. Regenerate provisioning profiles (automatic or manual)
4. Clean build and redeploy to device

## Investigation Completed

### ~~Possible Causes~~ (Ruled Out)

1. ~~**Data not being saved to App Group UserDefaults**~~ ✅ Code is correct
   - `SharedItem` encoding is correct
   - App Group suite name is correct: `group.com.notelayer.app`
   - UserDefaults usage is correct

2. ~~**Data saved but not being processed**~~ ✅ Code is correct
   - `LocalStore.processSharedItems()` is properly called
   - `.onAppear` implementation is correct

3. ~~**Data processed but task not created**~~ ✅ Code is correct
   - `addTask()` implementation is correct
   - No filtering issues

**Actual Cause:** Apple Developer Portal configuration - App Group not provisioned

### Debug Steps

1. Add console logging in:
   - `ShareViewController.saveTask()` - confirm save is called
   - `LocalStore.processSharedItems()` - confirm it runs on launch
   - `LocalStore.addTask()` - confirm task creation
   
2. Check UserDefaults directly:
   ```swift
   let defaults = UserDefaults(suiteName: "group.com.notelayer.app")
   if let data = defaults?.data(forKey: "com.notelayer.app.sharedItems") {
       let items = try? JSONDecoder().decode([SharedItem].self, from: data)
       print("Shared items: \(items?.count ?? 0)")
   }
   ```

3. Verify App Group entitlements are properly configured on device

## Files to Check

- `ios-swift/Notelayer/NotelayerShareExtension/ShareViewController.swift` (lines 280-320: saveTask)
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift` (lines 538-570: processSharedItems)
- `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift` (line 283: processSharedItems call)
- `ios-swift/Notelayer/Notelayer/Data/SharedItem.swift` (model definition)
- `ios-swift/Notelayer/Notelayer/Notelayer.entitlements` (App Groups config)
- `ios-swift/Notelayer/NotelayerShareExtension/ShareExtension.entitlements` (App Groups config)

## Risk Assessment

**High Impact:** Share extension is non-functional without this fix. Core feature completely broken.

**Quick Win:** Likely a simple configuration or timing issue. Debug logging should reveal the problem quickly.

## Notes

- Bug was discovered during initial testing on physical device
- Share sheet UI works correctly (shows, allows editing, confirms save)
- Problem is specifically in data persistence/retrieval pipeline
- May be related to App Group entitlements not being properly provisioned on device

---

**Next Steps:**
1. Add debug logging to trace data flow
2. Verify App Group entitlements on device
3. Test data persistence in UserDefaults
4. Consider alternative trigger for `processSharedItems()` (AppDelegate vs SwiftUI)
