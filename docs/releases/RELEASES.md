---
title: Releases — Index and Format Guide
last_updated: 2026-06-25
status: active
scope: all-platforms
group: operations
tags: [releases, app-store, changelog, marketing]
source_of_truth_for: [notelayer-ios, notelayer-web]
---

# Releases

This file is the index of all Notelayer releases and the format guide for release content.

Each release lives in its own subfolder: `releases/v[VERSION]/`. Every release produces four files, each with a different audience, format, and constraint. **Do not mix them** — an App Store reviewer, a developer reading a changelog, and a content writer working on social copy all need different things.

---

## Release Index

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| v1.5.0 | 2026-02-12 | Shipped | First major App Store release |

---

## Four Content Types Per Release

### 1. CHANGELOG.md
**Audience:** Developers, contributors, technical reviewers
**Format:** Bullet list grouped by Added / Changed / Fixed / Removed
**Constraint:** None — be complete and specific
**Voice:** Technical, precise, neutral

```md
# Changelog — v[VERSION]

## Added
- [feature]: brief technical description

## Changed
- [component]: what changed and why

## Fixed
- [bug]: what was wrong and what the fix was

## Removed
- [thing]: what was removed and why
```

---

### 2. RELEASE_NOTES.md
**Audience:** End users — what they experience
**Format:** Short paragraphs or bullets, benefit-led
**Constraint:** ~150–250 words. Scannable. No jargon.
**Voice:** Friendly, clear, user-benefit-focused

```md
# Release Notes — v[VERSION]

**[Headline: the single biggest thing in this release]**

[2–3 sentences on the main change and why it matters to the user.]

**Also in this release:**
- [Benefit, not feature name]: one line
- [Benefit]: one line
- [Benefit]: one line

**Bug fixes:**
- [Plain English description of what was broken and is now fixed]
```

---

### 3. APP_STORE.md
**Audience:** App Store — two distinct sections

#### Section A: Release Note (shown in "What's New")
**Constraint:** 4000 characters max. Shown to users updating the app.
**Format:** Short bullets, plain English, highlight the best things
**Voice:** Direct, user-benefit-led

#### Section B: Full Description (shown on App Store product page)
**Constraint:** 4000 characters max (Apple limit). Keyword-aware.
**Format:** Paragraph + bullets. First 2 lines visible before "more"
**Voice:** Marketing-forward but honest. Feature-complete.

```md
# App Store Content — v[VERSION]

---

## SECTION A: Release Note (What's New)
<!-- Max 4000 chars. Shown when user taps "What's New" during update. -->

[Short note — 3–6 bullet points of the biggest user-facing changes]

---

## SECTION B: Full App Description
<!-- Max 4000 chars. Shown on the product page. First ~2 lines visible above fold. -->

[Opening hook — most compelling thing about the app]

[Feature paragraphs]

[Closing / call to action]

**Keywords (do not publish — internal only):**
[comma-separated keyword list for ASO]
```

---

### 4. MARKETING_BRIEF.md
**Audience:** Content marketing — social posts, blog, email, screenshots
**Format:** Free-form, organized by channel
**Constraint:** None
**Voice:** Brand voice — varies by channel

```md
# Marketing Brief — v[VERSION]

## Release Narrative
[1–2 sentences: what's the story of this release?]

## Primary Angle
[The single most compelling hook for content]

## Secondary Angles
- Angle 1:
- Angle 2:

## Social Copy

### Twitter / X (280 chars)
Option A:
Option B:

### LinkedIn (longer, more context)
Draft:

## Screenshot Themes
[Which features to show in App Store screenshots and suggested copy overlays]

## Blog / Long-Form Hook
[Premise for a longer piece, if applicable]

## Email Subject Lines
Option A:
Option B:
```

---

## Adding a New Release

1. Create folder: `docs/releases/v[VERSION]/`
2. Copy the four templates above into four files
3. Add a row to the Release Index table above
4. Use `/nl-release` in Claude Code to generate draft content from a feature list
