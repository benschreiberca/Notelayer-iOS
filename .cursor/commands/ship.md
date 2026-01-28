# Ship Command (/ship)

This command automates the finalization of a feature branch, including dual-track documentation updates and git management.

## Workflow
1. Analyze the completed work and update documentation.
2. Commit and push the feature branch.
3. Merge into main with safety checks for conflicts.
4. Clean up and prepare for the next task.

**Source of Truth**: Strictly follow the rules and logic defined in `.codex/prompts/ship.md`.

---
*Note: This slash command is a Cursor-specific wrapper for the project-agnostic rules in .codex.*
