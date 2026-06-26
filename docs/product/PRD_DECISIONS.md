---
title: PRD Decisions (01–08)
last_updated: 2026-06-26
status: active
scope: notelayer-ios
group: product
tags: [prd, decisions, shipped, history]
related: [PRODUCT_OVERVIEW.md, FEATURE_INVENTORY.md]
---

# PRD Decisions — 01 through 08

Collapsed decision record for PRDs 01–08. Each entry captures what was decided, what shipped, and what remains open. Full PRD source files are in `docs/_archive/`.

---

## PRD 01 — Experimental Features Framework

**Decision:** Build a runtime gate (`experimentalFeaturesEnabled`) to ship voice capture and subtask hierarchy without exposing them to all users.

**Shipped in v1.5.0:** Gate is active. `experimentalFeaturesEnabled = false` in `LocalStore.swift`. No Settings UI to toggle it. Features compile and run; they are not user-accessible.

**Open:** Whether to add a Settings UI toggle, remove the gate, or ship voice/subtasks as stable in a future release.

---

## PRD 02 — Analytics / Natural Language Insights

**Decision:** Build a full Insights tab with chart-based analytics computed from local task data. Mirror Firebase Analytics events into `InsightsTelemetryStore` for on-device computation.

**Shipped in v1.5.0:** Full Insights tab — completion rate, streaks, category breakdown, most active hours, oldest open tasks. Category rows are tappable (deep-link to Todos category view). Chart + data + takeaway on all sections.

**Open:** Nothing — this PRD is complete.

---

## PRD 03 — Analytics Insights Toggle

**Decision:** Remove the toggle that gated Insights visibility. Make Insights always visible as a standard tab.

**Shipped in v1.5.0:** Insights tab always present. `visibleTabs = [.todos, .insights]`. Hint banners removed.

**Open:** Nothing — this PRD is complete.

---

## PRD 04 — Voice Entry Structured Capture

**Decision:** Local NLP parser (`VoiceTaskParser.swift`) converts voice input into structured task fields — title, due date, priority, categories. Not an AI/LLM API — fully on-device.

**Shipped:** Functional and in code. Gated behind `experimentalFeaturesEnabled`. Floating FAB above tab bar is active when gate is on.

**Open:** Stabilization pass and gate removal decision.

---

## PRD 05 — Voice Entry Preview & Staging

**Decision:** After voice input is parsed, show a staging view where users can review and edit parsed fields before creating a task.

**Shipped:** Functional and in code. Gated. Depends on PRD 04 parse output.

**Open:** Same gate removal decision as PRD 04.

---

## PRD 06 — First-Time User Onboarding

**Decision:** Replace the placeholder onboarding (video-based) with an interactive 4-step flow inspired by Duolingo/Noom — interactive, branded, skippable.

**Shipped in v1.5.0:** 4-step redesigned onboarding. Auto-triggers on first install. Replayable from gear menu ("Onboarding Guide").

**Open:** Nothing — this PRD is complete.

---

## PRD 07 — Share to Notelayer (Share Sheet)

**Decision:** Implement a system share extension so users can share text and URLs from any app into Notelayer as a task draft. Priority: ChatGPT output.

**Shipped:** Share extension is fully implemented (`NotelayerShareExtension/ShareViewController.swift`). Plain text and URL sharing works. ChatGPT-specific multi-task parsing: extension is there, parsing behavior uncertain — needs verification.

**Open:** Confirm ChatGPT multi-task splitting behavior. Consider shipping to App Store (currently not prominently featured).

---

## PRD 08 — Project-Based Tasks (Subtask Hierarchy)

**Decision:** Add parent-child task relationships. A parent task can have subtasks. Data model supports it (`parentTaskId: String?` in `Models.swift`).

**Shipped:** Data model in place. UI partially implemented in `TodosView.swift` (gated behind `experimentalFeaturesEnabled`). Not in App Store build.

**Open:** UI stabilization, gate removal decision, design for collapsed/expanded subtask display.
