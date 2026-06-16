# Notelayer Chrome Extension — Full Rebuild Plan

**Created:** 2026-06-11  
**Status:** Awaiting Confirmation Before Implementation  
**Scope:** Full Chrome Side Panel extension with iOS feature parity (excluding voice capture)

---

## My Understanding of the Ask

You want the Chrome extension rebuilt from scratch as a **Chrome Side Panel** (permanent sidebar that stays open while you browse) with **full feature and visual parity with the iOS app**, minus voice capture. That means:

- Same visual design system: same dark theme, token system, badge shapes, row logic, colored category pills, priority indicators — everything derived from the iOS design docs, nothing guessed
- Same navigation: Notes tab, To-Dos tab, Insights tab
- Same task features: 4 view modes, drag-and-drop reorder, task edit sheet, subtasks/projects, complete/restore
- Same category management: full CRUD, drag reorder, colors, emoji icons
- Same Insights: trend view, category view, usage view, gap analysis, oldest open tasks
- Same onboarding: first-run welcome flow
- Right-click context menu: "Save to Notelayer as Task/Note" from any page
- Keyboard shortcut to open the panel
- Auth: Google sign-in (now wired with real client ID)
- Scalable platform architecture so Android, macOS, etc. can share the same core

**Not included (by your instruction):** Voice capture, voice staging

---

## What This Is NOT

This is not a minor UI polish. The current extension is a basic popup with a form. This rebuild:
- Switches the architecture from popup → Chrome Side Panel API
- Rebuilds every view from scratch matching iOS source
- Implements drag and drop (requires a persistent panel, not a popup)
- Implements Insights (charts, data views)
- Implements full category management
- Requires a full Vite + React build (vanilla JS is not feasible at this feature depth)

---

## Architecture Decision: Why Side Panel

| | Popup (current) | Side Panel (new) |
|---|---|---|
| Stays open while browsing | ❌ Closes on click | ✅ Persistent |
| Drag and drop | ❌ Impossible | ✅ Supported |
| Multi-step flows | ❌ State lost on close | ✅ State persists |
| Full task list | ❌ Too small | ✅ Full height |
| iOS-like navigation | ❌ | ✅ |
| Scalable to more features | ❌ | ✅ |

The Chrome Side Panel API (`chrome.sidePanel`) was introduced in Chrome 114 (2023) and is stable. It opens as a persistent sidebar alongside the page, full browser height.

---

## Design System Rules (from iOS docs — verified, not guessed)

All rules sourced from `docs/ios-reference/design-system/`.

### Colors (from Token_Reference_Guide.md)
```
Background:   #0F0F0F (base)
Surface:      #1C1C1E (elevated 1)
Surface 2:    #2C2C2E (elevated 2)
Surface 3:    #3A3A3C (elevated 3)
Border:       rgba(255,255,255,0.08)
Text primary: #FFFFFF
Text 2:       rgba(255,255,255,0.55)
Text 3:       rgba(255,255,255,0.30)
Accent:       #4F8EF7 (brand primary)
```

### Priority Colors (from iOS TaskItemView.swift — verified)
```
High:     #FF3B30  (red)   background at 15–18% opacity
Medium:   #FF9500  (orange)
Low:      #34C759  (green)
Deferred: gray text, no colored background
```

### Category Pills (from iOS categoryBadge() — verified)
```
Background: category.color at 18% opacity
Border:     category.color at 30% opacity (0.5pt stroke)
Text:       secondary text color
Shape:      capsule (border-radius: 100px)
Content:    "{icon} {name}" — emoji then name
Font:       caption (11–12px), single line, no wrap
```

### Task Row Layout (from iOS TaskItemView.swift — verified)
```
Layout:    HStack — [checkbox] [VStack title + metadata]
Checkbox:  circle icon, 24pt, green fill when complete
Title:     14-15px, strikethrough + dimmed when complete
Metadata:  horizontal scroll row below title:
           [due date] [priority badge] [category pill] [category pill...]
Card:      rounded 12pt corners, surface fill, border stroke
Padding:   10-12pt horizontal, 8pt vertical
```

### Group Headers (from iOS — Category/Priority modes)
```
Left border: 3pt, category color
Label:       "{icon} {name}" in secondary text
Count badge: capsule, category color at 18% opacity, category color text
```

### Tab Bar
```
Style:    floating pill, NOT a standard browser bottom bar
Tabs:     Notes | To-Dos | Insights
Active:   accent color underline or background
Inactive: secondary text
```

### Badge / Chip Shape Rules
```
Category pills: capsule (full border-radius)
Priority tags:  rounded rect (8px radius)
Count badges:   capsule
View mode tabs: segmented control with 3px inner padding, 7px item radius
```

---

## Feature Scope (confirmed from PRODUCT_INVENTORY.md)

### ✅ Included

**Auth**
- Google sign-in via chrome.identity (OAuth client ID wired)
- Persistent session in chrome.storage.local
- Sign out

**Notes Tab**
- Scrollable card list, sorted by updatedAt (newest first)
- Pinned notes section (pinned first)
- Add note (expandable input)
- Delete note (swipe action or button)
- Pin/unpin
- Share/copy from context menu

**To-Dos Tab**
- 4 view modes: List / Priority / Category / Date
- Segmented control to switch modes
- Doing / Done toggle
- Task input (collapses to one line, expands on focus showing priority + category)
- Task row: title, priority badge, due date, category pills, checkbox
- Complete / restore task
- Task edit sheet: title, categories, priority, due date, notes, delete
- Drag-and-drop reorder (List mode: orderIndex, Grouped modes: updates grouping field)
- Subtasks / parent tasks (PRD_08)
- Bulk select mode + bulk category edit
- Search (filter by title)
- Right-click context menu → save as task (from service worker)

**Insights Tab** (from PRD_02/03)
- Trend view (7D / 30D / 60D / 180D / 365D)
- Category breakdown view
- Usage view
- Gap analysis (Unused / Underused features)
- Oldest open tasks

**Categories**
- Full CRUD (create, rename, delete, reorder)
- Drag reorder in category manager
- Per-category emoji icon and hex color
- 8 default categories (from iOS defaults)

**Onboarding** (from PRD_06)
- First-run welcome flow (shown once)
- Starter category presets
- Guided setup

**Right-click context menu** (service worker)
- "Save to Notelayer as Task"
- "Save to Notelayer as Note"
- Auto-populates from selected text or page title + URL

**Keyboard shortcut**
- Ctrl+Shift+L (or Cmd+Shift+L on Mac) → open/focus side panel

**Theme**
- Dark mode (matches iOS dark theme)
- System preference detection for future light mode

### ❌ Excluded (by your instruction)
- Voice capture (PRD_04)
- Voice staging (PRD_05)

---

## Technical Architecture

### Platform-Scalable Package Structure
```
notelayer-web/
├── packages/
│   ├── shared/              ← Firebase, types, Firestore helpers (already exists)
│   ├── ui/                  ← NEW: shared React component library
│   │   ├── TaskRow.tsx      ← used by extension AND webapp
│   │   ├── CategoryPill.tsx
│   │   ├── PriorityBadge.tsx
│   │   ├── TaskInput.tsx
│   │   ├── GroupHeader.tsx
│   │   └── tokens.css       ← single source of design tokens
│   └── hooks/               ← NEW: shared React hooks
│       ├── useTasks.ts
│       ├── useNotes.ts
│       ├── useCategories.ts
│       └── useInsights.ts
├── extension/
│   ├── manifest.json        ← updated: popup → side_panel
│   ├── sidepanel.html       ← replaces popup.html
│   ├── src/
│   │   ├── sidepanel/       ← React app (mounted in side panel)
│   │   │   ├── App.tsx
│   │   │   ├── views/
│   │   │   │   ├── TodosView.tsx
│   │   │   │   ├── NotesView.tsx
│   │   │   │   └── InsightsView.tsx
│   │   │   └── components/
│   │   ├── background/      ← service worker (context menu, shortcuts)
│   │   └── content/         ← content script (future: floating capture button)
└── webapp/                  ← web app (imports from packages/ui and packages/hooks)
```

This means: when Android companion web app is built, it imports `@notelayer/ui` and `@notelayer/hooks` and doesn't rewrite TaskRow or Firestore logic.

### Manifest Changes Required
```json
{
  "side_panel": {
    "default_path": "sidepanel.html"
  },
  "permissions": [
    "storage", "activeTab", "contextMenus", 
    "identity", "sidePanel"       ← new
  ],
  "commands": {
    "open-side-panel": {
      "suggested_key": { "default": "Ctrl+Shift+L", "mac": "Command+Shift+L" },
      "description": "Open Notelayer panel"
    }
  }
}
```

---

## Build Phases

### Phase 1 — Foundation (Side Panel shell, auth, design tokens)
1. Extract `packages/ui` with design tokens CSS and base components
2. Update manifest: popup → side_panel, add sidePanel permission and keyboard command
3. Build side panel React app shell with tab bar (Notes | To-Dos | Insights)
4. Wire Google auth in side panel
5. Build `packages/hooks` with `useTasks`, `useNotes`, `useCategories`

### Phase 2 — To-Dos Tab (core feature)
6. TaskRow component (iOS-matching layout, badges, pills)
7. TaskInput component (expandable, category/priority controls)
8. List mode with drag-and-drop reorder
9. Priority mode (grouped by priority level)
10. Category mode (grouped by category with colored headers)
11. Date mode (Overdue / Today / Tomorrow / This Week / Later / No Due Date)
12. Task edit sheet (all fields)
13. Done toggle, search, bulk select

### Phase 3 — Notes Tab
14. Note card list (sorted by updatedAt)
15. Pinned section
16. Add/delete/pin/copy note

### Phase 4 — Insights Tab
17. `useInsights` hook computing metrics from Firestore
18. Trend chart (7D–365D window)
19. Category breakdown
20. Usage view + gap analysis
21. Oldest open tasks

### Phase 5 — Categories + Onboarding
22. Category manager panel (CRUD, drag reorder, color picker, emoji)
23. 8 default categories seeded on first run
24. First-run onboarding flow

### Phase 6 — Power features + polish
25. Right-click context menu → save as task/note (service worker, already scaffolded)
26. Keyboard shortcut to open panel
27. Subtasks / parent task UI
28. Offline queue (tasks saved locally when Firestore is unreachable, synced on reconnect)
29. `createdFrom: "chrome-extension"` metadata on all Firestore writes (per PRD_11 analytics spec)

---

## Your Action Items Before I Start

None — all blockers are cleared:
- ✅ Firebase config wired
- ✅ Auth methods enabled (Email + Google)  
- ✅ OAuth client ID: `762003542605-fisqbvctac1bm2huhpbvigjh6o35g74p.apps.googleusercontent.com`
- ✅ Extension ID: `ifbgoehelkilenaafgnimkecfoaaliin`
- ✅ Docs folder with all iOS reference material

**Pending your confirmation of this plan → implementation begins immediately.**

---

## What I Need From You

1. **Confirm this plan is correct** — or correct anything I've misunderstood
2. **Confirm the tab order**: Notes | To-Dos | Insights (left to right) — or change it
3. **Default tab on open**: should it open to To-Dos (most likely capture intent) or Notes?

Once confirmed, I execute Phase 1 through 6 and update the progress tracker after each phase.
