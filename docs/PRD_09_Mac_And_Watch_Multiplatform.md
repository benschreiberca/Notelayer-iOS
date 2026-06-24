# PRD 09 — Notelayer for Mac (Apple Silicon) & Apple Watch

**Status:** Draft for review (no code yet)
**Author:** ben@benschreiber.ca
**Last Updated:** 2026-06-24
**Branch:** `claude/hopeful-rubin-9xouzo`
**Related docs:** `UI_COMPONENT_GUIDE.md`, `Native_Parity_Map.md`, `PRD_Program_Overview_And_Release_Summaries.md`, `THEME_UI_INCONSISTENCIES_PLAN.md`

---

## 1. Summary

Ship two new first-party surfaces built from the existing iOS app:

1. **Notelayer for Mac** — a native Apple-Silicon Mac app.
2. **Notelayer for Apple Watch** — a companion watchOS app focused on capture + triage.

Both must feel like the *same product* as iOS: identical design tokens, identical data model, identical sync, and a shared mental model. We also expose Notelayer's core actions to **the new Siri / Apple Intelligence** via the **App Intents** framework, so users can capture tasks, complete them, and query insights by voice across all surfaces.

The single hardest requirement: **100% adherence to the existing design system** (`DesignSystem.swift` / `ThemeManager.swift`) across iOS, Mac, and Watch — not a re-skin, but the same token pipeline rendering on each platform.

---

## 2. Goals & Non-Goals

### Goals
- A native Mac app on Apple Silicon with full Notes / To-Dos / Insights parity.
- A focused Apple Watch app: quick capture (incl. voice), today/triage list, complete/snooze.
- One shared design-token source of truth driving all three platforms.
- Real-time sync continuity (Firebase) across iOS ↔ Mac ↔ Watch ↔ Share Extension.
- Siri / Apple Intelligence exposure via App Intents (capture, complete, query).
- Zero divergence in visual language: color, type, spacing, radius, shadow, surface tint.

### Non-Goals (this phase)
- Standalone (cellular) Watch app independent of iPhone — phase 2.
- Apple Pencil / iPad-specific multitasking optimizations — separate PRD.
- Rewriting persistence (UserDefaults + Firestore stays).
- Replacing CocoaPods with SPM (tracked as a gap/risk, decided in Wave 0).
- A visionOS surface.

---

## 3. Current Architecture (as-built, indexed)

All paths relative to `ios-swift/Notelayer/Notelayer/` unless noted.

### Design system (the spine)
- `Data/DesignSystem.swift` (994 lines) — Primitive + semantic tokens, typography (11 styles), spacing (xs–xxl), radius, shadows (sm–xl), surface tinting, component tokens (Button/Card/GroupCard/TaskItem/Badge/GroupHeader), wallpaper defs.
- `Data/ThemeManager.swift` (994 lines) — `ThemeConfiguration`, `ThemeAccent`, `ThemeSurfaceStyle`, `ThemeMode`, `ThemeWallpaperKind`; `ThemeManager.shared`.
- `Data/AppearanceStore.swift` — theme mode + palette mode.
- `Utils/ColorHex.swift` — `Color(hex:)` **and** `UIColor(hex:)` ⚠️ (UIKit dependency — see gaps).
- `Data/DesignSystemValidation.swift` — token validation hooks.

### Shared UI components
- `Views/Shared/` (~23 components): `ThemeBackground.swift`, `ThemeAppearanceModifier.swift`, `InsetCard.swift`, `SettingsComponents.swift` (`PrimaryButtonStyle`, `TaskCategoryChip`, `TaskPriorityBadge`), `TaskEditorSections.swift`, `CategoryChipGridView.swift`, `TagChipsView.swift`, `AppTabHeaderComponents.swift`, `AuthButtonView.swift`, `RowContextMenu.swift`, `AnimatedLogoView.swift`, etc.

### Data & services (platform-agnostic candidates)
- `Data/Models.swift` — `Task`, `Category`, `Note`, `Priority`, `VoiceParsedTaskDraft`, etc.
- `Data/LocalStore.swift` (1,562 lines) — `LocalStore.shared`, app-group UserDefaults (`group.com.notelayer.app`), CRUD, sync glue.
- `Data/BackendSyncing.swift`, `Data/SyncService.swift`, `Data/SharedItem.swift`, `Data/CategoryColorDefaults.swift`.
- `Services/FirebaseBackendService.swift` (785), `Services/AuthService.swift` (687), `Services/InsightsAggregator.swift` (700), `InsightsTelemetryStore.swift`, `AnalyticsService.swift`, `ReminderManager.swift`, `CalendarExportManager.swift`, `VoiceInputController.swift`, `VoiceTaskParser.swift`.

### App shell / navigation
- `App/NotelayerApp.swift` (363) — `@main`, `@UIApplicationDelegateAdaptor` ⚠️ (UIKit AppDelegate), deep linking, Firebase config, APNS.
- `Views/RootTabsView.swift` (395) — bottom capsule tab bar (Notes/To-Dos/Insights), voice FAB.
- Core screens: `TodosView.swift` (1,886), `InsightsView.swift` (1,192), `AppearanceView.swift` (845), `NotesView.swift`, plus task editors/sheets.

### Targets today
- `Notelayer` (iOS 15+), `NotelayerShareExtension`, `NotelayerInsightsTests`, `NotelayerScreenshotTests`.
- Workspace + CocoaPods (`Podfile`): Firebase (Analytics/Auth/Firestore), GoogleSignIn, GTMSessionFetcher.

---

## 4. The Unification Strategy (how we hit ~100% design adherence)

The reason iOS, Mac, and Watch can look identical is that **none of them should re-define visual language** — they all consume the same token layer. Concretely:

### 4.1 Extract a shared "Notelayer Core" package
Create a Swift package (`NotelayerKit`) or a shared framework target containing:
- **DesignCore**: `DesignSystem.swift`, `ThemeManager.swift`, `AppearanceStore.swift`, `ColorHex.swift`, wallpaper defs.
- **DomainCore**: `Models.swift`, `Priority`, `CategoryColorDefaults`, `SharedItem`.
- **DataCore**: `LocalStore`, `BackendSyncing`, `SyncService`, `FirebaseBackendService`, `AuthService`.
- **Services**: insights aggregation, voice parsing, reminders (platform-guarded).

All three app targets depend on this package. **One token edit propagates everywhere** — this is what makes "100% adherence" enforceable rather than aspirational.

### 4.2 Make tokens platform-pure
Today `ColorHex.swift` and component tokens lean on `UIColor`/UIKit. To compile on macOS and watchOS cleanly:
- Provide a `PlatformColor` typealias (`UIColor` on iOS/watchOS, `NSColor` on macOS) or, preferred, render everything through SwiftUI `Color` and drop `UIColor` from the shared layer.
- Wrap any `UIKit`-only API (`.insetGrouped`, `UIApplicationDelegateAdaptor`, haptics, `UIPasteboard`) behind `#if os(...)` or platform protocols.

### 4.3 Platform-idiomatic *shells*, identical *content*
We keep the tokens identical but adapt the **navigation chrome** to each platform's conventions (Apple's HIG demands this; a literal pixel clone would feel broken):

| Surface | Shell | Token usage |
| --- | --- | --- |
| iOS | Bottom capsule tab bar (existing) | 100% shared tokens |
| Mac | `NavigationSplitView` (sidebar: Notes/To-Dos/Insights) | Same accent, type ramp, surface tint, wallpaper as window background |
| Watch | `TabView` page style / `NavigationStack` lists | Same accent + priority colors; type scaled to watch metrics |

The **cards, chips, badges, buttons, colors, and typography ramp are byte-identical** because they come from `NotelayerKit`. Only the container differs.

### 4.4 Design-tooling alignment (Figma)
The Figma MCP server is connected. We can:
- Pull existing design-system variables (`get_variable_defs`) and diff against `DesignSystem.swift` to confirm parity, and
- Generate Mac/Watch layout frames from the shared library so design + code never drift.
This becomes the visual QA gate per the existing `ui-consistency` command.

---

## 5. Surface Requirements

### 5.1 Notelayer for Mac (Apple Silicon)

**Decision required (Wave 0):** *Mac Catalyst* vs *native SwiftUI Mac app ("Designed for iPad" is not acceptable for a quality bar)*.
- **Recommendation: native SwiftUI multiplatform target.** Catalyst is faster to stand up but inherits iOS idioms (and UIKit AppDelegate baggage) and tends to feel "iPad-in-a-window." Native SwiftUI gives a true Mac feel and forces the clean `NotelayerKit` extraction we want anyway. Trade-off: more `#if os(macOS)` work for menus, window sizing, and Firebase/AppDelegate equivalents (`NSApplicationDelegateAdaptor`).

**Layout**
- `NavigationSplitView`: sidebar (Notes, To-Dos, Insights, Settings) + content + optional detail (task editor as trailing column instead of sheet).
- Menu bar commands: New Task (⌘N), New Note (⌘⇧N), Voice Capture, Search (⌘F), Toggle Appearance.
- Multiple windows / window restoration; keyboard-first navigation; hover states.
- Settings as a standard macOS Settings scene (⌘,) mapping to existing settings views.

**Parity**: Full Notes/To-Dos/Insights, categories, reminders, appearance/theming, sign-in (Google/Apple), share-equivalent (drag-drop + Services menu instead of share extension).

### 5.2 Notelayer for Apple Watch

Watch is **capture + triage**, not full editing.

**Core screens**
- **Today / Triage list**: due-today + overdue, complete/snooze swipes, priority color dots.
- **Quick capture**: dictation + Scribble → creates task (reuses `VoiceTaskParser` server-side parse if available, else plain title).
- **Category quick-add**: top categories as a grid.
- **Complications**: open-task count / next due — WidgetKit complications.
- **Notifications**: reminder nudges with Complete/Snooze actions (mirror `ReminderManager` categories).

**Token usage**: accent + priority + category colors identical; type ramp scaled to watch sizes; surface tint simplified (no heavy wallpaper on watch for legibility/battery).

### 5.3 Siri / Apple Intelligence (App Intents)

Expose an `AppIntents` package (shared) so Siri, Spotlight, Shortcuts, the Action button, and Apple Intelligence can drive Notelayer on **every** platform:
- `AddTaskIntent` ("Add buy filament to Notelayer") — title, optional category, priority, due date.
- `CompleteTaskIntent` ("Mark X done in Notelayer").
- `QueryTasksIntent` ("What's due today in Notelayer?").
- `OpenViewIntent` (Notes / To-Dos / Insights).
- **App Shortcuts** (`AppShortcutsProvider`) with spoken phrases so they work with zero user setup.
- **App Entities**: expose `Task`/`Category` as `AppEntity` so Siri can disambiguate and Spotlight can index.
- Donate intents on task creation/completion to improve Siri suggestions.

This intent layer lives in `NotelayerKit` and writes through `LocalStore`/sync, so behavior is consistent regardless of which surface triggered it.

---

## 6. Significant Gaps & Risks

1. **UIKit coupling in the shared layer** — `UIColor(hex:)`, `@UIApplicationDelegateAdaptor`, `.listStyle(.insetGrouped)`, haptics, `UIPasteboard`, share extension UIKit VC. *All* must be abstracted before macOS/watchOS will compile. **Highest-effort gap.**
2. **CocoaPods + Firebase on macOS/watchOS** — Firestore/Auth support macOS but watchOS support is limited/heavier. Likely need **SPM migration for Firebase** and a lighter Watch sync path (sync via the paired iPhone using `WatchConnectivity` rather than direct Firestore on-watch). Wave 0 decision.
3. **`.insetGrouped` is iOS-only** — the entire `UI_COMPONENT_GUIDE.md` gold-standard pattern doesn't exist on macOS. Need a Mac-equivalent `List` styling that preserves the *look* (grouped, inset, token-driven) without the iOS API. This is the core "look unified but idiomatic" tension.
4. **App Group & entitlements** — must add macOS and watchOS app groups, provisioning, and capabilities (Sign in with Apple, Push, iCloud if used). Apple Developer portal config required.
5. **Auth on Mac/Watch** — Google Sign-In SDK on macOS uses a different flow (ASWebAuthenticationSession); Apple Sign-In differs; Watch typically piggybacks the phone's session via `WatchConnectivity`.
6. **Wallpaper/surface-tint rendering** — `ThemeBackground.swift` gradients/patterns must be validated on macOS window backgrounds and (selectively disabled) on watchOS.
7. **Insights/Charts on Watch** — too heavy; Watch should omit Insights or show a single glanceable metric.
8. **iOS 15 minimum vs App Intents** — App Intents requires iOS 16+ / macOS 13+ / watchOS 9+. Decide whether to raise the iOS floor or gate intents behind availability. **Recommend raising to iOS 16+ for the multiplatform line.**
9. **Build/CI** — `fastlane` is iOS-only today; needs Mac + Watch lanes, separate signing, and TestFlight/Mac App Store distribution config.
10. **Notification routing** — APNS device token logic (`APNSTokenStore`, sandbox/prod) needs per-platform handling.
11. **Screenshot tests** — `NotelayerScreenshotTests` are iOS-only; need Mac/Watch equivalents or scoping.

---

## 7. Branches vs. Worktrees (recommendation)

**Yes — use git worktrees.** This program is a long-lived, multi-target effort that runs in parallel with ongoing iOS work, and the riskiest step (the `NotelayerKit` extraction) touches almost every file.

Recommended layout:
- **Long-lived integration branch:** `feature/multiplatform` off `main`. All platform work merges here; it merges to `main` only when a milestone is shippable.
- **Worktrees for parallel, non-conflicting streams** (each its own checkout so iOS builds/tests stay runnable while Mac/Watch churn):
  - `../nl-core` → `feature/mp-core-extraction` (the `NotelayerKit` package; sequence this **first**, everyone rebases on it).
  - `../nl-mac` → `feature/mp-mac`
  - `../nl-watch` → `feature/mp-watch`
  - `../nl-intents` → `feature/mp-app-intents`

Why worktrees over plain branches here: you can keep a clean iOS build open in one window while Xcode in another churns on the Mac target, without constant stashing. **Sequencing matters more than parallelism**: the core extraction (Wave 1) must land and be rebased onto before Mac/Watch/Intents diverge, or you get massive conflicts.

The designated working branch for *this PRD/planning task* remains `claude/hopeful-rubin-9xouzo`.

---

## 8. Execution Plan (Waves)

**Wave 0 — Decisions (no code).** Lock: Catalyst vs native Mac (rec: native); Firebase SPM migration + Watch sync strategy (rec: WatchConnectivity bridge); raise iOS floor to 16 (rec: yes); Mac distribution (Mac App Store vs notarized direct).

**Wave 1 — `NotelayerKit` extraction.** Move design/domain/data/services into a shared package. Purge UIKit from the shared layer behind platform shims. iOS app re-targets the package. *Acceptance: iOS app builds + all existing tests pass unchanged, zero visual diff (screenshot tests green).*

**Wave 2 — App Intents package.** Build intent + entity layer on top of `NotelayerKit`; wire into iOS first. *Acceptance: Siri/Shortcuts add/complete/query work on iOS.*

**Wave 3 — Mac target.** `NavigationSplitView` shell, menu commands, settings scene, macOS auth + Firebase. *Acceptance: full parity, ui-consistency pass, token diff = 0.*

**Wave 4 — Watch target.** Triage list, quick capture, complications, WatchConnectivity sync, notifications. *Acceptance: capture + complete round-trips to iPhone; tokens match.*

**Wave 5 — Integration/QA.** Cross-platform sync, Figma visual diff, CI lanes (fastlane Mac/Watch), regression. *Acceptance: `ui-consistency` pre/post pass on all surfaces; status docs updated.*

Run the existing `ui-consistency` command before/after every UI wave (per program convention).

---

## 9. Wave 0 Decisions

**Locked (2026-06-24):**
1. ✅ **Mac approach:** native SwiftUI multiplatform target (not Catalyst).
2. ✅ **iOS minimum:** raise to iOS 16 for the multiplatform line, enabling App Intents everywhere.
3. ✅ **Watch sync:** WatchConnectivity bridge via the paired iPhone (no standalone/cellular this phase).

**Still open:**
4. **Firebase:** migrate to SPM (recommended — needed for clean macOS support) vs keep CocoaPods iOS-only + separate dep path. *Leaning SPM; confirm before Wave 1.*
5. **Mac distribution:** Mac App Store vs notarized direct download?
6. **Watch scope:** capture/triage only (recommended) confirmed implicitly by the WatchConnectivity decision; flag if you want a single glanceable Insights metric.

---

## 10. Definition of Done

- Mac + Watch targets ship from a single `NotelayerKit` source of truth.
- Token diff between platforms = 0 (validated via `DesignSystemValidation` + Figma variable diff).
- Siri/App Intents add/complete/query work on iOS, Mac, and Watch.
- Cross-surface real-time sync verified.
- `ui-consistency` passes on every surface; all status/plan docs updated.
- No unresolved Wave 0 blockers.
