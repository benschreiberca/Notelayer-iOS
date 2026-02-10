# Auth Rebuild Tracking

**Overall Progress:** `83%`

## Tasks

- [x] 🟩 **Step 1: Inventory current auth surface + providers**
  - [x] 🟩 Identify all auth entry points and views
  - [x] 🟩 List all current auth providers/code paths to remove

- [x] 🟩 **Step 2: Remove existing auth UI and non-target providers**
  - [x] 🟩 Delete/strip email/password, anonymous, other providers
  - [x] 🟩 Remove old auth UI components and wiring

- [x] 🟩 **Step 3: Build new SignInSheet**
  - [x] 🟩 Rename view (SignInSheet) and keep entry at gear menu
  - [x] 🟩 Add minimal copy: “Sign into NoteLayer” + “to sync everywhere”
  - [x] 🟩 Add official Apple + Google button styles
  - [x] 🟩 Show signed-in email and “Sign out” below buttons

- [x] 🟩 **Step 4: Implement Phone auth in-sheet (two-step)**
  - [x] 🟩 Step 1 UI: phone number input + “Send code”
  - [x] 🟩 Step 2 UI: verification code input + “Verify”
  - [x] 🟩 Inline error text + loading states aligned with app style

- [ ] 🟨 **Step 5: Firebase integration + provider config**
  - [x] 🟩 Ensure Firebase init is called before auth flows
  - [ ] 🟥 Confirm Apple/Google/Phone enabled in Firebase console
  - [ ] 🟥 Remove console config for non-target providers

- [ ] 🟨 **Step 6: Validate**
  - [x] 🟩 Build succeeds
  - [ ] 🟥 Smoke test on iPhone 16e + 17 Pro simulators
  - [ ] 🟥 Verify sign-in/out, email display, auto-dismiss behavior
