---
title: Governance — Standards, Audit, Maintenance
last_updated: 2026-06-25
status: active
scope: all-platforms
group: governance
tags: [governance, standards, audit, maintenance]
---

# Governance

Doc standards, audit findings, and maintenance rules. Merges: `DOCS_STRUCTURE_AND_STANDARDS.md`, `REPO_AUDIT_2026_06_24.md`.

---

## Document Standard

Every maintained doc gets this frontmatter:

```yaml
---
title: Doc Title
last_updated: YYYY-MM-DD
status: active | archived | aspirational
scope: all-platforms | notelayer-ios | web | operations
group: product | design-system | architecture | operations | governance | lab
tags: [comma, separated]
related: [OTHER_DOC.md]
source_of_truth_for: [notelayer-ios, notelayer-web]   # optional
---
```

**Status definitions:**
- `active` — reflects current reality; update when feature ships or changes
- `aspirational` — describes intended behavior not yet in code; clearly labeled
- `archived` — historical record; do not use as reference

Headings: `##` for sections, `###` for sub-sections. No custom headers.

---

## Canonical Reference Hierarchy

When there's a conflict between docs, trust in this order:

1. Current Swift code (what compiles)
2. v1.5.0 App Store build (commit `b1aee8f`)
3. `FEATURE_INVENTORY.md`
4. PRD docs
5. Everything else

---

## Critically Stale Docs (Do Not Trust)

These are in `_archive/` and describe architectures that were never built:

| Doc | Problem |
|-----|---------|
| `Native_Parity_Map.md` | Describes Supabase backend that doesn't exist |
| `Native_Status.md` | Says share extension is 0% — it's fully implemented |
| `Native_Runbook.md` | Supabase setup instructions — irrelevant |
| `Project_Implementation_Plan.md` | Supabase as backend — wrong |
| `STATUS_REPORT.md` | Stale Supabase references |
| `PRODUCT_INVENTORY.md` | Pre-v1.5.0; shows 3 tabs — v1.5.0 has 2 |

---

## Key Facts for Agents

- **Backend:** Firebase/Firestore. Not Supabase.
- **iOS tabs:** 2 visible — Todos, Insights. Notes hidden since v1.5.0.
- **Gated features:** Voice capture + subtask hierarchy are in code, not in App Store build (`experimentalFeaturesEnabled = false`, no Settings UI)
- **Share extension:** IS implemented (`NotelayerShareExtension/ShareViewController.swift`)
- **Notes view:** Code exists (`NotesView.swift`) — plain text only, tab hidden
- **VoiceTaskParser:** Local NLP — not an AI/LLM API

---

## Aspirational Features (Documented, Not in Code)

| Feature | Status |
|---------|--------|
| App Intents / Siri | Planned (PRD 09 Wave 3) — 0 Swift code |
| visionOS | Noted in old docs — explicitly opted out in v1.5.0 |
| Mac app | Planned (PRD 09) — not started |
| Watch app | Planned (PRD 09) — not started |
| Notes rich text editor | Docs describe it — `NotesView.swift` is plain text only |

---

## Maintenance Rules

1. **FEATURE_INVENTORY.md** — update when any feature ships, changes scope, or is dropped
2. **RELEASES.md** — add a new version folder for every release
3. **REPOS.md** — add any new Notelayer repo immediately
4. **CLAUDE.md** — update the Active Branches table when new worktrees are created
5. **LAB_INDEX.md** — update status when explorations are promoted or dropped
6. **DS_* files** — update when design tokens change; re-verify export files after any token change

---

## Five Groups Summary

| Group | Folder | Maintained docs |
|-------|--------|----------------|
| Product | `product/` | 5 |
| Design System | `design-system/` | 6 + exports |
| Architecture | `architecture/` | 4 |
| Operations | `operations/` + `releases/` | 5 |
| Governance | `governance/` | 3 |
| **Total** | | **~23** |

Everything else → `_archive/` — historical, do not maintain.
