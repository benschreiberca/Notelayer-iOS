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

- [ ] 🟥 **Component 1: [Name]** → [`[File]`](file:///[path]/[File])
  - Issues found: X
  - Lines to remove: Y
  - Priority: 🔴 High / 🟡 Medium / 🟢 Low
  
- [ ] 🟨 **Component 2: [Name]** → [`[File]`](file:///[path]/[File])
  - Issues found: X
  - Lines to remove: Y
  - Priority: 🔴 High / 🟡 Medium / 🟢 Low

**Progress Calculation:** (Completed components / Total components) × 100%

**Visual Status Indicators:**
- 🟥 To Do / Not Started
- 🟨 In Progress
- 🟩 Done / Completed

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
- Unnecessary dividers caused by splitting descriptive text across multiple list rows

**Provide a detailed assessment report:**

Use the Assessment Report Template (see section below).

**CRITICAL REQUIREMENTS:**
1. **Always include clickable code links** using format: [`[File]`](file:///[absolute-path]/[File]#L[start]-L[end])
   - Example: [`ProfileSettingsView.swift`](file:///Users/bens/Notelayer/Notelayer-iOS-1/ios-swift/Notelayer/Notelayer/Views/ProfileSettingsView.swift#L21-25)
   - Links should point to the exact line numbers where issues occur
   - Use absolute file paths for reliable linking

2. **Use visual emoji indicators** for quick scanning:
   - 🟥 To Do / High Priority / High Risk
   - 🟨 In Progress / Medium Priority / Medium Risk / Exception
   - 🟩 Done / Low Priority / Low Risk / Skip
   - 🔴 High Priority / High Risk
   - 🟡 Medium Priority / Medium Risk
   - 🟢 Low Priority / Low Risk
   - 📄 File
   - 📍 Location
   - 📉 Lines saved
   - ⚠️ Risk
   - 👤 User impact

3. **Include actual code snippets** in the "Current Code" section showing the problematic code

4. **IMPORTANT:** Include an "Exceptions Skipped" section showing:
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

1. 🟨 **[Exception Name]** → [`[File]`](file:///[path]/[File]#L[line])
   - Reason: [From registry]
   - Still valid? (Reply "keep" or "deprecate")

2. 🟨 **[Exception Name]** → [`[File]`](file:///[path]/[File]#L[line])
   - Reason: [From registry]
   - Still valid? (Reply "keep" or "deprecate")

---

### 📄 File: [ComponentName]
**Issues Found:** [Number] | **Lines to Remove:** [Number] | **Priority:** 🔴 High / 🟡 Medium / 🟢 Low

#### 🔴 Issue 1: [Name]
**📍 Location:** [`[File]`](file:///[path]/[File]#L[start]-L[end]) - [Section/Component name]

**Current Code:**
```swift
[Show actual code snippet from lines X-Y]
```

**Problem:** [Description of custom code issue]

**Replace With:**
```swift
[Platform-standard approach code]
```

**Impact:** 
- 📉 Lines saved: [X]
- ⚠️ Risk: 🔴 High / 🟡 Medium / 🟢 Low
- 👤 User impact: [Description]

**Recommendation:** 🔴 Fix now / 🟡 Fix later / 🟢 Skip  
**Rationale:** [Why this recommendation]

---

#### 🟡 Issue 2: [Name]
[Repeat format with appropriate emoji for priority]

---

### 📄 File: [ComponentName]
[Repeat format]

---

## Summary & Priority Order

### 🔴 High Priority (Fix Now)
1. 🟥 [`[File]`](file:///[path]/[File]) - [Brief reason]
2. 🟥 [`[File]`](file:///[path]/[File]) - [Brief reason]

### 🟡 Medium Priority (Fix Next)
1. 🟨 [`[File]`](file:///[path]/[File]) - [Brief reason]

### 🟢 Low Priority (Optional)
1. 🟩 [`[File]`](file:///[path]/[File]) - [Brief reason]

**Overall Impact:**
- 📉 Cleaner codebase: ~[X] lines removed
- ✅ Consistency: [Y] components will match platform standards
- ⚠️ Risk: [Overall risk assessment]
```

**Visual Status Indicators:**
- 🟥 To Do / High Priority
- 🟨 In Progress / Medium Priority / Exception
- 🟩 Done / Low Priority / Skip
- 🔴 High Priority / High Risk
- 🟡 Medium Priority / Medium Risk
- 🟢 Low Priority / Low Risk
- 📄 File
- 📍 Location
- 📉 Lines saved
- ⚠️ Risk
- 👤 User impact

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

### Pattern 4: Custom Button for URLs → Platform Link

**BAD: Button that opens URL**
```
<Button onPress={() => openURL("https://example.com")}>
  <Row>
    <Text>Visit Website</Text>
    <Icon name="arrow.up.right" />
  </Row>
</Button>
```

**GOOD: Platform link component**
```
<Link url="https://example.com">
  <Label text="Visit Website" icon="globe" />
</Link>
```

**WHY:** Links have built-in behaviors (long-press preview, accessibility, browser context). Custom buttons don't provide these features.

**Platform Examples:**
- iOS: `Link(destination: URL) { Label(...) }`
- Android: `Intent.ACTION_VIEW` with styled TextView
- Web: `<a href="...">` tag

---

### Pattern 5: Manual Icon+Text Layout → Platform Label

**BAD: Manual layout**
```
<Row spacing="12">
  <Icon name="bell" size="20" />
  <Column spacing="2">
    <Text font="semibold">Notifications</Text>
    <Text font="caption" color="secondary">Manage alerts</Text>
  </Column>
</Row>
```

**GOOD: Platform label component**
```
<Label 
  title="Notifications"
  subtitle="Manage alerts"
  icon="bell" />
```

**WHY:** Label components handle icon alignment, text hierarchy, and RTL automatically. Manual layouts require individual updates for design changes.

**Platform Examples:**
- iOS: `Label("Text", systemImage: "icon")` or custom `Label` view
- Android: Material `ListItem` with icon and two-line text
- Web: Semantic HTML with CSS Grid for layout

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

## Managing Exceptions

### When to Add an Exception

**Valid reasons for exceptions:**
- **Brand consistency:** Company logo for website link, branded colors in specific places
- **UX requirement:** Specific interaction pattern that platform doesn't support well
- **Technical constraint:** Platform limitation requires custom solution
- **Intentional design:** Unique visual element that defines app identity

**Invalid reasons (should NOT be exceptions):**
- "We've always done it this way" - not a valid reason
- "It looks slightly better" - subjective, use platform standards
- "I forgot to use platform component" - fix it, don't exception it
- "It's easier to copy-paste custom code" - wrong approach

### How to Add an Exception

**During assessment (recommended):**
1. AI flags custom element as issue
2. You reply: "Keep [element name] as exception - [reason]"
3. AI adds to `.cursor/ui-consistency-exceptions.md`
4. AI skips this element in future assessments

**Manually:**
1. Open `.cursor/ui-consistency-exceptions.md`
2. Copy exception template from file
3. Fill in all required fields (location, reason, etc.)
4. Set Status to "Active"
5. Save file

### How to Deprecate an Exception

**When you change your mind:**
1. Open `.cursor/ui-consistency-exceptions.md`
2. Move exception from "Active Exceptions" to "Deprecated Exceptions"
3. Change Status from "Active" to "Deprecated"
4. Next `/ui-consistency` run will flag it for fixing

**Quick deprecation during review:**
When reviewing assessment report, reply: "Deprecate [exception name]" and AI will update the file automatically.

### Quarterly Exception Review

**Every 3 months, review your exceptions registry:**
- Are exceptions still necessary?
- Has platform added new components that make exceptions obsolete?
- Are there too many exceptions (sign of poor architecture)?

**Health indicators:**
- ✅ Healthy app: < 5 exceptions total
- ⚠️ Warning sign: 5-10 exceptions (consider if all are needed)
- ❌ Red flag: > 10 exceptions (architecture needs refactoring)

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
- Divider lines between descriptive text that should read as a single block
- Unnecessary width constraints where natural width is better
- Unnecessary spacers that prevent content from extending

---

## Troubleshooting

**Issue: Components don't look right after refactor**
- **Check:** Platform list/table styling is applied
- **Fix:** Ensure you're using the correct platform style
- **Example:** iOS: `.listStyle(.insetGrouped)`, Android: Material theme, Web: proper CSS

**Issue: Headers look inconsistent across pages**
- **Check:** All headers use platform Section mechanism
- **Fix:** Replace any custom header components with platform `Section("Header")`
- **Verify:** No custom Text() views with manual font/color for headers

**Issue: Unnecessary dividers inside a single explanation block**
- **Check:** Descriptive text split across multiple list rows (each row adds a divider)
- **Fix:** Merge descriptive text into a single row (e.g., VStack) so it reads as one block
- **Example:** Danger Zone copy should be one row, not separate `Text()` rows with dividers

**Issue: Lost functionality after removing wrappers**
- **Check:** Wrapper contained multiple interactive elements or complex layout
- **Fix:** Don't flatten wrappers that serve functional purpose - only remove styling-only wrappers
- **Example:** Keep wrapper if grouping multiple buttons, remove if only adding padding

**Issue: Spacing looks wrong after changes**
- **Check:** Manual padding was removed but platform isn't adding default spacing
- **Fix:** Verify platform list/table is properly configured
- **Example:** Check that rows aren't using zero insets which removes platform spacing

**Issue: Icons misaligned after replacing custom shapes**
- **Check:** Icon size and alignment properties
- **Fix:** Use platform's standard icon sizing system
- **Example:** Use platform-standard icon size modifiers, not manual frame sizing

**Issue: Build errors after changes**
- **Check:** Missing imports or incorrect component usage
- **Fix:** Verify all platform components are imported correctly
- **Example:** Check required imports for platform components

**Issue: Accessibility broken after refactor**
- **Check:** Accessibility labels were removed during cleanup
- **Fix:** Add back accessibility labels to all interactive elements
- **Preserve:** All accessibility labels and identifiers

**Issue: AI keeps flagging something I want to keep custom**
- **Check:** Is it documented in exceptions registry?
- **Fix:** Add to `.cursor/ui-consistency-exceptions.md` with clear reason
- **Verify:** Status is set to "Active"

**Issue: I changed my mind about an exception**
- **Fix:** Move exception to "Deprecated Exceptions" section in registry file
- **Update:** Change Status from "Active" to "Deprecated"
- **Result:** Next `/ui-consistency` run will flag it for fixing

**Issue: Too many exceptions in my project**
- **Check:** How many exceptions are registered?
- **Warning:** > 10 exceptions suggests architectural issues
- **Fix:** Review if exceptions are truly necessary or if architecture needs refactoring

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

**Pattern** | **Replace With** | **When to Apply** | **Exception?**
---|---|---|---
Custom wrapper with padding | Direct list/table rows | Always in settings/config | Check exceptions file
Custom section header component | Platform Section("Header") | Always - use platform headers | Never allow exceptions
Custom Circle/Rectangle shape | Platform icon (e.g., SF Symbol) | For status indicators, badges | Rare - must document
Custom Button opening URL | Platform Link component | For external links | Check for brand icons
Manual Row(Icon + Text) | Platform Label component | For navigation links | Check for brand elements
Custom .background() on list | Remove modifier | Always - let platform handle | Never allow exceptions
Manual .padding() in sections | Remove modifier | Unless functionally necessary | Rare - must justify
VStack wrapping single element | Remove wrapper | Unless grouping multiple | Never allow exceptions
Custom font/color on headers | Remove overrides | Always - use platform | Never allow exceptions

**How to decide:** 
1. Check exceptions registry FIRST
2. If documented exception → skip it
3. If NOT in exceptions → flag for fixing
4. If user wants to keep it → add to exceptions registry

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
