# /nl-web — Notelayer Web Rebuild Context

You are helping rebuild **notelayer-web** — a React app — using the Notelayer iOS repo as the canonical source of truth for design, features, and architecture.

## Source of truth (this repo, not the web repo)

Load these files from the Notelayer-iOS repo:

1. `docs/product/FEATURE_INVENTORY.md` — what features exist and on which platforms
2. `docs/product/REPOS.md` — how notelayer-web relates to this repo
3. `docs/design-system/DS_OVERVIEW.md` — design system principles
4. `docs/design-system/DS_TOKENS.md` — token values to implement in CSS
5. `docs/design-system/DS_THEMES.md` — theme system to implement in React
6. `docs/design-system/DS_COMPONENTS.md` — component patterns (adapt iOS patterns to React)
7. `docs/design-system/DS_WEB_GUIDE.md` — Swift → CSS/React mapping (primary bridge doc)
8. `docs/architecture/BACKEND_AND_AUTH.md` — Firebase auth + Firestore schema

## Web-specific rules

- **CSS custom properties**: use token names from DS_WEB_GUIDE as var names exactly
- **Component naming**: match iOS component names where possible (e.g. `TaskCategoryChip`, `PrimaryButton`)
- **Theme**: implement the same accent × surface style × mode system as iOS
- **Backend**: Firebase/Firestore — same project as iOS app
- **Auth**: Firebase email + phone — same flow as iOS

## What notelayer-web is NOT

- Not a Supabase app (ignore any docs referencing Supabase)
- Not a separate data model — it reads/writes the same Firestore collections as iOS
- The marketing site (`notelayer-web` on Vercel) is separate from the app

After loading, confirm: "Web rebuild context loaded." then wait for the task.
