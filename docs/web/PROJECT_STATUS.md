# Notelayer Chrome Extension — Project Status

**Branch:** `claude/notelayer-chrome-extension-0pwV8`
**Last Updated:** 2026-06-17 (branch consolidated; Firebase CLI blocker documented)
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

**Branch:** `claude/notelayer-chrome-extension-0pwV8` (pushed to GitHub).
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

The extension **installs and renders** — side panel loads, sign-in screen shows
with correct indigo branding and fonts, both Google and Apple buttons present. ✅

**Active blocker: Firebase CLI not installed.** Deploying the hosted auth page
requires the Firebase CLI. Running `firebase deploy --only hosting` on the
Chromebook returned `-bash: firebase: command not found`.

### Fix: install Firebase CLI first

```bash
npm install -g firebase-tools
firebase login          # opens browser for Google auth
cd ~/Notelayer-iOS
firebase deploy --only hosting
```

Then verify the page loads (should be blank, no errors):
`https://notelayer-c7bba.firebaseapp.com/extension-auth.html`

### Auth — what's done vs. what you must do

| | Status |
|---|---|
| Offscreen auth bridge (offscreen.html/ts) | ✅ code done |
| Service-worker offscreen lifecycle + relay | ✅ code done |
| Hosted popup page (`firebase-hosting/extension-auth.html`) | ✅ code done |
| Google + Apple buttons in AuthScreen | ✅ code done |
| Manifest `offscreen` permission, removed dead oauth2/identity | ✅ done |
| Build verified (offscreen.html/js in dist) | ✅ |
| **Install Firebase CLI** (`npm install -g firebase-tools`) | ⬜ **YOU** (one-time) |
| **Deploy hosted page** (`firebase deploy --only hosting`) | ⬜ **YOU** |
| **Enable Google provider** in Firebase Console | ⬜ **YOU** (likely already on) |
| **Enable Apple provider** (Apple Developer + Firebase) | ⬜ **YOU** |

---

## 7. Next Steps

### Immediate — make sign-in work (see `AUTH_SETUP.md` for detail)

```bash
# 1. Get the latest code
cd ~/Notelayer-iOS
git pull origin claude/notelayer-chrome-extension-0pwV8

# 2. Install Firebase CLI (one-time; only needed if not already installed)
npm install -g firebase-tools
firebase login

# 3. Deploy the hosted auth page (required for sign-in to function)
firebase deploy --only hosting

# 4. Rebuild + reload the extension
cd notelayer-web/extension
rm -rf dist && npm run build
# chrome://extensions → Reload Notelayer
```

Plus, in the **Firebase Console**:
- Enable **Google** sign-in provider (likely already on).
- Enable **Apple** sign-in provider (needs Apple Developer Services ID + key).

### Then

1. Side panel → **Continue with Google** (same account as iOS) → should sign in.
2. **Verify sync:** create a task in the panel → confirm it appears on iPhone
   (and vice versa).
3. **Review the UI** against iOS — especially Doing/Done and colors — note what
   still looks off.

### After auth + UI are approved

4. Next feature phase. Recommended: **web capture** (right-click +
   text-selection → save to Notelayer) — the extension's unique value over iOS.
5. Eventually: publish to Chrome Web Store ($5 dev account, upload zipped `dist/`).

---

## Suggested Next Steps (running list — updated each session)

- [ ] Install Firebase CLI: `npm install -g firebase-tools && firebase login`
- [ ] Deploy `firebase-hosting` so the auth page is live
- [ ] Enable Google + Apple providers in Firebase Console
- [ ] Confirm Google sign-in works end-to-end in the side panel
- [ ] Configure Apple Developer Services ID for Apple sign-in
- [ ] Verify real-time task/note sync between extension and iOS
- [ ] UI review pass against iOS (Doing/Done, colors, spacing)
- [ ] Build web capture (context menu + text selection)
- [ ] Web Push reminders
- [ ] Calendar sync (Google + Apple .ics)
- [ ] Chrome Web Store submission

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

- **Branch:** `claude/notelayer-chrome-extension-0pwV8`
- **Web project root:** `notelayer-web/`
- **Extension source:** `notelayer-web/extension/`
- **Build output (load this in Chrome):** `notelayer-web/extension/dist/`
- **Shared logic:** `notelayer-web/packages/{shared,ui,hooks}/`
- **Firebase project:** `notelayer-c7bba` (shared with iOS)
- **Plan docs:** `docs/web/WEB_UI_IOS_PARITY_PLAN.md`, `docs/web/WEB_EXTENSION_INSTALL_GUIDE.md`
- **PRD:** `docs/PRD_09_Web_App_Chrome_Extension.md`
