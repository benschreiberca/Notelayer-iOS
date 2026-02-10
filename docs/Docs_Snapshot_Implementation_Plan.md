# Feature Implementation Plan

**Overall Progress:** `100%`

## TLDR
Implement deterministic docs snapshot tooling and a rollback flow so the phrase "rollback docs snapshot" can be executed reliably to restore markdown docs to this exact baseline.

## Critical Decisions
- Decision 1: Snapshot all first-party markdown files repository-wide, excluding vendored Pods docs and snapshot storage internals.
- Decision 2: Use `manifest.tsv` + `docs.tar.gz` + metadata for exact reproducibility.
- Decision 3: Rollback deletes in-scope docs not present in target snapshot to guarantee exact restoration.
- Decision 4: Rollback auto-creates a safety snapshot before mutating files.

## Tasks

- [x] 🟩 **Step 1: Build Snapshot Tooling**
- [x] 🟩 Add `scripts/docs_snapshot.sh` with `create`, `list`, `verify`, and `rollback` commands.
- [x] 🟩 Implement deterministic snapshot IDs, metadata, and manifest generation.
- [x] 🟩 Implement strict scope filters and hash/mode/size capture.

- [x] 🟩 **Step 2: Add Docs + Governance Wiring**
- [x] 🟩 Add `docs/050-docs-snapshot-runbook.md` with one-command rollback instructions.
- [x] 🟩 Link snapshot runbook from governance and features hub docs.

- [x] 🟩 **Step 3: Create Baseline Snapshot**
- [x] 🟩 Generate baseline snapshot representing current docs arrangement.
- [x] 🟩 Record baseline ID and latest pointer.

- [x] 🟩 **Step 4: Validate Rollback Guarantee**
- [x] 🟩 Perform controlled docs mutation (edit + add in scope).
- [x] 🟩 Execute rollback to baseline snapshot.
- [x] 🟩 Verify hash/mode/size/file-set exactness.

- [x] 🟩 **Step 5: Finalize Tracking + Handoff**
- [x] 🟩 Mark statuses complete and include key commands.
- [x] 🟩 Summarize guarantees and residual operational risks.

## Execution Results

- Baseline pointer file: `.codex/docs-snapshots/baseline`
- Read active baseline ID with: `cat .codex/docs-snapshots/baseline`
- Canonical rollback command: `scripts/docs_snapshot.sh rollback baseline`
- Safety snapshots are auto-generated on every rollback with `pre-rollback-*` labels.

## Verified Command Sequence

```bash
scripts/docs_snapshot.sh create --label "docs-baseline-lock" --baseline
scripts/docs_snapshot.sh verify baseline
scripts/docs_snapshot.sh rollback baseline
scripts/docs_snapshot.sh verify baseline
```
