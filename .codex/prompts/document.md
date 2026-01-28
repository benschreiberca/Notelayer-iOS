# Update Documentation Task

You are updating documentation after code changes.

## 1. Identify Changes
- Check git diff or recent commits for modified files
- Identify which features/modules were changed
- Note any new files, deleted files, or renamed files

## 2. Verify Current Implementation
**CRITICAL**: DO NOT trust existing documentation. Read the actual code.

For each changed file:
- Read the current implementation
- Understand actual behavior (not documented behavior)
- Note any discrepancies with existing docs

## 3. Update Relevant Documentation

- **CHANGELOG.md**: Add entry under a new header with the current date and branch name.
  - Use categories: Added, Changed, Fixed, Security, Removed.
  - Be specific and technical (e.g., "Fixed race condition in TaskEditView").
  - Include files touched and specific logic changes.
- **release_notes.md**: Update release notes with user-facing, value-oriented descriptions.
  - Translate technical fixes into benefits (e.g., "Smoother calendar sync" instead of "Fixed state re-render").
  - Aim for 1-2 lines per change, ensuring a new user can understand the value.
  - Maintain a professional, marketing-friendly tone.

## 4. Documentation Style Rules

✅ **Concise** - Sacrifice grammar for brevity
✅ **Practical** - Examples over theory
✅ **Accurate** - Code verified, not assumed
✅ **Current** - Matches actual implementation

❌ No enterprise fluff
❌ No outdated information
❌ No assumptions without verification

## 5. Ask if Uncertain

If you're unsure about intent behind a change or user-facing impact, **ask the user** - don't guess.
