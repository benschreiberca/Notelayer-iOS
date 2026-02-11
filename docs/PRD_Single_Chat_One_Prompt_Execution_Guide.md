# PRD Single-Chat One-Prompt Execution Guide

Last Updated: 2026-02-10
Mode: Single chat, single prompt

## What You Personally Do

1. Open one Codex chat.
2. Copy the **Single Prompt** below and paste it.
3. Send one message: `START MASTER EXECUTION`.

That is all.

## Single Prompt (Copy/Paste Into One Chat)

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

When I send `START MASTER EXECUTION`, begin with Wave 0 immediately.
```

## How This Works In Practice

- This is not true parallelism. It is a controlled single-thread pipeline.
- You avoid managing multiple chats.
- You still preserve dependency order and reduce rework.

## Simple Commands You Can Use In That One Chat

- `START MASTER EXECUTION`
- `CONTINUE`
- `PAUSE`
- `RESUME`
- `SHOW BLOCKERS`
- `SHOW CHANGED FILES`
- `NEXT WAVE`

## Recommended First Message After Pasting Prompt

`START MASTER EXECUTION`

## Notes

- If you later want true parallel speed, switch to multi-chat lanes.
- For clarity and low overhead, this single-chat mode is the easiest operator workflow.
