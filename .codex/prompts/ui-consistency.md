# UI Consistency Rules & Standards

This document defines the project's standards for UI consistency, focusing on adherence to platform conventions (iOS/Material Design).

## Core Principles

### 1. Use Platform-Standard Components
- **ALWAYS** use native list/table components with standard section headers.
- **NEVER** create custom header components when platform provides them.
- Use platform's standard list/table styling (e.g., `.insetGrouped` in iOS).

### 2. Remove Custom Styling Wrappers
- No custom wrapper components with only padding/spacing.
- No custom card backgrounds, corner radius, or strokes (unless on main content cards).
- No custom dividers - let platform handle them.
- Let platform manage spacing, widths, and background colors.

### 3. Use Standard Component Patterns
- Use platform's standard label/icon components (e.g., `Label()` in SwiftUI).
- Use platform's standard link components for external URLs.
- Use platform's standard icon sets instead of custom shapes.

### 4. Natural Layout Flow
- Use appropriate alignment for icons that should align with each other.
- Remove unnecessary spacers when content should extend naturally.
- Let text flow naturally without forcing full-width constraints.

---

## Code Pattern Examples

### Pattern 1: Custom Wrapper → Platform Standard
**BAD**: Custom wrapper with only styling.
**GOOD**: Platform-standard list/table component.
**WHY**: Platform handles card styling, spacing, and margins automatically.

### Pattern 2: Custom Header → Platform Standard
**BAD**: Custom header component.
**GOOD**: Platform section header.
**WHY**: Platform handles all header styling (font, color, spacing) automatically.

### Pattern 3: Custom Shape → Platform Icon
**BAD**: Drawing custom shapes (e.g., `Circle()`).
**GOOD**: Platform icon set (e.g., `Image(systemName: "circle.fill")`).

### Pattern 4: Custom Button for URLs → Platform Link
**BAD**: Button that opens URL.
**GOOD**: Platform link component (`Link`).

### Pattern 5: Manual Icon+Text Layout → Platform Label
**BAD**: Manual `HStack` layout.
**GOOD**: Platform `Label` component.

---

## Assessment Logic

### 0. STRICT READ-ONLY POLICY
- **NEVER** execute changes before explicit user approval of the assessment report.
- The initial run of this command MUST be limited to observation, comparison, and reporting.
- Proposing code changes in the report is encouraged, but applying them to the codebase is FORBIDDEN until approved.

### 1. Benchmarking
- Identify a **Standard-Bearer** file (the file closest to platform standards).
- Compare **Deviator** files against the Standard-Bearer.

### 2. Metrics
- Use **📉 Lines saved** as the primary metric.
- If lines are added for better consistency, label as **"Quality Trade-off"** (e.g., `-5 lines`).

### 3. Use-Case Context
- Provide a narrative **User Flow** description for every issue (e.g., *"When a user is trying to customize their app appearance..."*).

---

## Managing Exceptions

### Valid Reasons for Exceptions
- **Brand consistency**: Company logo for website link, branded colors in specific places.
- **UX requirement**: Specific interaction pattern that platform doesn't support well.
- **Technical constraint**: Platform limitation requires custom solution.
- **Intentional design**: Unique visual element that defines app identity.

### Invalid Reasons
- "We've always done it this way."
- "It looks slightly better" (subjective).
- "I forgot to use platform component."

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