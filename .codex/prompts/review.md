# Code Review Task

Perform comprehensive code review. Be thorough but concise.

## Check For:

**Logging** - No console.log statements, uses proper logger with context
**Error Handling** - Try-catch for async, centralized handlers, helpful messages
**TypeScript** - No `any` types, proper interfaces, no @ts-ignore
**Production Readiness** - No debug statements, no TODOs, no hardcoded secrets
**React/Hooks** - Effects have cleanup, dependencies complete, no infinite loops
**Performance** - No unnecessary re-renders, expensive calcs memoized
**Security** - Auth checked, inputs validated, RLS policies in place
**Architecture** - Follows existing patterns, code in correct directory

## Output Format

### ✅ Looks Good
- [Item 1]
- [Item 2]

### ⚠️ Issues Found
- **[Severity]** [File:line] - [Issue description]
  - Fix: [Suggested fix]

### 📊 Summary
- Files reviewed: X
- Critical issues: X
- Warnings: X

## Severity Levels
- **CRITICAL** - Security, data loss, crashes
- **HIGH** - Bugs, performance issues, bad UX
- **MEDIUM** - Code quality, maintainability
- **LOW** - Style, minor improvements

## Docs Naming Contract (Required)

- Store project docs under `docs/`.
- Use `Title_Snake_Case` filenames.
- Use feature-oriented naming with explicit doc-type suffixes.
- Preferred format: `<Feature_Or_Domain>_<Doc_Type>[ _YYYY_MM_DD].md`.
- Keep meta docs at top with numeric prefixes:
  - `000_Docs_Start_Here.md`
  - `010_Docs_Features_Hub.md`
  - `020_Docs_Feature_Implementation_Plans_Index.md`
  - `030_Docs_Explorations_Index.md`
  - `040_Docs_Governance.md`
- When creating or renaming docs, update links and these indexes.