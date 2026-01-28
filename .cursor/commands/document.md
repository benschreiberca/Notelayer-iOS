# Document Command

This command automates the update of project documentation (CHANGELOG, Release Notes, etc.) after code changes.

## Workflow
1. Identify recent changes via git history and diffs.
2. Verify implementation against actual code behavior.
3. Update relevant documentation files.
4. **Source of Truth**: Strictly follow the rules and style guidelines defined in `.codex/prompts/document.md`.

---
*Note: This slash command is a Cursor-specific wrapper for the project-agnostic rules in .codex.*
