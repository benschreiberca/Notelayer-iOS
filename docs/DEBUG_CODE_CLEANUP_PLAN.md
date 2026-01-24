# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Remove debug code and polish the Swift codebase by wrapping print statements in `#if DEBUG`, removing TODO comments, cleaning up commented-out code, and eliminating test data/placeholders. This will improve production readiness and code cleanliness.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- **Decision 1**: Wrap print statements in `#if DEBUG` rather than removing them entirely - This preserves useful debugging capability during development while hiding them in production builds
- **Decision 2**: Remove TODO comments completely - These are tracked elsewhere and don't belong in production code
- **Decision 3**: Remove placeholder comments and empty placeholder functions - SyncService.swift contains placeholder code that should be cleaned up
- **Decision 4**: Keep documentation comments - Only remove commented-out code blocks, not explanatory comments

## Tasks:

- [ ] 🟥 **Step 1: Clean up AuthService.swift**
  - [ ] 🟥 Wrap all print() statements (50+ instances) in #if DEBUG
  - [ ] 🟥 Review and remove any commented-out code blocks
  - [ ] 🟥 Verify no test data or hardcoded values

- [ ] 🟥 **Step 2: Clean up NotelayerApp.swift**
  - [ ] 🟥 Wrap all print() statements (20+ instances) in #if DEBUG
  - [ ] 🟥 Review and remove any commented-out code blocks
  - [ ] 🟥 Verify no test data or hardcoded values

- [ ] 🟥 **Step 3: Clean up FirebaseBackendService.swift**
  - [ ] 🟥 Wrap print() statement in #if DEBUG
  - [ ] 🟥 Review and remove any commented-out code blocks
  - [ ] 🟥 Verify no test data or hardcoded values

- [ ] 🟥 **Step 4: Clean up SyncService.swift**
  - [ ] 🟥 Remove all TODO comments (3 instances)
  - [ ] 🟥 Remove placeholder comments (3 instances)
  - [ ] 🟥 Review if placeholder functions should be removed or kept as empty implementations

- [ ] 🟥 **Step 5: Review all other Swift files**
  - [ ] 🟥 Check remaining Swift files for any print() statements missed
  - [ ] 🟥 Check for any commented-out code blocks
  - [ ] 🟥 Check for any test data, placeholders, or hardcoded test values
  - [ ] 🟥 Files to review: LocalStore.swift, Models.swift, ThemeManager.swift, CategoryColorDefaults.swift, AppearanceStore.swift, BackendSyncing.swift, and all View files

- [ ] 🟥 **Step 6: Final verification**
  - [ ] 🟥 Run grep to verify no unwrapped print() statements remain
  - [ ] 🟥 Run grep to verify no TODO comments remain
  - [ ] 🟥 Verify code still compiles successfully
  - [ ] 🟥 Create summary of all changes made
