# Feature Implementation Plan

**Overall Progress:** `75%`

## TLDR
Add a standard email magic‑link sign‑in flow (using Firebase’s default Hosting domain) and stabilize phone auth fallback behavior by improving link handling + error messaging, with minimal UI changes and standard practices only.

## Critical Decisions
- Decision 1: Use Firebase default Hosting domain for email links (fastest setup, no custom domain wiring).
- Decision 2: Insert Email (magic link) section between Phone and Google in `SignInSheet` using standard SwiftUI controls; no custom UI beyond existing patterns.
- Decision 3: Keep “already signed in” behavior consistent with current auth service (block and prompt to sign out).

## Tasks:

- [x] 🟩 **Step 1: Email Magic Link Flow (AuthService + Link Handling)**
  - [x] 🟩 Add email‑link send + sign‑in methods in `AuthService` (Firebase Auth email‑link flow with `handleCodeInApp = true` and Firebase default domain).
  - [x] 🟩 Add inbound link handling in app lifecycle (universal link) to complete sign‑in when link opens the app.
  - [x] 🟩 Persist pending email locally to complete sign‑in after the user returns from Mail.

- [x] 🟩 **Step 2: UI Integration (Standard Flow, Minimal Changes)**
  - [x] 🟩 Insert Email section between Phone and Google in `SignInSheet` (TextField + “Send magic link”).
  - [x] 🟩 Post‑send standard UI: “Check your email”, “Resend”, and “Change email”.
  - [x] 🟩 UI Consistency Guardrail: Use existing List/Section/standard controls; no custom components unless absolutely necessary.

- [x] 🟩 **Step 3: Phone Auth Error Messaging (Standard Practice)**
  - [x] 🟩 Map common FirebaseAuth phone errors to clearer user‑facing messages (avoid generic “internal error”).
  - [x] 🟩 Keep reCAPTCHA fallback as‑is, only add standard explanatory copy if needed.

- [ ] 🟥 **Step 4: Verification**
  - [ ] 🟥 Test email magic‑link flow end‑to‑end on device (send → open link → complete sign‑in).
  - [ ] 🟥 Test phone auth on TestFlight (confirm reCAPTCHA fallback works, errors are readable).

## Docs Naming Contract (Required)

- Store project docs under `docs/`.
- Use `Title_Snake_Case` filenames.
- Use feature-oriented naming with explicit doc-type suffixes.
- Preferred format: `<Feature_Or_Domain>_<Doc_Type>[ _YYYY_MM_DD].md`.
- Keep meta docs at top with numeric prefixes:
  - `000_Docs_Start_Here.md`
  - `010_Docs_Features_Hub.md`
  - `020_Docs_Feature_Implementation_Plans_Index.md`
  - `030_Docs_Explorations_Index.md`
  - `040_Docs_Governance.md`
- When creating or renaming docs, update links and these indexes.