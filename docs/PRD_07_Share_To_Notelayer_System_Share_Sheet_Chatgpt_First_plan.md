# Feature Implementation Plan

**Overall Progress:** `82%`

## TLDR
Implement a ChatGPT-first iOS share-sheet intake flow that captures shared text into Notelayer as task or note, preserves useful structure, and provides reliable low-friction recovery for failures.

## Critical Decisions
- Decision 1: v1 focuses on ChatGPT-origin text inputs.
- Decision 2: Shared text may map to task or note according to finalized mapping rules.
- Decision 3: Preserve source structure where useful, normalize where necessary for readability.

## Dependency Gates
- Gate A: LOCKED - v1 supports prose, bullets, numbered lists, and markdown headings.
- Gate B: LOCKED - ambiguous mapping defaults to note.
- Gate C: LOCKED - preserve list/heading/check structure, normalize links/code to plain text; truncate above 10,000 chars with warning.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Data/SharedItem.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Data/Models.swift`
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Share extension target files (if separate target remains active in project).

## UI Consistency Integration
- Before implementation, run `.codex/prompts/ui-consistency.md` in read-only mode:
- Standard-Bearer: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`
- Deviators: share-import confirmation/edit surfaces.
- Use standard `List`, `Section`, `Label`, `Link` patterns in share confirmation UI.
- Avoid custom wrappers/buttons for URL-like content when platform link style works.
- Run post-implementation consistency review and capture deviations.

### UI Consistency Evidence (Wave 3)
- Pre-check completed against `ShareViewController.swift` confirmation surface and `TodosView.swift` retry affordance surface.
- Post-check completed: implementation uses native `List`, `Section`, `Label`, `Button`, and `confirmationDialog` patterns.
- Quality trade-off: +277 net lines across share/import UI surfaces for deterministic parsing, failure recovery, and retry controls.

## Tasks:

- [x] ✅ **Step 1: Finalize Input/Output Requirements**
  - [x] ✅ Locked v1 patterns: prose, bullets, numbered lists, markdown headings.
  - [x] ✅ Locked ambiguous intent default to note.
  - [x] ✅ Locked structure retention policy and normalization targets.

- [x] ✅ **Step 2: Build Share Intake Pipeline**
  - [x] ✅ Captured inbound shared payload from iOS share sheet.
  - [x] ✅ Added metadata normalization for source app, timestamps, and preparation timing.
  - [x] ✅ Enforced 10,000-character truncation with warning metadata.

- [x] ✅ **Step 3: Implement Content Normalization**
  - [x] ✅ Added deterministic parsing for headings/list/checklist forms.
  - [x] ✅ Added markdown link/code normalization to plain text readability.
  - [x] ✅ Added repeatable transformation behavior for QA stability.

- [x] ✅ **Step 4: Implement Destination Mapping**
  - [x] ✅ Added automatic destination inference with note-default fallback.
  - [x] ✅ Added multi-item list mapping into task batch drafts.
  - [x] ✅ Added in-sheet destination and parsed-task preview.

- [x] ✅ **Step 5: Implement Reliability And Recovery**
  - [x] ✅ Added pending queue semantics in App Group shared-items storage.
  - [x] ✅ Added retry affordance in Todos UI for failed pending imports.
  - [x] ✅ Added conversion-failure retention (never silently drop failed items).

- [x] ✅ **Step 6: Performance And Friction Hardening**
  - [x] ✅ Added preparation timing capture and >2s warning log.
  - [x] ✅ Preserved one-step save confirmation flow.
  - [x] ✅ Reduced user prompts to existing save/cancel interaction.

- [ ] 🟨 **Step 7: Verification And Acceptance**
  - [x] ✅ Added shared-item compatibility and queue-state unit tests.
  - [ ] 🟨 Full integration tests for destination mapping and structure retention are pending.
  - [ ] 🟨 Manual QA pass for share-from-ChatGPT failure-recovery scenarios is pending.
  - [x] ✅ Post-change UI consistency review completed for share confirmation surfaces.
