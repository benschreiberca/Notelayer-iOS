# Notelayer Web + Extension — Issues, Root Causes & Fixes

**Written:** 2026-06-11  
**Author:** Claude (for Ben to review)  
**Plain English — no jargon**

---

## Issue 1: Chrome Extension Stuck on Spinner After Magic Link Email

### What the problem looks like
You clicked "Continue with Email" in the extension, entered your email, got the "Check your email" message, clicked the link in the email, and the extension popup still just spins forever. You never get logged in.

### Root cause
Chrome extension popups are not normal web pages. When you click the magic link in your email, Firebase opens a new browser tab at `https://notelayer-c7bba.firebaseapp.com/emailSignIn`. The code that completes sign-in needs to run at that URL. But two things are broken:

1. **There's no page at that URL.** Firebase Hosting hasn't been set up yet, so visiting `firebaseapp.com/emailSignIn` loads a blank Firebase default page — nobody calls `signInWithEmailLink()`.

2. **Even if that page existed, the extension wouldn't know.** The extension popup runs in its own isolated sandbox. It has its own `localStorage`, its own auth state, and its own `window.location`. The browser tab that receives the magic link is a completely different context. There is no automatic bridge between "the browser tab signed in" and "the extension popup now knows you're signed in."

3. **The `isSignInWithEmailLink` check is pointed at the wrong URL.** Inside the popup code, we check `isSignInWithEmailLink(auth, window.location.href)`. But `window.location.href` in a Chrome extension popup is always `chrome-extension://[some-id]/popup.html` — it will never be a Firebase redirect URL. This check can never be true.

### How I know this is the root cause
- The Firebase console shows the magic link redirect URL is `https://notelayer-c7bba.firebaseapp.com/emailSignIn`
- There is no file deployed to Firebase Hosting at that path — it 404s
- Chrome's extension security model explicitly isolates popup storage from browser tab storage (this is documented in Chrome's Manifest V3 spec)
- Searching the codebase confirms the `isSignInWithEmailLink` check runs against `window.location.href` which is always the extension's own chrome-extension:// URL

### ELI5
Imagine you're waiting for a package. The delivery guy rings the doorbell at your neighbor's house instead of yours. Your neighbor opens the door. But you're still inside your house waiting — nobody told you the package arrived. That's what happens: the magic link "delivers" the sign-in to a browser tab (your neighbor's house), but the extension popup (your house) is still waiting and never hears about it.

### Fix applied
- **Removed email magic link from the extension entirely** — it fundamentally cannot work in a Chrome extension popup without a complex relay system
- **Kept Google sign-in** via `chrome.identity.getAuthToken()` — this is the proper Chrome extension auth method (built into Chrome, works natively)
- **Added a "Sign in via web app" fallback** — a button that opens the webapp in a browser tab where email sign-in works correctly. Once you sign in there, you can return to the extension
- **Note:** Google sign-in in the extension still needs the OAuth client ID filled in from the Google Cloud Console (Step 4 in the plan doc). Until that's done, only the "open web app" fallback works.

---

## Issue 2: Webapp Missing Categories, Priority Display, and Looks Nothing Like the iOS App

### What the problem looks like
The webapp showed tasks but:
- Categories showed as plain grey text tags, not colored pills
- Priority showed as small colored text but had no visual weight
- No view mode switcher (List / Category)
- No way to filter by category
- No "Done" section toggle
- No search
- Add task input didn't expand with options
- The overall layout looked like a barebones prototype, not a polished app

### Root cause
The first pass was a functional scaffold — it proved data syncs correctly. The UI components were written from scratch without referencing the iOS design system. Specifically:

1. **Category pills had no color.** The iOS app uses `category.color` (a hex value stored in Firestore) as a background tint on each pill. The web version just used a fixed grey `--surface2` regardless of the category's color field.

2. **Task rows were missing metadata.** The iOS `TaskItemView` shows: priority badge, category pills, due date, all in a horizontally scrollable metadata row below the title. The web version only showed one or two of these.

3. **No view modes.** The iOS app has List / Priority / Category / Date segmented modes. The web version had only a flat list.

4. **No Done section.** Completed tasks were mixed in at the bottom with no toggle.

5. **The add-task input didn't expand.** On iOS, tapping the input expands a row of options (priority, category). Web version always showed all controls, making it look crowded.

### How I know this is the root cause
- Directly compared `TaskItemView.swift` with the web `TaskRow` component — the iOS component has `categoryBadge()` that applies `categoryColor.opacity(0.18)` as background, which was absent in the web version
- The `Category` type in Firestore has a `color` field (confirmed in `types.ts`) that was never read in the web components
- `TodosView.swift` has `TodoViewMode` enum with List/Priority/Category/Date — none of these modes were implemented in the web version

### ELI5
Think of it like copying a recipe but only writing down the ingredients, not the cooking instructions. The data (tasks, categories) was all there, but the instructions for how it should look — colored pills, expandable inputs, grouped views — were never written. We had a skeleton, not a finished app.

### Fix applied (see rebuilt components below)
- **Category pills** now use each category's stored `color` with 18% opacity background + 30% opacity border (matching iOS exactly)
- **Task rows** now show priority badge + colored category pills + due date in a scrollable metadata row
- **View modes**: added List and Category segmented control
- **Category mode**: groups tasks under each category header with count badge
- **Done section**: collapsed by default, click to expand (matching iOS `showingDone` toggle)
- **Expandable add input**: collapsed to just a text field, expands on focus to show priority + category controls
- **Search bar**: filter tasks by title in real time
- **Notes page**: inset card style matching iOS `InsetCard` component

---

## Issue 3: Extension Google Sign-In Has a Placeholder OAuth Client ID

### What the problem looks like
Clicking "Continue with Google" in the extension either errors or does nothing.

### Root cause
The `manifest.json` has `"client_id": "762003542605-REPLACE_WITH_OAUTH_CLIENT_ID.apps.googleusercontent.com"` — this is a placeholder that was never replaced with the real value. Chrome uses this client ID to request a Google auth token. A placeholder value means Chrome can't find the app in Google's registry and refuses to issue a token.

### How I know this is the root cause
The string `REPLACE_WITH_OAUTH_CLIENT_ID` is literally in the manifest file. Chrome's `chrome.identity.getAuthToken()` will return an error referencing an invalid client ID.

### ELI5
It's like trying to check into a hotel by giving them a fake reservation number. The hotel's system looks it up, finds nothing, and turns you away.

### Fix
This requires Step 4 from the plan doc (Google OAuth consent screen setup). Once you complete that step, the Google Cloud Console will give you a real OAuth client ID that looks like `762003542605-abc123xyz.apps.googleusercontent.com`. Replace the placeholder in `extension/public/manifest.json` then rebuild.

**Exact steps to get the client ID:**
1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Select project **notelayer-c7bba**
3. Left sidebar → **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth client ID**
5. Application type: **Chrome Extension**
6. Name: `Notelayer Extension`
7. Extension ID: (load the extension in Chrome, copy the ID from `chrome://extensions`)
8. Click **Create** — copy the client ID
9. Tell Claude the client ID — I'll put it in the manifest and rebuild

---

## Issue 4: No Firestore Security Rules (Anyone Could Read Your Data)

### What the problem looks like
This isn't visible to you — it's a silent security gap. Right now, Firestore is likely in test mode which means any authenticated user could read any other user's tasks.

### Root cause
When you set up a Firebase project, the default Firestore rules allow any signed-in user to read/write any document. The webapp and extension never set custom rules that lock each user to only their own data path (`users/{uid}/...`).

### ELI5
Imagine a filing cabinet where every employee can open every other employee's drawer, not just their own. Your data is in there — and so is everyone else's, and they can all see yours.

### Fix applied
Added Firestore security rules to `firestore.rules` (see file). Rules lock every read/write to `users/{request.auth.uid}/...` — you can only touch your own data.

**You need to deploy these rules once Firebase Hosting is set up (Step 9 in the plan doc):**
```
firebase deploy --only firestore:rules
```

---

## Summary Table

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Extension magic link spins forever | High | ✅ Fixed — removed email link, added web app fallback |
| 2 | Webapp UI missing features + wrong styling | High | ✅ Fixed — rebuilt TodosPage, NotesPage, TaskRow |
| 3 | Extension Google sign-in has placeholder client ID | High | ⏸ Needs your action — Step 4 in plan doc |
| 4 | No Firestore security rules | Medium | ✅ Fixed — rules file written, needs `firebase deploy` |
