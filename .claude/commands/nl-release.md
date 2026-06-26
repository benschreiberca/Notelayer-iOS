# /nl-release — Release Content Templates

Load `docs/releases/RELEASES.md` for the full format guide.

Then create the four release content files for the target version by running:

```
mkdir docs/releases/v[VERSION]
```

And creating these four files using the templates in `RELEASES.md`:

| File | Audience | Format | Constraint |
|------|----------|--------|------------|
| `CHANGELOG.md` | Developers | Bullet list, technical | None |
| `RELEASE_NOTES.md` | Users | Plain English, benefit-led | ~200 words |
| `APP_STORE.md` | App Store | Two sections: short note + full description | Short: 4000 chars max |
| `MARKETING_BRIEF.md` | Content/social | Angles, hooks, copy variants | None |

Ask me for the version number and a rough list of what shipped, then generate all four files.
