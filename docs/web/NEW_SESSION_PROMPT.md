You are picking up an in-progress project. Read this entire prompt before doing anything.

---

## What Notelayer Is

Notelayer is a native SwiftUI iOS task and note app. This repo (`notelayer-web`) contains the Chrome extension that syncs with the iOS app in real time via Firebase/Firestore. The extension lives in `extension/`, shared packages in `packages/`. The marketing site is at getnotelayer.com (separate repo: `notelayer-site`).

---

## What's Already Built (do not rebuild any of this)

The extension is feature-complete at v1.1.0. Everything below is done and working:

- Google sign-in via Firebase Auth (offscreen document, MV3-compatible)
- Real-time Firestore sync with the iOS app — full data compatibility
- Four task views: List / Priority / Category / Date
- Collapsible group headers
- Subtasks with expand/collapse and drag-to-reorder within parent
- Inline task creation (List view) + FAB bottom-sheet (other views)
- Auto-saving task edit sheet (600ms debounce, no Save button, "✓ Saved" flash)
- Add to Calendar → opens Google Calendar pre-fill in new tab
- Notes overlay (via ··· menu)
- Insights view with drilldown on categories and stat cards
- Category manager
- Full theming: Auto/Light/Dark mode, 5 wallpaper presets, 12 accent colours — matching iOS ThemeWallpaperCatalog and ThemeAccentCatalog
- Space Grotesk + Work Sans fonts
- Keyboard shortcut: Ctrl+Shift+L / ⌘+Shift+L

Manifest is at `extension/public/manifest.json`, version 1.1.0, permissions: storage, activeTab, contextMenus, offscreen, sidePanel, tabs.

---

## Your Tasks

### 1. Health Check

Before anything else, do a full audit:
- Confirm all source files exist and are internally consistent (no broken imports, missing CSS files, undefined components)
- Confirm `manifest.json` is MV3-compliant and has all required fields for store submission
- Confirm the build system works: run `npm install` then `npm run build --workspace=extension` and check the output in `extension/dist/`
- List any errors or warnings found

### 2. Build & Package

Run the packaging script:

```
bash scripts/package-extension.sh
```

This should produce `notelayer-extension-v1.1.0.zip`. If the script fails or doesn't exist, create it: it should run `npm run build --workspace=extension` then zip the contents of `extension/dist/` into `notelayer-extension-v1.1.0.zip` at the repo root.

### 3. Chrome Web Store Submission Prep

The store listing copy is ready. Here it is in full — use it to create `docs/STORE_LISTING.md` if it doesn't exist:

**Short description (91 chars):**
Your Notelayer tasks and notes, right in your browser. Real-time sync with your iPhone app.

**Long description:**

```
Notelayer for Chrome brings your tasks, subtasks, and notes from the Notelayer iPhone app directly into your browser — without switching apps or losing context.

REAL-TIME SYNC WITH YOUR iPHONE
Everything you add, complete, or edit on iPhone appears in the browser immediately — and vice versa. Notelayer uses Firestore for instant, conflict-free sync across all your devices.

FOUR WAYS TO SEE YOUR TASKS
• List — your full task list with subtasks, drag-to-reorder, and inline task creation
• Priority — grouped by High / Medium / Low / None
• Category — grouped by your custom categories from the iPhone app
• Date — grouped by due date (Today / This Week / Later / No Date)

All views support collapsible group headers so you can focus on what matters.

TASK EDITING THAT STAYS OUT OF YOUR WAY
Tap any task to open the detail sheet. Changes save automatically — no Save button, no friction. Set a due date, priority, category, or notes. Add the task directly to Google Calendar with one tap.

SUBTASKS
Expand any task to see its subtasks. Drag to reorder subtasks within their parent. Check them off one by one.

INSIGHTS
A built-in productivity dashboard shows your streak, completion rate, tasks created vs completed, overdue count, and per-category breakdowns. Tap any stat or category to drill down into the specific tasks behind the number.

THEMING
Matches the Notelayer iPhone app's appearance system:
• Auto / Light / Dark mode
• 5 wallpaper presets (Iridescent, Focus, Midnight, Sunset, Arctic)
• 12 accent colours

NOTES
A full-screen notes overlay, accessible from the ··· menu. Synced with your iPhone notes in real time.

SIGN IN
Sign in with your Google account — the same one you use in the Notelayer iPhone app — and your data appears instantly.

KEYBOARD SHORTCUT
Open the Notelayer panel with Ctrl+Shift+L (⌘+Shift+L on Mac) at any time.

PRIVACY
Notelayer does not track your browsing, read page content, or share data with advertisers. Your tasks live in your own Firebase project. Appearance preferences are stored locally and never leave your device.

REQUIREMENTS
• Notelayer iPhone app (for account creation and iOS sync)
• Google account
• Chrome 114 or later (side panel support required)
```

**Permissions justification** — create `docs/PERMISSIONS_JUSTIFICATION.md` if it doesn't exist:

- `storage`: Persists appearance preferences (theme mode, wallpaper, accent colour) locally via chrome.storage.local. Never transmitted to any server.
- `activeTab`: Required for the side panel to attach to the user's current tab.
- `contextMenus`: Registers a right-click menu item so users can capture selected text as a task.
- `offscreen`: Required by MV3 to run Firebase Authentication. Service workers cannot access the DOM, so Firebase Auth completes its OAuth popup flow in an offscreen document. This is Google's recommended pattern for Firebase Auth in MV3 extensions.
- `sidePanel`: Required to register and open the extension's primary UI as a Chrome side panel.
- `tabs`: Used to open Google Calendar in a new tab when the user taps "Add to Calendar" from the task edit sheet (chrome.tabs.create).

Host permissions:
- `https://*.firebaseapp.com/*`: Required for Firebase Auth hosted popup (https://<project>.firebaseapp.com/__/auth/handler).
- `https://*.googleapis.com/*` and `https://firestore.googleapis.com/*`: Required for Firestore real-time sync.

**Privacy policy** — create `docs/PRIVACY_POLICY.md` if it doesn't exist. The policy will be hosted at https://www.getnotelayer.com/privacy. Content:

Notelayer Privacy Policy. Effective Date: June 21, 2026.

We collect: Google account info (name, email, UID) via Firebase Auth for account identification only. Task/note data stored in Google Firestore under the user's own account. Appearance preferences stored locally in chrome.storage.local only — never transmitted.

We do NOT collect: browsing history, page content, or any data for advertising. We do not sell or share user data.

Third parties: Firebase Authentication, Google Firestore, Google Fonts — all governed by Google's Privacy Policy (https://policies.google.com/privacy).

Permissions used: storage (local prefs), activeTab (side panel), contextMenus (right-click capture), offscreen (Firebase Auth MV3), sidePanel (primary UI), tabs (open Google Calendar).

Data retention: Firestore data retained until account deletion (via iOS app). Local prefs cleared on extension uninstall.

Children: Not directed at children under 13.

Contact: ben@benschreiber.ca

### 4. Store Submission Checklist

Create `docs/SUBMISSION_CHECKLIST.md` with this checklist for manual completion in the Chrome Web Store Developer Dashboard (https://chrome.google.com/webstore/devconsole):

- [ ] Upload `notelayer-extension-v1.1.0.zip`
- [ ] Short description: paste from STORE_LISTING.md
- [ ] Long description: paste from STORE_LISTING.md
- [ ] Category: Productivity
- [ ] Language: English
- [ ] Icons: upload 128×128px PNG (already in `extension/public/assets/icon128.png`)
- [ ] Screenshots: at least 1 required, up to 5 (1280×800 or 640×400px) — capture from the loaded extension showing List view, dark mode with wallpaper, Insights drilldown, task edit sheet
- [ ] Privacy policy URL: https://www.getnotelayer.com/privacy (must be live before submitting)
- [ ] Permissions justification: paste each item from PERMISSIONS_JUSTIFICATION.md into the corresponding field
- [ ] Single-purpose description: "Notelayer is a side-panel task manager that syncs in real time with the Notelayer iPhone app. All permissions support this core task management and sync functionality."
- [ ] Visibility: Public
- [ ] Distribution: All regions
- [ ] Submit for review (takes 1–3 business days)

### 5. Commit and Push

Commit everything to `main` with message: "Add Chrome Web Store submission docs and build packaging script"

---

## Important Context

- Firebase project ID: `notelayer-c7bba`
- The extension currently only supports Google sign-in (Apple sign-in is iOS-only for now)
- The privacy policy URL (getnotelayer.com/privacy) will be added to the marketing site separately — do not block on it
- Do not modify any extension source code unless the health check in step 1 reveals a genuine breaking issue
- The developer is on a Chromebook — focus on making the zip and docs production-ready
