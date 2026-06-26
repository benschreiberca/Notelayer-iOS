# PRD Program Overview And Release Summaries

Last Updated: 2026-02-10
Status: Ready For Use

## 1. App Store Release Note (Single Version)

```md
What’s New in Notelayer

- New Experimental Features mode: turn on early features from Gear > Enable Experimental Features.
- Insights is now easier to understand with plain-English labels and clearer chart explanations.
- New voice capture flow with a floating voice button above the tab bar.
- Voice entries now go through a required preview step before saving, so you can edit before anything is added.
- Improved first-time setup with guided onboarding and practical starter categories.
- New project-style task structure with parent tasks and subtasks.
- Improved share capture flow for ChatGPT-first workflows.

Note: New capabilities are controlled through Experimental Features.
```

## 2. PRD Overview (What Users Get)

```md
Notelayer PRD Overview (User Outcome Focus)

PRD 01: Experimental Features Framework
- What it is: A master UI visibility switch in Gear called "Enable Experimental Features."
- What users get: One simple place to opt into experimental UI.
- Affects UI visibility for: Insights, Voice Input, First-Time Onboarding, Project-Based Tasks.

PRD 02: Analytics Natural Language Insights
- What it is: Analytics labels and sections rewritten in plain English.
- What users get: Insights that are understandable, not developer jargon.
- Includes: clear axis labels, chart + data + takeaway summaries.

PRD 03: Analytics Insights Toggle Behavior
- What it is: Insights is shown only when Experimental Features is enabled.
- What users get: Clear and intentional control over Insights visibility.
- Includes: route handling and first-time hint behavior.

PRD 04: Voice Entry Structured Capture
- What it is: Voice parsing into structured tasks.
- What users get: Faster capture from speech with titles/notes/tags prefilled.
- Entry point: floating action button above the bottom tab area.

PRD 05: Voice Entry Preview/Staging
- What it is: Mandatory review/edit stage before any voice tasks are saved.
- What users get: More trust and fewer bad task saves.
- Includes: add/edit/delete/reorder, validation, and save controls.

PRD 06: First-Time User Onboarding
- What it is: Lightweight onboarding (video + cues) with starter category presets.
- What users get: Faster first-run setup and less blank-state confusion.
- Presets are finance-inclusive and non-time-based.

PRD 07: Share to Notelayer (ChatGPT-first)
- What it is: Share-sheet ingestion optimized for ChatGPT text.
- What users get: Faster capture from ChatGPT output into tasks/notes.
- Status: still needs final clarification decisions.

PRD 08: Project-Based Tasks (Parent/Subtasks)
- What it is: Hierarchical task structure for multi-step work.
- What users get: Better organization for projects vs flat task lists.
- Status: still needs final clarification decisions.
```

## 3. Internal Launch Brief (Execution + Rollout)

```md
Notelayer PRD Program Launch Brief

Objective
Deliver a coordinated feature set that improves capture speed, insight clarity, and task structure, while minimizing implementation risk via ordered execution.

Global Visibility Gate
Experimental Features controls UI visibility for:
- Insights
- Voice input
- First-time onboarding UI
- Project-based task UI

Recommended Execution Waves
- Wave 0: Lock unresolved decisions (no coding).
- Wave 1: PRD 01/03 foundation + PRD 04 parser.
- Wave 2: PRD 02 insights UX + PRD 05 staging + PRD 06 onboarding.
- Wave 3: PRD 07 share, then PRD 08 hierarchy (after clarifications).
- Wave 4: integration/regression/consistency validation.

User-Facing Wins
- Easier-to-read Insights
- Safer voice capture with mandatory preview
- Faster onboarding
- ChatGPT share capture
- Parent/subtask project organization

Remaining Decision Blockers
- PRD 01/03: final local-vs-synced conflict policy
- PRD 06: video skip timing + recommended preset default behavior
- PRD 07: mapping/structure-preservation rules
- PRD 08: hierarchy semantics (depth/completion/deletion/counting)

Done Definition
- All wave acceptance checks pass
- UI consistency checks run pre/post for UI changes
- Plan docs and status docs updated
- No unresolved blockers
```

## 4. One Prompt To Execute Everything (Single Chat)

Copy/paste this into a new Codex chat:

```md
Use this file as the only execution orchestrator:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_Unified_Execution_Master_plan.md

And these supporting control docs:
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_Parallel_Execution_Control_Plan.md
- /Users/benmacmini/Documents/Notelayer-iOS/docs/PRD_Parallel_Chat_Launch_Pack.md

Execution mode for this chat:
- Single-chat execution only (no additional chats).
- Follow wave order from the master plan.
- Do not start coding until Wave 0 decisions are locked.
- Run /Users/benmacmini/Documents/Notelayer-iOS/.codex/prompts/ui-consistency.md before and after any UI wave.

Wave behavior:
- Wave 0: decision lock only. If any decision is missing, ask me only those missing items.
- Wave 1: execute PRD 01/03 and PRD 04 in dependency-safe order within this same chat.
- Wave 2: execute PRD 02, PRD 05, and PRD 06 (respect upstream dependencies).
- Wave 3: execute PRD 07 then PRD 08 only after their blockers are resolved.
- Wave 4: integration, regression checks, and plan/doc status updates.

Output contract after every wave:
1. "Wave Complete" summary (what was done).
2. Exact files changed.
3. Any blockers.
4. Next wave that will start.

Safety constraints:
- Never exceed PRD scope.
- If blocked by unresolved requirements, stop and ask only decision questions.
- Keep all progress/status in plan docs updated.

START MASTER EXECUTION
```
