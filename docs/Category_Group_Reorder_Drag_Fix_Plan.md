# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Fix category group drag‑to‑reorder so the entire header row is draggable, long‑press timing matches tasks, the standard drop divider appears, and reordering works in both Category tab and Manage Categories.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Use platform‑standard drag/drop affordances (SwiftUI drag + dropDestination) - aligns with iOS List/ScrollView patterns and preserves consistency.
- Decision 2: Keep header‑only drag targets but expand hit area to full header row - avoids task drag conflicts while meeting UX expectations.

## Tasks:

- [ ] 🟩 **Step 1: Audit drag gesture targets + timing**
  - [ ] 🟩 Verify header view hit‑testing spans full row (icon/title/count/chevron)
  - [ ] 🟩 Match long‑press duration to task drag configuration

- [x] 🟩 **Step 2: Restore functional reordering in Category tab**
  - [x] 🟩 Ensure group drag payload attaches to header container (not just text)
  - [x] 🟩 Fix dropDestination target so divider line appears and reorder fires

- [x] 🟩 **Step 3: Restore functional reordering in Manage Categories**
  - [x] 🟩 Ensure list rows expose full‑width drag target
  - [x] 🟩 Fix dropDestination target so divider line appears and reorder fires

- [x] 🟩 **Step 4: Verify UX parity**
  - [x] 🟩 Confirm long‑press timing matches task drag
  - [x] 🟩 Confirm divider appears and order persists in both screens
