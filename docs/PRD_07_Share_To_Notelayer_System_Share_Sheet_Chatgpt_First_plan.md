# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Implement a ChatGPT-first iOS share-sheet intake flow that captures shared text into Notelayer as task or note, preserves useful structure, and provides reliable low-friction recovery for failures.

## Critical Decisions
- Decision 1: v1 focuses on ChatGPT-origin text inputs.
- Decision 2: Shared text may map to task or note according to finalized mapping rules.
- Decision 3: Preserve source structure where useful, normalize where necessary for readability.

## Dependency Gates
- Gate A: Finalize priority ChatGPT input patterns for v1 (prose, bullets, numbered lists, markdown headings).
- Gate B: Finalize task-vs-note default behavior for ambiguous input.
- Gate C: Finalize markdown preservation boundaries and truncation/chunking behavior.

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

## Tasks:

- [ ] 🟥 **Step 1: Finalize Input/Output Requirements**
  - [ ] 🟥 Define exactly which ChatGPT output patterns are accepted in v1.
  - [ ] 🟥 Define ambiguous-intent rule for default destination (task vs note).
  - [ ] 🟥 Define structure retention policy for markdown/list inputs.

- [ ] 🟥 **Step 2: Build Share Intake Pipeline**
  - [ ] 🟥 Capture inbound shared text payload from iOS share sheet.
  - [ ] 🟥 Normalize payload metadata (source app, timestamps, content type hints).
  - [ ] 🟥 Validate payload size and fallback behavior for oversized content.

- [ ] 🟥 **Step 3: Implement Content Normalization**
  - [ ] 🟥 Parse headings/lists/paragraphs into intermediate representation.
  - [ ] 🟥 Preserve useful hierarchy while removing noisy formatting artifacts.
  - [ ] 🟥 Keep deterministic transformation rules for QA reproducibility.

- [ ] 🟥 **Step 4: Implement Destination Mapping**
  - [ ] 🟥 Map normalized content to task or note per finalized decision tree.
  - [ ] 🟥 Handle multi-item list splitting behavior according to final requirements.
  - [ ] 🟥 Preserve user-editable preview before final commit if required by flow.

- [ ] 🟥 **Step 5: Implement Reliability And Recovery**
  - [ ] 🟥 Define behavior for offline or unavailable data store.
  - [ ] 🟥 Provide clear retry/recover messaging for failed imports.
  - [ ] 🟥 Ensure failure states never silently drop user-shared content.

- [ ] 🟥 **Step 6: Performance And Friction Hardening**
  - [ ] 🟥 Define measurable success benchmark for minimal friction.
  - [ ] 🟥 Instrument processing time from share action to successful create.
  - [ ] 🟥 Reduce user prompts to minimum required confirmation points.

- [ ] 🟥 **Step 7: Verification And Acceptance**
  - [ ] 🟥 Fixture tests for prose/bullets/numbered/markdown inputs.
  - [ ] 🟥 Integration tests for destination mapping and structure retention.
  - [ ] 🟥 Manual QA for share-from-ChatGPT happy path and failure recovery.
  - [ ] 🟥 Post-change UI consistency review for share confirmation surfaces.
