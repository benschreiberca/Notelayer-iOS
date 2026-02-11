# Changelog

## [2026-02-11] - Branch: codex/small-nav-tweak
- **Global Bottom-Clearance Standardization**: Introduced a shared tab clearance contract in `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift` via `AppBottomClearance` (`tabRowHeight`, `contentBottomSpacerHeight`, `tabBottomPadding`) and switched page-level bottom insets to consume the shared value instead of per-view constants.
- **No-Overlap Enforcement Across Tabs**: Applied the shared bottom spacer to `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, and `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (including all Insights drilldowns) to keep the final card/rows above the floating tab pill.
- **Insights Row Pattern Consolidation**: Implemented reusable row primitives (`DataRowModel`, `DataRowView`, `DataRowsSection`) in `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` and migrated drilldown row sections to remove repeated per-section `HStack` styling.
- **Insights Interaction + Copy Alignment**: Updated Insights copy and behavior for consistency, including Title Case normalization, right-side value placement for category/export rows, and retained secondary metadata beneath primary labels in detail sections.
- **Insights Coverage/Oldest-Task Expansion**: Landed compact/expandable coverage card behavior plus oldest-open-task overview/drilldown support through `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`, `ios-swift/Notelayer/Notelayer/Services/InsightsAggregator.swift`, and `ios-swift/Notelayer/NotelayerInsightsTests/InsightsAggregatorTests.swift`.
- **Planning + Design Docs Sync**: Updated implementation and PRD tracking docs (including `docs/Insights_Data_Row_Patterns_Implementation_Plan.md` and related PRD plan files) and added design-system guidance in `docs/DesignSystem/Documentation/Data_Row_Patterns_Reference_Guide.md`.

## [2026-02-10] - Branch: Overhaul-Personal-dashboard
- **Documentation Canonicalization**: Migrated and normalized project docs from root-level markdown files into structured `docs/` artifacts with index hubs and governance references (notably `docs/000_Docs_Start_Here.md`, `docs/010_Docs_Features_Hub.md`, `docs/040_Docs_Governance.md`, `scripts/docs_snapshot.sh`).
- **Insights Platform Build-Out**: Added the Insights tab experience and analytics pipeline, including telemetry definitions, storage, and aggregation in `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`, `ios-swift/Notelayer/Notelayer/Data/InsightsMetricDefinitions.swift`, `ios-swift/Notelayer/Notelayer/Services/InsightsTelemetryStore.swift`, and `ios-swift/Notelayer/Notelayer/Services/InsightsAggregator.swift`.
- **Instrumentation Expansion**: Broadened usage telemetry coverage and attribution across task/edit/calendar flows in `ios-swift/Notelayer/Notelayer/Services/AnalyticsService.swift`, `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, and `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`.
- **Header + Navigation Consistency**: Unified top-level header affordances and shared header components across tabs while preserving feature-specific center controls in `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`, and `ios-swift/Notelayer/Notelayer/Views/Shared/AppTabHeaderComponents.swift`.
- **Keyboard/Tab Bar Interaction**: Updated root floating tab behavior to hide during keyboard presentation and adjusted insets to avoid content overlap in `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift` and `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`.
- **Testing + Project Wiring**: Added Insights-focused test target/scheme and supporting fixtures in `ios-swift/Notelayer/NotelayerInsightsTests/` and updated project/scheme definitions in `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`, `ios-swift/Notelayer/Notelayer.xcodeproj/xcshareddata/xcschemes/Notelayer.xcscheme`, and `ios-swift/Notelayer/Notelayer.xcodeproj/xcshareddata/xcschemes/NotelayerInsightsTests.xcscheme`.

## [2026-02-09] - Branch: `Overhaul-Personal-dashboard`
- **Insights Feature**: Added a new root `Insights` tab after `To-Dos` with overview + drill-down analytics built in Swift Charts in `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`, `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`.
- **Insights Data Model**: Added metric/fidelity contracts and feature catalog enums in `ios-swift/Notelayer/Notelayer/Data/InsightsMetricDefinitions.swift`.
- **Telemetry Storage**: Added local per-device Insights telemetry persistence with scope isolation, schema migration handling, and raw-event compaction in `ios-swift/Notelayer/Notelayer/Services/InsightsTelemetryStore.swift`.
- **Aggregation Engine**: Added deterministic snapshot aggregation for totals, trends, categories, ranking, time-of-day, gap analysis, and calendar-export rates in `ios-swift/Notelayer/Notelayer/Services/InsightsAggregator.swift`.
- **Instrumentation Expansion**: Mirrored analytics events into local Insights telemetry and expanded category attribution for task/reminder/calendar events in `ios-swift/Notelayer/Notelayer/Services/AnalyticsService.swift`, `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`.
- **Auth Scope Wiring**: Bound Insights telemetry scope to signed-in user changes in `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift`.
- **Testing**: Added dedicated `NotelayerInsightsTests` target and deterministic coverage for formulas, windows, timezone handling, scope isolation, compaction, ranking, and stress fixtures in `ios-swift/Notelayer/NotelayerInsightsTests/InsightsAggregatorTests.swift`, `ios-swift/Notelayer/NotelayerInsightsTests/InsightsStressFixture.swift`.
- **Validation Docs**: Added Insights validation and performance fixture guide in `docs/INSIGHTS_VALIDATION_GUIDE.md`, and updated telemetry docs/release notes in `ANALYTICS_EVENTS.md`, `APP_STORE_RELEASE_NOTES.md`, `release_notes.md`.

## [2026-02-08] - Branch: `new-auth-flow`
- **Auth UI Simplification**: Removed phone sign-in from the Welcome screen and SignInSheet, and surfaced email magic link as the primary path in `ios-swift/Notelayer/Notelayer/Views/WelcomeView.swift`, `ios-swift/Notelayer/Notelayer/Views/SignInSheet.swift`, `ios-swift/Notelayer/Notelayer/Views/Shared/AuthButtonView.swift`.
- **Magic Link Defaults**: Reverted magic-link ActionCodeSettings to the default Firebase hosting domain and cleared custom link domain usage in `ios-swift/Notelayer/Notelayer/Services/AuthService.swift`.
- **APNS/Auth Plumbing**: Added APNS token storage + reapplication hooks, explicit notification handlers, and additional auth logging; disabled Firebase/GoogleUtilities swizzling via Info.plist flags in `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`, `ios-swift/Notelayer/Notelayer/Services/AuthService.swift`, `ios-swift/Notelayer/Info.plist`.
- **Universal Links**: Added `auth.getnotelayer.com` associated domains entries to debug/release entitlements in `ios-swift/Notelayer/Notelayer/Notelayer.entitlements`, `ios-swift/Notelayer/Notelayer/NotelayerRelease.entitlements`.
- **Firebase Hosting Artifacts**: Added Firebase Hosting config and project metadata in `firebase.json`, `.firebaserc`, `.firebase/`, and `firebase-hosting/`.
- **Docs/Notes**: Updated planning prompt and auth issue notes in `.codex/prompts/create-plan.md`, `AUTH_EMAIL_MAGIC_LINK_AND_PHONE_AUTH_ERROR_ISSUE.md`, and `performance-build-assessment.md`.

## [2026-02-08] - Branch: `Firebase-Auth-fix`
- **Auth Config + Versioning**: Expanded the Google sign-in URL scheme and reversed client ID for release builds, added a release entitlements file with production APNS + Apple Sign In + app group, aligned the share extension bundle version with the app, and bumped marketing/build versions in `ios-swift/Notelayer/Info.plist`, `ios-swift/Notelayer/NotelayerShareExtension/Info.plist`, `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`, `ios-swift/Notelayer/Notelayer/NotelayerRelease.entitlements`.
- **Firebase Sync Safety**: Added FirebaseCore import, tracked backend user ID, and guarded force sync against missing config, missing auth, and concurrent runs in `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift`.
- **Profile Refresh Behavior**: Disabled the manual refresh control and added force-refresh guards for signed-out users in `ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift`.
- **Pods Build Fix**: Removed stale GoogleSignIn image resource references to stop missing-input build errors in `ios-swift/Notelayer/Pods/Pods.xcodeproj/project.pbxproj`.
- **Docs/Notes**: Updated the plan prompt and refreshed the auth+sync issue note in `.codex/prompts/create-plan.md`, `authentication-and-sync-issues.md` (replacing the previous file).

## [2026-02-04] - Branch: `usage-analytics-hooks`
- **Analytics Core**: Added centralized analytics wrapper with event constants, view names, and screenshot-mode suppression in `ios-swift/Notelayer/Notelayer/Services/AnalyticsService.swift`.
- **View/Navigation Tracking**: Wired tab/view open + duration tracking across tabs, Todos modes, and sheets in `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, `ios-swift/Notelayer/Notelayer/Views/NotesView.swift`, `ios-swift/Notelayer/Notelayer/Views/RemindersSettingsView.swift`.
- **Task/Category/Reminder Events**: Instrumented task and category lifecycle changes plus reminder scheduling/clearing in `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`, `ios-swift/Notelayer/Notelayer/Views/ReminderPickerSheet.swift`.
- **Calendar + Theme Hooks**: Added calendar export analytics in `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`, and theme change analytics in `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`.
- **Documentation**: Added analytics reference and release notes artifacts in `ANALYTICS_EVENTS.md`, `APP_STORE_RELEASE_NOTES.md`, `USAGE_ANALYTICS_PLAN.md`, and updated `release_notes.md`.
- **Versioning**: Bumped build number to 8 in `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`.

## [2026-02-03] - Branch: `firebase-analytics-fix`
- **Firebase/CocoaPods Integration**: Added CocoaPods setup for Firebase + Google Sign-In and generated workspace/Pods artifacts in `ios-swift/Notelayer/Podfile`, `ios-swift/Notelayer/Podfile.lock`, `ios-swift/Notelayer/Notelayer.xcworkspace/`, `ios-swift/Notelayer/Pods/`.
- **Project Wiring Cleanup**: Removed SwiftPM resolution file and updated project build settings for new dependency graph in `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`, `ios-swift/Notelayer/Notelayer.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
- **Firebase Init & Debugging**: Ensured single Firebase startup path, re-added FirebaseCore import where needed, and tagged AppDelegate for swizzling in `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`, `ios-swift/Notelayer/Notelayer/Services/AuthService.swift`.
- **Analytics Debug Flags**: Added Analytics debug launch arguments in `ios-swift/Notelayer/Notelayer.xcodeproj/xcshareddata/xcschemes/Notelayer.xcscheme`.
- **Versioning Alignment**: Bumped build number to 7 and synced Share Extension versioning in `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`, `ios-swift/Notelayer/NotelayerShareExtension/Info.plist`.
- **UI Build Fix**: Removed an unused ViewBuilder expression in `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`.

## [2026-02-02] - Branch: `design-system-theme-refactor`
- **Theme Surface Tinting**: Implemented derived surface tinting with base ladders + tint strengths, including a neutral “white cards” theme, in `ios-swift/Notelayer/Notelayer/Data/DesignSystem.swift`, `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift`.
- **Design System Tokens**: Added unified design token structures and validation hooks to resolve semantic + component tokens consistently across modes in `ios-swift/Notelayer/Notelayer/Data/DesignSystem.swift`, `ios-swift/Notelayer/Notelayer/Data/DesignSystemValidation.swift`.
- **UI Surface Wiring**: Wired group vs card surfaces and updated surface roles to enforce the lightest→darkest ladder in `ios-swift/Notelayer/Notelayer/Views/Shared/InsetCard.swift`, `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, `ios-swift/Notelayer/Notelayer/Views/TaskItemView.swift`.
- **Theme Preview Accuracy**: Preset previews now render using the selected Light/Dark mode instead of the system scheme in `ios-swift/Notelayer/Notelayer/Views/AppearanceView.swift`.
- **Documentation**: Added design system references and theme planning artifacts in `docs/DesignSystem/*`, `docs/Theme_Surface_Tinting_PLAN.md`, `docs/design-system-production-architecture-claude-sonnet_PLAN.md`, `notelayer-design-system.md`.

## [2026-01-31] - Branch: `group-reorder`
- **Category Ordering**: Added persistent category ordering with `Category.order`, sorted accessors, and migration/backfill logic in `ios-swift/Notelayer/Notelayer/Data/Models.swift`, `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`.
- **Group Reorder UI**: Implemented drag/drop reorder slots for category groups in the Category tab and Manage Categories list with dedicated drop delegates and haptics in `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`, `ios-swift/Notelayer/Notelayer/Views/CategoryManagerView.swift`.
- **Uncategorized Placement Sync**: Introduced `uncategorizedPosition` tracking + Firestore user metadata sync for cross-device consistency in `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`, `ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift`.
- **Drag Payload Plumbing**: Registered a new UTType for category group drag payloads and added shared payload model in `ios-swift/Notelayer/Info.plist`, `ios-swift/Notelayer/Notelayer/Views/Shared/CategoryGroupDragPayload.swift`.
- **Task Drop Quality**: Stabilized task drop targets (including end-of-group placement) and visual drop indicators in `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`.
- **Auth/Notifications Polish**: Added APNS registration logging and friendlier auth error messaging + phone sign-in entry from Welcome in `ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift`, `ios-swift/Notelayer/Notelayer/Views/WelcomeView.swift`, `ios-swift/Notelayer/Notelayer/Views/SignInSheet.swift`.
- **Project/Config**: Bumped build version and enabled analytics in `ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj`, `ios-swift/Notelayer/GoogleService-Info.plist`.

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
