# PRD 16: Android / Google Play Store Launch

Last Updated: 2026-04-20
Status: Draft
Feature Area: Platform Expansion
Priority: High

## Purpose

Launch Notelayer on Android via the Google Play Store to double the addressable market and establish a cross-platform presence.

## Problem Statement

Notelayer is iOS-only. A large portion of the target audience (productivity-focused individuals) uses Android. Launching on Android is a significant growth lever, especially if paired with marketing (LinkedIn, Twitter/X).

## Goals

- Ship a functional Android version with feature parity on the core experience.
- Pass Google Play review and launch publicly.
- Maintain a single codebase or shared backend where possible.

## Non-Goals

- Full feature parity on day one (Analytics, Voice Entry can follow in v1.1).
- Wear OS or Android TV support.
- Cross-device sync between iOS and Android (backend already handles this if using Firebase).

## Approach Options

### Option A: React Native / Flutter Port (Recommended)
- Rewrite the UI layer in Flutter or React Native targeting both platforms.
- Pros: single codebase going forward, faster Android iteration.
- Cons: significant upfront rewrite, risk of iOS regression.

### Option B: Kotlin Native Android App
- Write a separate native Android app in Kotlin / Jetpack Compose.
- Pros: best Android UX, no iOS risk.
- Cons: maintaining two codebases long-term, higher development cost.

### Option C: Capacitor / Web Wrapper
- Wrap the Firebase Hosting web app in a Capacitor shell for Google Play.
- Pros: fastest to ship, reuses web assets.
- Cons: not a native experience, may not pass Play Store quality bar for productivity apps.

**Recommended: Option A (Flutter) if starting fresh. Option C as a fast validation step before committing to a full port.**

## In Scope (v1 Android)

- Task creation, editing, deletion.
- Category management.
- Reminders (via Android notification system).
- Firebase sync (same backend as iOS).
- Sign in with Google (native on Android).
- Sign in with Apple (supported on Android via Firebase Auth).
- Freemium model via Google Play Billing Library (see PRD 13).
- Light and dark mode.

## Device Testing Requirements

Before launch, test on:
- Pixel 8 (flagship reference).
- Samsung Galaxy S24 (most popular Android OEM).
- A mid-range device (e.g., Pixel 7a or Samsung A-series) — represents median user hardware.
- Android 12, 13, and 14.

## Google Play Store Requirements

- Privacy policy URL (already exists).
- App content rating questionnaire.
- Data safety form (map to what iOS Privacy Manifest already declares).
- At least 2 screenshots per screen size (phone + 7-inch tablet).
- Feature graphic (1024x500px).
- Short description (80 chars) and full description.

## Acceptance Criteria

- [ ] App builds and runs on Android 12+.
- [ ] Core task management works end-to-end on Android.
- [ ] Firebase sync works between iOS and Android for the same account.
- [ ] Google Play Billing handles Pro subscription correctly.
- [ ] App passes Google Play pre-launch report (no crashes on baseline devices).
- [ ] All required Play Store assets are prepared.
- [ ] App is submitted and approved by Google Play.

## Related

- PRD 13: Freemium Model (Google Play Billing implementation needed).
- PRD 09: Login Page Redesign (Android auth flow).
- `BUILD_INSTRUCTIONS.md`
