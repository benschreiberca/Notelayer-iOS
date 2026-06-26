# Build and Distribution Fixes

**Type**: Bug/Build Issue  
**Priority**: High  
**Effort**: Medium  
**Branch**: `v1.1-build2-tweaks`

## TL;DR

Multiple build warnings and App Store Connect upload failures blocking clean distribution. Issues include:
1. Missing UTType declaration in Info.plist for drag-and-drop
2. App icon asset catalog has unassigned child images
3. Firebase frameworks missing dSYM files for crash reporting

## Current State

### Build Warnings
- **Type Declaration**: Custom UTType `com.notelayer.todo.dragpayload` used but not exported in Info.plist
- **App Icon**: Asset catalog has orphaned `notelayer-logo.png` causing validation warnings

### App Store Connect Upload Issues
- **dSYM Upload Failures** for 5 Firebase/gRPC frameworks:
  - FirebaseFirestoreInternal.framework
  - absl.framework
  - grpc.framework
  - grpcpp.framework
  - openssl_grpc.framework

## Expected Outcome

- ✅ Build with zero warnings
- ✅ Clean upload to App Store Connect without dSYM errors
- ✅ Proper UTType registration for drag-and-drop functionality
- ✅ Clean app icon asset catalog

## Files to Modify

1. **`ios-swift/Notelayer/Info.plist`**
   - Add UTType export declaration for `com.notelayer.todo.dragpayload`

2. **`ios-swift/Notelayer/Notelayer/Assets.xcassets/AppIcon.appiconset/`**
   - Remove or assign orphaned `notelayer-logo.png`
   - Verify Contents.json structure

3. **`ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`** (or Build Settings)
   - Configure Firebase framework dSYM handling
   - May need to update "Debug Information Format" settings

## Technical Details

### 1. UTType Declaration Issue
```swift
// Currently in TodoDragPayload.swift:
extension UTType {
    static let notelayerTodoDragPayload = UTType(exportedAs: "com.notelayer.todo.dragpayload")
}
```

**Fix**: Add to Info.plist:
```xml
<key>UTExportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeIdentifier</key>
        <string>com.notelayer.todo.dragpayload</string>
        <key>UTTypeDescription</key>
        <string>Notelayer Todo Drag Payload</string>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.data</string>
        </array>
    </dict>
</array>
```

### 2. App Icon Asset Issue
- Xcode detects `notelayer-logo.png` in AppIcon.appiconset but it's not assigned to any size slot
- Either assign to specific icon size or remove from asset catalog

### 3. Firebase dSYM Issue
Common causes:
- Firebase SPM packages don't include dSYMs by default
- Need to ensure "Debug Information Format" is set to "DWARF with dSYM File" for Release builds
- May need to disable Bitcode (deprecated in Xcode 14+)

Possible fixes:
- Update Firebase SDK to latest version
- Configure build settings to generate dSYMs for all frameworks
- Use Firebase Crashlytics script to upload dSYMs manually if needed

## Risk Assessment

**Low Risk**: These are configuration and asset cleanup issues
- UTType declaration is additive (won't break existing functionality)
- App icon cleanup is cosmetic
- dSYM issues only affect crash reporting, not app functionality

**Testing Required**:
- Verify drag-and-drop still works after UTType declaration
- Test Archive → Upload to App Store Connect flow
- Confirm no new warnings appear

## Notes

- Priority is HIGH because these issues block clean distribution to TestFlight/App Store
- All issues are in build configuration, not runtime code
- Firebase dSYM warnings are common and usually don't affect app functionality, but should be resolved for proper crash reporting
