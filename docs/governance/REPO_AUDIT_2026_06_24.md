# Notelayer iOS — Full Repo Audit

**Created:** 2026-06-24  
**Branch:** `claude/hopeful-rubin-9xouzo`  
**Scope:** All files under `/docs/`, all Swift source under `/ios-swift/Notelayer/Notelayer/`  
**Purpose:** Pre-multiplatform cleanup pass — classify every doc, surface aspirational-vs-real gaps, and produce a recommended canonical doc structure before Mac/Watch development begins.  
**Source of Truth Hierarchy (tiebreaker order):**  
1. Current Swift code (what compiles and ships)  
2. v1.5.0 App Store build (commit `b1aee8f`)  
3. `PRODUCT_INVENTORY.md` (stale but intentional)  
4. PRD docs  

---

## Part 1: Document Classification

202 total files in `/docs/`. Classified into 7 categories.

### Category A — Canonical / Accurate (Keep, Update Before Multiplatform Work)

These documents accurately reflect the current v1.5.0 state. They are the authoritative references for PRD 09 work.

| File | Notes |
|------|-------|
| `UI_COMPONENT_GUIDE.md` | Gold standard patterns. ⚠️ `.insetGrouped` is iOS-only — must add macOS caveat before Mac dev. |
| `CHANGELOG_v1.5.0.md` | Accurate v1.5.0 history. |
| `RELEASE_NOTES_v1.5.0.md` | Accurate. |
| `APP_STORE_DESCRIPTION_v1.5.0.md` | Current store copy. |
| `APP_STORE_LAUNCH_CHECKLIST_v1.5.0.md` | Accurate checklist for v1.5.0 release. |
| `PRD_09_Mac_And_Watch_Multiplatform.md` | Created this session — authoritative for multiplatform work. |
| `Git_Worktrees_Explained.md` | Created this session. |
| `DesignSystem/Documentation/Token_Reference_Guide.md` | Accurate token documentation. |
| `DesignSystem/Documentation/Theme_Reference_Guide.md` | Accurate theme documentation. |
| `DesignSystem/Documentation/Component_Library_Reference_Guide.md` | Accurate component reference. |
| `DesignSystem/Documentation/Accessibility_Guide.md` | Accurate. |
| `DesignSystem/Documentation/Data_Row_Patterns_Reference_Guide.md` | Accurate. |
| `DesignSystem/Documentation/Floating_Tab_Bottom_Clearance_Reference_Guide.md` | Accurate. |
| `DesignSystem/Documentation/Migration_Guide.md` | Accurate. |
| `Analytics_Events.md` | Accurate — analytics events match code. |
| `BUILD_INSTRUCTIONS.md` | Accurate build setup. |
| `QUICK_START.md` | Accurate. |
| `PRIVACY_POLICY.md` | Accurate. |
| `Insights_Validation_Guide.md` | Accurate. |
| `Reminder_Implementation_Summary.md` | Accurate — reminders implemented. |
| `Share_Extension_Implementation_Summary.md` | Accurate — share extension IS implemented (see §2). |

---

### Category B — Stale / Needs Update Before Multiplatform Work

Docs that were once accurate but no longer reflect v1.5.0. **Do not use as reference without reading current code first.**

| File | What's Wrong |
|------|-------------|
| `PRODUCT_INVENTORY.md` | Last updated 2026-04-11. Predates v1.5.0 changes: shows 3 tabs (Notes/Todos/Insights), doesn't reflect Notes tab removal. Lists some features as planned that are now shipped. Primary pre-multiplatform update target. |
| `Native_Status.md` | States Share Extension is "0% Not Started" — but `NotelayerShareExtension/ShareViewController.swift` is fully implemented. States Notes as "0% Not Started" — code exists in `NotesView.swift` (plain text, not rich text, but not zero). |
| `Native_Parity_Map.md` | Calls backend "Supabase" throughout — backend is Firebase. Describes 3 tabs. The `notelayer-web` repo exists (Chrome extension) but is a separate codebase; the parity map was written against a Supabase model that was never built. Aspirational document mislabeled as parity map. |
| `Native_Runbook.md` | References Supabase. Predates current Firebase architecture. |
| `PRD_00_Feature_Set_Index.md` | May reference features from PRD 07/08 as shipped — needs review. |
| `Notelayer_Design_System_Reference_Guide.md` | Overlaps heavily with `DesignSystem/Documentation/` — potential contradictions if tokens diverged. |
| `Design_System_Production_Architecture_Claude_Sonnet.md` | Documents a refactor that may or may not reflect current `DesignSystem.swift` state. |
| `Theme_System_v2.md` | Documents theme v2 architecture — verify against `ThemeManager.swift`. |
| `Project_Feature_Master_Plan.md` | Broad feature plan, likely pre-v1.5.0. |
| `Project_Implementation_Plan.md` | References Supabase — stale. |
| `STATUS_REPORT.md` | Snapshot from unknown date — references Supabase. |
| `App_Store_Release_Notes.md` | Multiple versions — earlier entries may describe pre-shipped state. |
| `Project_Release_Notes.md` | Same concern. |
| `000_Docs_Start_Here.md` | Index doc — should be updated to reflect actual canonical hierarchy. |
| `010_Docs_Features_Hub.md` | Hub index — may point to stale docs. |
| `Project_Changelog.md` | Ongoing changelog — verify latest entries are current. |
| `Beta_Improvements_Progress_Tracking.md` | Beta-era tracking — may describe in-flight work that has since shipped or been dropped. |

---

### Category C — Aspirational / Not Yet Implemented in Code

Features explicitly documented in PRDs or plans that have **zero or minimal Swift implementation**. These are the gap items — see Part 2 for detail.

| File | Feature | Code Status |
|------|---------|-------------|
| `Native_Parity_Map.md` | Supabase-backed web app parity | ❌ `notelayer-web` (Chrome extension) exists but is a separate repo. This doc maps against a Supabase model that was never built in the iOS repo. |
| `PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First.md` | ChatGPT-optimized share parsing | ⚠️ Share extension exists; ChatGPT-specific handling unknown |
| `PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First_plan.md` | Same | ⚠️ |
| `PRD_08_Project_Based_Tasks_Parent_Subtasks.md` | Parent/subtask hierarchy | ⚠️ Partially implemented; gated by `experimentalFeaturesEnabled` |
| `PRD_08_Project_Based_Tasks_Parent_Subtasks_plan.md` | Same | ⚠️ |
| `PRD_Nav_Onboarding_Insights_DeepLinks_Plan.md` | Deep link routing | ❓ Check code |
| `PRD_Navigation_Experimental_Onboarding_DeepLinks.md` | Same | ❓ Check code |
| `Share_Extension_Enhancement_Plan.md` | Enhanced share parsing | ❓ May be aspirational beyond base implementation |
| `Share_Sheet_Enhancement_Plan.md` | Share sheet improvements | ❓ |
| `Emoji_Keyboard_Implementation_Plan.md` | Emoji picker for categories | ✅ Likely shipped — `EmojiTextField.swift` exists |
| `Calendar_Export_Implementation_Plan.md` | Calendar export | ✅ Shipped — `CalendarExportManager.swift` exists |

---

### Category D — Process / Operational (Archival, No Update Needed)

Build, release, CI, and distribution docs. Accurate for their moment in time. Keep for historical reference; not needed day-to-day.

| Files |
|-------|
| `APP_REVIEW_NOTES.md`, `APP_REVIEW_NOTES_PLAN.md` |
| `APP_STORE_ASSETS.md`, `APP_STORE_METADATA.md`, `APP_STORE_METADATA_PLAN.md` |
| `APP_STORE_LAUNCH_CHECKLIST_v1.5.0.md` |
| `AUTOMATED_SCREENSHOT_IMPLEMENTATION_SUMMARY.md`, `AUTOMATED_SCREENSHOT_PLAN.md`, `AUTOMATED_SCREENSHOT_USAGE.md` |
| `App_Store_Screenshot_Generation_Execution_Tracker_2026_02_12.md` |
| `Build_And_Distribution_Fixes.md`, `Build_Assessment.md`, `Build_Fixes_Implementation_Plan.md`, `Build_Fixes_Summary.md` |
| `Build_Warnings_Cleanup_Issue_Report.md`, `Build_Warnings_Cleanup_Summary.md` |
| `DEBUG_CODE_CLEANUP_PLAN.md`, `DEBUG_CODE_CLEANUP_SUMMARY.md` |
| `Dsym_Configuration_Guide.md` |
| `FULL_AUTOMATION_PROMPT.md` |
| `Github_Actions_Checklist.md` |
| `MERGE_AND_SHIP_PLAN_v1.5.0.md` |
| `PRE_SUBMISSION_CHECK_PLAN.md` |
| `SCREENSHOT_GUIDE.md`, `SCREENSHOT_GUIDE_PLAN.md`, `SCREENSHOT_TASK_DATA.md` |
| `SETUP_COMPLETE.md` |
| `Ship_Command_Plan.md` |
| `Testflight_Automation_Fix_Plan.md`, `Testflight_Automation_Plan.md`, `Testflight_Setup_Guide.md` |
| `XCUITEST_SETUP.md` |
| `v1.5.0_Build2_Release_Fix_Checklist.md` |
| `v1.5.0_Crash_On_Launch_Assessment_And_Remediation_Plan.md` |
| `Release_Checklist.md`, `Release_Checklist_Plan.md` |
| `App_Store_Rejection_Fix_Summary.md` |
| `PRD_Single_Chat_One_Prompt_Execution_Guide.md` |
| `PRD_Parallel_Chat_Launch_Pack.md`, `PRD_Parallel_Execution_Control_Plan.md` |
| `PRD_Unified_Execution_Master_plan.md` |
| `PRD_Program_Overview_And_Release_Summaries.md` |
| `050_Docs_Snapshot_Runbook.md`, `060_Project_Changelog_Index.md`, `070_Project_Feature_Master_Plan_Index.md` |
| `Docs_Snapshot_Implementation_Plan.md` |
| `APP_ICON_UPDATE_PLAN.md`, `APP_ICON_UPDATE_SUMMARY.md` |
| `App_Icon_Alpha_Fix_Summary.md` |
| `PRIVACY_POLICY_PLAN.md` |
| `release-notes/performance-updates-claude.md` |
| `Performance_Build_Assessment_Report.md`, `Performance_Review_Progress_Tracking.md` |
| `BUG_FIX_APRIL_2026.md` |
| `Project_Learning_Opportunity_Notes.md` |
| `Project_Readme.md` |

---

### Category E — Bug/Fix/Plan Triplets (Archival)

Historical issue → plan → summary docs for specific bugs. Accurate for their moment; archival only. No update needed.

| Topic | Files |
|-------|-------|
| Auth | `AUTH_ARCHITECTURE_REVIEW.md`, `AUTH_DEBUGGING_PLAN.md`, `Auth_And_Onboarding_Implementation_Plan.md`, `Auth_And_Sync_Issue_Report.md`, `Auth_Email_Magic_Link_And_Phone_Auth_Error_Issue_Report.md`, `Auth_Implementation_Summary.md`, `Auth_Phone_Apns_Swizzling_Issue_2026_01_30.md`, `Auth_Phone_Welcome_Plan_2026_01_30.md`, `Auth_Rebuild_Progress_Tracking.md`, `Auth_Simulator_Fix_Summary.md`, `Auth_Ux_Improvement_Plan.md` |
| Calendar | `Calendar_Bug_Fix_Plan.md`, `Calendar_Bug_Issue_Report.md`, `Calendar_Crash_Fix_Summary.md`, `Calendar_Export_Ux_Improvement.md`, `Calendar_Sheet_Bug_Issue_Report.md` |
| Category reorder | `Category_Group_Reorder_Drag_Fix_Plan.md`, `Category_Group_Reorder_Drag_Issue_Report.md`, `Category_Group_Reorder_Plan.md` |
| Header/Keyboard | `Header_Consistency_And_Keyboard_Tab_Visibility_Implementation_Plan.md`, `Header_Consistency_And_Keyboard_Tab_Visibility_Issue_Report.md` |
| Insights | `Insights_Data_Row_Patterns_Implementation_Plan.md`, `Insights_Feature_Usage_In_App_Section_Implementation_Plan.md`, `Insights_Feature_Usage_In_App_Section_Issue_Report.md`, `Insights_Global_Bottom_Clearance_And_Oldest_Open_Tasks_Implementation_Plan.md`, `Insights_Implementation_Plan.md`, `Insights_Requirements_Summary.md` |
| iOS standard | `Ios_Standard_Consistency_Issue_Report.md`, `Ios_Standard_Consistency_Plan.md` |
| Launch hang | `App_Launch_Hang_Untappable_And_Watchdog_Crash_Implementation_Plan.md`, `App_Launch_Hang_Untappable_And_Watchdog_Crash_Issue_Report.md` |
| New task group | `New_Task_Group_Placement_Progress_Tracking.md` |
| Reminder | `Reminder_Edit_From_Details_Issue_Report.md`, `Reminder_Edit_From_Details_Plan.md`, `Reminder_Edit_From_Details_Summary.md`, `Reminder_Implementation_Plan.md`, `Reminder_Implementation_Progress_Tracking.md` |
| Settings | `Settings_Consistency_Issue_Report.md`, `Settings_Consistency_Plan.md`, `Settings_Overhaul_Plan.md`, `Settings_Ui_Fix_Issue_Report.md`, `Settings_Ui_Fix_Plan.md` |
| Share extension bugs | `Share_Extension_Bug_Progress_Tracking.md`, `Share_Extension_Enhancement_Progress_Tracking.md`, `Share_Extension_Implementation_Plan.md`, `Share_Extension_Implementation_Progress_Tracking.md`, `Share_Extension_Quick_Start.md`, `Share_Extension_Xcode_Setup_Guide.md`, `App_Group_Setup_Fix_Summary.md` |
| Theme bugs | `THEME_UI_INCONSISTENCIES_PLAN.md`, `Theme_Action_Sheet_Full_Height_Implementation_Plan.md`, `Theme_Action_Sheet_Full_Height_Issue_Report.md`, `Theme_Persistence_Force_Quit_Issue_Report.md`, `Theme_Persistence_Force_Quit_Plan_2026_01_29.md`, `Theme_Sheet_Light_Dark_Mode_Not_Applying_Implementation_Plan.md`, `Theme_Sheet_Light_Dark_Mode_Not_Applying_Issue_Report.md`, `Theme_Surface_Tinting_PLAN.md`, `Theme_System_Architecture_Fix_Plan_Codex.md`, `Theme_Ui_Inconsistencies_Issue_Report.md` |
| Todos header | `Todos_Header_Alignment_Regression_Implementation_Plan.md`, `Todos_Header_Alignment_Regression_Issue_Report.md`, `Todos_Insights_Bottom_Clearance_Parity_Implementation_Plan.md` |
| UI badges | `Ui_Badges_Issue_Report.md`, `Ui_Consistency_Fixes_Issue_Report.md`, `Ui_Consistency_Fixes_Plan.md`, `Ui_Consistency_Fixes_Plan_2026_01_29.md`, `Ui_Tweaks_Summary.md` |
| Undo/shake | `Shake_Undo_Progress_Tracking.md`, `Undo_Task_Toggle_Progress_Tracking.md` |
| Voice | `Commands_Implementation_Progress_Tracking.md` |
| Misc | `Reminder_Picker_Sheet` (no doc found), `Low_Risk_Responsiveness_Optimization_Implementation_Plan.md`, `Task_Detail_Share_Sheet_Unification_Plan_2026_01_29.md`, `Firebase_Build_Errors_Issue_Report.md`, `Firebase_Build_Errors_Plan.md`, `Reminder_Edit_From_Details_Summary.md` |

---

### Category F — Design System Docs (Partially Redundant)

Four overlapping design system doc sets. Some are authoritative, some are superseded.

| File | Status |
|------|--------|
| `DesignSystem/Documentation/*.md` (7 files) | ✅ **Canonical** — authoritative design system reference |
| `DesignSystem/Examples/ComponentExample.swift` | ✅ Useful reference |
| `DesignSystem/Examples/CustomThemeExample.swift` | ✅ Useful reference |
| `DesignSystem/Exports/tokens.json` | ⚠️ Partial export — may not match current `DesignSystem.swift`; verify before multiplatform |
| `DesignSystem/Exports/figma-tokens.json` | ⚠️ Same concern — Figma export currency unknown |
| `DesignSystem/Exports/css-variables.css` | ℹ️ Web use only — not relevant to multiplatform Swift |
| `Notelayer_Design_System_Reference_Guide.md` | ⚠️ Overlaps with `DesignSystem/Documentation/` — keep as high-level summary only |
| `Design_System_Production_Architecture_Claude_Sonnet.md` | ⚠️ Describes architectural intent — verify against `DesignSystem.swift` |
| `Design_System_Production_Architecture_Claude_Sonnet_Plan.md` | Archival |
| `Theme_System_v2.md` | ⚠️ Documents theme v2 — verify against current `ThemeManager.swift` |
| `Theme_System_v2_PLAN.md` | Archival |
| `UI_COMPONENT_GUIDE.md` | ✅ **Canonical** — gold standard component patterns (Category A) |

---

### Category G — Index/Meta Docs (Update Before Multiplatform)

| File | Action Needed |
|------|--------------|
| `000_Docs_Start_Here.md` | Update to point to canonical docs; add PRD 09, Git_Worktrees_Explained, this audit |
| `010_Docs_Features_Hub.md` | Review links; remove or flag stale entries |
| `020_Docs_Feature_Implementation_Plans_Index.md` | Review |
| `030_Docs_Explorations_Index.md` | Review |
| `040_Docs_Governance.md` | Update governance rules for multiplatform era |
| `Welcome_And_Settings_Exploration.md` | May be outdated exploration |
| `Usage_Analytics_Plan.md` | Check if shipped or aspirational |

---

## Part 2: Aspirational Features — Documented But Not in Code

These are features described in docs (PRDs, plans, parity maps) that are **absent or incomplete** in the current Swift codebase. Ranked by how clearly they're documented vs. how absent they are in code.

### 🔴 Fully Aspirational — Zero Code Implementation

| Feature | Documented In | Code Evidence | Notes |
|---------|--------------|---------------|-------|
| **Supabase backend** | `Native_Parity_Map.md`, `Native_Runbook.md`, `Project_Implementation_Plan.md`, `STATUS_REPORT.md`, `Native_Status.md`, `DEBUG_CODE_CLEANUP_SUMMARY.md` | `grep "supabase"` → 0 Swift matches | Backend is Firebase/Firestore. Supabase docs are from an earlier architecture that was never built. These docs are now misleading. |
| **Web app (in iOS repo)** | `Native_Parity_Map.md`, `firebase-hosting/index.html` | `firebase-hosting/index.html` is boilerplate placeholder HTML | The `notelayer-web` repo exists (Chrome extension, separate codebase). What does NOT exist is a web app inside this iOS repo. `firebase-hosting` is an empty stub. Docs that describe a Supabase-backed web app as if it lives alongside the iOS code are inaccurate. |
| **visionOS app** | 3 docs mention visionOS as a target | `grep "visionOS"` → 0 Swift matches; v1.5.0 project explicitly opted out | Noted in some planning docs as future potential. Not started. |
| **App Intents / Siri / Apple Intelligence** | `PRD_09_Mac_And_Watch_Multiplatform.md` §Siri, general mentions | `grep "AppIntent\|SiriKit\|INIntent"` → 0 Swift matches | Fully aspirational. Planned for multiplatform Wave 3 (PRD 09). |
| **Notes rich text editor** | `Native_Parity_Map.md` describes full rich text editor with formatting toolbar | `NotesView.swift` → plain `Text(note.text)` in a `ScrollView`; no `TextEditor`, no formatting | The rich text editor described exists only in docs. The Notes view is a placeholder. |
| **Notes tab (visible)** | Multiple early docs show 3-tab design (Notes / Todos / Insights) | `RootTabsView.swift`: `visibleTabs = [.todos, .insights]` — Notes tab explicitly excluded | Notes was hidden in v1.5.0. Code structure preserved, tab hidden. Docs predate this change. |

---

### 🟡 Partially Implemented — Code Exists but Gated or Incomplete

| Feature | Documented In | Code Evidence | Gap |
|---------|--------------|---------------|-----|
| **Parent/subtask hierarchy (PRD 08)** | `PRD_08_Project_Based_Tasks_Parent_Subtasks.md` | `Models.swift` has `parentTaskId: String?`; `TodosView.swift` has full `hierarchyEnabled` logic with subtask rendering | Gated by `store.experimentalFeaturesEnabled`. The `experimentalFeaturesEnabled` Settings toggle was removed in v1.5.0 UI but the property still exists in `LocalStore.swift`. Subtask UI is in code but not reachable by users in the App Store build. |
| **Share extension (PRD 07 + ChatGPT-first)** | `PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First.md`, `Share_Extension_Implementation_Summary.md` | `NotelayerShareExtension/ShareViewController.swift` is fully implemented | Base share extension IS shipped (contra `Native_Status.md`). ChatGPT-specific parsing rules need code verification. Share extension may not be in the v1.5.0 App Store build — check entitlements and app group config. |
| **Experimental features framework (PRD 01)** | `PRD_01_Experimental_Features_Framework.md` | `LocalStore.experimentalFeaturesEnabled` exists; `TodosView.swift` and `TaskEditView.swift` read it | The Settings UI toggle was removed in v1.5.0. The property persists, defaults to `false`, and gates: voice FAB visibility, subtask hierarchy, and some task editor sections. Framework is zombie code — alive in the data layer, invisible in the UI. |
| **Voice entry capture (PRD 04)** | `PRD_04_Voice_Entry_Structured_Capture.md` | `VoiceInputController.swift`, `VoiceTaskParser.swift`, `VoiceCaptureSheet.swift`, `VoiceStagingView.swift` all exist | Gated by `experimentalFeaturesEnabled`. Voice button (FAB) only shows when experimental features on. Not accessible in standard v1.5.0 build. |
| **Voice staging/preview (PRD 05)** | `PRD_05_Voice_Entry_Preview_Staging.md` | `VoiceStagingView.swift` exists | Same gate as PRD 04. |
| **First-time onboarding (PRD 06)** | `PRD_06_First_Time_User_Onboarding.md` | `WelcomeView.swift`, `WelcomeCoordinator.swift` exist | `WelcomeCoordinator` controls display. Verify if shown to new users in v1.5.0 or also gated. |
| **Insights as experimental (PRD 03)** | `PRD_03_Analytics_Insights_Toggle.md` | `InsightsView.swift` exists; Insights tab IS in `visibleTabs` | Insights is always visible in v1.5.0 (not gated by experimental flag in current `visibleTabs`). PRD 03 described it as toggled — this was implemented then the approach changed. |
| **Shake to undo** | `Shake_Undo_Progress_Tracking.md` | `UndoShakeHost.swift` exists | Unknown if fully integrated or partial. |

---

### 🟢 Shipped — Docs May Call Them "Plans" But Code Confirms Implementation

| Feature | Code Evidence |
|---------|--------------|
| Reminders / nags | `ReminderManager.swift`, `RemindersSettingsView.swift`, `ReminderPickerSheet.swift` |
| Calendar export | `CalendarExportManager.swift`, `CalendarEventEditView.swift` |
| Share sheet (task sharing) | `ShareSheet.swift` |
| Analytics / Insights | `InsightsAggregator.swift`, `InsightsMetricDefinitions.swift`, `InsightsTelemetryStore.swift`, `InsightsView.swift` |
| Theme system v2 | `ThemeManager.swift`, `AppearanceStore.swift`, `ThemeBackground.swift`, `ThemeAppearanceModifier.swift` |
| Emoji picker for categories | `EmojiTextField.swift` |
| Drag-and-drop reorder | `CategoryGroupDragPayload.swift`, `TodoDragPayload.swift` |
| Bulk category updates | In `LocalStore.swift` |
| Sign in / auth (Firebase) | `AuthService.swift`, `SignInSheet.swift` |
| App Groups | `group.com.notelayer.app` configured in entitlements |

---

## Part 3: Critical Discrepancies — Docs That Actively Mislead

These docs should be flagged with a deprecation warning or updated **before** any new developer or AI session reads them.

| Doc | What It Says | What's Actually True |
|-----|-------------|---------------------|
| `Native_Status.md` | "Share Extension: ❌ Not Started 0%" | `NotelayerShareExtension/ShareViewController.swift` is fully implemented |
| `Native_Status.md` | "Notes: ❌ Not Started 0%" | `NotesView.swift` exists (plain text placeholder). Tab is hidden, not absent. |
| `Native_Parity_Map.md` | Entire document maps to a Supabase-backed web app | `notelayer-web` (Chrome extension) is a separate repo. The Supabase-backed model this doc describes was never built in the iOS codebase. Backend is Firebase. |
| `Native_Runbook.md` | Describes Supabase setup and connection strings | Backend is Firebase/Firestore. No Supabase. |
| `Project_Implementation_Plan.md` | Lists Supabase as the data backend | Firebase is the backend. |
| `STATUS_REPORT.md` | References Supabase integration | Stale — Supabase never built. |
| `PRODUCT_INVENTORY.md` | Lists 3 tabs (Notes, Todos, Insights) | v1.5.0: 2 visible tabs (Todos, Insights). Notes hidden. |
| `PRD_04/05_Voice_*` docs | Describe voice as a user-accessible feature | Voice is gated by `experimentalFeaturesEnabled = false`. Not accessible in v1.5.0 App Store build. |
| Various docs | Describe "AI task parsing" / voice-to-task as AI-powered | `VoiceTaskParser.swift` is fully local, rule-based NLP. No API calls. No AI/LLM. |

---

## Part 4: Swift Codebase — Source Files Reference

**62 app source files** (excluding Pods, tests, extensions).

### Core App

| File | Lines | Role |
|------|-------|------|
| `App/NotelayerApp.swift` | 363 | App entry point; `@UIApplicationDelegateAdaptor` (UIKit coupling — multiplatform gap) |
| `Data/Models.swift` | — | Task, Note, Category, Priority models; `parentTaskId` field present |
| `Data/LocalStore.swift` | 1,562 | Singleton ObservableObject; UserDefaults + app group; `experimentalFeaturesEnabled` |
| `Data/DesignSystem.swift` | 994 | Full token system: Primitive → Semantic → Component tokens |
| `Data/ThemeManager.swift` | 994 | Theme config: accent, surface style, mode, wallpaper |
| `Data/AppearanceStore.swift` | — | Appearance persistence |
| `Data/BackendSyncing.swift` | — | Sync protocol |
| `Data/SyncService.swift` | — | Sync orchestration |
| `Data/VoiceStateStore.swift` | — | Voice capture state |
| `Data/SharedItem.swift` | — | App group shared item model |
| `Data/InsightsMetricDefinitions.swift` | — | Metric definitions for Insights |
| `Data/CategoryColorDefaults.swift` | — | Default category colors |

### Services

| File | Role |
|------|------|
| `Services/FirebaseBackendService.swift` | Firebase/Firestore CRUD — the real backend |
| `Services/AuthService.swift` | Firebase Auth |
| `Services/AnalyticsService.swift` | Usage analytics |
| `Services/InsightsAggregator.swift` | Insights computation |
| `Services/InsightsTelemetryStore.swift` | Insights telemetry |
| `Services/ReminderManager.swift` | Local notifications for reminders |
| `Services/CalendarExportManager.swift` | EventKit calendar export |
| `Services/CalendarExportError.swift` | Export error types |
| `Services/VoiceInputController.swift` | Speech recognition controller |
| `Services/VoiceTaskParser.swift` | Local NLP rule-based parser (NOT AI/LLM) |
| `Services/WelcomeCoordinator.swift` | First-run onboarding coordinator |

### Views — Primary

| File | Lines | Role |
|------|-------|------|
| `Views/TodosView.swift` | 1,886 | Core feature; hierarchy gated by `experimentalFeaturesEnabled` |
| `Views/InsightsView.swift` | 1,192 | Analytics/Insights tab |
| `Views/RootTabsView.swift` | 395 | Tab bar; `visibleTabs = [.todos, .insights]` |
| `Views/NotesView.swift` | 128 | Placeholder; plain `Text(note.text)` only |
| `Views/TaskEditView.swift` | — | Gold standard settings pattern; full task editor |
| `Views/TaskItemView.swift` | — | Task card component |
| `Views/TaskInputView.swift` | — | Task creation input |
| `Views/AppearanceView.swift` | — | Theme picker UI |
| `Views/CategoryManagerView.swift` | — | Category CRUD UI |
| `Views/RemindersSettingsView.swift` | — | Reminders settings + `NagCardView` |
| `Views/ReminderPickerSheet.swift` | — | Reminder time picker |
| `Views/ManageAccountView.swift` | — | Account management |
| `Views/ProfileSettingsView.swift` | — | Profile/settings |
| `Views/SignInSheet.swift` | — | Auth sign-in sheet |
| `Views/VoiceCaptureSheet.swift` | — | Voice recording UI (experimental) |
| `Views/VoiceStagingView.swift` | — | Voice task staging/preview (experimental) |
| `Views/WelcomeView.swift` | — | First-run onboarding |

### Shared View Components

| File | Role |
|------|------|
| `Views/Shared/SettingsComponents.swift` | `PrimaryButtonStyle`, `TaskCategoryChip`, `TaskPriorityBadge` |
| `Views/Shared/InsetCard.swift` | Reusable card container |
| `Views/Shared/AppTabHeaderComponents.swift` | Tab header components |
| `Views/Shared/ThemeBackground.swift` | Theme background modifier |
| `Views/Shared/ThemeAppearanceModifier.swift` | Theme appearance modifier |
| `Views/Shared/AnimatedLogoView.swift` | Logo animation |
| `Views/Shared/ShareSheet.swift` | System share sheet wrapper |
| `Views/Shared/AuthButtonView.swift` | Auth action buttons |
| `Views/Shared/CalendarEventEditView.swift` | Calendar event editor |
| `Views/Shared/CategoryChipGridView.swift` | Category chip grid |
| `Views/Shared/CategoryGroupDragPayload.swift` | Category drag state |
| `Views/Shared/CheetahBackground.swift` | Cheetah background pattern |
| `Views/Shared/CheetahCardPattern.swift` | Cheetah card pattern |
| `Views/Shared/CustomDatePickerSheet.swift` | Date picker sheet |
| `Views/Shared/EmojiTextField.swift` | Emoji keyboard integration |
| `Views/Shared/RowContextMenu.swift` | Row context menu |
| `Views/Shared/TagChipsView.swift` | Tag chip display |
| `Views/Shared/TaskEditorSections.swift` | Reusable task editor sections |
| `Views/Shared/TodoDragPayload.swift` | Todo drag state |
| `Views/Shared/UndoShakeHost.swift` | Shake-to-undo integration |

### Extension + Tests

| File | Role |
|------|------|
| `NotelayerShareExtension/ShareViewController.swift` | **Implemented** share extension |
| `NotelayerInsightsTests/InsightsAggregatorTests.swift` | Insights unit tests |
| `NotelayerInsightsTests/VoiceTaskParserTests.swift` | Voice parser unit tests |
| `NotelayerInsightsTests/SharedItemTests.swift` | Shared item tests |
| `NotelayerScreenshotTests/ScreenshotGenerationTests.swift` | Screenshot automation |

---

## Part 5: Recommended Pre-Multiplatform Doc Actions

Before beginning any PRD 09 code work, do these in order:

### Step 1 — Add Deprecation Notices (1 hour, no content changes)

Add a banner to the top of each misleading doc:

```md
> ⚠️ **STALE — Do not use as reference.** See REPO_AUDIT_2026_06_24.md §3 for details.
```

Target files: `Native_Parity_Map.md`, `Native_Runbook.md`, `Native_Status.md`, `Project_Implementation_Plan.md`, `STATUS_REPORT.md`

### Step 2 — Update `PRODUCT_INVENTORY.md` (2–3 hours)

Bring it current with v1.5.0:
- 2 visible tabs (Todos, Insights). Notes hidden but code preserved.
- Experimental features toggle removed from Settings UI.
- Features always-on: Insights, categories, reminders, calendar export, auth, share extension.
- Features behind dead flag: Voice capture, subtask hierarchy.
- Features not started: App Intents/Siri, Notes rich text editor, Mac/Watch.

### Step 3 — Reconcile Design System Exports (1 hour)

Compare `DesignSystem/Exports/tokens.json` against current `DesignSystem.swift` to confirm token parity. Update export or add a note if drift exists. This matters for Figma and multiplatform design handoff.

### Step 4 — Update `000_Docs_Start_Here.md` (30 min)

Add to canonical references:
- `PRD_09_Mac_And_Watch_Multiplatform.md` (multiplatform PRD)
- `Git_Worktrees_Explained.md` (branching strategy)
- `REPO_AUDIT_2026_06_24.md` (this document)

### Step 5 — Decide on Zombie Features

Three features are in code but not user-accessible in v1.5.0. Before multiplatform work, make a deliberate decision on each:

| Feature | Current State | Options |
|---------|--------------|---------|
| Voice capture (PRD 04/05) | Code complete, experimental flag dead | (A) Re-expose in v1.6 settings, (B) Delete code, (C) Ship as-is on Mac/Watch |
| Subtask hierarchy (PRD 08) | Code complete, experimental flag dead | (A) Re-expose on Mac where it makes more sense, (B) Delete code, (C) Ship as experimental toggle |
| `experimentalFeaturesEnabled` flag | Exists in `LocalStore.swift`, no Settings UI | (A) Remove flag + all gated code, (B) Re-expose in Settings, (C) Keep as hidden dev toggle |

---

## Part 6: Canonical Reference Stack for PRD 09

When building for Mac, Watch, and App Intents, use these as the authoritative references — in priority order:

| Priority | Reference | For |
|----------|-----------|-----|
| 1 | Current Swift code | Any "is this implemented?" question |
| 2 | `PRD_09_Mac_And_Watch_Multiplatform.md` | Multiplatform architecture, features, waves |
| 3 | `DesignSystem/Documentation/` (all 7 files) | Design tokens, theme, components |
| 4 | `UI_COMPONENT_GUIDE.md` | iOS component patterns (note: `.insetGrouped` is iOS-only) |
| 5 | `CHANGELOG_v1.5.0.md` | What shipped when |
| 6 | `Git_Worktrees_Explained.md` | Branch/worktree strategy |
| 7 | `REPO_AUDIT_2026_06_24.md` (this file) | Gap analysis and doc health |

**Do not use** `Native_Parity_Map.md`, `Native_Status.md`, `Native_Runbook.md`, `Project_Implementation_Plan.md`, or `STATUS_REPORT.md` as reference — they describe a Supabase architecture that was never built.

---

*This audit covers the state of the repository as of 2026-06-24. Update after each major release or platform launch.*
