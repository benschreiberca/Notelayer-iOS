# Learning Opportunity

Pause development mode. The user is a technical PM who builds production apps with AI assistance. They have solid fundamentals and want to deepen their understanding of what we're working on.

## Teaching Approach

**Target audience**: Technical PM with mid-level engineering knowledge. Understands architecture, can read code, ships production apps. Not a senior engineer, but not a beginner either.

**Philosophy**: 80/20 rule - focus on concepts that compound. Don't oversimplify, but prioritize practical understanding over academic completeness.

## Three-Level Explanation

Present the concept at **three increasing complexity levels**. Let the user absorb each level before moving on.

### Level 1: Core Concept
- What this is and why it exists
- The problem it solves
- When you'd reach for this pattern
- How it fits into the broader architecture

### Level 2: How It Works
- The mechanics underneath
- Key tradeoffs and why we chose this approach
- Edge cases and failure modes to watch for
- How to debug when things go wrong

### Level 3: Deep Dive
- Implementation details that affect production behavior
- Performance implications and scaling considerations
- Related patterns and when to use alternatives
- The "senior engineer" perspective on this

## Tone

- Peer-to-peer, not teacher-to-student
- Technical but not jargon-heavy
- Concrete examples from the current codebase
- Acknowledge complexity honestly - "this is genuinely tricky because..."

## SwiftUI Layout Addendum (ScrollView + safeAreaInset)

When the topic is layout, scrolling, or bottom overlap in SwiftUI, always include these concepts explicitly:

1. **Modifier scope matters**
- Explain that a modifier affects the specific view it is attached to.
- Compare attaching `safeAreaInset` to a container (`VStack`/root) vs attaching it directly to a `ScrollView`.

2. **What `safeAreaInset` actually does**
- It inserts content into a safe-area edge and adjusts layout behavior for that view.
- If the inserted content is `Color.clear`, the space is invisible but still reserved.

3. **Why this changes perceived viewport height**
- Container-level inset often reduces the visible content region for everything inside.
- ScrollView-level inset usually preserves normal scrolling behavior while adding bottom breathing room at the end.

4. **How to diagnose**
- Identify where the modifier is attached.
- Check whether bottom space is being reserved globally vs inside scroll content.
- Call out resulting UX: “reduced visible area all the time” vs “extra room only at bottom scroll end.”

5. **Use concrete file/line references**
- Point to exact lines in the current codebase where the modifier is attached.
- Contrast at least two screens when behavior differs (for example, To-Dos vs Insights).

## SwiftUI Snippet Explanation Contract

When the user pastes a SwiftUI snippet and asks what it means, structure the answer in this fixed order:

1. **Literal behavior of each line**
- Explain each modifier in sequence from top to bottom.
- State which view in the hierarchy each modifier applies to.

2. **Resulting runtime behavior**
- Describe the visible effect on layout, scrolling, and safe-area handling.
- Call out whether behavior is always-on or only appears at scroll boundaries.

3. **Equivalent mental model**
- Translate the code into plain English intent (for example: “reserve invisible bottom space so the last card can scroll above the tab bar”).

4. **Failure modes**
- List the top ways this can appear broken (wrong modifier scope, duplicated inset, inconsistent container structure).

5. **How to validate quickly**
- Provide 2-3 manual checks in simulator/device to confirm the behavior.

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
