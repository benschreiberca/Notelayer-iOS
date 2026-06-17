# Notelayer Chrome Extension — Project Status

**Branch:** `web/ui-ios-parity`
**Last Updated:** 2026-06-17
**Maintainer:** ben@benschreiber.ca

> This is the living status document for the Notelayer web/Chrome-extension
> effort. It restates the objective, vision, goals, direction, current code
> status, and next steps. Update it as the project progresses.

---

## 1. Objective

Extend Notelayer beyond iOS to the **browser** — view, create, and manage
tasks and notes from any Chrome browser, capture content from any webpage,
with everything syncing in real time to the iPhone app.

---

## 2. Vision

**One codebase → many platforms.** A single React/TypeScript web project becomes:

- A **Chrome extension** (side panel) — *current focus*
- A **webapp** (Firebase Hosting) — same code, any browser
- Later: **PWA/Android** and a **Tauri desktop** app — no rewrites

The extension is a thin **shell** that loads the web UI. No duplicate logic.
Most feature updates ship via web deploy without resubmitting to the Chrome
Web Store (only `manifest.json` changes require resubmission).

---

## 3. Goals — Feature Parity with iOS

Per `PRD_09_Web_App_Chrome_Extension.md`, the extension targets everything iOS does:

- Tasks: priority, categories, due dates, subtasks, drag-reorder, bulk edit
- Notes: incl. capture page URL/title; right-click + text-selection capture
- **4 view lenses**: List / Priority / Category / Date
- **Doing / Done toggle**
- Categories: emoji + hex color, 8 defaults
- Reminders (Web Push), Voice capture (Web Speech), Insights
- Calendar sync: **Google Calendar (OAuth)** + **Apple Calendar (.ics feed; CalDAV later)**
- Themes, Settings, Auth (Google + email magic link)
- **Real-time Firestore sync** with iOS (shared project `notelayer-c7bba`)

---

## 4. Direction — Same Look & Feel as iOS

The design must match the iOS app exactly. Active priority.

| Element | Target (iOS) |
|---|---|
| Accent | Indigo `#6366F1` |
| Typography | Space Grotesk (headings) + Work Sans (body) |
| Doing/Done | Three-part toggle: `Doing (count)` ⟵ pill switch ⟶ `Done (count)` |
| Wallpaper | Iridescent Flow gradient tint + frosted-glass surfaces |
| Icons | SVG matching iOS SF Symbols (no emoji) |

> **User-flagged priorities:** the **Doing/Done tab** and **color theming** were
> called out as the biggest gaps. Both are addressed on `web/ui-ios-parity`.

---

## 5. Current Code Status

**Branch:** `web/ui-ios-parity` (pushed to GitHub).
**Repo location of web project:** `notelayer-web/`

### ✅ Done and working

| Area | Status |
|---|---|
| Full `notelayer-web` monorepo imported into repo | ✅ |
| Firebase auth (Google via `chrome.identity`) + Firestore live sync | ✅ already wired |
| Data layer (`shared/firestore.ts`, hooks) — tasks, notes, categories, insights | ✅ correct 3-segment paths |
| Views: Todos, Notes, Insights + Onboarding, CategoryManager, TaskEditSheet | ✅ exist in code |
| Doing/Done → iOS three-part toggle | ✅ rebuilt |
| Accent → indigo `#6366F1` | ✅ |
| Space Grotesk + Work Sans fonts | ✅ |
| Iridescent gradient overlay + frosted-glass tab bar | ✅ |
| SVG tab icons (replaced emoji) + indigo app mark | ✅ |
| Plan + install docs in `docs/web/` | ✅ |
| Build verified clean (no popup, manifest v2.0.0) | ✅ |

### 🐞 Bugs found & fixed

- Stale duplicate `manifest.json` (old popup version) → **removed**
- Old `chrome-extension/` folder caused Chrome to load the wrong build → **deleted**
- Icons excluded by `*.png` gitignore → **force-committed**

### ⬜ Not started (future phases)

Right-click / text-selection web capture · Web Push reminders · Voice capture ·
Calendar sync (Google + Apple) · Settings/theme polish · Light mode.

---

## 6. Where We Are Right Now

At the **final step of getting the extension to load.** The code is correct and
builds cleanly. Remaining: pull the icon fix, rebuild, load in Chrome.

---

## 7. Next Steps

### Immediate — finish the install (Chromebook)

```bash
cd ~/Notelayer-iOS
git pull origin web/ui-ios-parity

cd notelayer-web/extension
rm -rf dist
npm run build
ls dist/assets/          # confirm icon16/32/48/128.png present
```

Then in Chrome: `chrome://extensions` → **Reload** (or Load unpacked →
`…/notelayer-web/extension/dist`).

### Then

1. Click the Notelayer icon → side panel opens → **Sign in with Google**
   (same account as iOS).
2. **Verify sync:** create a task in the panel → confirm it appears on iPhone
   (and vice versa).
3. **Review the UI** against iOS — especially Doing/Done and colors — note what
   still looks off.

### After UI is approved

4. Next feature phase. Recommended: **web capture** (right-click +
   text-selection → save to Notelayer) — the extension's unique value over iOS.
5. Eventually: publish to Chrome Web Store ($5 dev account, upload zipped `dist/`).

---

## 8. Build Order (from PRD_09)

| Phase | What | Status |
|---|---|---|
| 1 | Scaffold — design system, components, pages | ✅ Done |
| 2 | Firebase auth + Firestore live sync | ✅ Done |
| — | **iOS UI parity (this branch)** | 🟨 In review |
| 3 | Quick capture — right-click + text selection | ⬜ Next |
| 4 | Web Push reminders | ⬜ |
| 5 | Google Calendar sync + Apple `.ics` feed | ⬜ |
| 6 | Voice capture (Web Speech API) | ⬜ |
| 7 | Full settings, theme sync, Insights polish | ⬜ |
| 8 | Chrome Web Store publish | ⬜ |

---

## 9. Key Paths & Facts

- **Branch:** `web/ui-ios-parity`
- **Web project root:** `notelayer-web/`
- **Extension source:** `notelayer-web/extension/`
- **Build output (load this in Chrome):** `notelayer-web/extension/dist/`
- **Shared logic:** `notelayer-web/packages/{shared,ui,hooks}/`
- **Firebase project:** `notelayer-c7bba` (shared with iOS)
- **Plan docs:** `docs/web/WEB_UI_IOS_PARITY_PLAN.md`, `docs/web/WEB_EXTENSION_INSTALL_GUIDE.md`
- **PRD:** `docs/PRD_09_Web_App_Chrome_Extension.md`
