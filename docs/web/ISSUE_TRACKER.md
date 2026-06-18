# Notelayer Chrome Extension — Issue Tracker

**Branch:** `claude/notelayer-chrome-extension-0pwV8`  
**Last Updated:** 2026-06-18

---

## Status Key

| Symbol | Meaning |
|--------|---------|
| ✅ | Fixed and pushed |
| ⚠️ | Partial — gaps remain |
| 🔴 | Active — fix in progress |
| ❌ | Not started |
| 🔧 | Requires user action (not code) |

---

## Round 1 Issues (from first screenshot)

| # | Issue | Status | Fix |
|---|-------|--------|-----|
| 1 | Google sign-in didn't work | ✅ | Offscreen + Firebase hosted popup |
| 2 | No Apple sign-in | ✅ | Button added; backend config in AUTH_SETUP.md |
| 3 | Onboarding wrong for existing users | ✅ | Existing iOS users skip onboarding |
| 4 | "Invalid Date" on all tasks | ✅ | Firestore Timestamp → ISO via `tsToString()` |
| 5 | Done tasks not syncing | ✅ | iOS `completedAt` ↔ web `isCompleted` mapped |
| 6 | Categories not showing | ✅ | `normalizeCategory()` uses `snap.id`; removed bad `orderBy` |
| 7 | No theme / accent colour | ✅ | Full appearance sheet (see Round 2 #18) |
| 8 | Wrong font | ✅ | Space Grotesk + Work Sans via Google Fonts CDN; CSP updated |
| 9 | No subtasks | ✅ | Subtask expand/collapse in List view; drag-to-reorder within parent |
| 10 | Notes as global bottom tab | ✅ | Moved to overflow menu |
| 11 | No add task on Priority/Category/Date views | ✅ | FAB opens bottom-sheet quick-add |
| 12 | Insights wrong structure | ✅ | Single scrollable page; drilldown on each item |
| 13 | Insights not synced | ✅ | Uses live Firestore data via normalized hooks |
| 14 | OAuth popup shows "notelayer-c7bba" | 🔧 | Fix in Google Cloud Console → OAuth consent → App name |

---

## Round 2 Issues (from second screenshot review)

| # | Issue | Status | Fix |
|---|-------|--------|-----|
| 15 | Categories not syncing between iOS and web | ✅ | Same fix as #6 |
| 16 | Headers not collapsible | ✅ | GroupHeader is a `<button>` with animated chevron |
| 17 | Add task missing in non-list views | ✅ | FAB floats over Priority/Category/Date views |
| 18 | No theming | ✅ | ThemeSheet with mode + wallpaper + accent |
| 19 | Calendar sync, voice, reminders, web capture | ❌ | Phase 3–6 |

---

## Round 3 Issues (current — from "theming is terrible" review)

### A — Theming: No Light/Dark Mode  ✅

```
Before:                         After:
┌────────────────┐              ┌────────────────┐
│ Dark only      │              │ APPEARANCE     │
│ No mode toggle │              │ ─────────────  │
│ No wallpaper   │              │ MODE           │
└────────────────┘              │ [Auto][☀ Light][☾ Dark] │
                                │ ─────────────  │
                                │ WALLPAPER      │
                                │ [▓][▓][▓][▓][▓]│
                                │ Irid Focus Mid Sun Arc │
                                │ ─────────────  │
                                │ ACCENT COLOUR  │
                                │ ⬤⬤⬤⬤⬤⬤⬤⬤⬤⬤⬤⬤ │
                                └────────────────┘
```

**What changed:**
- `ThemeSheet.tsx` — Mode toggle (Auto/Light/Dark), 5 wallpaper presets (Iridescent, Focus, Midnight, Sunset, Arctic) from iOS `ThemeWallpaperCatalog`, 12 accent colours from iOS `ThemeAccentCatalog`
- `tokens.css` — Full `[data-theme="light"]` block: gray100 bg, gray50 surface1, white surface2, indigo500 accent (iOS light mode values from `DesignSystem.swift`)
- `App.css` — `--wallpaper-overlay` CSS var driven by ThemeSheet; light-mode tab bar styles
- Mode saved to `chrome.storage.local` as `notelayer_theme_mode`
- Wallpaper saved as `notelayer_theme_wallpaper`

---

### B — Subtasks Not Drag-and-Droppable  ✅

```
Before:                         After:
Subtasks shown but              Each subtask has drag handles
static — cannot reorder         within its parent container.
                                Drag subtask → drops → 
                                reorderTasks() called for
                                that parent's children only.
```

**What changed:** `TodosView.tsx` — separate `subtaskDragId`/`subtaskDragOverId` refs; `handleSubtaskDrop(children)` called per parent group; each subtask `<div>` is `draggable`

---

### C — Font Hard to Read  ✅

```
Before: font-weight: 400 (regular)   →   After: font-weight: 440 (base body)
Task titles: no weight                →   Task titles: var(--weight-medium) 500
font-synthesis: on (faux bold)        →   font-synthesis: none
```

**What changed:** `App.css` base `font-weight: 440`; `TaskRow.css` title `font-weight: var(--weight-medium)`; `font-synthesis: none` prevents faux bolding

---

### D — Task Edit Needs Save Button / Auto-Saves  ✅

```
Before:                         After:
┌──────────────────────┐        ┌──────────────────────┐
│ Cancel  Edit Task  Save│      │ Done  Edit Task  📅 ✓│
│ (Save disabled until  │       │ (auto-saves 600ms     │
│  something changes)   │       │  after each change,   │
└──────────────────────┘        │  shows ✓ Saved flash) │
                                └──────────────────────┘
```

**What changed:** `TaskEditSheet.tsx` — `useEffect` debounce (600ms) on `[title, priority, selectedCats, dueDate, notes]` calls `updateTask`; removed Save button; Cancel → "Done"; `savedFlash` indicator

---

### E — Unselected Categories Too Dim  ✅

```
Before: opacity: 0.5 (50%) on unselected
After:  opacity: 0.75 (75%) on unselected, with hover 0.9
```

**What changed:** `TaskEditSheet.css` — `.sheet__cat-btn` raised from `opacity: 0.5` to `0.75`

---

### F — Add to Calendar  ✅

```
User taps 📅 button in task edit →
Google Calendar pre-filled event opens in new tab:
  Title:   task.title
  Start:   dueDate (or today) at 09:00
  End:     +15 minutes
  Details: notes + categories + priority + "Source: Notelayer"
```

**What changed:** `TaskEditSheet.tsx` — `handleAddToCalendar()` builds `calendar.google.com/calendar/r/eventedit?...` URL; `chrome.tabs.create({ url })` opens it; calendar icon button in sheet header

---

### G — Notes Button in Header Top-Left  ✅

```
Before:                         After:
[📄] [···]  To-Dos              [···]  To-Dos
 ↑
 Notes button in header         Notes accessible via ··· menu:
                                  Appearance
                                  Notes          ← here
                                  Manage Categories
                                  Select Tasks
                                  ─────────────
                                  Sign Out
```

**What changed:** `TodosView.tsx` — removed `<button className="todos__notes-btn">` from header; added `<button onClick={onOpenNotes}>Notes</button>` inside the `···` dropdown menu; also renamed "Themes" → "Appearance"

---

### H — Insights No Drilldown  ✅

```
Overview:                       Drilldown (tap any category row):
┌────────────────┐              ┌────────────────┐
│ Streak Rate    │              │ ← Work          │
│ [14d] [82%] → │              │ 3 open · 7 done │
│ Created Completed│            │                  │
│  [23]   [19] → │             │ ○ Fix homepage   │
│                │              │ ○ Write copy     │
│ By Category ▼  │             │ ○ Review design  │
│ Work   ███ 10→ │             │ ✓ Launch v1     │
│ Home   ██  6 →│             └────────────────┘
│                │
│ tap to drill down            Stat cards also tappable:
└────────────────┘             Streak/Rate/Created/Completed/Overdue
```

**What changed:** `InsightsView.tsx` — `drilldown` state; category rows are `<button>` elements that set drilldown; stat cards get `onClick`; `DrilldownView` shows filtered task list with done/open indicators; back button returns to overview

---

## Future Phase Features

| Feature | Phase | Status |
|---------|-------|--------|
| Web capture (right-click) | 3 | ❌ |
| Push reminders | 4 | ❌ |
| Google Calendar two-way sync | 5 | ❌ |
| Apple `.ics` feed | 5 | ❌ |
| Voice capture | 6 | ❌ |
| Full theme sync iOS↔web | 7 | ❌ |
| Chrome Web Store publish | 8 | ❌ |

---

## What's Working (full list)

- ✅ Google sign-in (offscreen + Firebase hosted popup)
- ✅ Real-time Firestore sync — iOS ↔ web, full data compatibility
- ✅ Light mode / Dark mode / System (auto) with iOS-matched tokens
- ✅ 5 wallpaper gradients from iOS ThemeWallpaperCatalog
- ✅ 12 accent colours from iOS ThemeAccentCatalog
- ✅ Doing / Done toggle
- ✅ 4 lens views: List / Priority / Category / Date
- ✅ Collapsible group headers
- ✅ Subtask expand/collapse + drag-to-reorder within parent
- ✅ Inline task creation (List) + FAB sheet (other views)
- ✅ Auto-saving task edit (600ms debounce, no Save button)
- ✅ Add to Calendar button → Google Calendar pre-fill
- ✅ Notes overlay (accessible from ··· menu, not header button)
- ✅ Insights with drilldown on categories and stat cards
- ✅ Category manager
- ✅ Space Grotesk + Work Sans fonts
- ✅ FAB for task entry on non-list views
