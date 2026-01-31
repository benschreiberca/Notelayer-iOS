# Prompt Crafting Feedback (Notelayer)

Below is targeted guidance on how your prompts helped or hurt, and how to tighten them for faster, more reliable outcomes on this app.

## What You Did Well
- **Clear urgency and constraints**: You stated “don’t change anything else” and “fix asap,” which is crucial.
- **Concrete symptoms**: You provided exact user-visible problems (no divider line, drop rejected).
- **Logs**: Sharing the console output surfaced the missing UTType export quickly.

## Where the Prompts Could Be Stronger
- **Specify exact acceptance criteria up front**: e.g., “Divider shows while hovering; drop inserts between groups; bottom drop inserts at end.”
- **Call out non‑regressions explicitly**: e.g., “task drag to bottom must still work.”
- **Define test context**: device vs simulator, OS version, build config.
- **Pin scope**: “Only touch `TodosView.swift` + `CategoryManagerView.swift`. No refactors.”
- **Demand rollback rules**: “If a change breaks task drag, revert that part immediately.”

## High‑Impact Prompt Template (Stealable)
> **Goal:** Fix category group drag reorder so divider appears and drop works.  
> **Must work:** iPhone device, iOS 17+, debug build.  
> **Acceptance criteria:**  
> 1) Divider shows when hovering between groups.  
> 2) Drop inserts group at hovered divider.  
> 3) Task drag/drop (including bottom‑of‑group) continues to work.  
> **Constraints:** Only touch `TodosView.swift` + `CategoryManagerView.swift`.  
> **Do not change:** task drag logic, data model, or backend sync.  
> **If a change breaks task drag, revert that part immediately.**  
> **Output:** explain why the fix works + list files touched.

## Why This Matters
SwiftUI drag/drop has a lot of implicit behavior. Clear acceptance criteria and explicit non‑regressions reduce churn, and a tight scope prevents collateral damage.
