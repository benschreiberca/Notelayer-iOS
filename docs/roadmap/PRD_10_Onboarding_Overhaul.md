# PRD 10: Onboarding Overhaul

Last Updated: 2026-04-20
Status: Draft
Feature Area: User Activation
Priority: High

## Purpose

Dramatically improve the new-user experience so that people understand Notelayer's value, discover its features naturally, and reach their first meaningful moment of value quickly.

## Problem Statement

The current onboarding (PRD 06 v1) is functional but minimal. Feature discovery is poor — users stumble on capabilities by accident or not at all. There is no persistent help layer, no guided walkthrough, and the demo video experience is not accessible from within the app post-onboarding.

## Goals

- Give every new user a clear mental model of what Notelayer does within the first 2 minutes.
- Surface key features to users at the right moment (contextual, not front-loaded).
- Make the demo / intro video re-watchable from Settings at any time.
- Reduce confusion-driven churn in the first week.

## Non-Goals

- Mandatory multi-screen tutorial that blocks app use.
- A/B testing infrastructure (not yet).
- Personalization engine (not yet).

## In Scope

### 1. Feature Discovery — Contextual Tooltips

- First time a user encounters a key surface (e.g., Insights tab, Voice Entry, Share Extension), show a one-time tooltip explaining what it does.
- Tooltips are dismissible. They do not block interaction.
- Tooltips can be reset from Settings → "Reset Feature Hints".
- Design: coach mark style (arrow + callout bubble), consistent with iOS conventions.

### 2. Demo / Intro Video

- Short video (60–90 seconds, hard cap 2 min) showing the core Notelayer workflow.
- Plays automatically on first launch after sign-in (can be skipped after 3 seconds).
- Re-accessible from Settings → "Watch Intro Video".
- Host externally (CDN or YouTube unlisted) — do not bundle in app binary.
- Subtitles/captions required for accessibility.

### 3. Onboarding Checklist (Optional First-Week Widget)

- Small card visible on the main Todos screen for the first 7 days.
- Items: "Add your first task", "Try a category", "Check Insights", "Share to Notelayer".
- Each item dismisses when the action is completed.
- The whole checklist can be dismissed manually.

### 4. Settings Re-Entry

- Settings → "Getting Started" section:
  - Watch Intro Video
  - Reset Feature Hints
  - View Feature Guide (links to website documentation)

## Feature Areas Requiring Tooltips (v1)

- Insights / Analytics tab
- Voice Entry (mic button)
- Manage Categories
- Share Extension
- Reminders
- Task export

## Acceptance Criteria

- [ ] Intro video plays on first launch, skippable after 3 seconds.
- [ ] Video is re-watchable from Settings without reinstalling.
- [ ] At least 5 contextual tooltips implemented for top feature surfaces.
- [ ] Tooltips only appear once per feature unless reset.
- [ ] Reset Feature Hints option in Settings works correctly.
- [ ] Onboarding checklist appears on fresh install and dismisses on completion.
- [ ] No tooltip or checklist UI appears for users who have been using the app for >7 days (clean migration).

## Related

- PRD 06: First-Time User Onboarding (v1 baseline).
- PRD 09: Login Page Redesign (what comes before onboarding).
- WEBSITE 01: Feature Documentation (the "learn more" destination for tooltips).
- ISSUE 01: Managed Categories Preset Overwrite (related to preset selection in onboarding).
