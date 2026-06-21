# Notelayer Chrome Extension — Privacy Policy

**Effective Date:** June 21, 2026  
**Last Updated:** June 21, 2026

---

## Overview

Notelayer ("we", "our", or "us") is a Chrome extension that syncs your tasks and notes from the Notelayer iPhone app directly into your browser. This Privacy Policy explains what data we collect, how we use it, and your rights.

---

## Data We Collect

### Account Information
When you sign in with Google, we receive your:
- Display name
- Email address
- Google profile photo URL
- Google user ID (UID)

This data is provided by Firebase Authentication and is used solely to identify your account and sync your data across devices.

### Task and Note Data
Your tasks, subtasks, categories, and notes are stored in **Google Firestore** under your user account. This data:
- Was created by you in the Notelayer iPhone app or Chrome extension
- Is synced in real time between your iPhone and browser
- Is stored in your own Firebase project (self-hosted)

### Local Preferences
Appearance settings (theme mode, wallpaper, accent colour) are stored in **`chrome.storage.local`** — locally on your device — and are never transmitted to any server.

---

## Data We Do NOT Collect

- We do not collect browsing history
- We do not track the websites you visit
- We do not read page content
- We do not sell, rent, or share your data with third parties
- We do not run analytics or advertising
- We do not store data outside of Firebase (Google) infrastructure

---

## Third-Party Services

Notelayer uses the following third-party services:

| Service | Purpose | Privacy Policy |
|---------|---------|----------------|
| Firebase Authentication | Sign-in | [Google Privacy Policy](https://policies.google.com/privacy) |
| Google Firestore | Task/note storage | [Google Privacy Policy](https://policies.google.com/privacy) |
| Google Fonts | Typography (Space Grotesk, Work Sans) | [Google Privacy Policy](https://policies.google.com/privacy) |

---

## Permissions Explained

| Permission | Why it's needed |
|-----------|----------------|
| `storage` | Save appearance preferences locally |
| `activeTab` | Required for the side panel to open on the current tab |
| `contextMenus` | Right-click to add tasks from any webpage (future feature) |
| `offscreen` | Run Firebase Authentication in a background document (MV3 requirement) |
| `sidePanel` | Display the Notelayer panel alongside your browser content |
| `tabs` | Open Google Calendar in a new tab when using "Add to Calendar" |

---

## Data Retention

Your task and note data is retained in Firestore for as long as your account exists. You can delete your data at any time by deleting your account within the Notelayer iPhone app.

Local appearance preferences can be cleared by uninstalling the extension or clearing Chrome extension storage in `chrome://settings`.

---

## Children's Privacy

Notelayer is not directed at children under 13. We do not knowingly collect personal information from children.

---

## Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be reflected in the "Last Updated" date above. Continued use of the extension after changes constitutes acceptance.

---

## Contact

Questions about this privacy policy?  
Email: **ben@benschreiber.ca**
