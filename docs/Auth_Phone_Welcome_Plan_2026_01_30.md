# Feature Implementation Plan

**Overall Progress:** `67%`

## TLDR
Wire the Welcome screen’s phone auth card to the existing `SignInSheet` flow, improve “already signed in” messaging, and verify APNS + phone auth logs locally.

## Critical Decisions
- Decision 1: Use existing `SignInSheet` for phone auth to keep a single, Firebase-aligned flow and avoid duplicate UI/logic.
- Decision 2: Preserve standard iOS presentation (`.sheet`) and existing button styles; no new custom components needed.

## Tasks

- [ ] 🟩 **Step 1: Wire Welcome phone card to SignInSheet**
  - [ ] 🟩 Present `SignInSheet` from `WelcomeView` when the phone button is tapped.
  - [ ] 🟩 Ensure `SignInSheet` receives `AuthService` and dismisses properly from Welcome context.

- [ ] 🟩 **Step 2: Improve “already signed in” messaging**
  - [ ] 🟩 Update auth error handling to show a friendly, specific message (“Already signed in with …”) instead of generic warnings.
  - [ ] 🟩 Ensure Welcome/SignInSheet clearly indicate signed-in state to prevent redundant attempts.

- [ ] 🟥 **Step 3: Validate APNS + Firebase phone auth locally**
  - [ ] 🟥 Confirm APNS token log appears on device and Firebase Auth handles phone auth request.
  - [ ] 🟥 Capture or summarize the relevant console logs for verification.
