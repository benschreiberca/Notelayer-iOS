# Notelayer Docs — Structure, Standards, and Maintenance Plan

**Last Updated:** 2026-06-25
**Status:** Active
**Scope:** All Platforms

This document defines which docs are canonical going forward, how they're grouped, and the formatting standard every kept doc should follow. It supersedes the ad-hoc classification in `REPO_AUDIT_2026_06_24.md`.

---

## 1. Formatting Standard (All Kept Docs)

Every doc that is actively maintained gets this header:

```md
# Doc Title

**Last Updated:** YYYY-MM-DD
**Status:** Active | Archived | Aspirational
**Scope:** iPhone | Mac | Watch | iPad | All Platforms | Operations
```

**Status definitions:**
- **Active** — reflects current reality; updated when the feature ships or changes
- **Aspirational** — describes intended behavior not yet in code; clearly labeled so no reader mistakes it for ground truth
- **Archived** — historical record; do not use as reference; header says "do not use as reference"

All headings use `##` for top-level sections and `###` for sub-sections. No custom section header components (mirrors the UI_COMPONENT_GUIDE principle applied to docs).

---

## 2. Canonical Doc Groups (Going Forward)

Six groups. Docs in a group live in the same subfolder or are explicitly listed here. Everything not in these groups is archival — leave in place, add Archived header, do not maintain.

---

### Group 1 — Product (Feature Definitions + PRDs)

*What the app does, what platforms it targets, what is planned.*

| Doc | Status | Notes |
|-----|--------|-------|
| `FEATURE_INVENTORY.md` | Active | Ground-truth feature list; iPhone (current), Mac (planned), iPad (planned). **Primary source of truth for features.** |
| `PRD_09_Mac_And_Watch_Multiplatform.md` | Active | Mac + Watch + Siri multiplatform plan |
| `PRD_00_Feature_Set_Index.md` | Active (needs review) | Index of all PRDs; update after each release |
| `PRD_01_Experimental_Features_Framework.md` | Aspirational | Gating framework; partially in code |
| `PRD_04_Voice_Entry_Structured_Capture.md` | Aspirational | Voice → task; in code, not in App Store build |
| `PRD_05_Voice_Entry_Preview_Staging.md` | Aspirational | Voice staging; in code, not in App Store build |
| `PRD_06_First_Time_User_Onboarding.md` | Active | Onboarding; shipped |
| `PRD_07_Share_To_Notelayer_System_Share_Sheet_Chatgpt_First.md` | Active | Share extension; shipped |
| `PRD_08_Project_Based_Tasks_Parent_Subtasks.md` | Aspirational | Subtask hierarchy; in code, gated |
| `CHANGELOG_v1.5.0.md` | Active | v1.5.0 change history |
| `APP_STORE_DESCRIPTION_v1.5.0.md` | Active | Current App Store copy |
| `RELEASE_NOTES_v1.5.0.md` | Active | v1.5.0 release notes |
| `App_Store_Release_Notes.md` | Active | Running release notes across versions |

**Docs that feed FEATURE_INVENTORY.md:**
- Current Swift code (primary)
- `CHANGELOG_v1.5.0.md`
- `APP_STORE_DESCRIPTION_v1.5.0.md`
- All PRD docs (01–09)

---

### Group 2 — Design System

*Tokens, themes, components, patterns. Single source of truth for visual decisions.*

| Doc | Status | Notes |
|-----|--------|-------|
| `UI_COMPONENT_GUIDE.md` | Active | Gold standard component patterns. ⚠️ Add macOS caveat for `.insetGrouped` before Mac dev. |
| `DesignSystem/Documentation/Token_Reference_Guide.md` | Active | Primitive → Semantic → Component tokens |
| `DesignSystem/Documentation/Theme_Reference_Guide.md` | Active | ThemeAccent, ThemeSurfaceStyle, ThemeMode |
| `DesignSystem/Documentation/Component_Library_Reference_Guide.md` | Active | Component catalog |
| `DesignSystem/Documentation/Accessibility_Guide.md` | Active | |
| `DesignSystem/Documentation/Data_Row_Patterns_Reference_Guide.md` | Active | |
| `DesignSystem/Documentation/Floating_Tab_Bottom_Clearance_Reference_Guide.md` | Active | iOS-only; will need Watch/Mac equivalent |
| `DesignSystem/Documentation/Migration_Guide.md` | Active | |
| `DesignSystem/Examples/ComponentExample.swift` | Active | |
| `DesignSystem/Examples/CustomThemeExample.swift` | Active | |
| `DesignSystem/Exports/tokens.json` | Active (verify) | Verify against `DesignSystem.swift` before multiplatform |
| `DesignSystem/Exports/figma-tokens.json` | Active (verify) | Same |
| `DesignSystem/Exports/css-variables.css` | Aspirational | For web use; `notelayer-web` scope |
| `Notelayer_Design_System_Reference_Guide.md` | Archived | Superseded by DesignSystem/Documentation/ |
| `Design_System_Production_Architecture_Claude_Sonnet.md` | Archived | Architecture intent doc; verify vs code then archive |
| `Theme_System_v2.md` | Archived | Superseded by Theme_Reference_Guide |

---

### Group 3 — Architecture & Backend

*How the app is built; auth, sync, data, services.*

| Doc | Status | Notes |
|-----|--------|-------|
| `Analytics_Events.md` | Active | Firebase analytics event catalog |
| `Auth_Architecture_Review.md` | Active (verify) | Firebase auth architecture |
| `App_Group_Setup_Fix_Summary.md` | Active | App Group config for share extension |
| `BUILD_INSTRUCTIONS.md` | Active | How to build |
| `QUICK_START.md` | Active | Dev onboarding |
| `Git_Worktrees_Explained.md` | Active | Branch/worktree strategy for multiplatform |
| `Dsym_Configuration_Guide.md` | Active | dSYM/crash reporting setup |

---

### Group 4 — Operations & Release

*App Store, TestFlight, CI. Reference during release cycles only.*

| Doc | Status | Notes |
|-----|--------|-------|
| `APP_STORE_LAUNCH_CHECKLIST_v1.5.0.md` | Active (template) | Use as template for future releases |
| `Release_Checklist.md` | Active (template) | Generic release checklist |
| `PRIVACY_POLICY.md` | Active | |
| `Testflight_Setup_Guide.md` | Active | |
| `SCREENSHOT_GUIDE.md` | Active | |
| `Github_Actions_Checklist.md` | Active | |

---

### Group 5 — Audit & Governance

*Planning, audits, governance decisions. Keep as decision record.*

| Doc | Status | Notes |
|-----|--------|-------|
| `REPO_AUDIT_2026_06_24.md` | Active | Full pre-multiplatform audit |
| `DOCS_STRUCTURE_AND_STANDARDS.md` | Active | This file |
| `040_Docs_Governance.md` | Active (needs update) | Update governance rules for multiplatform era |
| `000_Docs_Start_Here.md` | Active (needs update) | Update to point to canonical groups |
| `010_Docs_Features_Hub.md` | Active (needs update) | Update links |
| `Insights_Validation_Guide.md` | Active | Validation protocol for Insights feature |
| `XCUITEST_SETUP.md` | Active | |

---

### Group 6 — Archival (Do Not Maintain)

Everything not in Groups 1–5. These stay in the repo for historical context. Add the archived header if you want clarity, but don't maintain them. Includes:

- All `*_Issue_Report.md`, `*_Plan.md`, `*_Summary.md`, `*_Progress_Tracking.md` bug-fix triplets
- `Native_Parity_Map.md`, `Native_Status.md`, `Native_Runbook.md` (Supabase-era docs)
- `Project_Implementation_Plan.md`, `STATUS_REPORT.md` (stale Supabase references)
- `PRD_02_Analytics_Natural_Language_Insights.md`, `PRD_03_Analytics_Insights_Toggle.md` (shipped, no ongoing maintenance needed)
- All `_plan.md` implementation plan variants (archival once the feature shipped)
- `PRODUCT_INVENTORY.md` (superseded by `FEATURE_INVENTORY.md`)
- `FULL_AUTOMATION_PROMPT.md`, `PRD_Single_Chat_One_Prompt_Execution_Guide.md`, etc.

---

## 3. A vs F Overlap — Resolved

The previous audit had a split between Category A (Canonical) and Category F (Design System). That split was incorrect — the design system docs are canonical too. The resolved structure:

**All canonical docs → Groups 1–5 above.**

`UI_COMPONENT_GUIDE.md` and `DesignSystem/Documentation/*.md` are both in **Group 2** — they are not duplicates, they cover different levels:
- `UI_COMPONENT_GUIDE.md` — patterns and usage rules (how to build UI)
- `DesignSystem/Documentation/*.md` — token definitions and reference (what values exist)

Both are required. Neither supersedes the other.

---

## 4. MVP Approach to Updating Docs

Do these in order. Stop after any step if scope grows.

**Step 1 — Header sweep (1–2 hours)**
Add the standard header to every Group 1–5 doc. This alone makes the repo dramatically more navigable.

**Step 2 — Update `000_Docs_Start_Here.md`**
Replace current content with links to the 5 groups above.

**Step 3 — Update `PRODUCT_INVENTORY.md` → archive it**
Add Archived header. Point readers to `FEATURE_INVENTORY.md`.

**Step 4 — Add archived header to Group 6 misleading docs**
Priority targets: `Native_Parity_Map.md`, `Native_Status.md`, `Native_Runbook.md`.

**Step 5 — Verify DesignSystem/Exports/** before PRD 09 coding begins.

That's the MVP. Steps 1–2 are the highest leverage for the lowest effort.
