# Changelog

## [2026-01-29] - Branch: `UI-bug-fixes`
- **UI Unification**: Rebuilt Share Sheet into a List/Section editor aligned with Task Detail, added shared editor sections, editable notes/URL fields, and larger category chips across sheets in `ios-swift/Notelayer/Notelayer/Views/Shared/TaskEditorSections.swift`, `ios-swift/Notelayer/NotelayerShareExtension/ShareViewController.swift`, `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`, `ios-swift/Notelayer/Notelayer/Views/Shared/CategoryChipGridView.swift`.
- **Calendar Export Stability**: Introduced `CalendarEventEditSession` to prevent the native calendar editor from reopening/closing loops in `ios-swift/Notelayer/Notelayer/Views/Shared/CalendarEventEditView.swift`, `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`.
- **Theme Persistence & Dark Mode**: Timestamped theme persistence across app group + standard defaults and refreshed dark background handling in `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift`.
- **Input & Picker Polish**: Added keyboard dismiss helpers, aligned due/reminder pickers to include date+time, and updated task input behaviors in `ios-swift/Notelayer/Notelayer/Utils/KeyboardDismiss.swift`, `ios-swift/Notelayer/Notelayer/Views/TaskInputView.swift`, `ios-swift/Notelayer/NotelayerShareExtension/ShareViewController.swift`.
- **Project/Versioning**: Synced share extension version string and registered shared editor sources in `ios-swift/Notelayer/NotelayerShareExtension/Info.plist`, `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`.

## [2026-01-28] - Branch: `share-sheet-feature`
- **Feature**: Rebuilt the share extension UI with editable title, category chip grid, priority picker, due/reminder pickers, and content preview in `ios-swift/Notelayer/NotelayerShareExtension/ShareViewController.swift` plus new `ios-swift/Notelayer/Notelayer/Views/Shared/CategoryChipGridView.swift`.
- **Model/Sync**: Added shareable task fields (categories, priority, due date, reminder) and App Group category loading in `ios-swift/Notelayer/Notelayer/Data/SharedItem.swift`, and wired those fields through `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`.
- **Timing/Flow**: Moved shared-item processing to `ios-swift/Notelayer/Notelayer/Views/TodosView.swift` after backend sync delay, with launch logging in `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`.
- **UI/Polish**: Added an empty-state message for pending nags in `ios-swift/Notelayer/Notelayer/Views/RemindersSettingsView.swift`.
- **Project/Entitlements**: Added Share Extension app group entitlements and project wiring in `ios-swift/Notelayer/NotelayerShareExtension/NotelayerShareExtension.entitlements`, `ios-swift/Notelayer/NotelayerShareExtension/Info.plist`, and `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`.

## [2026-01-27] - Branch: `main`
- **Refactor**: Updated the `/ship` command logic in `.codex/prompts/ship.md` to adopt a droll, eccentric tone for public release notes.
- **Documentation**: Synchronized internal and external documentation rules to prioritize personality over corporate fluff.

## [2026-01-27] - Branch: `calendar-bug-fix`
- **Technical Fix**: Resolved a circular state update in the `.sheet(item:)` binding that caused the native iOS calendar event editor to auto-close immediately after presentation.
- **Files Touched**: `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`.
- **Refactor**: Updated `Binding` logic to only clear the state when explicitly set to `nil`, preventing SwiftUI from clearing the state during internal presentation updates.

## Branch: feature/app-store-metadata

**Purpose:** Prepare NoteLayer for App Store submission by completing pre-submission tasks including code cleanup, documentation creation, and verification tooling.

**Intent:** This branch addresses critical App Store launch requirements: productionewn-ready code (debug cleanup), complete metadata (description, keywords, promotional text), legal compliance (privacy policy), reviewer guidance (app review notes), asset preparation (screenshot guide), and submission verification (checklist + script).

**Quick Summary:**
- **Code Cleanup:** Wrapped 86 debug print statements in `#if DEBUG`, removed TODOs
- **Documentation:** Created App Store metadata, privacy policy, release checklist, app review notes, screenshot guide
- **Tooling:** Added pre-submission verification script
- **Assets:** Updated GoogleLogo with retina scale support

---

## Unreleased

### 2026-01-27 15:30:00 -0500 - Refactor: UI Consistency & Manage Account Overhaul (ios-standard-consistency)

#### Added
- **"The Big Red Button"**: Implemented a droll accordion-style section (`DisclosureGroup`) for account deletion in `ManageAccountView`, improving safety and visual hierarchy.
- **Branding**: Added official NoteLayer logo to the website link in `ProfileSettingsView` for brand consistency.
- **Exceptions Registry**: Created `.cursor/ui-consistency-exceptions.md` to track and justify intentional custom styling (e.g., branded app icons).

#### Changed
- **Manage Account Layout**: 
    - Grouped descriptive text in `VStack` blocks to suppress unnecessary `List` dividers, adhering to iOS platform standards for section content.
    - Relocated **Sign Out** to its own dedicated section between "Data" and "Danger Zone" for better organization.
- **UI Alignment**: Adjusted `TaskItemView` and `NagCardView` to ensure task reminder bell icons align perfectly with section expansion chevrons on the trailing edge.
- **Command Tooling**: Enhanced the `/ui-consistency` command with visual indicators (emojis), clickable code links to line numbers, and automated exception handling.

#### Fixed
- **Asset Referencing**: Corrected `ProfileSettingsView` to use the `NotelayerLogo` asset instead of attempting to reference the app icon directly as a SwiftUI image.

### 2026-01-27 09:18:23 -0500 - Feature: Task Reminders with Notifications (reminders-feature)

#### Added
- **Task Reminders**: Set reminders for any task with preset times (30 mins, 90 mins, 3 hours, tomorrow 9 AM) or custom date/time picker.
- **Local Notifications**: Receive notifications with task title and category icons. Notification actions: "Complete Task" or "Open Task".
- **Bell Icon Indicator**: Tasks with reminders show a 🔔 icon (or bell.slash if permissions denied).
- **Tap-to-Edit**: Tap reminder row in task details to quickly adjust time without removing and recreating.
- **Reminders Settings Page**: Dedicated settings page showing all upcoming reminders (soonest first) with swipe-to-cancel. Shows absolute and relative times (e.g., "Jan 27, 3:00 PM • In 2 hours").
- **Permission Handling**: First-time permission request when setting reminder. Banner in settings if denied with "Open Settings" link.
- **Context Menu Actions**: Long-press tasks to Set/Remove reminders directly from the list.

#### Changed
- **Task Model**: Added `reminderDate` and `reminderNotificationId` fields with Firebase sync.
- **Profile & Settings**: Added "Reminders" navigation link to manage all active reminders.
- **Notification System**: AppDelegate now handles notification actions (complete task, open task) with deep linking to TaskEditView.

#### Fixed
- **Smart Cancellation**: Notifications auto-cancel when tasks are completed or deleted.
- **Past Prevention**: Prevents scheduling reminders in the past.
- **Restore Logic**: If task uncompleted, reminder restored (but not rescheduled if time passed).
- **Cross-Device Sync**: Reminders stored in Firebase and rescheduled on device when synced (notifications fire locally on each device).

### 2026-01-26 20:45:00 -0500 - Overhaul: Authentication & Onboarding (improved-login)

#### Added
- **Welcome Experience**: First-launch `WelcomeView` with playful `AnimatedLogoView` (spin + confetti shatter effect).
- **Profile & Settings**: New comprehensive management page for account status, sync info, and sign-out.
- **Auth Components**: Reusable `AuthButtonView` with consistent Phone, Google, and Apple styling.
- **Notification Badges**: Red (not signed in) and Yellow (sync error) badges on gear icons in both tabs.
- **Website Link**: Prominent "Visit Notelayer" button in Profile settings.

#### Changed
- **Sign-In Redesign**: Rebuilt `SignInSheet` with inline Phone auth, country picker, and auto-formatting.
- **Header Branding**: Replaced "To-Dos" text with Notelayer logo in the main header.
- **Dynamic Header**: Implemented "squeeze" interaction that compresses the header on scroll while keeping controls visible.
- **Menu Reorg**: Renamed "Appearance" to "Colour Theme" and reordered gear menu items.
- **Terminology**: Updated "Todos" to "To-Dos" across the entire application.

#### Fixed
- **Stability**: Eliminated Firebase-related crashes by removing timing hacks and using proper async/await lifecycle.
- **Auth Logic**: Prevented linking multiple authentication providers to a single account.
- **Build Errors**: Resolved ambiguous math functions and task naming conflicts.

### 2026-01-25 17:12:45 -0500 - Update: New Task placement in grouped views

#### Changed
- "New Task" input appears after active tasks in Date, Priority, and Category groups (List view unchanged).

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
