# PRD 13: Freemium Monetization Model

Last Updated: 2026-04-20
Status: Draft
Feature Area: Business Model / Monetization
Priority: High

## Purpose

Introduce a freemium model where the core Notelayer experience is free, and power users pay a small monthly fee to unlock the Analytics / Insights layer.

## Problem Statement

Notelayer currently has no revenue model. Without a sustainable business model, the product cannot fund continued development, marketing, or infrastructure. Analytics is the highest-value feature for power users and the natural paywall.

## Goals

- Keep the core task management experience 100% free to drive growth and word-of-mouth.
- Create a clear, compelling reason to upgrade — centered on Analytics.
- Price accessibly ($1–5/month range) to reduce friction for individuals.
- Implementation should not degrade the experience for free users.

## Non-Goals

- Enterprise / team pricing (defer to later).
- Ads-based free tier.
- One-time purchase option for v1.

## Pricing Structure (Draft)

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | Full task management, categories, reminders, sharing, basic stats |
| Notelayer Pro | $2.99/month or $24.99/year | Full Analytics & Insights, AI-powered analytics (PRD 14), advanced export, priority support |

- Price is a starting point — validate with TestFlight beta users before launch.
- Annual plan at ~30% discount to improve LTV.

## What Stays Free

- Unlimited task creation.
- All categories and category management.
- Reminders.
- Voice entry.
- Share extension.
- Basic task statistics (count, completion rate, streak — no charts).
- Import / export.

## What Requires Pro

- Full Insights / Analytics dashboard with charts.
- AI-generated analytics summaries (PRD 14).
- Advanced export formats (CSV, JSON).
- Theme customization beyond 3 base themes (optional gating).

## Implementation Approach

- Use **StoreKit 2** for subscription management.
- Gate features via a `ProEntitlement` check that can be queried anywhere in the app.
- **RevenueCat** SDK strongly recommended to handle receipt validation, paywall A/B testing, and analytics without building custom server infrastructure.
- Paywall screen: shown when a free user taps a Pro-gated feature. Single-screen, no pop-up spam.
- Restore purchases option required by App Store guidelines.

## Acceptance Criteria

- [ ] Free users can use all non-Pro features without any upsell interruption.
- [ ] Tapping a Pro feature shows a clear, non-aggressive upgrade prompt.
- [ ] Subscription purchase flows through StoreKit 2 correctly.
- [ ] Restore purchases works.
- [ ] Pro status persists across reinstall (via RevenueCat or receipt validation).
- [ ] App Store metadata is updated to reflect freemium model before public launch.
- [ ] Pricing tested with at least 5 beta users before App Store submission.

## Related

- PRD 14: AI Analytics Intelligence (the primary Pro-only feature).
- PRD 16: Android Launch (freemium model must also work on Google Play via Billing Library).
- MARKETING 01: Brand Persona (free tier drives growth; messaging must reflect this).
