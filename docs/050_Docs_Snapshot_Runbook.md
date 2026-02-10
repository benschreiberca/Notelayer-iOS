# Docs Snapshot Runbook

Last Updated: 2026-02-09
Scope: Markdown documentation snapshots and exact rollback

## Purpose

Guarantee that docs can be restored to an exact known state (file set, paths, content, and file modes).

## One-Line Operator Commands

- Create snapshot: `scripts/docs_snapshot.sh create --label "<name>"`
- Create baseline snapshot: `scripts/docs_snapshot.sh create --label "docs-baseline" --baseline`
- List snapshots: `scripts/docs_snapshot.sh list`
- Verify against baseline: `scripts/docs_snapshot.sh verify baseline`
- Roll back to baseline: `scripts/docs_snapshot.sh rollback baseline`

## Phrase Mapping

When you say: `rollback docs snapshot`

Operational execution is:

`/Users/benmacmini/Documents/Notelayer-iOS/scripts/docs_snapshot.sh rollback baseline`

## Exactness Guarantee

Rollback to a snapshot performs these actions:

1. Creates a pre-rollback safety snapshot automatically.
2. Deletes in-scope markdown files that are not present in the target snapshot.
3. Restores all target snapshot markdown files.
4. Re-applies recorded file modes.
5. Verifies exactness (file set + SHA-256 + size + mode).

If verification fails, command exits non-zero with mismatch details.

## Scope Rules

Included:

- All `docs/**/*.md` files.

Excluded:

- `.codex/docs-snapshots/**`

## Recovery Path

Because rollback auto-creates a safety snapshot, rollback itself is reversible:

1. Run `scripts/docs_snapshot.sh list`.
2. Find the newest snapshot with purpose `pre-rollback`.
3. Roll back to that snapshot by ID:
   `scripts/docs_snapshot.sh rollback <snapshot-id>`

## Baseline Tracking

- Baseline pointer is stored at: `.codex/docs-snapshots/baseline`
- Latest pointer is stored at: `.codex/docs-snapshots/latest`

Use `scripts/docs_snapshot.sh list` to view IDs and flags.
