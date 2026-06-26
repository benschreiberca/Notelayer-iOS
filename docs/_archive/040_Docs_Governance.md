# Docs Governance

Last Updated: 2026-02-09
Scope: markdown docs in `docs/`

## Purpose

Define one consistent naming and navigation system for all project docs.

## Naming Contract

- Format: `<Feature_Or_Domain>_<Optional_Scope>_<Doc_Type>[ _YYYY_MM_DD].md`
- Style: `Title_Snake_Case` (each token starts uppercase, underscore separators)
- Location: all project docs live under `docs/`
- Meta docs keep numeric prefix for top-of-list ordering.

## Canonical Doc Type Suffixes

- `Requirements_Summary`
- `Implementation_Plan`
- `Fix_Plan`
- `Issue_Report`
- `Implementation_Summary`
- `Progress_Tracking`
- `Validation_Guide`
- `Architecture_Review`
- `Assessment_Report`
- `Release_Notes`
- `Release_Checklist`
- `Quick_Start`
- `Setup_Guide`
- `Runbook`
- `Status_Report`
- `Reference_Guide`
- `Notes`

## Required Meta Docs (Top Of List)

- `000_Docs_Start_Here.md`
- `010_Docs_Features_Hub.md`
- `020_Docs_Feature_Implementation_Plans_Index.md`
- `030_Docs_Explorations_Index.md`
- `040_Docs_Governance.md`
- `050_Docs_Snapshot_Runbook.md`
- `060_Project_Changelog_Index.md`
- `070_Project_Feature_Master_Plan_Index.md`

## Linking Rules

- Every new feature doc must be linked in `010_Docs_Features_Hub.md`.
- Every plan doc must be linked in `020_Docs_Feature_Implementation_Plans_Index.md`.
- Every exploration/requirements/review doc must be linked in `030_Docs_Explorations_Index.md`.
- Every summary doc should link to its related plan doc.

## Snapshot Protection

- Snapshot tool: `scripts/docs_snapshot.sh`
- Canonical rollback command: `scripts/docs_snapshot.sh rollback baseline`
- Runbook: [050_Docs_Snapshot_Runbook.md](050_Docs_Snapshot_Runbook.md)

## Prompt + Skill Consistency Requirement

- Slash-command prompts and skills that create docs must enforce this naming contract.
- If a generated filename does not match the contract, rename before finalizing and update links/indexes.
