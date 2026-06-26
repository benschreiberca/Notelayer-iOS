# Release Checklist - Notelayer iOS App

**Project**: Notelayer iOS  
**Bundle ID**: com.notelayer.app  
**Version**: 1.0  
**Build**: 1  
**Deployment Target**: iOS 16.0

---

## Code Quality

- [ ] All debug print() statements removed or wrapped
  - [ ] `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (66 print statements)
  - [ ] `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift` (15 print statements)
  - [ ] `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift` (1 print statement)
  - [ ] Wrap remaining print statements in `#if DEBUG` or remove entirely

- [ ] No TODO comments
  - [ ] `ios-swift/Notelayer/Notelayer/Data/SyncService.swift` (lines 10, 17, 22)

- [ ] No commented code
  - [ ] Review all Swift files for commented-out code blocks

- [ ] No test/placeholder data
  - [ ] Verify `SyncService.swift` placeholder methods are implemented or removed
  - [ ] Check for any hardcoded test data in views or data models

---

## Configuration

- [ ] Bundle ID: com.notelayer.app
  - [ ] Verify in `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj` (line 301, 338)
  - [ ] Verify in Xcode: Target → General → Bundle Identifier

- [ ] Version: 1.0, Build: 1
  - [ ] Verify MARKETING_VERSION = 1.0 in `project.pbxproj` (line 300, 337)
  - [ ] Verify CURRENT_PROJECT_VERSION = 1 in `project.pbxproj` (line 284, 321)
  - [ ] Verify in Xcode: Target → General → Version / Build

- [ ] Deployment target: iOS 16.0
  - [ ] Verify IPHONEOS_DEPLOYMENT_TARGET = 16.0 in `project.pbxproj` (line 209, 267, 295, 332)
  - [ ] Verify in Xcode: Target → General → Deployment Info

- [ ] Signing configured
  - [ ] Verify DEVELOPMENT_TEAM = DPVQ2X986Z in `project.pbxproj` (line 191, 255, 285, 322)
  - [ ] Verify CODE_SIGN_STYLE = Automatic in `project.pbxproj` (line 283, 320)
  - [ ] Verify in Xcode: Target → Signing & Capabilities → Team selected
  - [ ] Verify provisioning profile is valid

---

## Assets

- [ ] App icon 1024x1024 in Assets.xcassets
  - [ ] Verify `ios-swift/Notelayer/Notelayer/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` exists
  - [ ] Verify `Contents.json` references AppIcon-1024.png (lines 4-7, 16-19, 28-31)
  - [ ] Verify icon meets App Store requirements (no transparency, proper sizing)

- [ ] Launch screen configured
  - [ ] Verify `Info.plist` has `UILaunchScreen` key (line 30-31)
  - [ ] Verify launch screen displays correctly on all device sizes

- [ ] All required screenshots taken
  - [ ] iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max) - 1290 x 2796 pixels
  - [ ] iPhone 6.5" (iPhone 11 Pro Max, XS Max) - 1242 x 2688 pixels
  - [ ] iPhone 5.5" (iPhone 8 Plus) - 1242 x 2208 pixels
  - [ ] iPad Pro 12.9" (3rd gen) - 2048 x 2732 pixels
  - [ ] iPad Pro 12.9" (2nd gen) - 2048 x 2732 pixels

---

## Firebase

- [ ] GoogleService-Info.plist included
  - [ ] Verify `ios-swift/Notelayer/GoogleService-Info.plist` exists
  - [ ] Verify file is included in target (project.pbxproj line 10, 19, 139)
  - [ ] Verify all required keys are present (PROJECT_ID, CLIENT_ID, REVERSED_CLIENT_ID, etc.)

- [ ] Apple Sign-In enabled
  - [ ] Verify `ios-swift/Notelayer/Notelayer/Notelayer.entitlements` has `com.apple.developer.applesignin` (lines 5-8)
  - [ ] Verify Apple Sign-In capability enabled in Xcode: Target → Signing & Capabilities
  - [ ] Verify implementation in `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (signInWithApple method)

- [ ] Google Sign-In enabled
  - [ ] Verify Google Sign-In SDK dependency in `project.pbxproj` (lines 12, 38, 85, 122, 383-390, 399-403)
  - [ ] Verify implementation in `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (signInWithGoogle method)
  - [ ] Verify URL scheme configured in `Info.plist` (lines 45-57) with REVERSED_CLIENT_ID
  - [ ] Verify REVERSED_CLIENT_ID expands correctly (project.pbxproj line 303, 340)

- [ ] Phone Auth enabled
  - [ ] Verify implementation in `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (signInWithPhone, verifyPhoneCode methods)
  - [ ] Verify APNs configured (see APNs key item below)

- [ ] APNs key uploaded
  - [ ] Verify `aps-environment` in `Notelayer.entitlements` (line 9-10)
  - [ ] Verify APNs key uploaded to Firebase Console
  - [ ] Verify APNs token handling in `NotelayerApp.swift` (lines 56-94)
  - [ ] Verify production APNs token type for release builds (line 74)

- [ ] Firestore rules set
  - [ ] Verify Firestore security rules configured in Firebase Console
  - [ ] Verify rules allow authenticated users to read/write their own data
  - [ ] Test rules with Firebase Rules Playground

---

## App Store Connect

- [ ] App created
  - [ ] App created in App Store Connect
  - [ ] Bundle ID matches: com.notelayer.app
  - [ ] App name, subtitle, and description filled

- [ ] Privacy policy URL added
  - [ ] Privacy policy URL configured in App Store Connect
  - [ ] Privacy policy accessible and up-to-date

- [ ] All metadata filled
  - [ ] App name
  - [ ] Subtitle
  - [ ] Description
  - [ ] Keywords
  - [ ] Support URL
  - [ ] Marketing URL (if applicable)
  - [ ] Promotional text
  - [ ] What's New (for updates)

- [ ] Age rating completed
  - [ ] Age rating questionnaire completed
  - [ ] Rating appropriate for app content

- [ ] Build uploaded and selected
  - [ ] Archive created in Xcode: Product → Archive
  - [ ] Build uploaded to App Store Connect via Xcode Organizer
  - [ ] Build appears in App Store Connect → TestFlight → Builds
  - [ ] Build selected for submission

---

## Testing

- [ ] Tested on real device
  - [ ] App builds and runs on physical iPhone
  - [ ] App builds and runs on physical iPad (if supported)
  - [ ] No simulator-only code paths active

- [ ] All auth methods work
  - [ ] Apple Sign-In: `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (signInWithApple)
  - [ ] Google Sign-In: `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (signInWithGoogle)
  - [ ] Phone Auth: `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (signInWithPhone, verifyPhoneCode)
  - [ ] Sign out works correctly
  - [ ] Auth state persists across app launches

- [ ] Tasks CRUD works
  - [ ] Create task: `ios-swift/Notelayer/Notelayer/Views/TaskInputView.swift`
  - [ ] Read/view tasks: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
  - [ ] Update task: `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
  - [ ] Delete task: Verify delete functionality works
  - [ ] Task drag & drop: `ios-swift/Notelayer/Notelayer/Views/Shared/TodoDragPayload.swift`

- [ ] Notes CRUD works
  - [ ] Create note: Verify note creation works
  - [ ] Read/view notes: `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`
  - [ ] Update note: Verify note editing works
  - [ ] Delete note: Verify note deletion works

- [ ] Categories work
  - [ ] Category management: `ios-swift/Notelayer/Notelayer/Views/CategoryManagerView.swift`
  - [ ] Categories display correctly in task views
  - [ ] Category filtering works (if implemented)

- [ ] Themes work
  - [ ] Theme switching: `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`
  - [ ] Theme persistence: `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift`
  - [ ] Light/dark mode displays correctly

- [ ] Sync works
  - [ ] Sync service: `ios-swift/Notelayer/Notelayer/Data/SyncService.swift`
  - [ ] Backend sync: `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift`
  - [ ] Data syncs between devices
  - [ ] Offline mode works correctly

---

## Additional Pre-Submission Checks

- [ ] App Store Guidelines compliance
  - [ ] No placeholder content
  - [ ] All features functional
  - [ ] No broken links or empty screens

- [ ] Performance
  - [ ] App launches quickly (< 3 seconds)
  - [ ] No memory leaks
  - [ ] Smooth scrolling and animations

- [ ] Localization (if applicable)
  - [ ] All user-facing strings localized
  - [ ] Date/number formatting correct for locale

- [ ] Accessibility
  - [ ] VoiceOver support
  - [ ] Dynamic Type support
  - [ ] Color contrast meets WCAG standards

---

**Last Updated**: 2026-01-24  
**Status**: Pre-submission
