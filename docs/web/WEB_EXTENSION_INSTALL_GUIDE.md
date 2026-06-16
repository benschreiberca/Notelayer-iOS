# Chrome Extension — Install & Test Guide

**Branch:** `web/ui-ios-parity`
**Updated:** 2026-06-16

---

## Prerequisites

- Node.js 18+ and npm installed
- Chrome or any Chromium-based browser (Arc, Brave, Edge)
- Access to the repo at `~/Notelayer-iOS`

---

## Part 1 — Build the Extension

```bash
# 1. Navigate to the extension directory
cd ~/Notelayer-iOS/notelayer-web/extension

# 2. Install dependencies (first time only)
npm install

# 3. Build the extension
npm run build
```

The build output goes to `extension/dist/` (or `extension/public/` — check vite.config.ts for the exact output directory).

---

## Part 2 — Load in Chrome (Developer Mode)

1. Open Chrome and go to: `chrome://extensions`
2. Enable **Developer mode** (toggle in the top-right corner)
3. Click **Load unpacked**
4. Navigate to and select the build output folder:
   - `~/Notelayer-iOS/notelayer-web/extension/dist`
   - *(or wherever vite.config.ts outputs — confirm with `cat vite.config.ts`)*
5. The Notelayer extension icon should appear in your toolbar

> **Tip:** Pin it by clicking the puzzle piece icon → pin Notelayer

---

## Part 3 — Open the Side Panel

**Method A — Extension icon:**
1. Click the Notelayer icon in the toolbar
2. The side panel opens on the right side of the browser

**Method B — Keyboard shortcut:**
- Set one at `chrome://extensions/shortcuts`

**Method C — Right-click any page:**
- Right-click → "Open Notelayer"

---

## Part 4 — Sign In

1. In the side panel, click **Sign in with Google**
2. Chrome will prompt for your Google account
3. The extension uses `chrome.identity.getAuthToken` — no popup window
4. Once signed in, your tasks and notes load from Firestore instantly

> **Important:** Use the same Google account you use on the iOS app. Firestore is shared — both platforms read and write to `users/{uid}/tasks`.

---

## Part 5 — Confirm iOS Sync

After signing in on the extension:

1. Create a task in the extension side panel
2. Open the Notelayer iOS app on your phone
3. The task should appear within 1–2 seconds (Firestore `onSnapshot`)

Conversely:
1. Create a task on iOS
2. It should appear in the Chrome side panel within 1–2 seconds

---

## Part 6 — Reloading After Changes

When you make code changes and rebuild:

1. Run `npm run build` in `~/Notelayer-iOS/notelayer-web/extension`
2. Go to `chrome://extensions`
3. Find Notelayer and click the **reload icon** (circular arrow)
4. Reopen the side panel

> You do **not** need to re-add the extension — just reload it.

---

## Part 7 — Watching for Errors

Open the side panel DevTools:
1. Right-click inside the side panel
2. Click **Inspect**
3. Check the Console tab for errors

For service worker errors:
1. Go to `chrome://extensions`
2. Find Notelayer → click **Service Worker** link
3. DevTools opens for the background script

---

## Firestore Configuration

The Firebase project is `notelayer-c7bba`. Firebase config is in:

```
notelayer-web/packages/shared/src/firebase.ts
```

The `.env` file (not committed) must be present at:

```
notelayer-web/extension/.env
```

With these values (get from Firebase console → Project Settings → Your apps):

```
VITE_FIREBASE_API_KEY=...
VITE_FIREBASE_AUTH_DOMAIN=...
VITE_FIREBASE_PROJECT_ID=notelayer-c7bba
VITE_FIREBASE_STORAGE_BUCKET=...
VITE_FIREBASE_MESSAGING_SENDER_ID=...
VITE_FIREBASE_APP_ID=...
```

---

## Publishing to Chrome Web Store (When Ready)

1. Build the final version: `npm run build`
2. Zip the output folder: `zip -r notelayer-extension.zip dist/`
3. Go to [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
4. Click **New Item** → upload the zip
5. Fill in: title, description, screenshots (1280×800), 128×128 icon
6. Submit for review (typically 1–3 business days)

**Key advantage of the webapp-shell architecture:** after the initial store submission, all UI and feature updates deploy via `firebase deploy` — no resubmission required unless `manifest.json` changes.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Blank side panel | Check console for JS errors; ensure build succeeded |
| Sign-in fails | Check `chrome.identity` permissions in manifest.json; ensure OAuth client ID matches |
| Tasks don't sync | Check Firestore rules allow authenticated reads/writes; confirm same UID on iOS and web |
| Extension not loading | Ensure you selected the correct `dist/` folder, not the `src/` folder |
| "manifest.json not found" | You selected the wrong folder — must be the built output, not the source |
