# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Stabilize Firebase + GoogleSignIn integration via CocoaPods, remove conflicting SwiftPM artifacts, and ensure the workspace builds cleanly without missing module/header errors.

## Critical Decisions
- Decision 1: Standardize on CocoaPods for Firebase + GoogleSignIn to avoid SwiftPM/CocoaPods module conflicts.
- Decision 2: Keep Firebase imports in app code and validate header/module visibility via a clean workspace build.

## Tasks:

- [x] 🟩 **Step 1: Verify current dependency state**
  - [x] 🟩 Confirm Podfile pod set and versions (Firebase + GoogleSignIn + GTMSessionFetcher)
  - [x] 🟩 Ensure SwiftPM GoogleSignIn references are fully removed from `project.pbxproj`

- [x] 🟩 **Step 2: Regenerate pods cleanly**
  - [x] 🟩 Run `pod install` with UTF-8 env
  - [x] 🟩 Resolve any pod resolution conflicts (GTMSessionFetcher version alignment)

- [x] 🟩 **Step 3: Validate build path + module visibility**
  - [x] 🟩 Build from `Notelayer.xcworkspace` via `xcodebuild`
  - [x] 🟩 Confirm `import Firebase`, `FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore`, `GoogleSignIn` resolve

- [x] 🟩 **Step 4: Document remaining warnings or follow-ups**
  - [x] 🟩 Capture any pod deployment target warnings or script warnings
    - Pod deployment target warnings for several pods (e.g., GoogleSignIn, GTMSessionFetcher, AppAuth, gRPC, abseil).
    - Build script warning: "Create Symlinks to Header Folders" runs every build (no outputs set).
  - [x] 🟩 Note optional cleanup tasks (if needed) without changing scope
    - Optional: align pod deployment targets to project minimum in a post_install hook if you want warning-free builds.
    - Optional: add output paths to the "Create Symlinks to Header Folders" script to avoid always-run warning.
