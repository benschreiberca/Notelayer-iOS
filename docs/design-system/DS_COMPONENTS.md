---
title: Design System — Components
last_updated: 2026-06-25
status: active
scope: all-platforms
group: design-system
tags: [components, patterns, ios, mac, web, published]
related: [DS_TOKENS.md, DS_THEMES.md, DS_ACCESSIBILITY.md]
source_of_truth_for: [notelayer-ios, notelayer-web]
---

# DS Components

Component patterns, usage rules, and platform variants. This is the implementation guide — it tells you how to build UI that conforms to the design system.

Gold standard reference: `Views/TaskEditView.swift` — every page pattern decision made here is correct.

---

## Page Layout — Universal Pattern

### Settings and Detail Pages (iOS)

```swift
struct MyView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("First Section") {
                    // content rows
                }
                Section("Second Section") {
                    // content rows
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

**Rules:**
- ✅ Always: `List { Section("Header") { ... } }`
- ✅ Always: `.listStyle(.insetGrouped)` for iOS Settings appearance
- ✅ Always: `.navigationTitle()` + `.navigationBarTitleDisplayMode(.inline)`
- ❌ Never: `ScrollView + VStack` layouts
- ❌ Never: Custom section header components
- ❌ Never: Manual padding calculations

> ⚠️ **Platform note:** `.insetGrouped` is iOS-only. On Mac, use `NavigationSplitView` + `List` without `.insetGrouped`. On Watch, use `List` only.

### Mac Shell (Planned — PRD 09)

```swift
NavigationSplitView {
    // Sidebar: views, categories, filters
} detail: {
    // Main content: task list or detail
}
```

---

## Components

### PrimaryButtonStyle

**File:** `Views/Shared/SettingsComponents.swift`

```swift
// Standard
Button("Perform Action") { action() }
    .buttonStyle(PrimaryButtonStyle())

// Destructive
Button("Delete Data") { deleteData() }
    .buttonStyle(PrimaryButtonStyle(isDestructive: true))
    .disabled(isBusy)
```

| Variant | Background | Text |
|---------|-----------|------|
| Standard | `interactivePrimary` | `textOnAccent` |
| Destructive | `interactiveDestructive` at 10% opacity | `interactiveDestructive` |

- ✅ Use for: Sign Out, Delete, Export, Verify, Send Code, all primary actions
- ❌ Never: `.borderedProminent`, `.bordered`, inline color styling

---

### TaskCategoryChip

**File:** `Views/Shared/SettingsComponents.swift`

```swift
TaskCategoryChip(category: category)
    .environmentObject(theme)
```

| Property | Value |
|----------|-------|
| Font | `.caption` |
| Shape | `Capsule` (fully rounded) |
| Background | Category color at 12.5% opacity |
| Padding | 10pt horizontal, 5pt vertical |
| Overflow | Single line, no wrapping |

---

### TaskPriorityBadge

**File:** `Views/Shared/SettingsComponents.swift`

```swift
TaskPriorityBadge(priority: task.priority)
    .environmentObject(theme)
```

| Priority | Label |
|----------|-------|
| High | "High" |
| Medium | "Med" |
| Low | "Low" |
| Deferred | "Def" |

Font: `.caption`. Color: `textSecondary`. Fixed size, single line.

---

### InsetCard

**File:** `Views/Shared/InsetCard.swift`

```swift
InsetCard {
    // content
}
.environmentObject(theme)
```

| Property | Value |
|----------|-------|
| Background | `theme.tokens.groupFill` |
| Border | `theme.tokens.cardStroke` at 0.5pt |
| Corner radius | 12pt continuous |
| Padding | 10pt horizontal, 1pt vertical |

---

### TaskItemView (Task Card)

**File:** `Views/TaskItemView.swift` — **DO NOT MODIFY**. Canonical task card design.

| Property | Value |
|----------|-------|
| Checkbox | 24pt system image, 12pt from content |
| Card padding | 10pt horizontal, 1pt vertical |
| Corner radius | 12pt continuous |
| Background | `theme.tokens.groupFill` |
| Stroke | `theme.tokens.cardStroke` at 0.5pt |

---

### Data Row (Drilldown / Analytics)

Standard row contract for all data-heavy drilldown views (Insights, analytics). One pattern only — no per-section variants.

```swift
// Conceptual — implement as DataRowView
DataRowView(
    primary: "Tasks Left",       // required, left-aligned
    secondary: "This week",      // optional, below primary
    trailingValue: "12"          // optional, right-aligned
)
```

**Three allowed row types:**

| Type | Columns |
|------|---------|
| Value Row | Primary + trailing value |
| Value + Secondary Row | Primary + secondary + trailing value |
| Empty State Row | Single supporting message |

**Prohibited:**
- No per-section padding tweaks
- No value alignment changes (always right-aligned trailing)
- No duplicate semantics in trailing + secondary
- No custom wrapper cards inside `List` sections

**Current Insights sections using this pattern:**
Tasks Left per Category, Calendar Export by Category, Most Used Features, Least Used Features, Most Active Hours, Least Active Hours, Oldest Open Tasks, Unused, Underused, Used.

---

### Bottom Clearance (iOS Floating Tab)

Prevents the floating pill tab bar from obscuring bottom content.

```swift
// Apply to the scrolling container (ScrollView or List), not the root view
.safeAreaInset(edge: .bottom) {
    Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
}
```

**Values (from `RootTabsView.swift`):**

| Token | Value |
|-------|-------|
| `tabRowHeight` | 56pt |
| `contentBottomSpacerHeight` | `tabRowHeight * 2` = 112pt |
| `tabBottomPadding` | 12pt |

**Rules:**
- ✅ Apply to `ScrollView` or `List` that owns content
- ✅ Use `AppBottomClearance.contentBottomSpacerHeight` — one token, everywhere
- ❌ Do not apply to the root non-scrolling container
- ❌ Do not introduce screen-specific spacer constants
- ❌ Do not mix multiple competing bottom spacers on one screen

**Validation:** Last card must be fully visible above the tab pill at max scroll. Check on both small (SE) and large (Pro Max) simulators.

---

## Theme Token Usage Rules

```swift
// ✅ Correct
.background(theme.tokens.cardFill)
.foregroundColor(theme.tokens.textPrimary)
.overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.tokens.cardStroke, lineWidth: 0.5))

// ❌ Wrong
.background(Color(.secondarySystemBackground))
.foregroundColor(.primary)
.background(Color(hex: "#F5F5F5"))
```

| Token | Use |
|-------|-----|
| `theme.tokens.cardFill` | Card/InsetCard backgrounds |
| `theme.tokens.cardStroke` | Card borders (use at 0.5pt) |
| `theme.tokens.groupFill` | Section/group backgrounds |
| `theme.tokens.textPrimary` | Primary text |
| `theme.tokens.textSecondary` | Supporting/metadata text |
| `theme.tokens.accent` | Accent color — buttons, highlights |

---

## Enforcement Checklist

Before any new view:

- [ ] Uses `List + Section("Header")` (not ScrollView + VStack)
- [ ] Uses `.listStyle(.insetGrouped)` (iOS) or NavigationSplitView (Mac)
- [ ] Uses `PrimaryButtonStyle` for all primary actions
- [ ] Uses `TaskCategoryChip` for category display
- [ ] Uses `TaskPriorityBadge` for priority display
- [ ] No hardcoded colors — only `theme.tokens.*`
- [ ] Bottom clearance applied if screen has floating tab
- [ ] Platform variant noted if behavior differs (iOS vs Mac vs Watch)
