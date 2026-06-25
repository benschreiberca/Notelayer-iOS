---
title: Lab — Exploration Index
last_updated: 2026-06-25
status: active
scope: all-platforms
group: lab
tags: [explorations, ideas, pre-prd]
---

# Lab — Exploration Index

Explorations that are not ready to merge to main. Files in this folder live on feature branches. An exploration is promoted to a real PRD or dropped — it does not stay here indefinitely.

**Rule:** Lab docs merge to `main` only when promoted to a PRD or explicitly marked as archived reference. Never merge a lab doc to main in isolation.

**Branch naming:** `explore/[topic-slug]`

**File naming:** `EXPLORE_YYYY_MM_DD_topic-slug.md`

**Design files:** `docs/lab/explorations/` — Figma exports, screenshots, rough mockups

---

## Active Explorations

| File | Topic | Status | Branch | Started |
|------|-------|--------|--------|---------|
| *(none yet)* | | | | |

---

## Promoted to PRD

| Exploration | Promoted To | Date |
|-------------|-------------|------|
| *(none yet)* | | |

---

## Parked / Dropped

| Exploration | Reason | Date |
|-------------|--------|------|
| *(none yet)* | | |

---

## How to Start an Exploration

Use `/nl-explore` in Claude Code — it creates the file with the right template and adds an entry to this index.

Or manually:
1. Create branch: `git checkout -b explore/your-topic`
2. Create file: `docs/lab/EXPLORE_YYYY_MM_DD_your-topic.md`
3. Add entry to the Active Explorations table above
4. Work freely — no format requirements in the exploration doc itself
5. When done: promote to PRD, park, or drop; update this index
