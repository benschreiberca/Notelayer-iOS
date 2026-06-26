# Firebase Build Errors After CocoaPods Integration

## TL;DR
- Build fails with missing Firebase module headers and module dependencies.
- `import Firebase`, `FirebaseAuth`, `FirebaseCore`, `GoogleSignIn`, and `FirebaseFirestore` are unresolved.
- CocoaPods Firebase umbrella header fails to locate `FirebaseCore/FirebaseCore.h`.

## Current State
- Build error:  
  `Clang dependency scanner failure: While building module 'Firebase' ... Firebase.h:15:9: fatal error: 'FirebaseCore/FirebaseCore.h' file not found`
- Module imports fail in app code:
  - `NotelayerApp.swift`: `Firebase`, `FirebaseAuth`, `FirebaseCore`, `GoogleSignIn`
  - `FirebaseBackendService.swift`: `FirebaseFirestore`

## Expected Outcome
- Build succeeds using CocoaPods Firebase + GoogleSignIn.
- `import Firebase`, `FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore`, and `GoogleSignIn` resolve without header/module errors.
- App launches with Firebase configured.

## Most Relevant Files (max 3)
- `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`
- `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift`
- `ios-swift/Notelayer/Podfile`

## Notes / Risks
- Likely caused by mismatched or incomplete pod integration (umbrella header can’t see FirebaseCore headers).
- Conflicts between SwiftPM and CocoaPods dependencies can surface as duplicate/missing module errors.

## Labels
- Type: bug
- Priority: high
- Effort: medium
