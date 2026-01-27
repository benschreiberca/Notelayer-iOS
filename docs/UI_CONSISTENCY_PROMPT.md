# iOS-Standard UI Consistency Prompt

**Use this prompt for future UI consistency work across the codebase.**

---

## Prompt Template

```
I need you to review and refactor [PAGE/FEATURE NAME] to use iOS-standard components and remove custom styling.

### Goal:
Ensure 100% consistency with native iOS conventions (like the Settings app) by eliminating custom layouts and using system-provided components.

### Core Principles:
1. **Use Native iOS List + Section Headers**
   - ALWAYS use `List { Section("Header") { ... } }` pattern
   - NEVER create custom header components
   - Use `.listStyle(.insetGrouped)` for Settings-like appearance

2. **Remove Custom Styling**
   - No custom VStack/HStack wrappers with manual padding
   - No custom card backgrounds, corner radius, or strokes (unless on main content cards)
   - No custom dividers - let iOS List handle them
   - Let iOS manage all spacing, widths, and background colors

3. **Use Standard Components**
   - Use `Label("Text", systemImage: "icon")` for NavigationLinks
   - Use `Link(destination:)` for external URLs
   - Use SF Symbols instead of custom shapes (e.g., `circle.fill` instead of `Circle()`)
   - Use `PrimaryButtonStyle()` for action buttons (already defined in codebase)

4. **Alignment & Spacing**
   - Use `.center` alignment for icons that should align with each other
   - Remove `Spacer()` when content should extend naturally
   - Let text flow naturally without `.frame(maxWidth: .infinity)`

### Process:

**Step 1: Assessment (DO NOT EXECUTE YET)**
Review the following pages/features for custom styling:
- [LIST SPECIFIC FILES/PAGES TO REVIEW]

For each page, identify:
- Custom VStack/HStack wrappers with manual padding
- Custom section headers (not using `Section("Header")`)
- Custom card styling where iOS List should handle it
- Custom layouts that could use Label(), Link(), or standard rows
- Custom shapes that could use SF Symbols
- Any `.background()`, `.padding()`, or manual spacing that overrides iOS defaults

Provide a detailed assessment report showing:
- What custom code exists
- What iOS-standard component should replace it
- How many lines would be saved
- Priority order for fixes (easiest/highest impact first)

**Step 2: Execution (After user approval)**
Implement the approved changes:
1. Remove custom wrappers and padding
2. Replace custom headers with `Section("Header")`
3. Replace custom layouts with Label(), Link(), standard rows
4. Replace custom shapes with SF Symbols
5. Remove unnecessary .background() and manual styling
6. Verify no linter errors
7. Commit with clear description of what was simplified

### Reference Files:
- **Gold Standard**: `TaskEditView.swift` - Uses pure iOS List + Section headers
- **Component Library**: `Shared/SettingsComponents.swift` - Reusable components (chips, badges, buttons)
- **Style Guide**: `docs/UI_COMPONENT_GUIDE.md` - Full documentation

### What to KEEP:
- Animation code (unless explicitly asked to remove)
- Main To-Do list card styling (TaskItemView.swift)
- Functional custom components (TaskCategoryChip, TaskPriorityBadge, PrimaryButtonStyle)
- Theme tokens where they provide actual theming value

### What to REMOVE:
- Custom section header components
- VStack/HStack wrappers with only padding
- Manual .padding(.vertical, X) in List sections
- Custom Circle() for status indicators (use SF Symbols)
- Custom .background() on List views
- Custom card styling on settings pages
- .frame(maxWidth: .infinity) where natural width is better
- Unnecessary Spacer() that prevents content from extending

### Expected Outcome:
- Cleaner, more maintainable code
- Automatic consistency (iOS handles all styling)
- Fewer lines of custom code
- Better adherence to iOS Human Interface Guidelines
- Scalable pattern for future pages

### Verification:
- [ ] No linter errors
- [ ] All headers use Section("Header") syntax
- [ ] All List views use .listStyle(.insetGrouped)
- [ ] No custom VStack wrappers with manual padding in List sections
- [ ] NavigationLinks use Label() where appropriate
- [ ] External links use Link(destination:)
- [ ] Status indicators use SF Symbols, not custom shapes
- [ ] Dividers span correct distance (iOS-managed)
- [ ] Card widths consistent across all pages
```

---

## Example Usage:

### For a specific page:
```
I need you to review and refactor ProfileSettingsView.swift to use iOS-standard components and remove custom styling.

[PASTE FULL PROMPT ABOVE]
```

### For multiple pages:
```
I need you to review and refactor the following pages to use iOS-standard components:
- ManageAccountView.swift
- CategoryManagerView.swift  
- RemindersSettingsView.swift

[PASTE FULL PROMPT ABOVE]

Focus on [SPECIFIC AREAS] first.
```

### For assessment only:
```
DO NOT EXECUTE. Just assess:

Review [PAGE NAMES] for opportunities to reduce custom code and use iOS-standard components.

[PASTE ASSESSMENT SECTION FROM PROMPT ABOVE]
```

---

## Quick Checklist for Self-Review:

Before asking for a consistency review, check:

- [ ] Does this page use `List { Section("Header") { ... } }`?
- [ ] Does this page have `.listStyle(.insetGrouped)`?
- [ ] Are there any custom header components?
- [ ] Are there VStack/HStack wrappers with only padding?
- [ ] Are NavigationLinks using Label() or custom layouts?
- [ ] Are external URLs using Link() or Button?
- [ ] Are status indicators using SF Symbols or custom shapes?
- [ ] Is there a `.background()` modifier on the List?

If you answered "no" to the first two or "yes" to any others, use this prompt to request a refactor.

---

## Notes:

- This prompt is optimized for SwiftUI settings/detail pages
- Main content views (like To-Do list) may have legitimate custom styling
- Always get user approval before executing changes
- Prioritize high-impact, low-risk changes first
- Keep animations unless explicitly asked to remove them
