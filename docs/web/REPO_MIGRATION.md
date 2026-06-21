# Moving `notelayer-web/` to Its Own Repository

The Chrome extension code lives at `notelayer-web/` inside the `notelayer-ios` monorepo. This guide moves it to `benschreiberca/notelayer-web` **preserving full git history**.

---

## Prerequisites

- You have `git` installed locally
- You have push access to `github.com/benschreiberca/notelayer-web`
- The `notelayer-web` GitHub repo exists and is empty (or has only a default README)

---

## Step 1 — Clone the iOS repo locally (if not already)

```bash
git clone https://github.com/benschreiberca/notelayer-ios.git
cd notelayer-ios
```

---

## Step 2 — Extract the `notelayer-web/` subtree into a standalone branch

This rewrites history so that only commits that touched `notelayer-web/` are kept, with paths relative to the `notelayer-web/` root:

```bash
git subtree split --prefix=notelayer-web -b web-only
```

This creates a local branch called `web-only` containing the full history of `notelayer-web/` as if it were its own repo.

---

## Step 3 — Push to `notelayer-web`

```bash
git push https://github.com/benschreiberca/notelayer-web.git web-only:main
```

---

## Step 4 — Verify

```bash
git clone https://github.com/benschreiberca/notelayer-web.git
cd notelayer-web
ls   # should show: extension/ packages/ scripts/ docs/ package.json etc.
git log --oneline -10  # should show web-specific commit history
```

---

## Step 5 — Clean up (optional)

Delete the temporary local branch:

```bash
cd ../notelayer-ios
git branch -D web-only
```

---

## After Migration

Once the code is in `notelayer-web`:

1. **Update CI/CD** — if you have any GitHub Actions in `notelayer-ios` that build the extension, move or duplicate them to `notelayer-web/.github/workflows/`
2. **Update the dev branch** — `claude/notelayer-chrome-extension-0pwV8` exists in `notelayer-ios`; after migration, future work branches from `notelayer-web/main`
3. **Keep `notelayer-ios`** — the iOS Xcode project stays where it is; only the web sub-folder moves

---

## Alternative: Keep as Monorepo

If you prefer to keep both in `notelayer-ios`, that's fine for now. The only trade-offs are:
- Chrome Web Store CI requires referencing a specific subdirectory in your build
- Contributors to the extension see unrelated iOS commits in the log
- The GitHub repo name may confuse extension-only contributors

You can always migrate later — the `git subtree split` command works at any point.
