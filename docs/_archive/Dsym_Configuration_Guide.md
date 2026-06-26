# dSYM Configuration Guide

## Overview
This document explains how to configure debug symbol (dSYM) generation for Firebase frameworks to resolve App Store Connect upload warnings.

## The Issue
When uploading to App Store Connect, you may see "Upload Symbols Failed" warnings for these frameworks:
- FirebaseFirestoreInternal.framework  
- absl.framework
- grpc.framework
- grpcpp.framework
- openssl_grpc.framework

## Why This Happens
Firebase SDKs installed via Swift Package Manager don't always generate dSYM files by default. These symbols are needed for:
- Crash report symbolication
- App Store Connect validation
- Firebase Crashlytics integration

## Solution: Configure Build Settings

### Step 1: Open Build Settings in Xcode
1. Open `Notelayer.xcodeproj` in Xcode
2. Select the "Notelayer" target
3. Go to "Build Settings" tab
4. Filter for "Debug Information Format"

### Step 2: Verify Debug Information Format
**For Release Configuration:**
- Set "Debug Information Format" to **"DWARF with dSYM File"**
- This ensures dSYM files are generated when archiving for distribution

**For Debug Configuration (Optional):**
- Can leave as "DWARF" for faster debug builds
- Or set to "DWARF with dSYM File" if you need crash reports during development

### Step 3: Verify Generate Debug Symbols
1. Filter for "Generate Debug Symbols"
2. Ensure it's set to **YES** for both Debug and Release

### Step 4: Check Strip Debug Symbols Setting
1. Filter for "Strip Debug Symbols During Copy"
2. For Release: Should be **YES** (strips symbols from embedded frameworks but keeps dSYM)
3. For Debug: Can be **NO** (for easier debugging)

## Firebase-Specific Considerations

### Swift Package Manager (SPM) Limitations
Firebase frameworks installed via SPM don't always include pre-built dSYMs. The solution is to ensure Xcode generates them during the build/archive process with the settings above.

### Alternative: Manual dSYM Upload (If Needed)
If App Store Connect still complains after configuration:

1. After archiving, locate your `.xcarchive`:
   ```
   ~/Library/Developer/Xcode/Archives/[DATE]/Notelayer [TIME].xcarchive
   ```

2. Find dSYMs in:
   ```
   [Your Archive]/dSYMs/
   ```

3. Upload manually to Firebase Crashlytics (if using):
   ```bash
   /path/to/Pods/FirebaseCrashlytics/upload-symbols \
       -gsp /path/to/GoogleService-Info.plist \
       -p ios /path/to/dSYMs
   ```

## Verification

### During Archive
When creating an archive (Product → Archive), check the build log for dSYM generation:
```
GenerateDSYMFile [framework].framework.dSYM
```

### After Upload
App Store Connect should no longer show "Upload Symbols Failed" warnings for these frameworks.

## Best Practices
1. **Always use Release configuration** for App Store builds
2. **Archive, don't just Build** - dSYMs are generated during archiving
3. **Keep dSYMs** - Store archives for at least 90 days for crash report symbolication
4. **Update Firebase SDK regularly** - Newer versions may have better dSYM support

## Technical Notes
- dSYM files map machine code addresses back to source code for crash reports
- They're separate files (not embedded in the app binary) to reduce app size
- App Store Connect expects dSYMs for all frameworks, including dependencies
- Firebase SPM packages generate dSYMs during build, not pre-packaged

## Status
✅ Build settings documented
⚠️ Requires manual Xcode project configuration
📋 Verify after next Archive + Upload to App Store Connect
