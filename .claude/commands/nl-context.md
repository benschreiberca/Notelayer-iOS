# /nl-context — Notelayer Session Context Loader

You are working on **Notelayer**, a SwiftUI task and notes app for iOS, Mac, and Watch.

Load and internalize the following files as your working context for this session. Read each one before responding to any task.

## Files to load (in order)

1. `docs/product/REPOS.md` — the Notelayer repo universe; know which repo is which
2. `docs/product/FEATURE_INVENTORY.md` — ground-truth feature list for all platforms
3. `docs/product/PRODUCT_OVERVIEW.md` — product vision, PRD index, open decisions
4. `docs/governance/GOVERNANCE.md` — doc standards, canonical hierarchy, what to trust

## Ground rules for this session

- **Source of truth**: current Swift code > v1.5.0 commit `b1aee8f` > PRD docs > other docs
- **Stale docs**: do not trust `Native_Parity_Map.md`, `Native_Status.md`, `Native_Runbook.md`, `Project_Implementation_Plan.md` — they describe a Supabase architecture that was never built
- **Backend**: Firebase/Firestore. Not Supabase. Not Supabase. Never Supabase.
- **Tabs**: iOS has 2 visible tabs (Todos, Insights). Notes tab hidden since v1.5.0.
- **Experimental flag**: `experimentalFeaturesEnabled` exists in code but has no Settings UI. Voice capture and subtask hierarchy are in code but not accessible in the App Store build.
- **Design system**: always use `docs/design-system/DS_COMPONENTS.md` for component patterns. Never hardcode colors or invent layout patterns.

## After loading

Confirm: "Notelayer context loaded. Ready." then wait for the task.
