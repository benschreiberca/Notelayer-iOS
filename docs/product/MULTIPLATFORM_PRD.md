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
- A native Mac app on Apple Silicon with full To-Dos / Insights parity, plus a product decision on whether to resurface Notes (hidden since v1.5.0).
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
- `Views/RootTabsView.swift` (395) — floating pill tab bar with **2 visible tabs: To-Dos + Insights** (`visibleTabs = [.todos, .insights]`). Notes tab hidden since v1.5.0 ("F1: Hide Notes tab from bottom navigation") — `NotesView.swift` code preserved but not exposed. Voice FAB above tab bar.
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
| iOS | Floating pill tab bar — **2 tabs: To-Dos + Insights** (Notes hidden since v1.5.0) | 100% shared tokens |
| Mac | `NavigationSplitView` sidebar: To-Dos · Insights · Settings (Notes: see §12 open decision) | Same accent, type ramp, surface tint, wallpaper as window background |
| Watch | `TabView` page style / `NavigationStack` lists | Same accent + priority colors; type scaled to watch metrics |

The **cards, chips, badges, buttons, colors, and typography ramp are byte-identical** because they come from `NotelayerKit`. Only the container differs.

### 4.4 Design-tooling alignment (Figma)
The Figma MCP server is connected. We can:
- Pull existing design-system variables (`get_variable_defs`) and diff against `DesignSystem.swift` to confirm parity, and
- Generate Mac/Watch layout frames from the shared library so design + code never drift.
This becomes the visual QA gate per the existing `ui-consistency` command.

---

## 5. Complete Feature Inventory by Platform

> **Source references:** `docs/PRODUCT_INVENTORY.md` (canonical feature list, last updated 2026-04-11), `docs/Native_Parity_Map.md`, `docs/UI_COMPONENT_GUIDE.md`, `docs/Notelayer_Design_System_Reference_Guide.md`, `ios-swift/Notelayer/Notelayer/Data/DesignSystem.swift`, `ios-swift/Notelayer/Notelayer/Data/ThemeManager.swift`, `ios-swift/Notelayer/Notelayer/Views/` (source of truth for iOS implementation).
>
> **Status key:** ✅ Ship at launch · 🟨 Ship at launch (adapted) · ⏳ Post-launch · ❌ Not applicable · 🔔 Siri/App Intents

---

### 5A. Navigation & Shell

| Feature | iOS (existing) | Mac | Watch |
| --- | --- | --- | --- |
| **Navigation shell** | Floating pill tab bar — **2 tabs: To-Dos + Insights**. Notes tab hidden from nav since v1.5.0 (`visibleTabs = [.todos, .insights]`). Tab bar hides when keyboard visible. `RootTabsView.swift`. | `NavigationSplitView` sidebar: To-Dos · Insights · Settings. Notes: see §12 open decision. Sidebar collapsible. Full macOS menu bar (⌘N, ⌘F, ⌘,). | `TabView` (page style) or `NavigationStack`. Triage · Capture · Settings. Digital Crown scrolls lists. |
| **Active tab indicator** | Accent-color tint on active pill. `DesignSystem.swift` → `accent` token. | Sidebar row highlight using `accent` token. | Selected page indicator dot using `accent` token. |
| **Deep linking** | `NSNotificationCenter` posts open specific tasks from reminders (`NotelayerApp.swift:363`). | Menu commands + `NSUserActivity` for task focus. | Tap notification → opens task on Watch. |
| **Keyboard hide/show** | Tab bar hides when keyboard is visible. | N/A (physical keyboard; toolbar stays). | N/A (Scribble / dictation, no keyboard). |

---

### 5B. Notes

> **Current iOS status (v1.5.0):** Notes tab is **hidden from navigation** by design decision ("F1: Hide Notes tab"). `NotesView.swift` code is preserved but `visibleTabs = [.todos, .insights]` excludes it. Notes data model and sync remain intact.
>
> **Open product decision for Mac/Watch (§12):** Mac has sidebar space where Notes could be re-surfaced without the iOS nav-crowding concern. This needs an explicit decision before Mac implementation. Until decided, all Notes cells below are marked ⚠️.
>
> iOS source files if/when re-surfaced: `Views/NotesView.swift`, `Views/Shared/InsetCard.swift`. Design: `InsetCard` with `theme.tokens.groupFill` background + `theme.tokens.cardStroke` border.

| Feature | iOS (v1.5.0) | Mac | Watch |
| --- | --- | --- | --- |
| **Note list** | ⚠️ Code exists (`NotesView.swift`), hidden from nav. | ⚠️ Decision pending — sidebar space available. | ❌ |
| **Pinned / unpinned sections** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Create note** | ⚠️ Not reachable. | ⚠️ Decision pending. | ❌ |
| **Note editor** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Rich text formatting** | ⚠️ Bold, italic, underline, headings, lists, dividers — implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Auto-formatting** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Create task from note** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Pin / unpin** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Delete note** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Share / copy note** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |
| **Bulk select + delete** | ⚠️ Implemented, not exposed. | ⚠️ Decision pending. | ❌ |

---

### 5C. To-Dos

> iOS implementation: `Views/TodosView.swift` (1,886 lines), `Views/TaskItemView.swift`, `Views/TaskInputView.swift`, `Views/TaskEditView.swift`. Design: task cards use `theme.tokens.groupFill` + `cardStroke`, category chips use category hex color at 12.5% opacity, priority badges use `textSecondary`. Gold standard: `TaskEditView.swift` + `UI_COMPONENT_GUIDE.md`.

#### Task List & View Modes

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Task list** | Scrollable list of active tasks sorted by selected view mode. `List` + `ForEach`. | ✅ Same content column. `List` with `.sidebar` style instead of `.insetGrouped`. | 🟨 Triage list only: due-today + overdue tasks. No view mode switching. |
| **Doing / Done toggle** | Header toggle switch shows active vs. completed tasks. | ✅ Toolbar segmented control or toolbar button. | 🟨 Swipe actions on task row to complete/restore. No dedicated toggle. |
| **Search** | Floating search button → search bar overlay; full-text across title + notes. | ✅ ⌘F → search field in toolbar. Same full-text logic. | ❌ |
| **View mode: List** | Flat chronological list; manually reorderable via drag handle. | ✅ Same with macOS drag-to-reorder. | ❌ |
| **View mode: Priority** | Grouped by High/Medium/Low/Deferred; drag between sections updates priority. | ✅ Same grouping logic; drag-and-drop between sections. | ❌ |
| **View mode: Category** | Grouped by category; drag between sections updates categories. | ✅ Same. | ❌ |
| **View mode: Date** | Grouped by Overdue/Today/Tomorrow/This Week/Later/No Due Date; drag between date sections updates `dueDate`. | ✅ Same. | 🟨 Fixed date filter: Overdue + Today only (triage focus). |
| **View mode segmented control** | Pill-style segmented control at top of To-Dos. | 🟨 Toolbar segmented control (native macOS style). | ❌ |
| **Empty state** | Friendly message when no tasks. | ✅ Same in content column. | 🟨 "Nothing due today" when triage list is empty. |

#### Task Creation

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Inline task input** | Type-and-submit at bottom of list (or top of section in grouped views). Expands on focus to show category chips + priority picker. | ✅ Same at top of content column. Expands on click. Keyboard-first. | ❌ |
| **Voice task entry** | Floating mic FAB above tab bar → `VoiceCaptureSheet` → `VoiceStagingView`. Records speech, transcribes, parses into structured drafts. `VoiceInputController.swift`, `VoiceTaskParser.swift`. | ✅ Menu bar item or ⌘⇧V → voice capture panel (floating window). Same parse pipeline. | ✅ Primary capture method. Dictation via `WKInterfaceController` speech API → `VoiceTaskParser`. Simplified staging: confirm or discard each draft individually. |
| **Voice capture sheet** | Animated waveform during recording; transcribe on stop. `VoiceCaptureSheet.swift`. | 🟨 Floating panel with waveform visualization. Same recording/transcription logic. | 🟨 Simplified: progress indicator + time elapsed. No waveform (screen too small). |
| **Voice staging view** | Review parsed drafts before saving; edit, reorder, delete, add manually; "Save All". `VoiceStagingView.swift`. | ✅ Same as sheet / panel. | 🟨 Sequential review: one draft at a time. Swipe to accept/discard. |
| **AI task parsing** | Transcript → structured draft (title, categories, priority, due date, confidence score). `VoiceTaskParser.swift`. | ✅ Same pipeline. | ✅ Same `VoiceTaskParser` via shared `NotelayerKit`. |
| **Voice recording indicator** | Pulsing rings on mic FAB. | 🟨 Menu bar icon pulses. Floating panel header pulses. | 🟨 Digital Crown crown pulse / system recording indicator. |

#### Task Item

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Task row display** | Title, category chips, priority indicator, due date. 24pt checkbox. `TaskItemView.swift`. Card: `groupFill` bg, `cardStroke` 0.5px, 12px continuous radius. | ✅ Same tokens + components from `NotelayerKit`. Row height adapts to macOS minimum (~44pt). Right-click context menu replaces long-press. | 🟨 Simplified row: title + priority color dot + due date. No category chips (too small). Tap to expand details. |
| **Complete task** | Tap checkbox → `completedAt` set; moves to Done section immediately. | ✅ Same. Keyboard shortcut: Space or ⌘Return on selected row. | ✅ Tap row → complete. Or swipe right → complete. |
| **Restore task** | Tap checkbox on completed task. | ✅ Same. | ✅ Swipe right on completed task. |
| **Edit task** | Tap row → full `TaskEditView` sheet. | ✅ Tap row → detail column editor (no sheet). | 🟨 Tap row → simplified edit: title + due date + priority only. Full edit deferred to iPhone. |
| **Delete task** | Swipe-to-delete or context menu. `RowContextMenu.swift`. | ✅ Backspace on selected row or right-click → Delete. | 🟨 Swipe left → delete (with confirmation). |
| **Share task** | Context menu → iOS share sheet. | ✅ Right-click → Share via macOS sharing services. | ❌ |
| **Set reminder** | Context menu quick-set. `ReminderPickerSheet.swift`. | ✅ Right-click → Set Reminder or via detail editor. | 🟨 Quick-set from task detail: "In 1 hour", "Tomorrow". No full picker. |
| **Reorder (List mode)** | Drag handle. `onMove` modifier. | ✅ Drag row. | ❌ |
| **Drag-to-group** | Drag between sections in Priority/Category/Date views to update grouping field. | ✅ Same. | ❌ |
| **Drag-to-nest (subtasks)** | Drag task onto another task's middle third → sets `parentTaskId`. | ✅ Same. | ❌ |
| **Category chips on row** | Capsule chips with category hex color at 12.5% opacity, `.caption` font. `TaskCategoryChip` in `SettingsComponents.swift`. | ✅ Same `TaskCategoryChip` component. | ❌ (too small for Watch) |
| **Priority badge** | `.caption` text, `textSecondary` color. `TaskPriorityBadge` in `SettingsComponents.swift`. | ✅ Same. | 🟨 Color dot only (no text label). |
| **Bulk selection** | Long-press → select mode → multi-select → "Edit Categories". | ✅ ⌘-click multi-select → toolbar "Edit Categories". | ❌ |
| **Bulk category edit** | Sheet with category multi-select grid. `CategoryChipGridView.swift`. | ✅ Panel. | ❌ |

#### Task Editor (Full)

> iOS gold standard: `TaskEditView.swift`. Pattern: `NavigationStack { List { Section { } } .listStyle(.insetGrouped) }` per `UI_COMPONENT_GUIDE.md`.

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Title field** | Editable text field at top. | ✅ Same in detail column. | 🟨 Editable via Scribble or dictation. |
| **Categories multi-select** | Chip grid from user's category list. `CategoryChipGridView.swift`. | ✅ Same chip grid. | ❌ (post-launch: single category tap). |
| **Priority picker** | Segmented picker: High/Medium/Low/Deferred. | ✅ Same (or native macOS `Picker` style). | 🟨 Tap to cycle priority. |
| **Due date picker** | Date + time picker; clearable. Quick presets. `CustomDatePickerSheet.swift`. | ✅ `DatePicker` native macOS style. Quick preset buttons. | 🟨 Quick presets only: Today / Tomorrow / This Week. No full picker. |
| **Reminder** | Notification-based reminder tied to date/time. Requires notification permission. `ReminderPickerSheet.swift`. | ✅ Same via `UNUserNotificationCenter` (macOS). | 🟨 Quick-set only. |
| **Task notes** | Freeform text field. | ✅ Same multiline field. | ❌ (post-launch). |
| **Calendar export** | Export as calendar event via `EventKit`. `CalendarExportManager.swift`. | ✅ Same via `EventKit` on macOS. | ❌ |
| **Parent task** | Assign as subtask via picker. | ✅ Same. | ❌ |
| **Subtask indicator** | Shows when task has subtasks; parent auto-closes when all subtasks done. | ✅ Same. | ❌ |
| **Delete task** | Destructive button at bottom. `PrimaryButtonStyle(isDestructive: true)` per `UI_COMPONENT_GUIDE.md`. | ✅ Same style. Or toolbar Delete button. | 🟨 Available via swipe only. |
| **Add to calendar button** | Toolbar button in edit sheet header. | ✅ Same in detail column toolbar. | ❌ |
| **Share task button** | Toolbar button in edit sheet header. | ✅ Same. | ❌ |

---

### 5D. Insights

> iOS implementation: `Views/InsightsView.swift` (1,192 lines). Uses Apple Charts framework. Data from `InsightsAggregator.swift`, `InsightsTelemetryStore.swift`.

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Insights tab / section** | Third tab, always visible (post PRD-03 removal). | ✅ Sidebar item. Same content in main column. | 🟨 Single glanceable metric only: open task count today. No charts. |
| **Trend view** | Task completion trends over 7D/30D/60D/180D/365D rolling window. Apple Charts. | ✅ Same charts. Larger canvas = richer visualization possible. | ❌ |
| **Category breakdown** | Task volume + completion by category. Charts. | ✅ Same. | ❌ |
| **Usage view** | Feature usage frequency across core actions. | ✅ Same. | ❌ |
| **Gap analysis** | Unused/underused feature identification. | ✅ Same. | ❌ |
| **Oldest open tasks** | Surfaces longest-open tasks. | ✅ Same. | ❌ |
| **Data fidelity labels** | Event-Exact / Snapshot-Estimated / Mixed. | ✅ Same. | ❌ |
| **Genie collapse transition** | Animated collapse to tab bar corner when Insights disabled. | ❌ (feature gate removed in v1.5.0 — not applicable). | ❌ |
| **Category deep-link** | Tap category in Insights → jumps to To-Dos category view. | ✅ Same (sidebar navigation). | ❌ |

---

### 5E. Categories

> iOS implementation: `Views/CategoryManagerView.swift` (399 lines), `Data/CategoryColorDefaults.swift`, `Data/Models.swift`. Shared via `NotelayerKit`.

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Default categories** | 8 presets with emoji icons + distinct hex colors: House & Repairs, Garage & Workshop, 3D Printing, Vehicle & Motorcycle, Tech & Apps, Finance & Admin, Shopping & Errands, Travel & Health. `CategoryColorDefaults.swift`. | ✅ Same — from `NotelayerKit`. | ✅ Available for triage grouping. |
| **Custom categories (CRUD)** | Full create/edit/delete/reorder in `CategoryManagerView`. Emoji picker, color picker, name validation. | ✅ Same in Settings → Categories. | ❌ Managed on iPhone. |
| **Category reorder** | Drag in `CategoryManagerView`. | ✅ Same in Settings panel. | ❌ |
| **Category colors** | Per-category accent hex used in chips + group headers. | ✅ Same token. | 🟨 Color dot on triage row (no chip). |
| **Multi-category assignment** | Tasks can belong to multiple categories. | ✅ Same. | 🟨 Display only; editing deferred to iPhone. |

---

### 5F. Reminders

> iOS implementation: `Services/ReminderManager.swift` (186 lines), `Views/ReminderPickerSheet.swift`, `Views/RemindersSettingsView.swift`. Uses `UserNotifications`.

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Reminder scheduling** | `UNNotificationRequest` on set; date/time picker. | ✅ Same via `UNUserNotificationCenter` macOS. | 🟨 Quick presets (1 hour, tomorrow); Watch notifies via paired iPhone. |
| **Reminder cancellation** | Clears notification when removed or task deleted. | ✅ Same. | ✅ Via `WatchConnectivity` → iPhone handles cancellation. |
| **Notification permission** | Requested on first reminder set; graceful denied-permission handling. | ✅ Same macOS permission prompt. | ✅ Watch notification permission via paired iPhone. |
| **Notification actions** | "Complete Task" + "Open Task" actionable notification buttons. `ReminderManager.swift`. | ✅ Same macOS notification actions. | 🟨 "Complete" action only (from Watch notification). |
| **Reminders settings screen** | `RemindersSettingsView.swift` — list all reminders, clear all. Pattern: `List { Section }` `.insetGrouped`. | ✅ Settings → Reminders pane. Same content. | ❌ Managed on iPhone. |
| **Bell icon on task row** | `🔔` indicator on tasks with active reminders. `TaskItemView.swift`. | ✅ Same. | 🟨 Indicator on triage row. |

---

### 5G. Appearance & Themes

> Source of truth: `Data/DesignSystem.swift` (994 lines), `Data/ThemeManager.swift` (994 lines). Design reference: `docs/Notelayer_Design_System_Reference_Guide.md`, `Views/AppearanceView.swift` (845 lines).

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Appearance mode** | Light / Dark / System. `AppearanceStore.swift`. | ✅ Same three modes. Maps to `NSApp.appearance`. | 🟨 System only (Watch follows system). |
| **Theme presets** | Curated presets in Traditional + Patterns categories. `ThemeConfiguration`. | ✅ Same presets from `NotelayerKit`. | ❌ Fixed accent + surface; no custom themes on Watch. |
| **Custom theme builder** | Full builder: wallpaper selection (gradient/pattern/designer/image), accent color, section tint, surface style (soft/frosted/gradient/solid), intensity slider, surface opacity. `AppearanceView.swift`. | ✅ Settings → Appearance pane. Same builder. | ❌ |
| **Wallpaper / background** | `ThemeBackground.swift` (296 lines) renders gradient, pattern, designer, or image behind primary screens. | 🟨 Window background uses `surfaceFill` token + accent tint. Gradient wallpaper optional (lighter, no pattern overlays — macOS convention). | ❌ Plain surface background for legibility + battery. |
| **Surface tinting** | 3 styles: subtle/medium/bold. Drives `groupFill`, `cardFill` tokens. | ✅ Same token pipeline. | 🟨 `subtle` only; cards are plain filled. |
| **Accent color** | Global highlight color used on tab bar, buttons, selection, chips. | ✅ Same `accent` token everywhere. | ✅ Same `accent` token on priority dots, completion checkmarks. |
| **Intensity slider** | Global visual strength: drives wallpaper opacity, pattern contrast. | 🟨 Applies to window tint strength, not pattern (no heavy patterns on Mac). | ❌ |
| **Palette mode** | Default / High Contrast / Warm / Cool / Neutral. `AppearanceStore.swift`. | ✅ Same. | ❌ |
| **Theme persistence** | Persisted + synced via Firebase. | ✅ Same sync. | 🟨 Reads accent from sync; no local customization. |

---

### 5H. Sync & Account

> iOS implementation: `Services/FirebaseBackendService.swift` (785 lines), `Services/AuthService.swift` (687 lines), `Data/LocalStore.swift` (1,562 lines). App group: `group.com.notelayer.app`.

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Firebase backend sync** | Tasks, notes, categories, preferences sync to Firestore in real-time. `FirebaseBackendService.swift`. | ✅ Same Firestore sync on macOS. | 🟨 Via `WatchConnectivity` — iPhone is the Firestore node; Watch syncs task subset (today+overdue) from phone. |
| **Auth — Apple Sign-In** | `AuthenticationServices`. `AuthService.swift`. | ✅ `ASWebAuthenticationSession` on macOS. | 🟨 Uses paired iPhone's auth session. Not re-auth'd on Watch. |
| **Auth — Google Sign-In** | `GoogleSignIn` SDK. | ✅ `GoogleSignIn` macOS flow. | ❌ Not on Watch. |
| **Local-first / offline** | Fully functional offline; sync on reconnect. `LocalStore.shared` with UserDefaults. | ✅ Same. | 🟨 Offline via last-synced subset from `WatchConnectivity`. |
| **Profile settings** | Account info, sign out, manage account. `ProfileSettingsView.swift`, `ManageAccountView.swift`. | ✅ Settings → Account pane. | ❌ Managed on iPhone. |
| **Experimental features sync** | Toggle state syncs across devices with conflict resolution. | ✅ Same. | ❌ N/A on Watch. |

---

### 5I. Share Extension / Capture Handoff

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Share extension** | `NotelayerShareExtension` target — accepts URLs + plain text from any app. Parses + queues as tasks/notes. `ShareViewController.swift`. App group `group.com.notelayer.app`. | 🟨 macOS Share Extension target (separate from iOS). Accepts text, URLs, Safari selections. Same parse pipeline via `NotelayerKit`. | ❌ |
| **Shared item import queue** | `LocalStore.processSharedItems()` on launch/foreground. `SharedItem.swift`. | ✅ Same on macOS foreground. | ❌ |
| **ChatGPT-first optimization** | Share from ChatGPT → structured task extraction (PRD 07, not yet shipped). | ✅ Same pending PRD 07. | ❌ |
| **Drag-and-drop into app** | ❌ Not implemented on iOS. | ✅ Native macOS drag-and-drop: drop text/URLs from any app into Notelayer → create task or note. | ❌ |

---

### 5J. Onboarding

> iOS implementation: `Views/WelcomeView.swift` (426 lines), `Services/WelcomeCoordinator.swift`. 4-step Duolingo/Noom-inspired flow (shipped v1.5.0, PRD 06).

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Welcome flow** | 4-step onboarding on first launch. Auto-triggers on fresh install. Replayable from gear menu. | 🟨 Condensed 2-step welcome (Mac users are power users; skip the interactive tutorial). First launch only. | ❌ |
| **Starter categories** | Finance-inclusive, non-time-based preset categories offered in onboarding. | ✅ Same offer in Mac onboarding. | ❌ |
| **Replay from settings** | Settings → replay onboarding. | ✅ Settings → Onboarding. | ❌ |

---

### 5K. Siri / App Intents (New — all platforms)

> New feature. Lives in `NotelayerKit` as a shared `AppIntents` module. Requires iOS 16+ / macOS 13+ / watchOS 9+ (aligned with the iOS-16 floor decision).

| Intent | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Add Task** ("Add buy filament to Notelayer") | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |
| **Complete Task** ("Mark X done in Notelayer") | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |
| **Query Tasks** ("What's due today in Notelayer?") | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |
| **Open View** ("Open Insights in Notelayer") | 🔔 ✅ | 🔔 ✅ | 🔔 🟨 Opens triage list. |
| **App Shortcuts** (no user setup) | 🔔 ✅ Spoken phrases via `AppShortcutsProvider`. | 🔔 ✅ | 🔔 ✅ |
| **App Entities** (Task, Category) | 🔔 ✅ Spotlight indexing + Siri disambiguation. | 🔔 ✅ | 🔔 ✅ |
| **Intent donation** | 🔔 ✅ Donates on create/complete for Siri suggestions. | 🔔 ✅ | 🔔 ✅ |
| **Shortcuts app integration** | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |

---

### 5L. Undo

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Shake to undo** | Shake gesture → undo last task mutation. `UndoShakeHost.swift`. | ❌ Shake doesn't exist on Mac. | ❌ |
| **⌘Z undo** | ❌ Not implemented. | ✅ Standard macOS `⌘Z` undo via `UndoManager`. | ❌ |

---

### 5M. Internal Analytics / Telemetry

| Feature | iOS | Mac | Watch |
| --- | --- | --- | --- |
| **Event tracking** | `AnalyticsService.swift` — task CRUD, reminders, calendar export, theme changes, tab/view events. | ✅ Same events, same service. | 🟨 Subset: capture, complete, reminder set. |
| **Insights telemetry** | `InsightsTelemetryStore.swift` — persisted usage data powering Insights. | ✅ Same. | 🟨 Capture + complete events only; aggregation runs on phone. |

---

### 5N. watchOS-Exclusive Features

| Feature | Description |
| --- | --- |
| **Triage list** | Due-today + overdue tasks. Swipe right to complete, swipe left to delete, tap to expand. Primary Watch screen. |
| **Watch complications** | WidgetKit complications showing open-task count or next-due task title. 4 sizes: Circular, Corner, Rectangular, Inline. |
| **WatchConnectivity sync** | `WCSession` bridge: Watch sends task mutations (complete, create) to iPhone for Firestore commit. Phone pushes task subset updates to Watch on change. Conflict resolution: last-write-wins using `updatedAt`. |
| **Quick capture** | Dictation-first capture. Mic button → speech → `VoiceTaskParser` → confirm draft → save. |
| **Snooze reminder** | From a notification or triage row: snooze reminder by 1 hour or to tomorrow. |
| **Digital Crown navigation** | Scroll triage list and detail. Crown press navigates home. |

---

### 5O. macOS-Exclusive Features

| Feature | Description |
| --- | --- |
| **Menu bar commands** | New Task (⌘N), Voice Capture (⌘⇧V), Search (⌘F), Preferences (⌘,), full Edit menu with ⌘Z undo. New Note (⌘⇧N) if Notes re-surfaced (§12). |
| **Multiple windows** | `WindowGroup` supports opening multiple windows (e.g., task detail + note side-by-side). Window restoration on relaunch. |
| **Keyboard-first navigation** | Full keyboard navigation: arrow keys in lists, Tab between panels, Return to open, Space to complete, ⌘Return to save. |
| **Drag-and-drop from other apps** | Drop text/URLs from Safari, Notes, ChatGPT into Notelayer window → create task or note. |
| **macOS Share Services** | Right-click → Share via macOS sharing services (AirDrop, Mail, Messages). |
| **Hover states** | Row hover highlight on cursor over. Token: `groupFill` at hover opacity. |
| **Column layout (NavigationSplitView)** | Sidebar + content + optional detail column. Sidebar collapsible. Width resizable. |
| **Settings scene** | Standard macOS Settings (⌘,) with multiple panes (Account, Appearance, Categories, Reminders, About). |

---

## 6. Platform Comparison Table

> **Legend:** ✅ Full parity · 🟨 Adapted for platform · ⏳ Post-launch · ❌ Not applicable · 🔔 Siri/App Intents

| Feature Area | Feature | iPhone (iOS 16+) | Mac (macOS 13+) | Watch (watchOS 9+) |
| --- | --- | :---: | :---: | :---: |
| **Shell** | Tab / sidebar navigation | ✅ Pill tab bar | ✅ Sidebar split view | ✅ Page tabs |
| | Keyboard shortcuts | ❌ | ✅ Full ⌘ menu | ❌ |
| | Multiple windows | ❌ | ✅ | ❌ |
| | Hover states | ❌ | ✅ | ❌ |
| **Notes** | Note list | ⚠️ Hidden (v1.5.0) | ⚠️ Decision pending | ❌ |
| | Rich text editor | ⚠️ Hidden (v1.5.0) | ⚠️ Decision pending | ❌ |
| | Pin / unpin | ⚠️ Hidden (v1.5.0) | ⚠️ Decision pending | ❌ |
| | Create task from note | ⚠️ Hidden (v1.5.0) | ⚠️ Decision pending | ❌ |
| | Share / copy | ⚠️ Hidden (v1.5.0) | ⚠️ Decision pending | ❌ |
| | Bulk select + delete | ⚠️ Hidden (v1.5.0) | ⚠️ Decision pending | ❌ |
| **To-Dos** | All 4 view modes | ✅ | ✅ | ❌ |
| | Triage view (today+overdue) | ❌ Date view partial | ❌ Date view partial | ✅ Primary screen |
| | Inline task input | ✅ | ✅ | ❌ |
| | Voice capture (full) | ✅ FAB + staging | ✅ Panel + staging | 🟨 Simplified staging |
| | Drag-to-reorder | ✅ | ✅ | ❌ |
| | Drag-to-group | ✅ | ✅ | ❌ |
| | Drag-to-nest (subtasks) | ✅ | ✅ | ❌ |
| | Bulk selection | ✅ | ✅ ⌘-click | ❌ |
| | Full task editor | ✅ Sheet | ✅ Column | 🟨 Title/priority/date only |
| | Complete / restore | ✅ Checkbox | ✅ Checkbox / Space | ✅ Tap / swipe |
| | Delete | ✅ Swipe | ✅ Backspace / right-click | 🟨 Swipe |
| | Share task | ✅ | ✅ | ❌ |
| | Reminder quick-set | ✅ | ✅ | 🟨 Presets only |
| | Calendar export | ✅ | ✅ | ❌ |
| | Subtask / parent | ✅ | ✅ | ❌ |
| | Undo last action | ✅ Shake | ✅ ⌘Z | ❌ |
| **Insights** | Full analytics dashboard | ✅ | ✅ | ❌ |
| | Glanceable task count | ❌ | ❌ | ✅ |
| | Complications (widget) | ❌ | ❌ | ✅ 4 sizes |
| **Categories** | Full CRUD | ✅ | ✅ | ❌ |
| | Display + filter | ✅ | ✅ | 🟨 Display only |
| **Reminders** | Full date/time picker | ✅ | ✅ | ❌ |
| | Quick presets | ✅ | ✅ | ✅ |
| | Notification actions | ✅ Complete + Open | ✅ Complete + Open | 🟨 Complete only |
| | Snooze | ❌ | ❌ | ✅ 1 hour / tomorrow |
| **Appearance** | Light / Dark / System | ✅ | ✅ | 🟨 System only |
| | Full custom theme builder | ✅ | ✅ | ❌ |
| | Wallpaper / gradient | ✅ Full | 🟨 Tinted window bg | ❌ |
| | Accent color | ✅ | ✅ | ✅ |
| | Theme presets | ✅ | ✅ | ❌ |
| **Sync** | Firestore real-time sync | ✅ | ✅ | 🟨 Via WatchConnectivity |
| | Offline support | ✅ | ✅ | 🟨 Last-synced subset |
| | Apple Sign-In | ✅ | ✅ | 🟨 Inherits from phone |
| | Google Sign-In | ✅ | ✅ | ❌ |
| **Share Extension** | Accept from other apps | ✅ | ✅ macOS extension | ❌ |
| | Drag-drop from other apps | ❌ | ✅ | ❌ |
| **Onboarding** | Full 4-step welcome | ✅ | 🟨 2-step condensed | ❌ |
| **Siri / App Intents** | Add Task | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |
| | Complete Task | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |
| | Query Tasks | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |
| | Open View | 🔔 ✅ | 🔔 ✅ | 🔔 🟨 |
| | Spotlight indexing | 🔔 ✅ | 🔔 ✅ | ❌ |
| | Shortcuts app | 🔔 ✅ | 🔔 ✅ | 🔔 ✅ |
| **UX pattern** | Navigation chrome | Pill tab bar | Sidebar split | Page tabs |
| | Primary task entry | FAB + inline input | Inline input + keyboard | Dictation |
| | Context actions | Long-press / swipe | Right-click / keyboard | Swipe |
| | Full editing | Sheet (modal) | Detail column (non-modal) | Simplified inline |
| | Background | Wallpaper / gradient | Tinted window | Plain surface |

---

## 7. Design System Enforcement (Per Platform)

> Enforcement rules per `UI_COMPONENT_GUIDE.md`. All three platforms consume tokens from `NotelayerKit/DesignCore`.

| Design Token Layer | iOS (today) | Mac | Watch |
| --- | --- | --- | --- |
| `PrimitiveTokens` (colors, spacing, radius, typography) | `DesignSystem.swift` | ✅ Same file via `NotelayerKit` | ✅ Same |
| Semantic tokens (`accent`, `textPrimary`, `groupFill`, `cardStroke`, etc.) | `DesignSystem.swift` | ✅ Same | ✅ Same |
| Typography ramp (DisplayLarge → LabelSmall, Code) | `.caption` → `.largeTitle` mapped | ✅ Same ramp | 🟨 `BodyMedium` max; no Display sizes |
| Spacing (xs=4 → xxl=48) | Applied across all views | ✅ Same | 🟨 xs/sm/md only (screen too small for lg+) |
| Corner radius (sm=4 → xl=16) | `12` default card radius | ✅ Same | 🟨 `md=8` default |
| `PrimaryButtonStyle` | `SettingsComponents.swift` | ✅ Same component | 🟨 Full-width simplified |
| `TaskCategoryChip` | `SettingsComponents.swift` | ✅ Same | ❌ |
| `TaskPriorityBadge` | `SettingsComponents.swift` | ✅ Same | 🟨 Color dot substitution |
| `ThemeBackground` | `Views/Shared/ThemeBackground.swift` | 🟨 Window tint (not full wallpaper) | ❌ |
| `InsetCard` | `Views/Shared/InsetCard.swift` | ✅ Same | 🟨 Simplified |
| List style | `.insetGrouped` (iOS) | `.sidebar` + `.inset` (macOS) | Default list |

---

## 8. Surface Requirements (Shell Detail)

### 5.1 Notelayer for Mac (Apple Silicon)

**Decision required (Wave 0):** *Mac Catalyst* vs *native SwiftUI Mac app ("Designed for iPad" is not acceptable for a quality bar)*.
- **Recommendation: native SwiftUI multiplatform target.** Catalyst is faster to stand up but inherits iOS idioms (and UIKit AppDelegate baggage) and tends to feel "iPad-in-a-window." Native SwiftUI gives a true Mac feel and forces the clean `NotelayerKit` extraction we want anyway. Trade-off: more `#if os(macOS)` work for menus, window sizing, and Firebase/AppDelegate equivalents (`NSApplicationDelegateAdaptor`).

**Layout**
- `NavigationSplitView`: sidebar (To-Dos, Insights, Settings) + content + optional detail column. Notes: pending §12 open decision — Mac sidebar has space for it unlike the iOS pill tab bar.
- Menu bar commands: New Task (⌘N), Voice Capture (⌘⇧V), Search (⌘F), Preferences (⌘,). New Note (⌘⇧N) added only if Notes is re-surfaced (§12 decision).
- Multiple windows / window restoration; keyboard-first navigation; hover states.
- Settings as a standard macOS Settings scene (⌘,) mapping to existing settings views.

**Parity**: To-Dos + Insights (matching current iOS v1.5.0). Notes pending decision — Mac sidebar naturally accommodates it without the crowding concern that drove its removal from the iOS pill tab bar. Categories, reminders, appearance/theming, sign-in (Google/Apple), drag-drop + Services menu capture.

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
- `OpenViewIntent` (To-Dos / Insights — Notes if re-surfaced, see §12).
- **App Shortcuts** (`AppShortcutsProvider`) with spoken phrases so they work with zero user setup.
- **App Entities**: expose `Task`/`Category` as `AppEntity` so Siri can disambiguate and Spotlight can index.
- Donate intents on task creation/completion to improve Siri suggestions.

This intent layer lives in `NotelayerKit` and writes through `LocalStore`/sync, so behavior is consistent regardless of which surface triggered it.

---

## 9. Significant Gaps & Risks

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

## 10. Branches vs. Worktrees (recommendation)

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

## 11. Execution Plan (Waves)

**Wave 0 — Decisions (no code).** Lock: Catalyst vs native Mac (rec: native); Firebase SPM migration + Watch sync strategy (rec: WatchConnectivity bridge); raise iOS floor to 16 (rec: yes); Mac distribution (Mac App Store vs notarized direct).

**Wave 1 — `NotelayerKit` extraction.** Move design/domain/data/services into a shared package. Purge UIKit from the shared layer behind platform shims. iOS app re-targets the package. *Acceptance: iOS app builds + all existing tests pass unchanged, zero visual diff (screenshot tests green).*

**Wave 2 — App Intents package.** Build intent + entity layer on top of `NotelayerKit`; wire into iOS first. *Acceptance: Siri/Shortcuts add/complete/query work on iOS.*

**Wave 3 — Mac target.** `NavigationSplitView` shell, menu commands, settings scene, macOS auth + Firebase. *Acceptance: full parity, ui-consistency pass, token diff = 0.*

**Wave 4 — Watch target.** Triage list, quick capture, complications, WatchConnectivity sync, notifications. *Acceptance: capture + complete round-trips to iPhone; tokens match.*

**Wave 5 — Integration/QA.** Cross-platform sync, Figma visual diff, CI lanes (fastlane Mac/Watch), regression. *Acceptance: `ui-consistency` pre/post pass on all surfaces; status docs updated.*

Run the existing `ui-consistency` command before/after every UI wave (per program convention).

---

## 12. Wave 0 Decisions

**Locked (2026-06-24):**
1. ✅ **Mac approach:** native SwiftUI multiplatform target (not Catalyst).
2. ✅ **iOS minimum:** raise to iOS 16 for the multiplatform line, enabling App Intents everywhere.
3. ✅ **Watch sync:** WatchConnectivity bridge via the paired iPhone (no standalone/cellular this phase).

**Still open:**
4. **Notes on Mac:** Notes tab is hidden on iOS (v1.5.0, intentional). Mac sidebar has space — should Notes be re-surfaced there? Options: (a) re-surface on Mac only, (b) re-surface on iOS + Mac together, (c) keep hidden everywhere. This affects the sidebar item count and the `NotelayerKit` extraction scope.
5. **Firebase:** migrate to SPM (recommended — needed for clean macOS support) vs keep CocoaPods iOS-only + separate dep path. *Leaning SPM; confirm before Wave 1.*
6. **Mac distribution:** Mac App Store vs notarized direct download?
7. **Watch scope:** capture/triage only (recommended) confirmed implicitly by the WatchConnectivity decision; flag if you want a single glanceable Insights metric.

---

## 13. Definition of Done

- Mac + Watch targets ship from a single `NotelayerKit` source of truth.
- Token diff between platforms = 0 (validated via `DesignSystemValidation` + Figma variable diff).
- Siri/App Intents add/complete/query work on iOS, Mac, and Watch.
- Cross-surface real-time sync verified.
- `ui-consistency` passes on every surface; all status/plan docs updated.
- No unresolved Wave 0 blockers.
