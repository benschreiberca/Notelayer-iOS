# Issue: Phone Auth Warning About App Delegate Swizzling

## TL;DR
Phone auth fails with the Firebase warning: “If app delegate swizzling is disabled, remote notifications received by UIApplicationDelegate need to be forwarded to FirebaseAuth’s canHandleNotification method.” Need to verify APNS/remote notification registration flow and ensure Firebase Auth is receiving the APNS token + notifications on real devices.

## Current Behavior
- On “Send code” in phone auth, the UI shows the Firebase warning about App Delegate swizzling being disabled.
- Phone auth does not proceed as expected.

## Expected Behavior
- Phone auth should send/verify without surfacing Firebase’s swizzling warning.
- If the user is already signed in, show a friendly message, not a Firebase internal warning.

## Context / Notes
- APNS auth keys (sandbox + production) were created and uploaded to Firebase.
- The warning suggests Firebase is not receiving APNS notifications or believes swizzling is disabled.

## Suspected Causes
- Remote notification registration may be incomplete (missing authorization request before `registerForRemoteNotifications`).
- Firebase Messaging/Auth delegate wiring may be incomplete for SwiftUI AppDelegate.
- `FirebaseAppDelegateProxyEnabled` may be disabled or overridden in the built Info.plist/xcconfig.
- APNS token isn’t being delivered or set (device token not logged / not forwarded).

## Relevant Files (max 3)
- `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift` (AppDelegate: APNS token handling, `canHandleNotification`)
- `ios-swift/Notelayer/Notelayer/Services/AuthService.swift` (phone auth start/verify flow)
- `ios-swift/Notelayer/Notelayer/Views/SignInSheet.swift` (phone auth UI + `prepareForPhoneAuth` trigger)

## Repro Steps
1) Fresh install on real device.
2) Open Welcome → Phone auth → enter number → “Send code”.
3) Observe warning text about app delegate swizzling.

## Checklist for Verification
- Confirm `UNUserNotificationCenter.current().delegate` is set early enough.
- Confirm `UNUserNotificationCenter.current().requestAuthorization` is called before `registerForRemoteNotifications`.
- Confirm APNS device token is logged on device and passed to `Auth.auth().setAPNSToken`.
- Confirm Firebase receives notifications via `Auth.auth().canHandleNotification`.
- Confirm `FirebaseAppDelegateProxyEnabled` is not disabled in build output.

## Labels
- Type: bug
- Priority: normal
- Effort: medium
