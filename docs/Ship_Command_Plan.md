# Release Notes Renaming & /ship Command Plan

**Overall Progress:** `100%`

## TLDR
Rename `TESTFLIGHT_RELEASE_NOTES.md` to `release_notes.md` across the project and create a new `/ship` slash command to automate the end-of-feature workflow for a sole developer.

## Critical Decisions
- **File Naming**: Standardizing on `release_notes.md` for simplicity and consistency.
- **Workflow Automation**: The `/ship` command will handle documentation (Changelog/Release Notes), committing, merging, and branch cleanup to reduce manual overhead and mental load.
- **Safety First**: The `/ship` command will include explicit checks for merge conflicts and require manual intervention if they occur.

## Tasks:

- [x] 🟩 **Step 1: Rename Release Notes File**
  - [x] 🟩 Rename `TESTFLIGHT_RELEASE_NOTES.md` to `release_notes.md`
  - [x] 🟩 Update any internal references to the old filename (if found)

- [x] 🟩 **Step 2: Create Hypothetical `/ship` Command**
  - [x] 🟩 Create `.cursor/commands/ship.md`
  - [x] 🟩 Include commentary on why this exists (sole dev, simplicity, mental load)
  - [x] 🟩 Define the full workflow (Doc Sync -> Commit -> Merge -> Cleanup)

- [x] 🟩 **Step 3: Update Related Prompts**
  - [x] 🟩 Update `.codex/prompts/document.md` to refer to the new `release_notes.md` name
