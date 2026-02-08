# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Fix production auth crashes by walking through beginner‑level configuration checks for Google Sign‑In and Phone Auth (APNS), then validating with TestFlight. Only move to code changes if configs are correct.

## Critical Decisions
- Decision 1: Validate Release/TestFlight configuration first because crash logs show SDK assertions (GoogleSignIn + FirebaseAuth) that are typically caused by misconfiguration.
- Decision 2: Keep UI unchanged; focus on configuration and verification steps only.

## Tasks:
- [ ] 🟥 **Step 1: Google Sign‑In URL Scheme (Beginner Steps)**
- [ ] 🟥 **Subtask (Step 1): Open Xcode → select the Notelayer project → select the Notelayer target.**
- [ ] 🟥 **Subtask (Step 1): In the left sidebar, click “Info” tab.**
- [ ] 🟥 **Subtask (Step 1): Expand “URL Types” and verify there is one entry for `com.notelayer.app`.**
- [ ] 🟥 **Subtask (Step 1): Confirm “URL Schemes” includes `com.googleusercontent.apps.762003542605-d65npj0l7qhc48hjk10ao6d3fntmbbi4`.**
- [ ] 🟥 **Subtask (Step 1): If it shows `$(REVERSED_CLIENT_ID)`, go to Build Settings → search `REVERSED_CLIENT_ID` → confirm Release has the full value.**

- [ ] 🟥 **Step 2: Confirm GoogleService-Info.plist Is Bundled (Beginner Steps)**
- [ ] 🟥 **Subtask (Step 2): In Xcode, open the Project Navigator and locate `GoogleService-Info.plist` under the Notelayer app.**
- [ ] 🟥 **Subtask (Step 2): Click it and verify the `BUNDLE_ID` matches `com.notelayer.app`.**
- [ ] 🟥 **Subtask (Step 2): Select the plist file → open the File Inspector (right panel) → confirm “Target Membership” includes the Notelayer app.**

- [ ] 🟥 **Step 3: APNS / Phone Auth Configuration (Beginner Steps)**
- [ ] 🟥 **Subtask (Step 3): In Xcode, select Notelayer target → Signing & Capabilities.**
- [ ] 🟥 **Subtask (Step 3): Ensure “Push Notifications” capability is added.**
- [ ] 🟥 **Subtask (Step 3): Ensure “Background Modes → Remote notifications” is enabled (if required for phone auth).**
- [ ] 🟥 **Subtask (Step 3): Verify the entitlements file used for Release has `aps-environment = production` (not development).**

- [ ] 🟥 **Step 4: Install iOS Platform (Required for Archive)**
- [ ] 🟥 **Subtask (Step 4): Open Xcode → Settings → Components.**
- [ ] 🟥 **Subtask (Step 4): Install iOS 26.x platform if missing.**

- [ ] 🟥 **Step 5: Build an Archive and Inspect Built Info.plist (Beginner Steps)**
- [ ] 🟥 **Subtask (Step 5): Xcode → Product → Archive.**
- [ ] 🟥 **Subtask (Step 5): In Organizer, right‑click archive → Show in Finder.**
- [ ] 🟥 **Subtask (Step 5): Right‑click `.xcarchive` → Show Package Contents.**
- [ ] 🟥 **Subtask (Step 5): Open `Products/Applications/Notelayer.app/Info.plist`.**
- [ ] 🟥 **Subtask (Step 5): Confirm `CFBundleURLSchemes` contains the expanded Google client ID string (not `$(REVERSED_CLIENT_ID)`).**

- [ ] 🟥 **Step 6: TestFlight Validation**
- [ ] 🟥 **Subtask (Step 6): Upload new build to TestFlight.**
- [ ] 🟥 **Subtask (Step 6): On a device, test Google sign‑in, Apple sign‑in, phone auth, and refresh sync.**
- [ ] 🟥 **Subtask (Step 6): If any crash persists, capture new crash logs for that specific action.**

## Open Questions / Ambiguities
- Is the Release entitlements file using `aps-environment = production`?
- Do we have crash logs for refresh and Apple sign‑in, or only Google and phone?
