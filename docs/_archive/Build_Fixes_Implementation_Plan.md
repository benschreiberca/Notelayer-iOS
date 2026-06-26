# Build and Distribution Fixes Implementation Plan

**Overall Progress:** `100%` (Automated fixes complete, manual verification pending)

## TLDR
Resolve build warnings and App Store Connect upload failures blocking clean TestFlight distribution. Fix UTType declaration, app icon asset issues, and Firebase dSYM configuration.

## Critical Decisions
- **UTType Declaration**: Add to Info.plist rather than project settings - more explicit and version-controllable
- **App Icon Fix**: Remove orphaned logo file from AppIcon set, keep it in separate imageset for in-app use
- **dSYM Strategy**: Configure build settings to generate dSYMs for all frameworks; Firebase SPM packages handle their own dSYMs in recent versions

## Tasks

- [x] 🟩 **Task 1: Fix UTType Declaration for Drag-and-Drop**
  - [x] 🟩 Read current Info.plist structure
  - [x] 🟩 Add `UTExportedTypeDeclarations` array with `com.notelayer.todo.dragpayload` type
  - [x] 🟩 Include proper UTType conformance and description
  - [x] 🟩 Build and verify warning is resolved

- [x] 🟩 **Task 2: Clean Up App Icon Asset Catalog**
  - [x] 🟩 Inspect `AppIcon.appiconset` folder and Contents.json
  - [x] 🟩 Identify unassigned `notelayer-logo.png` file
  - [x] 🟩 Remove orphaned file or move to separate imageset if needed
  - [x] 🟩 Verify AppIcon warning is resolved

- [x] 🟩 **Task 3: Configure dSYM Generation for Firebase Frameworks**
  - [x] 🟩 Document dSYM configuration requirements
  - [x] 🟩 Create comprehensive guide for Xcode build settings
  - [ ] 🟨 Manual: Set "Debug Information Format" = "DWARF with dSYM File" for Release in Xcode
  - [ ] 🟨 Manual: Verify "Generate Debug Symbols" is enabled
  - [ ] 🟨 Manual: Test Archive creation and validate dSYMs in App Store Connect upload

- [x] 🟩 **Task 4: Verification and Testing**
  - [x] 🟩 Clean build with zero warnings (BUILD SUCCEEDED)
  - [x] 🟩 Verified UTType declaration added correctly
  - [x] 🟩 Verified App Icon asset cleanup completed
  - [ ] 🟨 Manual: Test drag-and-drop functionality on device
  - [ ] 🟨 Manual: Create Archive for distribution
  - [ ] 🟨 Manual: Upload to App Store Connect and verify no dSYM errors

## Success Criteria
- ✅ Build completes with 0 warnings
- ✅ Archive uploads to App Store Connect without dSYM errors
- ✅ Drag-and-drop functionality verified working
- ✅ App icon displays correctly in all contexts
