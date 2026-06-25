---
title: Notelayer Feature Inventory
last_updated: 2026-06-25
status: active
scope: all-platforms
group: product
tags: [features, ios, mac, watch, ipad, ground-truth]
related: [MULTIPLATFORM_PRD.md, REPOS.md, DS_COMPONENTS.md]
source_of_truth_for: [notelayer-ios, notelayer-web, notelayer-marketing]
---

# Notelayer Feature Inventory

**Last Updated:** 2026-06-25
**Status:** Active
**Scope:** All Platforms
**Source of Truth:** Current Swift code (v1.5.0, commit `b1aee8f`) + PRD 09 for Mac/Watch planned state

This document is the single canonical reference for what Notelayer does on each platform. Update it when features ship or scope changes. It supersedes `PRODUCT_INVENTORY.md`.

---

## iPhone (iOS 16+) — Ground Truth, v1.5.0

All features below are **shipped and accessible** in the current App Store build unless marked ⚠️ Gated.

### Todos

| Feature | Detail |
|---------|--------|
| Add task | Inline text input at bottom of screen |
| Edit task | Full editor sheet: title, notes, priority, categories, due date, reminder |
| Complete task | Checkbox toggle; moves to Done view |
| Restore task | Toggle completed task back to active |
| Delete task | Swipe left or context menu |
| Reorder tasks | Drag and drop within any view |
| Bulk category update | Select multiple tasks → assign category |
| List view | All active tasks, flat list |
| Priority view | Tasks grouped by High / Medium / Low / Deferred |
| Category view | Tasks grouped by assigned category |
| Date view | Grouped: Overdue / Today / Tomorrow / This Week / Later / No Due Date |
| Doing / Done toggle | Switch between active and completed tasks |
| Context menu | Per-task: Edit, Share, Set Reminder, Add to Calendar, Delete |
| Swipe actions | Delete (left), complete (right) |
| Task card | Title, priority badge, category chips, due date indicator |

### Categories

| Feature | Detail |
|---------|--------|
| Add category | Name + emoji + color |
| Edit category | Name, emoji, color |
| Reorder categories | Drag and drop |
| Delete category | With confirmation |
| Category chips | Displayed on task cards and task editor |
| Default presets | Starter categories shown on first run |
| Emoji picker | Native emoji keyboard integration |

### Insights (Analytics)

| Feature | Detail |
|---------|--------|
| Completion rate | % of tasks completed in time window |
| Tasks completed over time | Bar/line chart by day or week |
| Category breakdown | Tasks per category, visual distribution |
| Streak tracking | Consecutive days with completed tasks |
| Oldest open tasks | List of longest-outstanding tasks |
| Feature usage section | In-app stats on which views/features used |
| Plain English labels | All axes and summaries written in plain language |

### Reminders

| Feature | Detail |
|---------|--------|
| Set reminder | Per-task; date + time |
| Local notifications | System notification at reminder time |
| Nag cards | Pending reminders shown as cards in Todos view |
| Edit reminder | Change time or remove |
| Delete reminder | Via task editor or nag card |

### Calendar Export

| Feature | Detail |
|---------|--------|
| Export task to calendar | Taps through to Calendar event editor |
| Edit before saving | Title, date, notes pre-filled from task |
| EventKit integration | Uses system calendar; works with any calendar account |

### Themes & Appearance

| Feature | Detail |
|---------|--------|
| Accent color | 7 options: Indigo, Purple, Pink, Blue, Green, Amber, Red |
| Surface style | 4 options: Soft, Frosted, Gradient, Solid |
| Mode | Light, Dark, System |
| Wallpaper | Themed wallpapers including Cheetah pattern |
| Live preview | Theme changes apply immediately |

### Auth & Sync

| Feature | Detail |
|---------|--------|
| Email sign-in | Firebase email authentication |
| Phone sign-in | Firebase phone + SMS verification |
| Guest / local mode | Full app access without sign-in; data stays on device |
| Cloud sync | Tasks and categories sync to Firestore on sign-in |
| Sign out | Clears session; local data retained |

### Share

| Feature | Detail |
|---------|--------|
| Share extension | Receive text/URLs from any app via iOS share sheet |
| Task sharing | Share individual task as text via system share sheet |
| App Group | `group.com.notelayer.app` enables extension ↔ app data sharing |

### Onboarding

| Feature | Detail |
|---------|--------|
| Welcome flow | Shown to new users on first launch |
| Starter categories | Pre-populated category presets |
| Skip option | Users can skip and start blank |

### Navigation & Shell

| Feature | Detail |
|---------|--------|
| Floating pill tab bar | Todos tab, Insights tab |
| Bottom input field | Fixed to bottom of Todos view |
| Shake to undo | Shake device to undo last task action |
| Haptic feedback | On task actions (complete, delete) |

---

### ⚠️ Gated — In Code, Not in App Store Build

These features are implemented in Swift but hidden by `experimentalFeaturesEnabled = false`. The Settings toggle was removed in v1.5.0. A deliberate decision is needed before multiplatform work on whether to ship, expose, or remove them.

| Feature | Code Files | Status |
|---------|-----------|--------|
| Voice capture | `VoiceInputController.swift`, `VoiceCaptureSheet.swift`, `VoiceTaskParser.swift` | Floating voice FAB hidden; speech recognition → structured task |
| Voice staging/preview | `VoiceStagingView.swift` | Review + edit step before voice tasks are saved |
| Subtask hierarchy | `Models.swift` (`parentTaskId`), `TodosView.swift` | Parent → child task structure; full UI built |

---

## Mac (macOS 13+, Apple Silicon) — Planned, PRD 09

Status: **Not started.** All items below are planned scope from `PRD_09_Mac_And_Watch_Multiplatform.md`.

### Shell & Navigation

| Feature | Detail |
|---------|--------|
| NavigationSplitView | Sidebar (categories/views) + detail pane (task list) |
| Toolbar | macOS standard toolbar with primary actions |
| Menu bar | Standard Mac menus (File, Edit, View) with keyboard shortcuts |
| Window sizing | Resizable; minimum size set; remembers last size |
| Multiple windows | (TBD — not in Wave 1 scope) |

### Todos (same as iPhone, adapted)

| Feature | Detail |
|---------|--------|
| All iPhone todo features | Full parity with iPhone task CRUD |
| Keyboard shortcuts | ⌘N new task, ⌘⌫ delete, ⌘↵ complete, ⌘E edit |
| Right-click context menu | Same actions as iOS context menu |
| Hover states | Reveal action buttons on row hover |
| Drag and drop | Reorder tasks; drag from Finder to create task from file |
| Inline editing | Double-click task title to edit inline (Mac convention) |

### Categories (same as iPhone)

Full parity.

### Insights (same as iPhone)

Full parity. Charts adapted to larger screen with more data visible.

### Reminders, Calendar, Share

Full parity with iPhone equivalents.

### Themes & Appearance

Full design system parity. `NotelayerKit` shared tokens ensure identical visual output.

### Auth & Sync

Full parity with iPhone. Same Firebase backend.

### App Intents / Siri / Apple Intelligence (Wave 3, aspirational)

| Feature | Detail |
|---------|--------|
| Add task via Siri | "Hey Siri, add task to Notelayer" |
| Complete task via Siri | Voice-complete by title |
| Shortcuts integration | App Shortcuts surfaced in Shortcuts.app |
| Spotlight | Tasks searchable via Spotlight |

### Mac-Only Features

| Feature | Detail |
|---------|--------|
| Touch Bar support | (TBD — low priority) |
| Notification Center widget | (TBD — Wave 4) |

---

## iPad (iPadOS 16+) — Current State + Planned

### Current State (v1.5.0)

The iOS app runs on iPad today but is **not iPad-optimized**. It runs as a scaled iPhone layout.

| Behavior | Detail |
|---------|--------|
| Runs on iPad | Yes — all iPhone features available |
| Layout | iPhone layout scaled up; pill tab bar, bottom input |
| Split View | Not supported — full screen only |
| Keyboard | External keyboard works; no keyboard shortcuts defined |
| Pencil | No Pencil support |

### Planned (not in PRD 09 scope — decision needed)

iPad is not in the current multiplatform PRD. Options:

**Option A — Minimum effort:** Ship the Mac app; iPad continues running iPhone layout. No special iPad work.

**Option B — Adaptive layout:** Add `NavigationSplitView` for iPad using the same Mac shell code. Moderate effort; high quality gain for large iPad.

**Option C — Dedicated iPad tier:** Full iPad design with Pencil, multi-column, Stage Manager. High effort; out of scope for current PRD.

Recommendation: **Option A** for the multiplatform release; revisit iPad as a separate PRD after Mac ships.

---

## Apple Watch (watchOS 9+) — Planned, PRD 09

Status: **Not started.** Planned scope from `PRD_09_Mac_And_Watch_Multiplatform.md`.

### Watch Features

| Feature | Detail |
|---------|--------|
| Today's tasks | Glanceable list of tasks due today |
| Complete task | Tap to complete from wrist |
| Add task | Dictation or Scribble input |
| Complication | Task count or next due task on watch face |
| Sync | WatchConnectivity bridge from iPhone; no direct Firestore |
| Offline capable | Reads last synced data when iPhone not nearby |

### Watch Exclusions (not on Watch)

| Excluded | Reason |
|---------|--------|
| Insights / Analytics | Screen too small; compute stays on phone |
| Theme customization | Not applicable on Watch |
| Full task editor | Watch input is gesture/dictation only |
| Calendar export | Stays on iPhone |
| Auth | Inherits from paired iPhone |

---

## Platform Comparison Table

| Feature | iPhone | Mac | iPad (current) | Watch |
|---------|--------|-----|----------------|-------|
| **Add task** | ✅ Text input | ✅ Text input + keyboard | ✅ Same as iPhone | ✅ Dictation / Scribble |
| **Edit task (full)** | ✅ Sheet | ✅ Panel / sheet | ✅ Same as iPhone | ❌ View only |
| **Complete task** | ✅ Checkbox | ✅ Checkbox / ⌘↵ | ✅ Same as iPhone | ✅ Tap |
| **Delete task** | ✅ Swipe | ✅ ⌘⌫ / right-click | ✅ Same as iPhone | ❌ Via iPhone only |
| **Reorder tasks** | ✅ Drag | ✅ Drag | ✅ Drag | ❌ |
| **Priority / Category / Date views** | ✅ | ✅ (sidebar) | ✅ | ❌ Today only |
| **Doing / Done toggle** | ✅ | ✅ | ✅ | ❌ |
| **Bulk operations** | ✅ | ✅ | ✅ | ❌ |
| **Categories (CRUD)** | ✅ | ✅ | ✅ | ❌ |
| **Insights / Analytics** | ✅ | ✅ (larger charts) | ✅ | ❌ |
| **Reminders / nag cards** | ✅ | ✅ | ✅ | ⚠️ Notifications only |
| **Calendar export** | ✅ | ✅ | ✅ | ❌ |
| **Theme & appearance** | ✅ Full | ✅ Full | ✅ Full | ❌ |
| **Auth + sync** | ✅ | ✅ | ✅ | ⚠️ Via iPhone |
| **Share extension** | ✅ | ✅ (planned) | ✅ | ❌ |
| **Voice capture** | ⚠️ Gated | ❌ (TBD) | ⚠️ Gated | ✅ Dictation only |
| **Subtask hierarchy** | ⚠️ Gated | ⚠️ Gated | ⚠️ Gated | ❌ |
| **App Intents / Siri** | ❌ Planned | ❌ Planned | ❌ Planned | ❌ |
| **Watch complication** | N/A | N/A | N/A | ✅ Planned |
| **Keyboard shortcuts** | ❌ | ✅ | ⚠️ Partial | N/A |
| **Right-click / context menu** | ⚠️ Long-press | ✅ Right-click | ⚠️ Long-press | N/A |
| **Navigation shell** | Pill tab bar | NavigationSplitView | Pill tab bar (scaled) | List |
| **Offline capable** | ✅ Guest mode | ✅ Guest mode | ✅ Guest mode | ✅ Last synced |
| **Notes tab** | ⚠️ Hidden | ❓ Decision needed | ⚠️ Hidden | ❌ |

**Key:**
- ✅ Shipped / planned and fully supported
- ⚠️ Partial, gated, or platform-constrained
- ❌ Not supported / not in scope
- ❓ Open decision

---

## Open Decisions (Required Before Coding)

| # | Decision | Options | Impacts |
|---|---------|---------|---------|
| 1 | Gated features (voice, subtasks) | (A) Ship on Mac where they make sense, (B) Remove dead code first, (C) Keep gated | PRD 09 scope |
| 2 | Notes tab | (A) Re-surface on Mac, (B) Stay hidden everywhere, (C) Build rich editor first | Mac shell design |
| 3 | iPad approach | (A) iPhone layout, (B) Adaptive with Mac shell code, (C) Dedicated PRD | PRD 09 scope |
| 4 | Mac distribution | (A) Mac App Store, (B) Direct download, (C) Both | Entitlements, notarization |
| 5 | Firebase SPM migration | (A) SPM (required for Mac worktree), (B) Stay on CocoaPods | Wave 1 dependency |
