# WEBSITE 01: Website Feature Documentation (Automated)

Last Updated: 2026-04-20
Status: Draft
Type: Website / Documentation
Priority: Medium

## Purpose

Build a feature documentation section on the Notelayer website that explains every feature clearly — what it does, how to use it, and why it exists. This content is the "learn more" destination for in-app tooltips (PRD 10) and the answer to every support question.

## Problem Statement

New users do not know what Notelayer can do. There is no public reference for features. Support questions repeat because there is no documentation to point people to. Writing and maintaining docs manually is unsustainable.

## Goals

- Cover every major feature with a dedicated page or section.
- Keep documentation accurate without manual effort on every update.
- Make it easy for users to find answers without emailing support.
- Support in-app tooltip "Learn more" deep links.

## Non-Goals

- Video walkthroughs for every feature (too expensive to maintain).
- Developer API documentation (Notelayer is a consumer app).
- Multilingual documentation (English-only for v1).

## In Scope

### Feature Pages (v1 Coverage)

Each feature gets its own page or section with:
- **What it is** (1 paragraph).
- **How to access it** (numbered steps, with screenshot).
- **How to use it** (the core workflow).
- **Tips** (1–3 power-user tips).
- **FAQ** (2–4 most common questions about that feature).

Priority features to document first:
1. Task creation and editing.
2. Categories and category management.
3. Reminders.
4. Insights / Analytics.
5. Voice Entry.
6. Share Extension.
7. Export and Import.
8. Theme customization.
9. Experimental Features toggle.
10. Pro / subscription management.

### Automation Strategy

The goal is to avoid manually writing and updating docs. Approaches to evaluate:

**Option A: AI-Assisted Generation**
- Write a structured prompt that takes the feature name + behavior description and generates a documentation page.
- Use Claude API to generate docs from a spec input (the PRD files in this repo are the source of truth).
- Review and approve generated content before publishing.
- Re-run generation when a feature changes.

**Option B: Docs-as-Code with GitHub Actions**
- Store docs as Markdown files in the repo.
- GitHub Action auto-publishes to the website when docs are merged.
- This does not automate writing — just publishing.

**Option C: Combine A + B**
- Use Claude API to draft docs from PRDs.
- Store approved drafts as Markdown in `docs/website/`.
- GitHub Action deploys to Firebase Hosting on merge.
- **Recommended approach.**

### Screenshots

- Automated screenshots already exist in this project (`AUTOMATED_SCREENSHOT_PLAN.md`).
- Reuse these for documentation — update automatically when the app's screenshot pipeline runs.

## Site Structure (Documentation Section)

```
notelayer.app/docs/
  getting-started/
    first-time-setup
    adding-your-first-task
    understanding-categories
  features/
    tasks
    categories
    reminders
    insights
    voice-entry
    share-extension
    export-import
    themes
  pro/
    what-is-pro
    manage-subscription
  faq/
```

## Content Guidelines

- **Tone:** match the brand voice (calm, direct, warm — see MARKETING 01).
- **Screenshots:** every page has at least one.
- **Length:** as short as possible. If a user needs to read 500 words to learn a feature, the feature or the UI has a problem.
- **No jargon:** assume the reader has never heard of Notelayer before.

## Acceptance Criteria

- [ ] Documentation section live at a public URL.
- [ ] At least 6 feature pages published at launch.
- [ ] Every page has at least one screenshot.
- [ ] In-app tooltip "Learn more" links resolve to the correct doc page.
- [ ] Pages are indexed by Google (verified in Search Console).
- [ ] Content generation pipeline (Claude API → Markdown → Firebase) is documented and reproducible.
- [ ] Docs update process takes under 30 minutes when a feature changes.

## Related

- PRD 10: Onboarding Overhaul (tooltips link here).
- MARKETING 04: Landing Page (docs are linked from main nav).
- `AUTOMATED_SCREENSHOT_PLAN.md` (screenshot source).
- `FULL_AUTOMATION_PROMPT.md` (existing automation infrastructure).
- PRDs 01–16 (source of truth for feature documentation content).
