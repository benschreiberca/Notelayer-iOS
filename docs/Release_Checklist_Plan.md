# Release Checklist Plan

**Overall Progress:** `0%`

## TLDR
Create a comprehensive release checklist document (`RELEASE_CHECKLIST.md`) that covers all aspects of preparing the Notelayer iOS app for App Store submission, including code quality checks, configuration verification, asset validation, Firebase setup, App Store Connect requirements, and testing procedures.

## Critical Decisions
- Decision 1: Include file locations for each checklist item - Makes it easier to verify and fix issues
- Decision 2: Organize by category (Code Quality, Configuration, Assets, Firebase, App Store Connect, Testing) - Logical grouping for systematic review
- Decision 3: Mark items with specific file paths where applicable - Provides actionable guidance

## Tasks:

- [ ] 🟥 **Step 1: Create RELEASE_CHECKLIST.md structure**
  - [ ] 🟥 Create file in root directory
  - [ ] 🟥 Add header with project info
  - [ ] 🟥 Create section headers for each category

- [ ] 🟥 **Step 2: Populate Code Quality section**
  - [ ] 🟥 Add checklist for debug print() statements (87 found in codebase)
    - [ ] 🟥 List files with print statements: `AuthService.swift`, `NotelayerApp.swift`, `FirebaseBackendService.swift`
  - [ ] 🟥 Add checklist for TODO comments (found in `SyncService.swift`)
  - [ ] 🟥 Add checklist for commented code
  - [ ] 🟥 Add checklist for test/placeholder data

- [ ] 🟥 **Step 3: Populate Configuration section**
  - [ ] 🟥 Add Bundle ID verification: `com.notelayer.app` (from `project.pbxproj`)
  - [ ] 🟥 Add Version/Build verification: Version 1.0, Build 1 (from `project.pbxproj`)
  - [ ] 🟥 Add Deployment target: iOS 16.0 (from `project.pbxproj`)
  - [ ] 🟥 Add Signing configuration check (DEVELOPMENT_TEAM = DPVQ2X986Z)

- [ ] 🟥 **Step 4: Populate Assets section**
  - [ ] 🟥 Add App icon check: `Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
  - [ ] 🟥 Add Launch screen check (configured in `Info.plist`)
  - [ ] 🟥 Add Screenshots placeholder (to be taken)

- [ ] 🟥 **Step 5: Populate Firebase section**
  - [ ] 🟥 Add GoogleService-Info.plist check: `ios-swift/Notelayer/GoogleService-Info.plist`
  - [ ] 🟥 Add Apple Sign-In check: `Notelayer.entitlements` (com.apple.developer.applesignin)
  - [ ] 🟥 Add Google Sign-In check (implemented in `AuthService.swift`)
  - [ ] 🟥 Add Phone Auth check (implemented in `AuthService.swift`)
  - [ ] 🟥 Add APNs key check (aps-environment in entitlements)
  - [ ] 🟥 Add Firestore rules placeholder

- [ ] 🟥 **Step 6: Populate App Store Connect section**
  - [ ] 🟥 Add App creation checklist
  - [ ] 🟥 Add Privacy policy URL placeholder
  - [ ] 🟥 Add Metadata checklist
  - [ ] 🟥 Add Age rating checklist
  - [ ] 🟥 Add Build upload checklist

- [ ] 🟥 **Step 7: Populate Testing section**
  - [ ] 🟥 Add Real device testing checklist
  - [ ] 🟥 Add Auth methods testing (Apple, Google, Phone)
  - [ ] 🟥 Add Tasks CRUD testing
  - [ ] 🟥 Add Notes CRUD testing
  - [ ] 🟥 Add Categories testing
  - [ ] 🟥 Add Themes testing
  - [ ] 🟥 Add Sync testing

- [ ] 🟥 **Step 8: Add file location references**
  - [ ] 🟥 Add file paths to Code Quality items
  - [ ] 🟥 Add file paths to Configuration items
  - [ ] 🟥 Add file paths to Assets items
  - [ ] 🟥 Add file paths to Firebase items
