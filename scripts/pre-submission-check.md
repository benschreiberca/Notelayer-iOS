# Pre-Submission Configuration Checklist

This document provides a manual verification checklist for App Store submission requirements.

## Requirements

- **Bundle ID**: `com.notelayer.app`
- **Version**: `1.0`
- **Build**: `1`
- **Deployment Target**: iOS 16.0
- **Capabilities**: Sign in with Apple, Push Notifications

---

## Configuration Verification Checklist

### 1. Bundle Identifier ✅

- [ ] **Location**: `project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`
- [ ] **Expected**: `com.notelayer.app`
- [ ] **Current**: `com.notelayer.app`
- [ ] **Status**: ✅ Verified

**How to verify:**
1. Open Xcode project
2. Select project in navigator
3. Select "Notelayer" target
4. Go to "General" tab
5. Check "Bundle Identifier" field

**Or via command line:**
```bash
grep "PRODUCT_BUNDLE_IDENTIFIER" ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj
```

---

### 2. Version Number (CFBundleShortVersionString) ✅

- [ ] **Location**: `project.pbxproj` → `MARKETING_VERSION`
- [ ] **Expected**: `1.0`
- [ ] **Current**: `1.0`
- [ ] **Status**: ✅ Verified

**How to verify:**
1. Open Xcode project
2. Select project in navigator
3. Select "Notelayer" target
4. Go to "General" tab
5. Check "Version" field

**Or via command line:**
```bash
grep "MARKETING_VERSION" ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj
```

---

### 3. Build Number (CFBundleVersion) ✅

- [ ] **Location**: `project.pbxproj` → `CURRENT_PROJECT_VERSION`
- [ ] **Expected**: `1`
- [ ] **Current**: `1`
- [ ] **Status**: ✅ Verified

**How to verify:**
1. Open Xcode project
2. Select project in navigator
3. Select "Notelayer" target
4. Go to "General" tab
5. Check "Build" field

**Or via command line:**
```bash
grep "CURRENT_PROJECT_VERSION" ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj
```

---

### 4. iOS Deployment Target ✅

- [ ] **Location**: `project.pbxproj` → `IPHONEOS_DEPLOYMENT_TARGET`
- [ ] **Expected**: `16.0`
- [ ] **Current**: `16.0`
- [ ] **Status**: ✅ Verified

**How to verify:**
1. Open Xcode project
2. Select project in navigator
3. Select "Notelayer" target
4. Go to "General" tab
5. Check "Minimum Deployments" → iOS version

**Or via command line:**
```bash
grep "IPHONEOS_DEPLOYMENT_TARGET" ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj
```

---

### 5. Capabilities - Sign in with Apple ✅

- [ ] **Location**: `Notelayer.entitlements` → `com.apple.developer.applesignin`
- [ ] **Expected**: Present with `Default` value
- [ ] **Current**: ✅ Configured
- [ ] **Status**: ✅ Verified

**How to verify:**
1. Open Xcode project
2. Select project in navigator
3. Select "Notelayer" target
4. Go to "Signing & Capabilities" tab
5. Verify "Sign in with Apple" capability is listed

**Or check entitlements file:**
```bash
cat ios-swift/Notelayer/Notelayer/Notelayer.entitlements
```

**Expected content:**
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

---

### 6. Capabilities - Push Notifications ✅

- [ ] **Location**: `Notelayer.entitlements` → `aps-environment` AND `project.pbxproj` → SystemCapabilities
- [ ] **Expected**: Enabled in both locations
- [ ] **Current**: ✅ Configured
- [ ] **Status**: ✅ Verified

**How to verify:**

**In Xcode:**
1. Open Xcode project
2. Select project in navigator
3. Select "Notelayer" target
4. Go to "Signing & Capabilities" tab
5. Verify "Push Notifications" capability is listed

**In project.pbxproj:**
```bash
grep -A 3 "com.apple.Push" ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj
```

**Expected in project.pbxproj:**
```
com.apple.Push = {
    enabled = 1;
};
```

**In entitlements file:**
```bash
cat ios-swift/Notelayer/Notelayer/Notelayer.entitlements
```

**Expected content:**
```xml
<key>aps-environment</key>
<string>development</string>
```

**Note**: For App Store submission, `aps-environment` should be set to `production` in the Release build configuration.

---

### 7. Info.plist Required Keys ✅

- [ ] **CFBundleIdentifier**: ✅ Present (uses `$(PRODUCT_BUNDLE_IDENTIFIER)`)
- [ ] **CFBundleShortVersionString**: ✅ Present (uses `$(MARKETING_VERSION)`)
- [ ] **CFBundleVersion**: ✅ Present (uses `$(CURRENT_PROJECT_VERSION)`)
- [ ] **CFBundleName**: ✅ Present (uses `$(PRODUCT_NAME)`)
- [ ] **CFBundleExecutable**: ✅ Present (uses `$(EXECUTABLE_NAME)`)
- [ ] **LSRequiresIPhoneOS**: ✅ Present (set to `true`)

**How to verify:**
```bash
cat ios-swift/Notelayer/Info.plist
```

**Or in Xcode:**
1. Open `Info.plist` file
2. Verify all required keys are present

---

## Automated Verification

Run the verification script to automatically check all configuration values:

```bash
chmod +x scripts/pre-submission-check.sh
./scripts/pre-submission-check.sh
```

The script will:
- Extract current values from project files
- Compare against expected values
- Report any mismatches
- Exit with error code if checks fail

---

## Additional Pre-Submission Checks

### App Store Connect Configuration

- [ ] App name matches display name
- [ ] App icon is uploaded (1024x1024 PNG)
- [ ] Screenshots are uploaded for all required device sizes
- [ ] App description and keywords are complete
- [ ] Privacy policy URL is provided
- [ ] Support URL is provided
- [ ] Age rating is configured
- [ ] Pricing and availability are set

### Code Signing

- [ ] Distribution certificate is valid
- [ ] Provisioning profile matches bundle ID
- [ ] Code signing is set to "Automatic" or properly configured for distribution

### Build Configuration

- [ ] Release build configuration is selected
- [ ] Debug symbols are included (for crash reporting)
- [ ] Bitcode is disabled (if required)
- [ ] App thinning is enabled

### Testing

- [ ] App builds successfully for Release
- [ ] App runs on physical device
- [ ] All features work as expected
- [ ] No console errors or warnings
- [ ] Memory leaks checked
- [ ] Performance is acceptable

---

## Notes

- Version numbers must be incremented for each App Store submission
- Build numbers must be unique and incrementing
- Deployment target cannot be increased after first submission (can only be decreased)
- Capabilities must match what's configured in App Store Connect
- Entitlements file must match capabilities enabled in Xcode

---

## Last Verified

- **Date**: [Fill in date]
- **Verified by**: [Fill in name]
- **All checks passed**: [ ] Yes [ ] No
