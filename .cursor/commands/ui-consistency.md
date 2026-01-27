# UI Consistency Refactor

**Overall Progress:** `0%`  
**Version:** 1.0  
**Last Updated:** January 27, 2026

Refactor UI components to use platform-standard components and remove custom styling for consistency, maintainability, and adherence to platform conventions.

---

## How to Use This Command

This command follows a **two-phase approach** to ensure safe, approved changes:

**Phase 1: Assessment (READ-ONLY)**
- AI reviews specified files/components for custom styling issues
- Identifies patterns that should use platform standards
- Provides detailed report with recommendations and impact analysis
- **NO CODE CHANGES ARE MADE**

**Phase 2: Execution (AFTER USER APPROVAL)**
- User reviews assessment report and approves specific changes
- AI implements approved fixes in priority order
- Updates progress tracker and task list as work completes
- Commits changes with clear descriptions of what was simplified

**Typical Workflow:**
1. User invokes: `/ui-consistency` + list of files/components to review
2. AI provides assessment report (Phase 1)
3. User reviews recommendations and approves changes
4. AI executes approved changes, updating progress (Phase 2)
5. User tests changes and verifies success criteria

---

## Scope

**Use this command for:**
- Settings/preferences pages
- Configuration/management pages
- Detail/edit forms accessed via navigation
- List-based admin interfaces
- Any page that should follow platform conventions (iOS Settings, Android Material Design, etc.)

**DO NOT use this command for:**
- Main content views (feeds, lists, dashboards)
- Custom card components that are part of the app's unique design
- Sheet presentations requiring specific layouts
- Onboarding/landing pages with intentional custom designs
- Views that require specific visual hierarchy for brand identity

**Rule of thumb:** If it's a settings/config page accessed via navigation, use platform standards. If it's main content, custom styling may be appropriate.

---

## Core Principles

### 1. Use Platform-Standard Components
- **ALWAYS** use native list/table components with standard section headers
- **NEVER** create custom header components when platform provides them
- Use platform's standard list/table styling (e.g., `.insetGrouped` in iOS, Material Design lists in Android)

### 2. Remove Custom Styling Wrappers
- No custom wrapper components with only padding/spacing
- No custom card backgrounds, corner radius, or strokes (unless on main content cards)
- No custom dividers - let platform handle them
- Let platform manage spacing, widths, and background colors

### 3. Use Standard Component Patterns
- Use platform's standard label/icon components (e.g., `Label()` in SwiftUI, `MaterialButton` in Android)
- Use platform's standard link components for external URLs
- Use platform's standard icon sets instead of custom shapes
- Use existing reusable components from component library (if they're truly reusable)

### 4. Natural Layout Flow
- Use appropriate alignment for icons that should align with each other
- Remove unnecessary spacers when content should extend naturally
- Let text flow naturally without forcing full-width constraints

---

## Tasks

*(This section is populated after assessment phase)*

After completing the assessment, this section will track progress:

- [ ] 🟥 **Component 1: [Name]**
  - Issues found: X
  - Lines to remove: Y
  - Priority: High/Medium/Low
  
- [ ] 🟥 **Component 2: [Name]**
  - Issues found: X
  - Lines to remove: Y
  - Priority: High/Medium/Low

**Progress Calculation:** (Completed components / Total components) × 100%

---

## Process

### Step 0: Initialize Exceptions Registry (First Run Only)

**On first use of this command in a project:**

1. Check if `.cursor/ui-consistency-exceptions.md` exists
2. If NOT exists, auto-generate it with this template:

```markdown
# UI Consistency Exceptions Registry

**Last Updated:** [Today's Date]  
**Project:** [Project Name]

This file tracks intentional custom styling that should NOT be flagged by the `/ui-consistency` command.

---

## Active Exceptions

*(No exceptions registered yet)*

---

## How to Add an Exception

When you want to keep custom styling that would normally be flagged:

### [Exception Name]
**Location:** `[File]` - [Section/Component]  
**Custom Element:** [Description of what's custom]  
**Reason:** [Why it's intentional - brand consistency, UX requirement, etc.]  
**Platform Standard Would Be:** [What the standard approach would be]  
**Approved By:** [Your name] on [Date]  
**Status:** Active

---

## Deprecated Exceptions

*(Exceptions that are no longer needed - will be flagged on next consistency review)*

---

## Review Schedule

Review this file quarterly to ensure exceptions are still valid and necessary.
```

3. Inform user: "Created exceptions registry at `.cursor/ui-consistency-exceptions.md`. Use this to document intentional custom styling."

### Step 1: Load & Check Exceptions

**Before assessing any files:**

1. Load `.cursor/ui-consistency-exceptions.md` if it exists
2. Parse all exceptions with `Status: Active`
3. Create an exclusion list for assessment
4. Proceed to assessment phase

### Step 2: Assessment (DO NOT EXECUTE YET)

**Review the following pages/components for custom styling:**
- [LIST SPECIFIC FILES/COMPONENTS TO REVIEW]

**For each component, identify:**
- Custom wrapper components with manual padding/spacing
- Custom section headers (not using platform-standard headers)
- Custom card styling where platform list/table should handle it
- Custom layouts that could use standard label/link/row components
- Custom shapes that could use platform icon sets
- Any manual styling (backgrounds, padding, spacing) that overrides platform defaults

**Provide a detailed assessment report:**

Use the Assessment Report Template (see section below).

**IMPORTANT:** Include an "Exceptions Skipped" section showing:
- What custom elements were skipped (from exceptions registry)
- Why they were skipped (reason from registry)
- Ask user to confirm: "Are these exceptions still valid? Reply 'yes' to keep, 'no' to flag for fixing"

### Step 3: Execution (After user approval)

Implement the approved changes:
1. Remove custom wrappers and padding
2. Replace custom headers with platform-standard section headers
3. Replace custom layouts with standard label/link/row components
4. Replace custom shapes with platform icon sets
5. Remove unnecessary background and manual styling
6. Update progress tracker and task list as each component is completed
7. Verify no linter/build errors
8. Commit with clear description of what was simplified

---

## Assessment Report Template

Use this format when providing assessment results:

```markdown
## Assessment Report

**Date:** [Date]
**Files Reviewed:** [X]
**Exceptions Skipped:** [Y]
**Total Issues Found:** [Z]
**Total Lines to Remove:** [W]

---

### Exceptions Skipped

*(Custom elements that were NOT flagged due to exceptions registry)*

1. **[Exception Name]** (`[File]`)
   - Reason: [From registry]
   - Still valid? (Reply "keep" or "deprecate")

2. **[Exception Name]** (`[File]`)
   - Reason: [From registry]
   - Still valid? (Reply "keep" or "deprecate")

---

### File: [ComponentName]
**Issues Found:** [Number]  
**Lines to Remove:** [Number]  
**Priority:** High/Medium/Low

**Issue 1: [Name]**
- **Location:** Lines X-Y (or component name)
- **Current:** [Description of custom code]
- **Replace With:** [Platform-standard approach]
- **Impact:** 
  - Lines saved: [X]
  - Risk: Low/Medium/High
  - User impact: [Description]

**Issue 2: [Name]**
...

**Recommendation:** Fix now / Fix later / Skip  
**Rationale:** [Why this recommendation]

---

### File: [ComponentName]
[Repeat format]

---

## Summary & Priority Order

**High Priority (Fix Now):**
1. [Component/File] - [Brief reason]
2. [Component/File] - [Brief reason]

**Medium Priority (Fix Next):**
1. [Component/File] - [Brief reason]

**Low Priority (Optional):**
1. [Component/File] - [Brief reason]

**Overall Impact:**
- Cleaner codebase: ~[X] lines removed
- Consistency: [Y] components will match platform standards
- Risk: [Overall risk assessment]
```

---

## Code Pattern Examples

### Pattern 1: Custom Wrapper → Platform Standard

**BAD: Custom wrapper with only styling**
```
<Container>
  <Padding value="20">
    <CustomHeaderComponent text="Account Settings" />
    <Card>
      <Padding value="16">
        <Content />
      </Card>
    </Padding>
  </Container>
</Container>
```

**GOOD: Platform-standard list/table component**
```
<List style="grouped">
  <Section header="Account Settings">
    <Content />
  </Section>
</List>
```

**WHY:** Platform list/table components automatically handle card styling, spacing, and margins. Custom wrappers add unnecessary code and prevent automatic consistency.

**Platform Examples:**
- iOS: `List { Section("Header") { ... } }` with `.listStyle(.insetGrouped)`
- Android: `RecyclerView` with `MaterialCardView` in sections
- Web: `<ul>` with CSS Grid/Flexbox and section headers

---

### Pattern 2: Custom Header → Platform Standard

**BAD: Custom header component**
```
<CustomSectionHeader 
  text="Account" 
  font="caption-semibold"
  color="secondary"
  padding="leading-4" />
```

**GOOD: Platform section header**
```
<Section header="Account">
  // content
</Section>
```

**WHY:** Platform handles all header styling (font, color, spacing) automatically. Custom headers require manual maintenance and create inconsistency.

**Platform Examples:**
- iOS: `Section("Header") { ... }`
- Android: Section dividers with `TextView` styled by Material theme
- Web: `<section>` with `<h2>` styled by design system

---

### Pattern 3: Custom Shape → Platform Icon

**BAD: Drawing custom shapes**
```
<Circle 
  fill="green" 
  width="8" 
  height="8" />
```

**GOOD: Platform icon set**
```
<Icon 
  name="circle.fill" 
  size="8" 
  color="green" />
```

**WHY:** Platform icon sets provide consistent, tested shapes. Custom shapes require maintenance and may not scale properly across densities/sizes.

**Platform Examples:**
- iOS: SF Symbols (`Image(systemName: "circle.fill")`)
- Android: Material Icons (`@drawable/ic_circle`)
- Web: Icon fonts (Font Awesome, Material Icons)

---

### Pattern 4: Custom Link → Platform Link Component

**Bad (Custom Button):**
```pseudocode
Button {
  action: openURL("https://example.com")
  content: {
    Text("Visit Website")
    Icon("arrow.up.right")
  }
}
```

**Good (Platform Link):**
```pseudocode
Link(url: "https://example.com") {
  Label("Visit Website", icon: "globe")
}
```

**Key Principle:** Use platform's standard link component for external URLs, not custom buttons.

---

### Pattern 5: Custom Label Layout → Platform Label Component

**Bad (Custom Layout):**
```pseudocode
Row {
  Icon("bell")
  Column {
    Text("Notifications")
    Text("Manage alerts")
  }
}
```

**Good (Platform Label):**
```pseudocode
Label(
  text: "Notifications",
  icon: "bell",
  subtitle: "Manage alerts"
)
```

**Key Principle:** Use platform's standard label component that combines icon + text, rather than manually laying them out.

---

## Common Pitfalls to Avoid

- ❌ **DON'T** remove animations unless explicitly asked
- ❌ **DON'T** flatten wrappers that contain multiple interactive elements
- ❌ **DON'T** remove theme tokens that provide actual theming (accent colors, etc.)
- ❌ **DON'T** break existing functionality for the sake of "cleaner code"
- ❌ **DON'T** assume all padding is bad - some is necessary for readability
- ❌ **DON'T** replace custom components that are reused across the app
- ❌ **DON'T** remove accessibility labels and identifiers
- ✅ **DO** preserve accessibility labels and identifiers
- ✅ **DO** test that navigation flows still work after changes
- ✅ **DO** verify visual appearance matches platform conventions
- ✅ **DO** check edge cases (empty states, long text, etc.)

---

## When Custom Styling is Acceptable

- Content cards in main views (feeds, lists, dashboards)
- Themed components that need brand consistency
- Complex interactive elements (drag-to-reorder, swipe actions)
- Views that require specific visual hierarchy
- Components that are part of the app's unique design language
- Reusable components from component library (if they're truly reusable)

**Rule of thumb:** If it's in a settings/config page accessed via navigation, use platform standard. If it's main content, custom styling may be appropriate.

---

## Edge Cases & Special Situations

**Multi-line content in list rows:**
- If content needs multiple lines, use appropriate layout inside the row (this is acceptable)
- But don't wrap the entire row in a wrapper with only padding

**Buttons in list sections:**
- Use standard button styles for primary actions
- Use platform-standard button components for secondary actions
- Don't wrap buttons in unnecessary wrappers unless grouping multiple buttons

**Empty states:**
- Keep custom empty state designs (they're intentional)
- But ensure they're inside platform list/table sections, not custom layouts

**Conditional sections:**
- Use conditional rendering directly in list/table, not wrapping entire list in conditional
- Example: `if condition { Section("Header") { ... } }`

---

## Reference Files

- **Gold Standard:** [Identify a file in the codebase that uses pure platform-standard components]
- **Component Library:** [Path to reusable components - only use if they're truly reusable]
- **Style Guide:** [Path to platform style guide documentation]

---

## What to KEEP

- Animation code (unless explicitly asked to remove)
- Main content card styling (feeds, lists, dashboards)
- Functional reusable components from component library
- Theme tokens where they provide actual theming value
- Accessibility labels and identifiers
- Complex interactive behaviors

---

## What to REMOVE

- Custom section header components
- Wrapper components with only padding/spacing
- Manual padding/spacing in list/table sections
- Custom shapes for status indicators (use platform icons)
- Custom backgrounds on list/table views
- Custom card styling on settings/config pages
- Unnecessary width constraints where natural width is better
- Unnecessary spacers that prevent content from extending

---

## Testing Requirements

After refactoring, verify:
- [ ] No linter/build errors
- [ ] Visual inspection: Compare before/after screenshots
- [ ] Light/dark mode: Test both appearances (if applicable)
- [ ] Multiple themes: Test with different theme presets (if applicable)
- [ ] Navigation flows: Ensure all links/buttons still work
- [ ] Accessibility: Screen readers still work correctly
- [ ] Edge cases: Empty states, long text, etc.
- [ ] Platform conventions: Matches platform's standard appearance

---

## Success Criteria

A refactor is successful when:
- ✅ Code uses platform-standard components (List/Table, Section, Label, Link)
- ✅ No custom wrappers with only padding/spacing
- ✅ Headers are consistent across all pages
- ✅ Card/row widths match platform standard
- ✅ Dividers span correct distance (platform-managed)
- ✅ No linter/build errors or warnings
- ✅ Visual appearance matches platform conventions
- ✅ Functionality preserved (all buttons/links work)
- ✅ Code is simpler (fewer lines, less complexity)
- ✅ Accessibility maintained

---

## Quick Reference Card

**Replace This** → **With This**
- Custom wrapper with padding → Direct list/table rows
- Custom section header → Platform Section("Header")
- Custom shape (Circle, etc.) → Platform icon
- Custom button for URL → Platform Link component
- Manual icon + text layout → Platform Label component
- Custom background on list → Remove it
- Manual padding in sections → Remove it

---

## Verification Checklist

- [ ] No linter/build errors
- [ ] All headers use platform Section("Header") syntax
- [ ] All list/table views use platform-standard styling
- [ ] No custom wrapper components with manual padding in sections
- [ ] Navigation links use Label() or equivalent where appropriate
- [ ] External links use Link() or equivalent
- [ ] Status indicators use platform icons, not custom shapes
- [ ] Dividers span correct distance (platform-managed)
- [ ] Card/row widths consistent across all pages
- [ ] Visual appearance matches platform conventions

---

## Example Usage

### For a specific page:
```
Review and refactor [PAGE NAME] to use platform-standard components.

[Use this command]
```

### For multiple pages:
```
Review and refactor the following pages to use platform-standard components:
- Page1
- Page2
- Page3

[Use this command]

Focus on [SPECIFIC AREAS] first.
```

### For assessment only:
```
DO NOT EXECUTE. Just assess:

Review [PAGE NAMES] for opportunities to reduce custom code and use platform-standard components.

[Use Step 1: Assessment section only]
```

---

## Sharing This Command

**This command is designed to be publicly shareable!**

To use in a new project:
1. Copy `.cursor/commands/ui-consistency.md` to your project's `.cursor/commands/` folder
2. Run `/ui-consistency [files to review]`
3. AI auto-generates `.cursor/ui-consistency-exceptions.md` on first run
4. Review assessment, approve changes, and execute

**No project-specific configuration needed!** The command is framework-agnostic and self-contained.

---

## Notes

- This command is optimized for settings/config pages
- Main content views may have legitimate custom styling
- Always get user approval before executing changes
- Prioritize high-impact, low-risk changes first
- Keep animations unless explicitly asked to remove them
- Preserve functionality and accessibility above all else
- Use exceptions registry for intentional custom elements
- Review exceptions quarterly to keep architecture clean
