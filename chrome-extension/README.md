# Notelayer — Chrome Extension (Side Panel)

A Manifest V3 Chrome extension that opens in the browser **side panel**, lets you
capture the current page as a Notelayer task, and shows your open to-dos. It reads
and writes the **same Firestore data** as the iOS app, so anything you add here
shows up on your iPhone/iPad and vice-versa.

- **No build step.** Plain ES modules + the Firestore REST API.
- **Auth:** Google sign-in via `chrome.identity`, exchanged for a Firebase ID token.
- **Data:** `users/{uid}/tasks` and `users/{uid}/categories`, identical field layout
  to the iOS app (`FirebaseBackendService.swift`).

---

## File layout

```
chrome-extension/
  manifest.json        MV3 manifest (side panel, oauth2, permissions)
  background.js        Service worker — opens the side panel on icon click
  sidepanel.html/.css  Side panel UI (Notelayer dark theme)
  sidepanel.js         UI controller
  lib/
    config.js          Firebase identifiers, endpoints, colors
    auth.js            Google → Firebase ID-token flow
    firestore.js       Firestore REST client (typed-value encode/decode)
    tasks.js           Task/category domain layer (matches iOS schema)
  icons/               16 / 48 / 128 px PNG icons
```

---

## One-time setup (required before it will sign in)

The extension uses `chrome.identity.getAuthToken`, which needs an **OAuth 2.0
client of type "Chrome Extension"** in the Firebase/Google-Cloud project
(`notelayer-c7bba`). Do this once:

### 1. Load the extension unpacked
1. Open `chrome://extensions`.
2. Turn on **Developer mode** (top right).
3. Click **Load unpacked** and select this `chrome-extension/` folder.
4. Copy the **extension ID** shown on the card (e.g. `abcd…wxyz`).

> The unpacked ID is derived from the `key` in `manifest.json`. There isn't one
> yet, so Chrome assigns a random ID per machine. To keep the ID stable across
> machines/reinstalls, generate a key (see "Stable extension ID" below) — or just
> use the current ID for now and update the OAuth client if it changes.

### 2. Create the OAuth client
1. Go to **Google Cloud Console → APIs & Services → Credentials** for project
   `notelayer-c7bba`.
2. **Create credentials → OAuth client ID**.
3. Application type: **Chrome Extension** (older consoles: "Chrome App").
4. Item/Application ID: paste the **extension ID** from step 1.
5. Create, then copy the generated **Client ID**
   (`…apps.googleusercontent.com`).

### 3. Wire it into the manifest
In `manifest.json`, replace the placeholder:
```json
"oauth2": {
  "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
  "scopes": ["openid", "email", "profile"]
}
```
Then return to `chrome://extensions` and click **Reload** on the card.

### 4. Sign in
Click the Notelayer toolbar icon → the side panel opens → **Sign in with Google**
using the account you use for Notelayer.

---

## Firestore security rules

The extension authenticates as the real Firebase user, so your existing rules
already cover it. They should allow each user to read/write only their own subtree:

```
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

No rule changes are needed if the iOS app already syncs.

---

## Stable extension ID (optional but recommended)

So the ID (and therefore the OAuth client) doesn't change:

1. Pack the extension once (`chrome://extensions → Pack extension`) to generate a
   `.pem`, **or** generate a key pair manually.
2. Derive the `key` (base64 public key) and add it to `manifest.json`:
   ```json
   "key": "MIIBIjANBgkqhkiG9w0BAQ…"
   ```
3. The ID is now deterministic. Use it for the OAuth client.

---

## Publishing to the Chrome Web Store

1. Bump `version` in `manifest.json`.
2. Zip the **contents** of `chrome-extension/` (not the folder itself).
3. Upload at the [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole)
   ($5 one-time developer registration).
4. Fill in listing copy (see `docs/product/PRD_10_*` for positioning), screenshots,
   and privacy disclosures (the extension stores only an auth session locally and
   talks to Firestore).
5. Once published, the Web Store assigns the final extension ID — create a
   **production OAuth client** for that ID and ship it in the published manifest.

---

## Notes / limitations

- Category **recency** ordering is stored per-browser (`chrome.storage.local`),
  mirroring how iOS keeps recency in its App Group rather than in Firestore.
- This first version captures tasks and completes them; it intentionally doesn't
  replicate the full iOS editor. Subtasks, reminders, and the Insights tab are
  out of scope for v0.1.
- If sign-in fails, it's almost always the OAuth client ID / extension ID
  mismatch in steps 1–3 above.
