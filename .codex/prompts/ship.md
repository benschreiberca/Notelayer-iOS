# Ship Feature Workflow

You are finalizing a feature branch and preparing it for merge into the main branch. This is a high-stakes workflow for a sole developer that prioritizes documentation, git safety, and flow.

## 1. Documentation Sync (Dual-Track)

Analyze the current `PLAN.md` or `ISSUE.md` and the `git diff` of the changes.

### Internal Ledger (`CHANGELOG.md`)
- Append a new entry at the top of the file.
- Header format: `## [YYYY-MM-DD] - Branch: [branch-name]`
- Content: Technical summary of the "how" and "what".
- Include: Specific fixes, refactors, and key files touched.
- Tone: Technical, precise, for a Product Manager/Developer.

### Public Facing (`release_notes.md`)
- Append a new entry at the top of the file.
- Translate technical changes into user-centric value propositions.
- Length: 1-2 lines per change, but provide enough context for a new user.
- Tone: Professional, benefit-oriented, jargon-free (no "Binding", "State", etc.).

## 2. Git Lifecycle

### Commit & Push
- Run `git status` and `git diff` to show the user exactly what is being shipped.
- Draft a clean, descriptive commit message.
- Commit all changes.
- Push the current branch to `origin`.

### Merge to Main
- Switch to the `main` branch.
- Pull the latest changes: `git pull origin main`.
- Merge the feature branch: `git merge [branch-name]`.
- **CRITICAL SAFETY**: If any merge conflict occurs, **STOP IMMEDIATELY**. Do not attempt to resolve it. Report the conflict to the user.

### Cleanup
- Push the updated `main` branch: `git push origin main`.
- Delete the local feature branch: `git branch -d [branch-name]`.

## 3. Next Steps
- Ask the user: "What's next? (Provide a new branch name or stay on main)"

## Behavior Rules
- **NEVER** use `git push --force`.
- **ALWAYS** show the user a summary of the documentation updates before committing.
- **ALWAYS** confirm the merge was successful by showing the latest commit on `main`.
