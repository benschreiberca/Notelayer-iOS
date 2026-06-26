---
title: PRD 11 — iOS Polish & UX
last_updated: 2026-06-26
status: Draft
scope: iPhone
group: product
tags: [ios, polish, ux, voice, search, categories, share]
related: [PRD_DECISIONS.md, FEATURE_INVENTORY.md, BUGS.md]
---

# PRD 11: iOS Polish & UX

**Last Updated:** 2026-06-26  
**Status:** Draft  
**Scope:** iPhone (iOS 16+)  
**Group:** Product  
**Tags:** ios, polish, voice, search, categories, share  
**Related:** `PRD_DECISIONS.md`, `FEATURE_INVENTORY.md`, `docs/BUGS.md`

---

## Purpose

A focused polish sprint for the iOS app addressing friction points found through real use: voice entry quality, share extension capabilities, category chip discoverability, and search placement. These are individually small but collectively they define whether the app feels polished or rough at its edges.

---

## Goals

- Reduce friction in the most common capture flows (voice, share, quick-add).
- Make the category system feel smarter and more responsive to actual usage patterns.
- Move search to where iOS users expect it (bottom tab area), reducing cognitive load.
- Keep the share extension working and make it more useful.

## Non-Goals

- New features outside of capture and navigation (no new Insights, no subtask redesign).
- iPad or Mac adaptations — iOS only.
- Voice AI/LLM integration — parser stays local (see `VoiceTaskParser.swift`).

---

## In Scope

### 1. Voice Entry — Better Parsing and UX

**Problem:** Voice entry exists and is functional, but the parsing is not always reliable and the UI experience around it is rough.

**Changes:**
- Review and improve `VoiceTaskParser.swift` parsing rules — especially date/time extraction (today, tomorrow, next Monday) and priority detection ("urgent", "high priority").
- After voice recognition completes, show the raw transcription AND the parsed fields side-by-side so users can see and correct the parse result before confirming.
- Add a "Re-record" button on the staging view — tap to try voice again without losing the current parse.
- Improve staging view layout so title, categories, due date, and priority fields are clearly editable after parse.

**Open Decision:** Should voice entry be gated still (`experimentalFeaturesEnabled`) or graduated to always-on in this PRD? The gate exists in code; removing it is a one-line change.

---

### 2. Share to Notelayer — Maintain + Enhance

**Problem:** The share extension works for plain text and URLs. Enhance it without breaking existing behavior.

**Current:** `NotelayerShareExtension/ShareViewController.swift` — plain text and URL sharing creates a draft task.

**Changes:**
- Ensure share extension always works — add to release checklist (already added in `RELEASE_CHECKLIST.md`).
- Add category selection to the share extension compose view — user can assign categories before saving.
- Show a preview of the task that will be created (title from selected text, URL in notes field) before confirming.
- Improve multi-item parsing: if shared content has clear list structure (numbered list, bullet list), offer to create multiple task drafts.
- Add a "Save and Open App" button as an alternative to "Save" — deep-links into the app to the newly created task.

---

### 3. Category Chips — Dynamic Reorder (Recently Used First)

**Problem:** Category chips in the quick-add new task flow are in a fixed order. Users who have favorite or frequently-used categories have to scroll past others every time.

**Changes:**
- Track last-used timestamp per category in `LocalStore.swift` or a separate lightweight store (e.g., UserDefaults with `group.com.notelayer.app`).
- In the category chip row for new task entry, sort categories: recently used (last 3–5) first, then remaining alphabetically.
- Same reorder should apply in the share extension compose view (consistent experience).
- No UI change required — same chip design, just different ordering.

**Implementation note:** "Recently used" = most recently assigned to a task (on task save/edit). Don't count browse/tap-without-save as usage.

---

### 4. Search — Move to Bottom iOS-Style Placement

**Problem:** Search is currently placed at the top of the Todos view in a custom position. iOS 18+ design convention places search integrated with or near the bottom tab bar (using `UISearchController` in the navigation bar, or a floating search field above the tab bar). The current placement feels custom and hard to reach on large phones.

**Changes:**
- Move the search trigger to the tab bar row — either as an additional tab icon (magnifying glass) or as a floating button above the tab bar consistent with the add-task FAB pattern.
- On tap: expand a search sheet or inline search bar — full-screen or sheet style.
- Search scope: task titles, task notes, category names.
- Results show in a flat list (no grouping) with category chips visible.
- Dismiss search: swipe down or tap outside.

**Open Decision:**
- A) Search as a 3rd tab icon in the tab bar (`TabItem` with magnifying glass SF Symbol) — simplest, familiar.
- B) Floating search button above the tab bar (same row as add-task FAB) — more custom, consistent with existing FAB pattern.
- C) Pull-down search (swipe down on list to reveal) — hidden but discoverable.

Option A is the lowest-effort iOS-idiomatic choice. Option B keeps the tab bar clean (2 tabs only as designed).

---

## Open Decisions

| # | Decision | Options | Resolved? |
|---|---------|---------|-----------|
| 1 | Voice entry — remove gate in this PRD? | A) Graduate to always-on / B) Keep gated | ❌ |
| 2 | Search placement | A) 3rd tab / B) Floating above tab bar / C) Pull-down | ❌ |
| 3 | Category "recently used" storage | A) Extend LocalStore / B) Separate UserDefaults key | ❌ |
| 4 | Share extension multi-task parsing — threshold for offering split? | Clear list structure only / Any line break | ❌ |

---

## Acceptance Criteria

**Voice:**
- [ ] Parser correctly extracts date from "tomorrow", "next Monday", "June 30"
- [ ] Parser correctly extracts priority from "urgent", "high priority", "low priority"
- [ ] Staging view shows raw transcription + all parsed fields editable
- [ ] Re-record button returns to recording without losing current parse

**Share:**
- [ ] Sharing plain text from Safari creates a task — no regression
- [ ] Sharing a URL creates a task with URL in notes field — no regression
- [ ] Category selection available in share compose view
- [ ] "Save and Open App" deep-links to the new task in the app

**Category chips:**
- [ ] Last 3 recently-used categories appear first in the new task chip row
- [ ] Order updates after each task save (not after tap)
- [ ] Chips still scroll horizontally if count exceeds row width

**Search:**
- [ ] Search accessible without scrolling to top of Todos view
- [ ] Search works on task titles, notes, and category names
- [ ] Results update as user types
- [ ] Dismiss is clear (swipe down or tap outside)

---

## Implementation Notes

- `VoiceTaskParser.swift` (203 lines) — local NLP, no external API. Improvements are rule additions only.
- `NotelayerShareExtension/ShareViewController.swift` — share extension. App group `group.com.notelayer.app` is the data bridge.
- Category chip row: likely in `Views/Shared/CategoryChipGridView.swift` — check where task-create chips are rendered.
- Search: `Views/TodosView.swift` (1,886 lines) — current search placement is here. Check for `searchText` state and where the search field is rendered.
- Tab bar: `Views/RootTabsView.swift` — `visibleTabs = [.todos, .insights]`. Adding a 3rd tab here is trivial; keeping it at 2 and adding a floating button is more work.

---

## Status

| Item | Status | Branch |
|------|--------|--------|
| Category chip reorder (main app + share extension) | ✅ Done | `feature/category-chip-recents` |
| Voice parser improvements (date/priority/title + tests) | ✅ Done | `feature/voice-improvements` |
| Share extension category recents | ✅ Done | `feature/category-chip-recents` |
| Voice — re-record button | ⏸ Deferred (audio re-capture plumbing) | — |
| Voice — side-by-side raw transcript pane | ⏸ Deferred (staging view already shows transcript in notes field) | — |
| Share — "Save and Open App" deep-link | ⏸ Deferred (app-extension openURL is restricted/fragile) | — |
| Search relocation | 🧊 On ice (per Ben) | — |
