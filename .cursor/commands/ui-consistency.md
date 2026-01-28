# UI Consistency Refactor Command

**Overall Progress:** `0%`  
**Version:** 2.1  
**Last Updated:** January 27, 2026

This command automates the refactoring of UI components to use platform-standard components.

## Workflow

### Phase 1: Assessment (STRICTLY READ-ONLY)
1. Load `.codex/ui-consistency-exceptions.md` to identify active exceptions.
2. Review specified files/components for custom styling issues.
3. **Source of Truth**: Strictly follow the rules, benchmarking logic, and patterns defined in `.codex/prompts/ui-consistency.md`.
4. **MANDATORY**: DO NOT execute any code changes during this phase. This is a review-only step.
5. Generate a report using the **Assessment Report Template** below.
6. **Catch-All Rule**: Perform a final pass to identify 'orphaned' inconsistencies that didn't fit a major pattern. List these in "Miscellaneous Observations".
7. **Append**: Append findings to `@UI_CONSISTENCY_FIXES_ISSUE.md` as a new Phase.

### Phase 2: Execution (ONLY AFTER EXPLICIT USER APPROVAL)
1. ONLY proceed to this phase if the user has explicitly approved the findings in Phase 1 and requested implementation.
2. Implement approved fixes in priority order.
2. Update progress tracker and task list.
3. Verify no linter/build errors.
4. Commit changes with clear descriptions.

---

## Tasks
*(Populated after assessment phase)*

- [ ] 🟥 **Pattern 1: [Issue Type]**
- [ ] 🟨 **Pattern 2: [Issue Type]**

---

## Assessment Report Template

```markdown
# 🎯 UI Consistency Assessment: Phase [X]

## ⚡ TL;DR Exec Sum
- **Pattern 1**: [One-liner about the major inconsistency]

---

### Exceptions Skipped
1. 🟨 **[Exception Name]** → [`[File]`](file:///[path]/[File]#L[line])

---

## 🏗 Issue Type: [Issue Type]

### 📍 [Issue Name]
**👤 Use-Case**: [Narrative user flow]
**🔗 Flow**: `Breadcrumb Path`

**🔍 Comparison**:
- **Standard-Bearer**: [`File.swift:10`](file:///...)
- **Deviator**: [`OtherFile.swift:45`](file:///...)

**Problem**: [Description]

**Impact**: 
- 📉 Lines saved: [X]
- ⚠️ Risk: 🟢/🟡/🔴

---

## 📄 Miscellaneous Observations
1. [`File.swift:100`](file:///...) - [Description]

---

## 🗂 Files Reviewed
- [Link to full list in UI_CONSISTENCY_FIXES_ISSUE.md]
```

---
*Note: This slash command is a Cursor-specific wrapper for the project-agnostic rules in .codex.*
