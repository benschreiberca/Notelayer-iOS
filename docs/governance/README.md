---
title: Notelayer Repo — Start Here
last_updated: 2026-06-25
status: active
scope: all-platforms
group: governance
---

# Notelayer iOS — Repo Navigation

This is the front door. Five groups of maintained docs. Everything else is in `_archive/`.

---

## Group 1 — Product

*What the app does, what's planned, which repos exist.*

| Doc | Purpose |
|-----|---------|
| `product/FEATURE_INVENTORY.md` | **Ground truth** — every feature, every platform, comparison table |
| `product/MULTIPLATFORM_PRD.md` | Mac + Watch + Siri plan (PRD 09) |
| `product/PRODUCT_OVERVIEW.md` | Product vision, PRD index, open decisions |
| `product/PRD_DECISIONS.md` | PRDs 01–08 — shipped decisions, implementation status |
| `product/REPOS.md` | Registry of all Notelayer repos |

---

## Group 2 — Design System

*Published design system. Token-based, cross-platform, portfolio asset.*

| Doc | Purpose |
|-----|---------|
| `design-system/DS_OVERVIEW.md` | Principles, token pipeline, how to use |
| `design-system/DS_TOKENS.md` | All token values (Primitive → Semantic → Component) |
| `design-system/DS_THEMES.md` | Accent, surface, mode, wallpaper system |
| `design-system/DS_COMPONENTS.md` | Component patterns, usage rules, platform variants |
| `design-system/DS_ACCESSIBILITY.md` | Contrast, motion, color-blindness requirements |
| `design-system/DS_WEB_GUIDE.md` | Swift → CSS/React bridge for web rebuild |
| `design-system/exports/` | `tokens.json`, `figma-tokens.json`, `css-variables.css` |

---

## Group 3 — Architecture

*How the app is built.*

| Doc | Purpose |
|-----|---------|
| `architecture/DEVELOPMENT_SETUP.md` | Build instructions, Xcode setup, dSYM |
| `architecture/BACKEND_AND_AUTH.md` | Firebase auth, Firestore schema, sync, app groups |
| `architecture/ANALYTICS.md` | Full Firebase Analytics event catalog |
| `architecture/GIT_STRATEGY.md` | Branches, worktrees, multiplatform sequencing |

---

## Group 4 — Operations

*App Store, TestFlight, CI, releases.*

| Doc | Purpose |
|-----|---------|
| `releases/RELEASES.md` | Release index + four-format content guide |
| `releases/v1.5.0/` | v1.5.0 release content |
| `operations/RELEASE_CHECKLIST.md` | Release checklist template |
| `operations/CI_AND_DISTRIBUTION.md` | TestFlight, GitHub Actions, code signing |
| `operations/APP_STORE_ASSETS.md` | Screenshot guide + metadata |
| `operations/PRIVACY_POLICY.md` | Privacy policy |

---

## Group 5 — Governance

*Docs about docs.*

| Doc | Purpose |
|-----|---------|
| `governance/README.md` | This file |
| `governance/GOVERNANCE.md` | Standards, audit findings, maintenance rules |
| `governance/TESTING.md` | Insights validation, XCUITest setup |

---

## Slash Commands

`.claude/commands/` — type these in Claude Code:

| Command | When |
|---------|------|
| `/nl-context` | Start any Notelayer session |
| `/nl-design` | Any UI or design work |
| `/nl-web` | React / web rebuild sessions |
| `/nl-explore` | New idea or exploration |
| `/nl-prd` | New formal PRD |
| `/nl-release` | Writing release content |

---

## Lab (Explorations)

`lab/LAB_INDEX.md` — ideas and explorations not ready for main.
Files stay on `explore/` branches until promoted to a PRD or dropped.
