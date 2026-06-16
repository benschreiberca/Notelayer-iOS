# PRD 09 — Notelayer Web App + Chrome Extension: Launch Plan

**Created:** 2026-06-10  
**Status:** Ready to Execute  
**Goal:** Build and ship the Notelayer Chrome extension + companion web app, synced to the same Firebase backend as the iOS app.

---

## Legend

- 🤖 **Automated** — Claude does this entirely, no action needed from you
- 👤 **Manual** — You must do this; exact steps listed
- ⚠️ **Blocker** — Cannot proceed to the next step until this is done

---

## Step 1 — Create New GitHub Repo

**Owner:** 🤖 Claude  
**Estimated time:** 2 minutes

### What Claude does:
- Runs `gh repo create benschreiberca/notelayer-web --private --description "Notelayer web app and Chrome extension"`
- Clones it locally to `~/Documents/GitHub/notelayer-web`
- Scaffolds the monorepo structure:
  ```
  notelayer-web/
  ├── extension/          ← Chrome extension (Manifest v3, Vite build)
  ├── webapp/             ← React web app (Vite + React + TypeScript)
  ├── packages/
  │   └── shared/         ← Firebase config, types, Firestore helpers shared by both
  ├── package.json        ← npm workspaces root
  └── .gitignore
  ```
- Installs dependencies: React, Vite, TypeScript, Firebase JS SDK, Tailwind CSS
- Ports existing scaffolding from `notelayer-web-platform` branch (tokens.css, UI components, firebase.js)
- Ports Chrome extension scaffold from `Notelayer-ChromeExtension` branch (manifest.json, popup UI, service worker)
- Pushes initial commit to GitHub

### You do: Nothing.

---

## Step 2 — Firebase Config: Get Real API Keys

**Owner:** 👤 You  
**Estimated time:** 5 minutes  
⚠️ **Blocker — Claude cannot write working Firebase code without real keys**

### Exact steps:

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select project **notelayer-c7bba**
3. Click the **gear icon** (top left, next to "Project Overview") → **Project settings**
4. Scroll down to **"Your apps"** section
5. If a **Web app** already exists, click it and copy the config object. If not:
   - Click **"Add app"** → select the **Web** icon (`</>`)
   - App nickname: `Notelayer Web`
   - Check **"Also set up Firebase Hosting"** → NO (skip this for now)
   - Click **Register app**
6. Copy the `firebaseConfig` object — it looks like:
   ```js
   const firebaseConfig = {
     apiKey: "AIza...",
     authDomain: "notelayer-c7bba.firebaseapp.com",
     projectId: "notelayer-c7bba",
     storageBucket: "notelayer-c7bba.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:abc123",
   };
   ```
7. Paste this entire block into the chat

### What Claude does next:
Fills in the real keys into `packages/shared/firebase.ts` and `.env` files.

---

## Step 3 — Firebase Auth: Enable Sign-In Methods

**Owner:** 👤 You  
**Estimated time:** 5 minutes  
⚠️ **Blocker — Auth will fail silently without this**

### Exact steps:

1. In Firebase Console → **notelayer-c7bba** → left sidebar → **Authentication**
2. Click **"Get started"** if not already enabled
3. Click the **"Sign-in method"** tab
4. Enable **Email/Password**:
   - Click Email/Password → toggle **Enable** ON
   - Toggle **"Email link (passwordless sign-in)"** ON
   - Click **Save**
5. Enable **Google**:
   - Click Google → toggle **Enable** ON
   - Set **Project support email** to `ben@benschreiber.ca`
   - Click **Save**
6. Click the **"Settings"** tab → **"Authorized domains"**
7. Confirm `localhost` is in the list (it should be by default)
8. Click **"Add domain"** and add: `notelayer-c7bba.firebaseapp.com`
9. Come back here and confirm this is done

---

## Step 4 — Google OAuth Consent Screen (Required for Google Sign-In)

**Owner:** 👤 You  
**Estimated time:** 8 minutes  
⚠️ **Blocker — Google sign-in button will error without this**

### Exact steps:

1. Open [Google Cloud Console](https://console.cloud.google.com)
2. Make sure you're in the **notelayer-c7bba** project (check the dropdown at the top)
3. Left sidebar → **APIs & Services** → **OAuth consent screen**
4. Select **External** → click **Create**
5. Fill in:
   - **App name:** `Notelayer`
   - **User support email:** `ben@benschreiber.ca`
   - **App logo:** skip for now
   - **Developer contact email:** `ben@benschreiber.ca`
6. Click **Save and Continue** through Scopes (no changes needed)
7. On **Test users** page: click **"Add users"** → add `ben@benschreiber.ca`
8. Click **Save and Continue** → **Back to Dashboard**
9. Come back here and confirm

---

## Step 5 — Build Core Extension: Firebase Auth + Firestore Wired Up

**Owner:** 🤖 Claude  
**Estimated time:** 20–30 minutes

### What Claude does:
Replaces all `// TODO` stubs in the extension with real Firebase code:

**Auth (`extension/src/auth.ts`):**
- `signInWithGoogle()` — opens Chrome identity popup, exchanges token with Firebase
- `sendEmailLink(email)` — sends magic link via Firebase Auth
- `onAuthStateChanged()` — persists session in `chrome.storage.local`
- `signOut()`

**Firestore (`packages/shared/firestore.ts`):**
- `saveTask(task)` — writes to `users/{uid}/tasks` using exact same schema as iOS (`title`, `categories`, `priority`, `dueDate`, `taskNotes`, `orderIndex`, `isCompleted`, `createdAt`, `updatedAt`)
- `saveNote(note)` — writes to `users/{uid}/notes`
- `loadCategories()` — reads from `users/{uid}/categories` (same categories as iOS app)
- `loadTasks()` — reads live with `onSnapshot` listener

**Popup (`extension/src/popup/`):**
- Replaces mock auth state with real `onAuthStateChanged`
- Loads real categories from Firestore on sign-in
- Save buttons write to Firestore instead of `console.log`
- Context menu saves (right-click on any page → "Save to Notelayer as Note/Task") wired to Firestore

### You do: Nothing.

---

## Step 6 — Build Core Web App Views

**Owner:** 🤖 Claude  
**Estimated time:** 20–30 minutes

### What Claude does:
Builds the full web app in `webapp/src/`:

- **Auth page** — Sign in with Google or email magic link, same style as extension
- **Todos view** — Full task list matching iOS layout: grouped by category, priority indicators, complete/uncomplete toggle, add task input
- **Notes view** — Note list with add note input
- **App shell** — Tab bar (Todos / Notes), header, sign-out button
- **Real-time sync** — Firestore `onSnapshot` so changes from iOS appear instantly on web

### You do: Nothing.

---

## Step 7 — Local Chrome Testing

**Owner:** 🤖 Claude builds, 👤 You test  
**Estimated time:** 10 minutes

### What Claude does:
- Runs `npm run build` in `/extension`
- Confirms `/extension/dist` folder is valid (manifest, popup, service worker all present)
- Reports any build errors and fixes them

### What you do (manual — Chrome won't allow automation here):

1. Open Chrome browser
2. Go to `chrome://extensions` in the address bar
3. Toggle **"Developer mode"** ON (top-right corner)
4. Click **"Load unpacked"** button (top-left)
5. Navigate to: `~/Documents/GitHub/notelayer-web/extension/dist`
6. Click **Select** — the Notelayer icon should appear in your Chrome toolbar
7. Click the Notelayer icon → sign in with Google
8. Add a test task: title "Test from Chrome", priority High
9. Open the Notelayer iOS app → confirm the task appears in your list
10. Report back what you see (any errors, anything missing)

---

## Step 8 — Web App Local Testing

**Owner:** 🤖 Claude runs, 👤 You verify  
**Estimated time:** 5 minutes

### What Claude does:
- Runs `npm run dev` in `/webapp`
- Opens `http://localhost:5173` in your browser

### What you do:
1. Sign in with Google
2. Confirm your existing iOS tasks appear
3. Add a task on the web → confirm it appears in the iOS app
4. Add a task on iOS → confirm it appears on the web (may take a few seconds)
5. Report any issues

---

## Step 9 — Web App Deployment to Firebase Hosting

**Owner:** 🤖 Claude builds + deploys  
**Estimated time:** 10 minutes

### What Claude does:
- Runs `npm run build` in `/webapp`
- Configures `firebase.json` for hosting
- Runs `firebase deploy --only hosting`
- Reports the live URL (will be `https://notelayer-c7bba.web.app`)

### You do: Nothing for the default URL.

### Optional — Custom domain `app.notelayer.com`:

**Owner:** 👤 You  
**Estimated time:** 15 minutes + up to 24h for DNS propagation

1. In Firebase Console → **Hosting** → **Add custom domain**
2. Enter `app.notelayer.com`
3. Firebase gives you two DNS records (TXT + A records)
4. Log into your domain registrar (wherever notelayer.com DNS is managed)
5. Add both records exactly as Firebase shows them
6. Click **Verify** in Firebase console
7. Wait for SSL cert provisioning (Firebase does this automatically, takes 10–30 min after DNS propagates)

---

## Step 10 — Chrome Web Store: Developer Account + Submission

**Owner:** 👤 You (account + payment) + 🤖 Claude (assets + zip)  
**Estimated time:** 20 minutes your time, 1–7 days Google review

### What Claude does:
- Builds production zip of `/extension/dist`
- Writes the store listing copy (title, description, category)
- Generates Chrome Web Store screenshots at required dimensions (1280×800)
- Provides the zip file path for upload

### What you do (manual — no API for this):

#### Part A — One-time developer registration ($5):
1. Go to [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
2. Sign in with your Google account
3. Click **"Get started"**
4. Pay the **one-time $5 USD registration fee** (credit card)
5. Accept the developer agreement

#### Part B — Create the listing:
1. Click **"New item"**
2. Upload the `.zip` file Claude prepared (path will be given)
3. Fill in:
   - **Store listing tab:**
     - Name: `Notelayer`
     - Summary: `Capture tasks and notes from any webpage — synced with your Notelayer iPhone app.`
     - Description: (Claude provides this)
     - Category: `Productivity`
     - Language: `English (United States)`
   - Upload the **screenshots** Claude prepared (at least 1, up to 5)
   - Upload the **promo tile** (440×280px) — Claude provides
4. **Privacy tab:**
   - Justify permissions (Claude provides the text):
     - `activeTab` — to read current page URL and title when saving
     - `storage` — to persist auth session locally
     - `contextMenus` — right-click "Save to Notelayer" menu
     - `identity` — Google sign-in
   - Privacy policy URL: `https://notelayer-c7bba.web.app/privacy` (Claude deploys this)
5. Click **"Submit for review"**

#### Part C — After review (1–7 days):
- Google emails you with **Approved** or **Rejected + reason**
- If rejected: paste the reason here and Claude fixes it same day
- If approved: go to the dashboard → click **"Publish"**

---

## Summary: Everything You Need To Do

| Step | Your action | Time | Blocker? |
|------|-------------|------|----------|
| 2 | Get Firebase API keys from Firebase Console, paste here | 5 min | ⚠️ Yes |
| 3 | Enable Email + Google auth in Firebase Console, add authorized domains | 5 min | ⚠️ Yes |
| 4 | Set up Google OAuth consent screen in Google Cloud Console | 8 min | ⚠️ Yes |
| 7 | Load unpacked extension in Chrome, smoke test add-task flow | 10 min | No |
| 8 | Verify web app syncs with iOS | 5 min | No |
| 9 | (Optional) Add DNS records for custom domain | 15 min | No |
| 10A | Pay $5 Chrome Web Store developer registration | 5 min | ⚠️ Yes |
| 10B | Upload zip + fill in store listing | 10 min | No |
| 10C | Click Publish after approval | 1 min | No |

**Total your time: ~50 minutes spread across the process**  
**Total clock time to live: 2–9 days (gated on Google's review SLA)**

---

## Firebase Schema Reference (iOS parity)

The web app and extension write to the exact same Firestore paths and field names as the iOS app, so everything syncs automatically.

```
users/
  {uid}/
    tasks/
      {taskId}/
        title: string
        categories: string[]       ← array of category IDs
        priority: "high"|"medium"|"low"|null
        isCompleted: bool
        dueDate: timestamp|null
        taskNotes: string|null
        orderIndex: number
        parentTaskId: string|null
        createdAt: timestamp
        updatedAt: timestamp
    notes/
      {noteId}/
        text: string
        createdAt: timestamp
        updatedAt: timestamp
    categories/
      {categoryId}/
        name: string
        icon: string
        color: string
        orderIndex: number
```
