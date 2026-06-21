# Notelayer — Chrome Web Store Permissions Justification

Use this document when filling out the Chrome Web Store Developer Dashboard. Each permission must be individually justified in the "Permission justification" field during submission.

---

## Permissions in `manifest.json`

```json
"permissions": [
  "storage",
  "activeTab",
  "contextMenus",
  "offscreen",
  "sidePanel",
  "tabs"
]
```

---

## Justification per Permission

### `storage`
**Reason:** Used to persist the user's appearance preferences (theme mode: light/dark/auto, wallpaper preset, accent colour) across browser sessions. These preferences are stored locally via `chrome.storage.local` and are never transmitted to any server.

---

### `activeTab`
**Reason:** Required to enable the side panel to open and operate in the context of the user's current tab. Without this permission, the extension cannot attach the side panel to the active browser tab.

---

### `contextMenus`
**Reason:** Used to add a right-click context menu entry that lets users capture selected text from any webpage as a task (planned for a near-term release). The menu item is registered in the background service worker on install.

---

### `offscreen`
**Reason:** Required by Chrome Manifest V3 to run Firebase Authentication. MV3 service workers cannot access the DOM, so Firebase Auth (which requires a real document to complete the OAuth popup flow) must run in an offscreen document. This is the Google-recommended pattern for Firebase Auth in MV3 extensions. See: https://firebase.google.com/docs/auth/web/chrome-extensions

---

### `sidePanel`
**Reason:** The extension's primary UI is a side panel (not a popup). This permission is required to register and open the `sidepanel.html` page using the Chrome Side Panel API (`chrome.sidePanel`).

---

### `tabs`
**Reason:** Used to open Google Calendar in a new browser tab when the user taps "Add to Calendar" from the task edit sheet. Specifically, `chrome.tabs.create({ url })` is called with a pre-filled `calendar.google.com/calendar/r/eventedit?...` URL. Without this permission, the extension cannot open a new tab programmatically.

---

## Host Permissions in `manifest.json`

```json
"host_permissions": [
  "https://*.firebaseapp.com/*",
  "https://*.googleapis.com/*",
  "https://firestore.googleapis.com/*"
]
```

### `https://*.firebaseapp.com/*`
**Reason:** Required for the Firebase Authentication hosted popup. During sign-in, Firebase opens `https://<project-id>.firebaseapp.com/__/auth/handler` to complete the OAuth flow. Without this host permission, the auth popup is blocked.

### `https://*.googleapis.com/*`
**Reason:** Required for Firestore real-time data sync. The extension connects to `https://firestore.googleapis.com` to read and write tasks, categories, and notes. Also required for Google Sign-In API calls.

### `https://firestore.googleapis.com/*`
**Reason:** Explicitly listed (in addition to the wildcard above) to satisfy some Firestore SDK connection requirements for direct REST/gRPC calls made during real-time listeners.

---

## Single-Purpose Description (for store form)

> Notelayer is a side-panel task manager that syncs in real time with the Notelayer iPhone app. Users can view, create, edit, complete, and reorder tasks and notes directly in the browser, with full category, priority, and due-date support. All permissions are used exclusively to support this core sync and task management functionality.
