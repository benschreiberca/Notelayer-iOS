# CLAUDE.md — Notelayer

> This file is auto-loaded by Claude Code at the start of every session.
> It is the single source of orientation for all AI-assisted work on this repo.

---

## Slash Commands — Quick Reference

| You're about to… | Type this first |
|---|---|
| Work on anything Notelayer | `/nl-context` |
| Do any UI or design work | `/nl-design` |
| Work on the web repo (React) | `/nl-web` |
| Start a new exploration/idea | `/nl-explore` |
| Write a formal PRD | `/nl-prd` |
| Write release content | `/nl-release` |

**After the slash command — just talk normally.** Don't type it again mid-session.

---

## Ground Rules (Always Apply)

- **Backend:** Firebase/Firestore. Never Supabase. Never Supabase.
- **Tabs:** iOS has 2 visible tabs — Todos and Insights. Notes tab hidden since v1.5.0.
- **Source of truth order:** Current Swift code → v1.5.0 commit `b1aee8f` → PRD docs → other docs
- **Stale — do not trust:** `Native_Parity_Map.md`, `Native_Status.md`, `Native_Runbook.md`, `Project_Implementation_Plan.md` (all describe a Supabase architecture that was never built)
- **Gated features:** Voice capture and subtask hierarchy exist in code but are not accessible in the App Store build (`experimentalFeaturesEnabled` has no Settings UI)
- **Design system:** Always use `docs/design-system/DS_COMPONENTS.md` for component patterns. Never hardcode colors or invent layout patterns.
- **No custom layouts:** Always `List + Section` for settings/detail pages. Never `ScrollView + VStack`.
- **Tokens only:** Always `theme.tokens.*` — never `Color(.systemBackground)` or hex values.

---

## Repo Map

```
docs/
  product/          Feature inventory, PRDs, roadmap, repo registry
  design-system/    DS_* files — published design system (tokens, themes, components)
  architecture/     Backend, auth, analytics, dev setup, git strategy
  operations/       Release checklists, CI, App Store assets
  releases/         Per-version release content (changelog, notes, App Store, marketing)
  governance/       Audit, standards, testing
  lab/              Explorations not ready for main — LAB_INDEX.md tracks them
  _archive/         Old docs — historical only, do not maintain
.claude/commands/   Slash command definitions
```

---

## Canonical Files (Read These First for Any Task)

| Task | File |
|------|------|
| What features exist | `docs/product/FEATURE_INVENTORY.md` |
| What platforms are planned | `docs/product/MULTIPLATFORM_PRD.md` |
| Which repos exist | `docs/product/REPOS.md` |
| Design tokens | `docs/design-system/DS_TOKENS.md` |
| Component patterns | `docs/design-system/DS_COMPONENTS.md` |
| Theme system | `docs/design-system/DS_THEMES.md` |
| Backend/auth | `docs/architecture/BACKEND_AND_AUTH.md` |
| Bug tracking | `docs/BUGS.md` (create if missing) |

---

## Active Branches / Worktrees

| Branch | Purpose |
|--------|---------|
| `main` | Stable — always shippable |
| `docs/audit` | Doc consolidation (active) |
| `claude/hopeful-rubin-9xouzo` | PRD 09 planning (merge or close) |

*Update this table when new worktrees are added.*

---

## Three Sizes of Work

**🐛 Bug / small tweak** → `fix/name` branch → fix → push → PR → done. No doc system needed.

**💡 Idea / exploration** → `/nl-explore` → `explore/name` branch → lab doc → decide → promote to PRD or drop.

**🚀 Feature** → PRD exists → `feature/name` branch → build → update `FEATURE_INVENTORY.md` → `/nl-release` → PR.

---

## Swift Codebase Key Files

| File | Role |
|------|------|
| `Data/DesignSystem.swift` | Token system (994 lines) — source of truth for all design values |
| `Data/ThemeManager.swift` | Theme configuration (994 lines) |
| `Data/LocalStore.swift` | App state singleton (1,562 lines) |
| `Views/TodosView.swift` | Core feature (1,886 lines) |
| `Views/RootTabsView.swift` | Tab shell — `visibleTabs = [.todos, .insights]` |
| `Services/FirebaseBackendService.swift` | Firebase/Firestore CRUD |
| `Services/VoiceTaskParser.swift` | Local NLP — NOT an AI/LLM API |
| `NotelayerShareExtension/ShareViewController.swift` | Share extension (implemented) |
