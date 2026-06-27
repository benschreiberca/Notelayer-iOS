---
title: Product Overview
last_updated: 2026-06-26
status: active
scope: all-platforms
group: product
tags: [product, vision, prd, roadmap]
related: [FEATURE_INVENTORY.md, MULTIPLATFORM_PRD.md, PRD_DECISIONS.md]
---

# Product Overview

Notelayer is a focused task management app for iOS — built around speed, clarity, and a design system that can span iPhone, Mac, Watch, and Web. The core premise: capture anything fast, get it out of your head, and let the system surface what matters.

---

## Vision

A task app that feels native everywhere: one data model, one design language, multiple surfaces. Notelayer is not a project management tool — it is a personal capture and completion system.

---

## Platform Roadmap

| Platform | Status | Branch |
|----------|--------|--------|
| iPhone (iOS 16+) | Shipped — v1.5.0 | `main` |
| Mac (Apple Silicon, macOS 13+) | Catalyst-ready — enable destination in Xcode (`MAC_APP_SETUP.md`) | `test/prd-11-integration` |
| Apple Watch (watchOS 9+) | Scaffolded — create target in Xcode (`WATCH_APP_SETUP.md`) | `test/prd-11-integration` |
| Siri / App Intents | Planned — PRD 09 Wave 3 | TBD |
| Chrome Extension (side panel) | v0.1 built — `chrome-extension/` (PRD 10) | `test/prd-11-integration` |
| Web (React, Firebase) | Separate repo — `notelayer-web` | — |
| iPad | Layout runs; tab bar + sheet sizing fixed for iPad | `test/prd-11-integration` |
| visionOS | Explicitly opted out in v1.5.0 | — |

---

## PRD Index

| PRD | Title | Status |
|-----|-------|--------|
| PRD 00 | Feature Set Index | Historical — see FEATURE_INVENTORY.md |
| PRD 01 | Experimental Features Framework | ✅ Shipped v1.5.0 — gate removed |
| PRD 02 | Analytics / Natural Language Insights | ✅ Shipped v1.5.0 |
| PRD 03 | Insights Toggle | ✅ Shipped v1.5.0 — Insights always visible |
| PRD 04 | Voice Entry Structured Capture | 🟨 Functional, gated (`experimentalFeaturesEnabled`) |
| PRD 05 | Voice Entry Preview & Staging | 🟨 Functional, gated |
| PRD 06 | First-Time User Onboarding | ✅ Shipped v1.5.0 — 4-step redesigned flow |
| PRD 07 | Share to Notelayer (Share Sheet) | 🟨 Extension implemented; ChatGPT parsing status unclear |
| PRD 08 | Project-Based Tasks (Subtask Hierarchy) | 🟨 Functional, gated |
| PRD 09 | Mac + Watch Multiplatform | 🟨 Mac Catalyst-ready + Watch scaffolded — needs Xcode target wiring |
| PRD 10 | Chrome Extension Side Panel | 🟨 v0.1 built — `chrome-extension/`, pending OAuth setup + Web Store |
| PRD 11 | iOS Polish & UX | 🟨 Bugs + category recents + voice built; iPad layout fixed; search on ice |

For shipped decisions and implementation notes, see `PRD_DECISIONS.md`.

---

## Open Decisions

| Decision | Options | Owner |
|----------|---------|-------|
| iPad approach | A) iPhone layout as-is / B) Optimized split view / C) Mac port | Ben |
| Mac distribution | Mac App Store only / direct download / both | Ben |
| Notes tab re-surface | Hidden (v1.5.0+) / Mac only / bring back everywhere | Ben |
| SPM migration | Required before Mac worktrees — timing TBD | Engineering |
| Voice + Subtasks gate | Ship behind gate / remove gate / new Settings UI | Ben |

---

## Key Facts

- **Backend:** Firebase / Firestore. Not Supabase. Not ever.
- **Current App Store build:** v1.5.0, commit `b1aee8f`
- **iOS minimum:** iOS 16
- **Visible tabs:** Todos, Insights — Notes hidden since v1.5.0
- **Gated in code (not in App Store):** Voice capture, voice staging, subtask hierarchy
- **Design system:** Token-based, fully documented in `docs/design-system/`
- **Share extension:** Implemented — `NotelayerShareExtension/ShareViewController.swift`
