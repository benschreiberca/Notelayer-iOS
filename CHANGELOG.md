# Changelog

## Branch: feature/app-store-metadata

**Purpose:** Prepare NoteLayer for App Store submission by completing pre-submission tasks including code cleanup, documentation creation, and verification tooling.

**Intent:** This branch addresses critical App Store launch requirements: production-ready code (debug cleanup), complete metadata (description, keywords, promotional text), legal compliance (privacy policy), reviewer guidance (app review notes), asset preparation (screenshot guide), and submission verification (checklist + script).

**Quick Summary:**
- **Code Cleanup:** Wrapped 86 debug print statements in `#if DEBUG`, removed TODOs
- **Documentation:** Created App Store metadata, privacy policy, release checklist, app review notes, screenshot guide
- **Tooling:** Added pre-submission verification script
- **Assets:** Updated GoogleLogo with retina scale support

---

## Unreleased

### 2026-01-25 16:40:23 -0500 - Merge: ShakeUndo-and-delete

#### Added
- Shake to Undo support for task deletions.

#### Changed
- Task long-press menu now surfaces a Delete action.
- Task list grouping and category badge lookup optimized to reduce lag.

### 2026-01-25 11:58:57 -0500 - Merge: Beta improvements

#### Added
- Category deletion warning with a bulk reassign option for tasks in the category.

#### Fixed
- Done tasks can be unchecked to return to Doing, including when synced.
- New task control responds when tapping the plus icon.

### 2026-01-24 13:37:04 -0500 - Merge: feature/app-store-metadata

#### Added
- App Store metadata documentation (name, subtitle, description, keywords, promotional text) in `docs/APP_STORE_METADATA.md`.
- Privacy policy document in `docs/PRIVACY_POLICY.md` covering data collection, storage, third-party services, and user rights.
- Release checklist in `RELEASE_CHECKLIST.md` covering code quality, configuration, assets, Firebase setup, App Store Connect, and testing.
- App review notes in `docs/APP_REVIEW_NOTES.md` with testing instructions for App Store reviewers.
- Screenshot guide in `docs/SCREENSHOT_GUIDE.md` with step-by-step instructions for creating 6 App Store screenshots.
- Pre-submission verification script (`scripts/pre-submission-check.sh`) to validate bundle ID, version, build, deployment target, and capabilities.
- Debug code cleanup summary in `docs/DEBUG_CODE_CLEANUP_SUMMARY.md` documenting removal of debug prints and TODOs.

#### Changed
- Debug print statements wrapped in `#if DEBUG` to prevent console output in release builds (86 statements across AuthService, NotelayerApp, FirebaseBackendService).
- GoogleLogo asset updated with 2x and 3x scale entries for proper retina display support.

#### Removed
- TODO comments from SyncService replaced with implementation pending notes.
