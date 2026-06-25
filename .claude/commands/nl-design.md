# /nl-design — Notelayer Design System Context

You are working with the **Notelayer Design System** — a SwiftUI-first token-based design system targeting iOS, macOS, watchOS, and React web.

Load these files before any design, UI, or component work:

## Files to load

1. `docs/design-system/DS_OVERVIEW.md` — principles, token pipeline, how to use the system
2. `docs/design-system/DS_TOKENS.md` — all token values (Primitive → Semantic → Component)
3. `docs/design-system/DS_THEMES.md` — accent colors, surface styles, modes, wallpapers
4. `docs/design-system/DS_COMPONENTS.md` — component patterns, usage rules, platform variants
5. `docs/design-system/DS_ACCESSIBILITY.md` — accessibility requirements

## Design rules (always enforce)

- **Token pipeline**: Primitive → Semantic → Component. Never skip levels.
- **No hardcoded values**: always use `theme.tokens.*` — never `Color(.systemBackground)` or hex values
- **List + Section pattern**: for all settings/detail pages — never `ScrollView + VStack`
- **PrimaryButtonStyle**: for all primary actions — never `.borderedProminent`
- **Platform variants**: `.insetGrouped` is iOS-only. Mac uses `NavigationSplitView` shell. Watch is list-only.
- **Typography**: 11 defined styles only — DisplayLarge/Medium, HeadingLarge/Medium/Small, BodyLarge/Medium/Small, LabelLarge/Medium/Small, Code
- **Spacing**: xs=4, sm=8, md=16, lg=24, xl=32, xxl=48

## For web/React work

Also load `docs/design-system/DS_WEB_GUIDE.md` — it maps Swift tokens to CSS custom properties and React equivalents.

After loading, confirm: "Design system context loaded." then wait for the task.
