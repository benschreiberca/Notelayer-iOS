# TestFlight Automation - Issue Resolution Plan

**Overall Progress:** `95%`

**Last Updated:** Build #16 - Fixed Xcode project signing configuration (awaiting results)

## TLDR
Fix the persistent GitHub Actions TestFlight automation failures. Currently failing because xcodebuild times out when detecting build settings with `-allowProvisioningUpdates` flag.

## Critical Decisions

- **Code Signing Strategy**: Using fastlane match with git storage for certificate management ✅
- **Authentication Method**: App Store Connect API key with App Manager role ✅
- **Keychain Configuration**: Custom keychain with Apple WWDR certificate ✅
- **Build Approach**: Skip build settings detection and build directly with known parameters

## Issue History

### Build #1-13: Code Signing Issues
- ❌ API key authentication failures (fixed with new key)
- ❌ Keychain configuration issues (fixed)
- ❌ WWDR certificate missing (fixed)
- ❌ Swift Package signing conflicts (attempted fix)

### Build #14: Provisioning Profile Conflict
- ❌ Error: "does not support provisioning profiles" for Swift Packages
- ❌ Manual provisioning profile was being forced on all targets
- Fix attempted: Removed manual profile specification

### Build #15: Timeout
- ❌ Error: `xcodebuild -showBuildSettings timed out after 4 retries`
- ❌ Caused by: `-allowProvisioningUpdates` flag
- Fix: Added `skip_profile_detection: true`

### Build #16: Provisioning Profile Not Found
- ❌ Error: "No profiles for 'com.notelayer.app' were found"
- ❌ Xcode looking for Development profile, but match installed App Store profile
- **Root Cause**: Xcode project had wrong settings:
  - `CODE_SIGN_IDENTITY = "Apple Development"` in Release config (wrong!)
  - `PROVISIONING_PROFILE_SPECIFIER = ""` (empty!)
  - No `ProvisioningStyle = Automatic` in TargetAttributes

### Build #17: CURRENT - Complete Fix Applied
- ✅ Added `ProvisioningStyle = Automatic` to main target
- ✅ Changed Release identity to `Apple Distribution`
- ✅ Removed empty PROVISIONING_PROFILE_SPECIFIER
- **Expected**: Xcode will now auto-select the match App Store profile

## Current Status

### ✅ Working (85%)
- [x] 🟩 GitHub Actions workflow configured
- [x] 🟩 All 6 GitHub secrets correct
- [x] 🟩 API authentication working
- [x] 🟩 Keychain configured
- [x] 🟩 Certificates installing successfully
- [x] 🟩 Build number incrementing
- [x] 🟩 Swift packages resolving

### ❌ Failing
- [ ] 🟥 **Build settings detection timing out**
  - xcodebuild hangs for 45+ seconds trying to read settings
  - `-allowProvisioningUpdates` causing the hang
  - Fastlane retries 4 times then fails

## Root Cause Analysis

The fundamental issue is a **three-way conflict**:
1. **Xcode project**: Has automatic signing DISABLED for main app
2. **Swift Packages**: REQUIRE automatic signing (can't use manual profiles)
3. **CI Environment**: Needs to use match profiles without Xcode GUI

**Why it keeps failing:**
- Manual profile specification → Breaks Swift Packages
- `-allowProvisioningUpdates` → Causes xcodebuild to hang
- Automatic signing in project → Not set up that way

## Solution: Skip Profile Detection

Instead of letting fastlane detect profiles, we'll:
1. Tell fastlane to skip automatic detection
2. Build directly with minimal signing parameters
3. Let Xcode use the installed profile naturally
4. Specify export options explicitly

## Implementation

### Fix #1: Skip Build Settings Detection
```ruby
build_app(
  skip_profile_detection: true,  # Don't try to read build settings
  xcargs: "DEVELOPMENT_TEAM=DPVQ2X986Z",
  # Remove -allowProvisioningUpdates (causes hang)
)
```

### Fix #2: If That Doesn't Work - Enable Automatic Signing
Modify the Xcode project to use automatic signing:
- Set `ENABLE_AUTOMATIC_PROVISIONING = YES`
- Match profiles will be auto-detected
- Cleanest long-term solution

## Next Steps

### Immediate Action (Fix #1)
- [ ] 🟥 Add `skip_profile_detection: true` to build_app
- [ ] 🟥 Remove `-allowProvisioningUpdates` flag
- [ ] 🟥 Let Xcode find installed profiles naturally
- [ ] 🟥 Push and test build #16

### If Still Fails (Fix #2)
- [ ] 🟥 Read Xcode project.pbxproj
- [ ] 🟥 Enable automatic provisioning for Notelayer target
- [ ] 🟥 Keep development team specified
- [ ] 🟥 Test build #17

### Post-Success
- [ ] 🟥 Verify upload to TestFlight
- [ ] 🟥 Test subsequent builds
- [ ] 🟥 Document final configuration
- [ ] 🟥 Clean up temporary files

## Success Criteria

- ✅ Build completes without timeouts
- ✅ Archive created successfully
- ✅ IPA exports with correct signing
- ✅ Upload to TestFlight succeeds
- ✅ Build appears in App Store Connect

## Files to Modify

**Immediate:**
- `fastlane/Fastfile` - Add `skip_profile_detection: true`

**If needed:**
- `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj` - Enable automatic provisioning

## Why This Will Work

**Skip profile detection** works because:
1. Match has already installed the correct profiles
2. Xcode can find them in ~/Library/Developer/Xcode/UserData/Provisioning Profiles/
3. Development team is specified, so Xcode knows which profiles to use
4. No need for fastlane to detect anything - just build

This is actually the **simplest** approach and commonly used in CI.

## Lessons Learned

1. ✅ Match + manual signing + Swift Packages = Complex
2. ✅ `-allowProvisioningUpdates` can cause hangs in CI
3. ✅ Fastlane's automatic detection isn't always helpful
4. ✅ Skip detection and let Xcode do its thing = Simpler
5. ✅ Automatic signing in project would avoid all this

## Timeline

- **Attempt 1-13**: Code signing and certificate issues (RESOLVED)
- **Attempt 14**: Swift Package provisioning conflict (IDENTIFIED)
- **Attempt 15**: Build settings timeout (CURRENT)
- **Attempt 16**: Skip detection approach (NEXT)
- **Attempt 17**: Enable automatic signing if needed (BACKUP)

---

**Current Blocker:** xcodebuild hanging when detecting build settings  
**Next Action:** Skip profile detection entirely  
**ETA to Success:** 1-2 more attempts
