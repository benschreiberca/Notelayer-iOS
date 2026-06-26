# App Store Rejection Fix - Guideline 5.1.1 & 5.1.2

**Status:** 🔴 Blocking App Store Approval  
**Priority:** Critical  
**Effort:** Medium  
**Submission ID:** b9f1495c-4b47-4f83-a383-07fd415b71c4  
**Review Date:** January 27, 2026  

## TL;DR

App rejected for two privacy guideline violations:
1. **5.1.2** - Privacy labels indicate tracking, but no App Tracking Transparency (ATT) framework implemented
2. **5.1.1(v)** - App supports account creation but lacks in-app account deletion

## Issue Details

### 1. Guideline 5.1.2 - Data Use and Sharing (Privacy Labels Misconfiguration)

**Current State:**
- App Store Connect privacy labels indicate the app "tracks" users by collecting:
  - User ID
  - Product Interaction  
  - Email Address
- No App Tracking Transparency (ATT) framework is implemented
- App uses Firebase only for authentication and data storage, NOT for advertising or third-party tracking

**Expected Outcome:**
- Privacy labels in App Store Connect should accurately reflect that the app does NOT track users for advertising
- Data collection should be categorized as "Data Used to Track You" = NONE
- Data should be categorized under "Data Linked to You" for functionality purposes only

**Root Cause:**
Privacy labels were likely misconfigured during initial App Store Connect setup. The app collects User ID, Email, and interaction data for core functionality (auth, sync, app features), NOT for cross-app/cross-site tracking or advertising.

**Solution:**
Update App Store Connect privacy labels to indicate:
- ✅ **Data Linked to You** (for app functionality): User ID, Email Address, Product Interaction
- ❌ **Data Used to Track You**: None
- ✅ **Tracking**: No

No code changes needed - this is a metadata fix in App Store Connect.

### 2. Guideline 5.1.1(v) - Account Deletion (Missing In-App Deletion)

**Current State:**
- Privacy policy (lines 94-100 in `docs/PRIVACY_POLICY.md`) states users must email `ben@benschreiber.ca` to request account deletion
- `ProfileSettingsView.swift` only has "Sign Out" button (line 79-88)
- No in-app account deletion flow exists

**Expected Outcome:**
- Users can initiate and complete account deletion entirely within the app
- Account deletion removes:
  - User from Firebase Authentication
  - All user data from Firestore (notes, tasks, categories)
  - Local cached data
- Confirmation dialog prevents accidental deletion
- Privacy policy updated to reflect in-app deletion

**Solution:**
Add account deletion feature to `ProfileSettingsView.swift`:
1. Add "Delete Account" button in signed-in section (destructive style, below Sign Out)
2. Show confirmation dialog with warning about permanent data loss
3. Implement deletion flow in `AuthService.swift`:
   - Delete all Firestore user data
   - Delete Firebase Auth user
   - Clear local data
4. Update privacy policy to mention in-app deletion

## Files to Modify

### Code Changes (for Account Deletion)
- `ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift` - Add Delete Account UI and flow
- `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` - Add `deleteAccount()` method
- `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift` - Add `deleteAllUserData()` method

### Documentation Changes
- `docs/PRIVACY_POLICY.md` - Update section 5 (User Rights > Account Deletion) to reflect in-app deletion
- App Store Connect - Update privacy labels (no tracking)

## Implementation Plan

### Phase 1: Privacy Labels Fix (Can do immediately)
1. Log into App Store Connect
2. Navigate to App Privacy section
3. Review and correct privacy labels:
   - Remove any "Data Used to Track You" entries
   - Move User ID, Email, Product Interaction to "Data Linked to You" 
   - Ensure "Tracking" is set to "No"
4. Reply to App Review explaining the correction

### Phase 2: Account Deletion Feature (Code changes required)
1. Add `deleteAccount()` method to AuthService
2. Add `deleteAllUserData()` method to FirebaseBackendService  
3. Update ProfileSettingsView with Delete Account button and confirmation dialog
4. Update privacy policy
5. Test deletion flow thoroughly

### Phase 3: Resubmission
1. Build new version (bump to 1.0 build 2)
2. Update Review Notes in App Store Connect to explain fixes
3. Resubmit for review

## Risk Assessment

**Low Risk:**
- Privacy labels fix is metadata-only, no code changes
- Account deletion is a new feature, doesn't affect existing functionality

**Testing Required:**
- Account deletion flow (Firebase Auth + Firestore + Local)
- Ensure deletion is permanent and complete
- Test on device (not just simulator) due to Firebase

**Rollback Plan:**
- Privacy labels can be edited anytime
- Account deletion can be disabled via feature flag if issues arise

## Apple's Response Options

Apple provided three resolution paths for 5.1.2:
1. ✅ **Update privacy info if app doesn't track** - THIS IS THE CORRECT PATH
2. ❌ Notify if tracks on other platforms but not iOS - Not applicable
3. ❌ Implement ATT if app tracks - Not needed, app doesn't track

## Notes

- This is a metadata + feature gap issue, not a fundamental architecture problem
- Firebase usage for auth/data storage is completely fine
- The key distinction: We collect data FOR app functionality, not for advertising/tracking
- Account deletion must be truly permanent per Apple guidelines
- Consider adding export data feature in future (mentioned in privacy policy but not required for approval)

## Definition of Done

- [ ] App Store Connect privacy labels updated to reflect no tracking
- [ ] Account deletion button added to ProfileSettingsView
- [ ] Account deletion deletes Firebase Auth user
- [ ] Account deletion removes all Firestore user data
- [ ] Account deletion clears local cached data
- [ ] Confirmation dialog prevents accidental deletion
- [ ] Privacy policy updated with in-app deletion instructions
- [ ] Tested on physical device with real Firebase project
- [ ] App resubmitted with updated Review Notes
- [ ] App approved by Apple

---

**Contact:** Ben Schreiber (ben@benschreiber.ca)  
**Branch:** `appstore-submission`
