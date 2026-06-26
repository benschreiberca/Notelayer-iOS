---
title: App Store Assets
last_updated: 2026-06-26
status: active
scope: notelayer-ios
group: operations
tags: [app-store, screenshots, metadata, assets]
related: [RELEASE_CHECKLIST.md, CI_AND_DISTRIBUTION.md]
---

# App Store Assets

Screenshot guide, metadata structure, and asset locations.

---

## Asset Locations

App Store assets live **outside the git repo** at:
```
/Users/bens/Notelayer/App-Icons-&-screenshots/
```

Do not commit screenshots or demo videos to the repo.

**Key folders:**
```
App-Icons-&-screenshots/
  NoteLayer-AppIcon.icon/          # SVG sources
  AppIcons/Assets.xcassets/        # Exported iOS icon sizes
  AppIcons/appstore.png            # 1024×1024 App Store icon
  Screenshots for App Store/       # Finalized screenshots
    screenshot-1-todos-list.png
    screenshot-2-sign-in.png
    screenshot-3-task-edit.png
    screenshot-4-category-view.png
    screenshot-5-appearance.png
    screenshot-6-priority-view.png
    gesture-demo-trimmed-v2.mp4
```

---

## Required Screenshot Sizes

| Device | Dimensions | Required |
|--------|-----------|---------|
| iPhone 6.7" (15 Pro Max) | 1290 × 2796 | Yes |
| iPhone 6.1" (15) | 1179 × 2556 | Yes |
| iPhone 5.5" (8 Plus) | 1242 × 2208 | Yes |
| iPad 12.9" (if submitting iPad) | 2048 × 2732 | Optional |

Minimum 5 screenshots per device size. Maximum 10.

---

## Automated Screenshot Generation

**Target:** `NotelayerScreenshotTests`

```bash
xcodebuild test \
  -workspace ios-swift/Notelayer/Notelayer.xcworkspace \
  -scheme NotelayerScreenshotTests \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro Max"
```

See `docs/_archive/AUTOMATED_SCREENSHOT_USAGE.md` for full setup.

Screenshots are generated programmatically and then moved to the asset folder for review before upload.

---

## Screenshot Content Guidelines

Each screenshot should show a distinct value proposition:

1. **Todos list** — clean task view, category chips visible
2. **Task creation / edit** — shows priority, due date, categories
3. **Insights overview** — charts and analytics
4. **Category view** — category-filtered task list
5. **Appearance / themes** — shows theming capability

Caption text: keep under 30 characters. Plain English. No marketing jargon.

---

## App Store Metadata

**App Name:** Notelayer  
**Subtitle:** Tasks, Captured Fast (30 char max)  
**Category:** Productivity  
**Subcategory:** Task Management

**What's New text:** Written per-release — see `docs/releases/vX.Y.Z/APP_STORE.md`. Max 4000 characters.

**Full Description:** Lives in `docs/releases/` — `APP_STORE.md` contains both What's New and Full Description sections. Max 4000 characters each.

**Keywords:** task manager, to-do list, productivity, reminders, categories, insights, focus (update per release as needed, 100 char total limit)

**Support URL:** Set to current support channel.  
**Privacy Policy URL:** `docs/operations/PRIVACY_POLICY.md` is the source; the published URL must be live before App Store submission.

---

## App Icon

Source SVG is in the asset folder. Exported at all required sizes via Xcode asset catalog (`ios-swift/Notelayer/Notelayer/Assets.xcassets/AppIcon.appiconset/`).

The 1024×1024 App Store icon must not have rounded corners — Apple applies them automatically.
