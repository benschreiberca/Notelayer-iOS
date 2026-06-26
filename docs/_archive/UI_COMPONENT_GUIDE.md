# NoteLayer UI Component Guide

**Last Updated:** January 27, 2026

This document defines the standard UI components used across NoteLayer to ensure visual consistency. When building new features or settings pages, always reuse these components instead of creating custom layouts.

## Core Principles

1. **"Use Native iOS Components"** - Always prefer iOS-standard List, Section, and NavigationLink over custom layouts.
2. **"Zero Custom Headers"** - NEVER create custom section header components. Use native `Section("Header")` syntax.
3. **"Reuse Task Components"** - For task-specific UI (chips, badges), use the shared components below.

---

## Page Layout Pattern

### Settings/Detail Pages (Universal Pattern)

**✅ ALWAYS use this pattern for ALL settings and detail pages:**

```swift
struct MySettingsView: View {
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
            .listStyle(.insetGrouped)  // iOS Settings appearance
            .navigationTitle("My Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

**Reference:** `TaskEditView.swift` - This is the gold standard for all pages.

**❌ NEVER do this:**
- Custom `ScrollView` + `VStack` layouts
- Custom section header components (`SettingsSectionHeader`)
- Manual padding calculations
- Custom card width styling

---

## Reusable Components Library

### 1. Task Display Components

#### `TaskCategoryChip`
**Location:** `Views/Shared/SettingsComponents.swift`  
**Usage:** Display category badges in task cards, nag cards, and detail views.

```swift
TaskCategoryChip(category: category)
    .environmentObject(theme)
```

**Style:**
- Font: `.caption`
- Shape: `Capsule` (fully rounded)
- Background: Category color at 12.5% opacity
- Padding: 10px horizontal, 5px vertical
- Single line, no wrapping

#### `TaskPriorityBadge`
**Location:** `Views/Shared/SettingsComponents.swift`  
**Usage:** Display priority labels in task cards and nag cards.

```swift
TaskPriorityBadge(priority: task.priority)
    .environmentObject(theme)
```

**Style:**
- Font: `.caption`
- Text: "High", "Med", "Low", "Def"
- Color: `textSecondary`
- Single line, fixed size

---

### 2. Action Button Component

#### `PrimaryButtonStyle`
**Location:** `Views/Shared/SettingsComponents.swift`  
**Usage:** All primary action buttons across the app.

```swift
Button("Sign Out") { /* action */ }
    .buttonStyle(PrimaryButtonStyle(isDestructive: true))
    .environmentObject(theme)
```

**Variants:**
- **Standard** (default): Accent color background, white text
- **Destructive** (`isDestructive: true`): Red background (10% opacity), red text

**When to Use:**
- ✅ "Send Code", "Verify", "Sign Out", "Export Data", "Delete Account"
- ✅ Any future primary action in sheets or settings
- ❌ Never use `.borderedProminent` or custom button styles

---

### 3. Card Layouts

#### Task Card (Main List)
**Reference:** `Views/TaskItemView.swift`  
**DO NOT MODIFY** - This is the canonical design.

**Style:**
- Padding: 10px horizontal, 1px vertical
- Corner radius: 12px (continuous)
- Background: `theme.tokens.groupFill`
- Stroke: `theme.tokens.cardStroke` (0.5px)
- Checkbox: 24pt system image, 12px spacing from content

#### Nag Card (Pending Nags)
**Reference:** `Views/RemindersSettingsView.swift` (`NagCardView`)  
**Reuses:** Task card layout with bell icon instead of checkbox.

**Additional Element:**
- Nag details inset: Orange background (5% opacity), 8px corner radius, clock icon

---

## Usage Rules

### Page Layout
- **Always** use `List` + `Section("Header")` for settings/detail pages.
- **Always** use `.listStyle(.insetGrouped)` for iOS Settings appearance.
- **Never** create custom ScrollView + VStack layouts.
- **Never** create custom section header components.

### Buttons
- **Always** use `PrimaryButtonStyle` for primary actions.
- **Always** pass `isDestructive: true` for Sign Out, Delete, or other destructive actions.
- **Never** use `.borderedProminent`, `.bordered`, or inline styling.

### Task Cards
- **Always** reuse `TaskCategoryChip` and `TaskPriorityBadge` for consistency.
- **Always** use the category lookup dictionary for performance.
- **Never** create custom chip layouts or priority styles.

### Theme Tokens
- **Always** use `theme.tokens.cardFill`, `theme.tokens.cardStroke`, and `theme.tokens.groupFill`.
- **Never** hardcode `Color(.secondarySystemBackground)` or custom hex values for cards.

---

## Quick Reference Matrix

| Element | Component | File |
| :--- | :--- | :--- |
| Page Layout | `List { Section("Header") { ... } }` | Native iOS |
| Section Header | Native `Section("Title")` | Native iOS |
| Primary Button | `PrimaryButtonStyle` | `Shared/SettingsComponents.swift` |
| Category Chip | `TaskCategoryChip` | `Shared/SettingsComponents.swift` |
| Priority Badge | `TaskPriorityBadge` | `Shared/SettingsComponents.swift` |
| Task Card (Main) | `TaskItemView` | `Views/TaskItemView.swift` |
| Nag Card | `NagCardView` | `Views/RemindersSettingsView.swift` |

---

## Examples

### Creating a New Settings Page
```swift
struct MySettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                // Simple navigation link
                Section("Features") {
                    NavigationLink {
                        NewFeatureView()
                    } label: {
                        Label("New Feature", systemImage: "star.fill")
                    }
                }
                
                // Action button
                Section("Actions") {
                    Button {
                        performAction()
                    } label: {
                        Text("Perform Action")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("My Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

### Adding a Primary Action Button
```swift
Button {
    performAction()
} label: {
    Text("Perform Action")
}
.buttonStyle(PrimaryButtonStyle())
.disabled(isBusy)
```

### Adding a Destructive Action Button
```swift
Button {
    deleteData()
} label: {
    Text("Delete Data")
}
.buttonStyle(PrimaryButtonStyle(isDestructive: true))
.disabled(isBusy)
```

---

## Enforcement Checklist

Before submitting any new feature or settings page:

### Page Structure
- [ ] Uses `List` wrapper (not ScrollView + VStack)
- [ ] Uses `Section("Header")` syntax (not custom components)
- [ ] Uses `.listStyle(.insetGrouped)` for iOS Settings appearance
- [ ] Uses `.navigationTitle()` and `.navigationBarTitleDisplayMode(.inline)`

### Components
- [ ] All primary action buttons use `PrimaryButtonStyle`
- [ ] All task chips use `TaskCategoryChip`
- [ ] All priority badges use `TaskPriorityBadge`
- [ ] No custom section header components created

### Visual Consistency
- [ ] Card widths match iOS standard (List-managed)
- [ ] Headers match iOS Settings app style
- [ ] Compare with TaskEditView.swift (gold standard)

**Failure to follow this guide will result in visual regressions and inconsistency.**

---

## Migration from Custom Layouts

If you encounter old code using custom layouts, refactor it:

### Before (Custom):
```swift
ScrollView {
    VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            SettingsSectionHeader(title: "Account")
            // custom card with manual padding
        }
    }
    .padding(20)
}
```

### After (iOS Standard):
```swift
List {
    Section("Account") {
        // content rows (List manages layout)
    }
}
.listStyle(.insetGrouped)
```
