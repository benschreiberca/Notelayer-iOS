# Feature Implementation Plan

**Overall Progress:** `0%`

## TLDR
Implement English voice parsing that produces granular staged tasks with existing-category-only guesses, confidence flags for uncertain fields, and deterministic fallback title behavior.

## Critical Decisions
- Decision 1: v1 parsing language is English only.
- Decision 2: Split behavior favors granular tasks.
- Decision 3: Unknown category guesses map only to existing categories.
- Decision 4: Title fallback uses first 6 words with 55-character cap.

## Dependency Gates
- Gate A: Final parse confidence threshold for `Needs Review` state.
- Gate B: Final decision on one-level vs multi-tier confidence display.

## Integration Surfaces (Expected)
- `ios-swift/Notelayer/Notelayer/Views/TaskInputView.swift`
- `ios-swift/Notelayer/Notelayer/Views/TaskEditView.swift`
- `ios-swift/Notelayer/Notelayer/Data/Models.swift`
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`

## UI Consistency Integration
- Parser is primarily non-UI, but preview-facing confidence badges/labels must follow `.codex/prompts/ui-consistency.md`.
- Standard-Bearer for preview UI checks: `ios-swift/Notelayer/Notelayer/Views/TodosView.swift`.
- Use standard labels/icons and avoid decorative wrappers for confidence hints.
- Run read-only consistency review before and after preview-surface updates.

## Tasks:

- [ ] 🟥 **Step 1: Define Parsing Contract And Fixtures**
  - [ ] 🟥 Define input/output schema for parsed staged task payload.
  - [ ] 🟥 Create fixture set for single-task, multi-task, ambiguous-category, and noisy utterances.
  - [ ] 🟥 Define deterministic behavior for punctuation- and conjunction-based splits.

- [ ] 🟥 **Step 2: Build English Parsing Pipeline**
  - [ ] 🟥 Implement English utterance normalization (trim filler, normalize separators).
  - [ ] 🟥 Implement task segmentation with granular split bias.
  - [ ] 🟥 Ensure segmentation remains stable for repeated identical utterances.

- [ ] 🟥 **Step 3: Implement Field Extraction Rules**
  - [ ] 🟥 Extract/guess title, notes, date, priority.
  - [ ] 🟥 Apply category inference against existing categories only.
  - [ ] 🟥 Reject new-category auto-creation from parser output.

- [ ] 🟥 **Step 4: Implement Confidence And Fallback Behavior**
  - [ ] 🟥 Score per-field confidence for guessed values.
  - [ ] 🟥 Mark low-confidence values as `Needs Review` (or approved tier model).
  - [ ] 🟥 Apply title fallback: first 6 words, 55-character max with ellipsis.

- [ ] 🟥 **Step 5: Prepare Output For PRD 05 Staging**
  - [ ] 🟥 Emit complete staged-task payload consumable by preview screen.
  - [ ] 🟥 Ensure all guessed fields are editable and marked for user review.

- [ ] 🟥 **Step 6: Quality And Drift Protections**
  - [ ] 🟥 Add deterministic unit tests for split behavior.
  - [ ] 🟥 Add tests for category mapping to existing set only.
  - [ ] 🟥 Add tests for fallback title length/word-count constraints.

- [ ] 🟥 **Step 7: Verification And Acceptance**
  - [ ] 🟥 Validate granular split outcomes across representative voice fixtures.
  - [ ] 🟥 Validate confidence flags appear for uncertain guesses.
  - [ ] 🟥 Validate output integrates cleanly with staging flow and user edits.
  - [ ] 🟥 Run post-change UI consistency review for preview-facing confidence UI.
