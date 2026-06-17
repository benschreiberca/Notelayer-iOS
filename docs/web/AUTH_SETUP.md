# Extension Auth Setup — Google + Apple (Web Auth Flow)

**Branch:** `web/ui-ios-parity`
**Updated:** 2026-06-17

This describes the **web auth flow** chosen for the Chrome extension: an
offscreen document loads a Firebase-hosted page that runs `signInWithPopup`,
then relays the OAuth credential back to the extension. One flow handles both
Google and Apple.

---

## How it works (architecture)

```
Side panel (AuthScreen)
  │  click "Continue with Google/Apple"
  ▼  chrome.runtime.sendMessage({ action:"firebase-auth", provider })
Service worker (background.js)
  │  ensures offscreen document exists, relays request
  ▼  chrome.runtime.sendMessage({ target:"offscreen-auth", provider })
Offscreen document (offscreen.js)
  │  postMessage → invisible iframe
  ▼
Hosted page  https://notelayer-c7bba.firebaseapp.com/extension-auth.html
  │  signInWithPopup(google|apple) → OAuth credential
  ▼  postMessage credential back up the chain
Side panel
     signInWithCredential(auth, credential) → onAuthStateChanged fires
```

**Files involved:**
- `firebase-hosting/extension-auth.html` — the hosted popup page (must be deployed)
- `notelayer-web/extension/offscreen.html` + `src/offscreen/offscreen.ts`
- `notelayer-web/extension/src/background/service-worker.ts` — offscreen lifecycle + relay
- `notelayer-web/extension/src/sidepanel/App.tsx` — `handleSignIn(provider)`
- `notelayer-web/extension/src/sidepanel/components/AuthScreen.tsx` — Google + Apple buttons
- `notelayer-web/extension/public/manifest.json` — `offscreen` permission

---

## What YOU must configure (one-time, external)

The code is complete, but auth won't function until these console steps are done.

### A. Deploy the hosted auth page  ⬅ required for BOTH providers

The iframe page must be live on your Firebase Hosting domain.

```bash
cd ~/Notelayer-iOS
firebase deploy --only hosting
```

Verify it loads in a browser (should be blank, no errors):
`https://notelayer-c7bba.firebaseapp.com/extension-auth.html`

### B. Enable Google sign-in  ⬅ likely already on

1. [Firebase Console](https://console.firebase.google.com) → project `notelayer-c7bba`
2. **Authentication → Sign-in method → Google → Enable** (set a support email)
3. That's it — `firebaseapp.com` is an auto-authorized domain, so no redirect-URI
   work is needed for the popup flow.

### C. Enable Apple sign-in  ⬅ needs Apple Developer setup

Apple is more involved (requires a paid Apple Developer account):

1. **Apple Developer → Certificates, IDs & Profiles:**
   - Create a **Services ID** (e.g. `ca.benschreiber.notelayer.web`)
   - Enable "Sign in with Apple" on it
   - Add **Return URL**: `https://notelayer-c7bba.firebaseapp.com/__/auth/handler`
   - Create a **Sign in with Apple key** (.p8); note the Key ID and your Team ID
2. **Firebase Console → Authentication → Sign-in method → Apple → Enable:**
   - Services ID = the one above
   - Apple Team ID, Key ID, and paste the .p8 private key
3. Save.

> If you only want Google working first, do A + B and skip C — the Apple button
> will show an error until C is complete.

---

## After configuring — rebuild & reload

```bash
cd ~/Notelayer-iOS/notelayer-web/extension
rm -rf dist
npm run build
```

Then `chrome://extensions` → **Reload** Notelayer → open side panel → sign in.

---

## Troubleshooting

| Symptom | Cause / Fix |
|---|---|
| Button spins then errors immediately | Hosted page not deployed (do step A) |
| `auth/operation-not-allowed` | Provider not enabled in Firebase (step B / C) |
| Popup opens then "unauthorized domain" | Using a domain not in Firebase authorized domains — use the `firebaseapp.com` URL |
| Apple errors but Google works | Apple provider/Services ID not configured (step C) |
| Nothing happens on click | Check side panel console + the offscreen document console (chrome://extensions → Inspect views) |

---

## Note on the old approach

The previous code used `chrome.identity.getAuthToken` (Google-only) with an
OAuth client ID that didn't match the unpacked extension's ID — that's why
"Continue with Google" failed. That path and its `oauth2`/`identity` manifest
entries have been removed in favor of this provider-agnostic web flow.
