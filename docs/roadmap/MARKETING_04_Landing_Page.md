# MARKETING 04: Marketing Landing Page

Last Updated: 2026-04-20
Status: Draft
Type: Marketing Plan
Channel: Web
Priority: High

## Purpose

Create a dedicated marketing landing page for Notelayer that functions as the canonical home of the product on the web — converting visitors from LinkedIn, Twitter/X, App Store searches, and word of mouth.

## Current State

The Firebase Hosting site (`firebase-hosting/`) appears to exist but may be a functional web app or a basic page — not an optimized marketing page. This document is about the **marketing landing page** specifically, not the app's web interface.

## Goals

- Clearly communicate what Notelayer is and who it is for in under 10 seconds.
- Drive App Store installs (primary CTA).
- Build an email list for the Android launch and future announcements.
- Establish SEO presence for "Notelayer" and related terms.

## Non-Goals

- Replace the existing web app (if one exists).
- Full documentation site (that is WEBSITE 01).
- E-commerce or subscription management on the website (handled in-app).

## Page Structure

### Hero Section
- Headline: the tagline (from MARKETING 01).
- Sub-headline: 1–2 sentences expanding on the value prop.
- Primary CTA: "Download on the App Store" (button with App Store badge).
- Secondary CTA: "Join the waitlist for Android" (email capture).
- Hero visual: app screenshot on iPhone mockup, or short demo GIF/video.

### Feature Highlights (3–4 items)
Each with a short headline, 1-sentence description, and an app screenshot.
1. Task management — "Everything in one place."
2. Smart categories — "Organize the way your brain works."
3. Insights / Analytics — "See patterns you never noticed."
4. AI summaries (Pro) — "Understand your productivity in plain English."

### Social Proof
- App Store rating (once established).
- 2–3 short user quotes.
- "Featured in" section if press coverage happens.

### Pricing Section
- Free tier: list features.
- Pro tier: list features + price ($2.99/month or $24.99/year).
- "Start for free" CTA.

### Footer
- Links: Privacy Policy, Terms, Support email.
- Twitter / LinkedIn icons.
- App Store badge.

## Technical Implementation

- **Host:** Firebase Hosting (already set up).
- **Build:** Static HTML/CSS/JS or a lightweight framework (Astro, Next.js static export, or plain HTML).
- **Analytics:** Google Analytics or Plausible (privacy-friendly, easier GDPR compliance).
- **Email capture:** Mailchimp, ConvertKit, or a simple Firebase Function to store emails.
- **Domain:** confirm custom domain is set up (not the default firebase URL).

## SEO Basics

- Page title: "Notelayer — A Task Manager That Pays Attention"
- Meta description: 155 chars describing the app.
- OG image: 1200x630px for social sharing previews (used when LinkedIn/Twitter link is shared).
- Structured data: SoftwareApplication schema for App Store listing visibility.

## UTM Parameter Plan

All inbound links from social should include UTM params so traffic sources are measurable:
- LinkedIn posts: `?utm_source=linkedin&utm_medium=social&utm_campaign=buildinpublic`
- Twitter/X posts: `?utm_source=twitter&utm_medium=social`
- App Store description link: `?utm_source=appstore&utm_medium=organic`

## Acceptance Criteria

- [ ] Page loads in under 2 seconds on mobile (test with Lighthouse).
- [ ] App Store download button works and links to correct App Store listing.
- [ ] Email capture form stores submissions (verify in backend).
- [ ] Page is mobile-responsive (iPhone SE through large desktop).
- [ ] OG image appears correctly when URL is shared on LinkedIn and Twitter.
- [ ] Privacy Policy link works.
- [ ] Custom domain resolves (not a firebase.app subdomain).
- [ ] Google Analytics or equivalent is tracking page views.

## Related

- WEBSITE 01: Feature Documentation (linked from this page's navigation or footer).
- MARKETING 01: Brand Persona (visual and voice direction).
- PRD 13: Freemium Model (pricing section content).
- `firebase-hosting/` directory in repo.
