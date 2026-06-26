# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Enable global category group reordering via long‑press drag on headers in the Category tab and in Manage Categories, with synced order across devices.

## Critical Decisions
Key architectural/implementation choices made during exploration:
- Decision 1: Global `Category.order` field - ensures a single ordering rule used everywhere and synced.
- Decision 2: Client-side sort by `order` even after fetch - resilient against backend ordering quirks.

## Tasks:

- [x] 🟩 **Step 1: Add global ordering model + migration**
  - [x] 🟩 Add `order` to `Category` and update encoding/decoding
  - [x] 🟩 Backfill missing order on load using existing array order (preserve current ordering)
  - [x] 🟩 Insert new categories at top (`order = 0`, shift others)

- [x] 🟩 **Step 2: Sync ordering across devices**
  - [x] 🟩 Include `order` in Firebase category read/write
  - [x] 🟩 Ensure category lists are sorted by `order` after fetch

- [x] 🟩 **Step 3: Centralize ordering rule**
  - [x] 🟩 Add a single `sortedCategories` access path in `LocalStore` (global rule)
  - [x] 🟩 Update all category consumers to use the sorted list (Category tab, Manage Categories, chips, share extension)

- [x] 🟩 **Step 4: Category tab drag‑to‑reorder**
  - [x] 🟩 Add header‑only long‑press drag on group cards
  - [x] 🟩 Collapse dragged group only while dragging; restore after drop
  - [x] 🟩 Use standard iOS drop indicator + haptic feedback
  - [x] 🟩 Update order and persist/sync on drop

- [x] 🟩 **Step 5: Manage Categories drag‑to‑reorder**
  - [x] 🟩 Implement long‑press + drag reordering in list rows (no handles)
  - [x] 🟩 Use same ordering update path + haptic + drop indicator
