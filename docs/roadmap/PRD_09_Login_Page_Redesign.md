# PRD 09: Login / Splash Page Redesign

Last Updated: 2026-04-20
Status: Draft
Feature Area: Auth / First Impression
Priority: High

## Purpose

Redesign the Notelayer landing / login screen to feel polished and professional — on par with top-tier productivity apps. This is the first thing every new user sees, and the current screen undersells the product.

## Problem Statement

The current login screen does not inspire trust or signal quality. It lacks visual personality, the sign-in options feel utilitarian, and it does not differentiate Notelayer from a generic app.

## Goals

- Create a strong first impression that converts visitors into sign-ups.
- Support all standard auth methods cleanly: Sign in with Apple, Sign in with Google, email magic link.
- Establish the Notelayer visual identity on this screen.
- Be accessible (Dynamic Type, VoiceOver, high contrast).

## Non-Goals

- Full rebrand of the entire app (that is a separate brand project).
- Adding new auth methods beyond Apple, Google, and email.

## In Scope

- Hero illustration or motion graphic that communicates the app's value.
- Sign in with Apple button (Apple HIG compliant).
- Sign in with Google button.
- Email / magic link option as secondary action.
- Notelayer wordmark and logo lockup.
- Light and dark mode versions.
- Responsive layout for all iPhone sizes (SE through Pro Max).

## Out Of Scope

- iPad-specific layout (defer).
- Animated onboarding carousel on the login screen (belongs in onboarding PRD 10).

## Design Direction

- Clean, minimal background — avoid busy patterns on the login screen itself.
- Single clear CTA hierarchy: Apple → Google → email.
- Subtle Notelayer-branded color accent (not generic blue).
- Consider a short tagline below the logo: something that captures the product promise in under 8 words.

## Acceptance Criteria

- [ ] Sign in with Apple works end-to-end on device.
- [ ] Sign in with Google works end-to-end on device.
- [ ] Email magic link option visible and functional.
- [ ] Screen passes Xcode accessibility audit (no critical issues).
- [ ] Looks correct on iPhone SE (375pt), iPhone 15 (390pt), and iPhone 15 Pro Max (430pt).
- [ ] Light mode and dark mode both look intentional.
- [ ] No debug or placeholder UI visible.

## Related

- PRD 10: Onboarding Overhaul — what happens immediately after login.
- MARKETING 01: Brand Persona — should inform visual direction.
- `Auth_And_Onboarding_Implementation_Plan.md`
