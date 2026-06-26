---
title: Notelayer Repository Registry
last_updated: 2026-06-25
status: active
scope: all-platforms
group: product
tags: [repos, architecture, cross-repo]
source_of_truth_for: [notelayer-ios, notelayer-web, notelayer-marketing]
---

# Notelayer Repository Registry

Single reference for every Notelayer repo. When an agent or developer needs to know what lives where, this is the file to read.

**This repo (Notelayer-iOS) is the canonical source of truth** for product decisions, design system, feature definitions, and architecture. All other repos pull from it — not the reverse.

---

## Repos

### Notelayer-iOS
**Repo:** `github.com/benschreiberca/Notelayer-iOS`
**Purpose:** iOS app (primary). Also the source of truth for design system, features, and architecture for all platforms.
**Platforms:** iOS 16+, Mac (planned), watchOS (planned)
**Backend:** Firebase / Firestore
**Branch strategy:** `main` (stable) → `docs/audit`, `claude/hopeful-rubin-9xouzo` (active planning) → feature branches
**Canonical docs this repo exposes:**
- `docs/design-system/DS_*.md` — published design system
- `docs/product/FEATURE_INVENTORY.md` — feature ground truth
- `docs/product/MULTIPLATFORM_PRD.md` — Mac + Watch plan
- `docs/architecture/BACKEND_AND_AUTH.md` — Firebase schema and auth

---

### notelayer-web (Marketing Site)
**Repo:** `github.com/benschreiberca/notelayer-web` *(verify repo name)*
**Deploy:** Vercel
**Purpose:** Public marketing website for Notelayer
**Pulls from Notelayer-iOS:**
- `FEATURE_INVENTORY.md` — for accurate feature descriptions
- `DS_TOKENS.md` + `DS_THEMES.md` — for visual consistency with app
- `APP_STORE.md` (latest release) — for "What's New" content
- `PRIVACY_POLICY.md` — legal copy
**Does NOT use:** Firebase directly (marketing site only, no auth)

---

### notelayer-web (Chrome Extension)
**Repo:** *(confirm — may be same repo as marketing site or separate)*
**Purpose:** Chrome extension for web-based task capture
**Pulls from Notelayer-iOS:**
- `BACKEND_AND_AUTH.md` — Firebase auth and Firestore collections
- `DS_WEB_GUIDE.md` — CSS tokens for visual consistency
- `FEATURE_INVENTORY.md` — to know which features the extension should surface

---

## Cross-Repo Consistency Rules

1. **Feature descriptions**: always sourced from `FEATURE_INVENTORY.md`. Never write marketing copy that describes a feature differently than it's described here.
2. **Design tokens**: any web property (marketing site, extension, future web app) must use the token values from `DS_TOKENS.md`. The CSS export at `docs/design-system/exports/css-variables.css` is the bridge.
3. **Privacy policy**: single source in this repo. The marketing site hotlinks or copies verbatim — never diverges.
4. **Release content**: `APP_STORE.md` (Section B: Full Description) is the canonical description of what the app does. Marketing site "features" section should not contradict it.

---

## Adding a New Repo

When a new Notelayer repo is created:
1. Add a section here following the format above
2. Specify what it pulls from Notelayer-iOS (source of truth relationship)
3. Add `source_of_truth_for: [new-repo-name]` to the frontmatter of any doc it should read from
