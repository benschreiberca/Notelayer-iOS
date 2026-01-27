# NoteLayer UI Component Guide

**Last Updated:** January 27, 2026

This document defines the standard UI components used across NoteLayer to ensure visual consistency. When building new features or settings pages, always reuse these components instead of creating custom layouts.

## Core Principle
**"Zero Custom Layouts"** - If a component exists in this guide, use it. If you need something new, extract it from an existing view and add it here first.

---

## Components Library

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

### 2. Settings Components

#### `SettingsSectionHeader`
**Location:** `Views/Shared/SettingsComponents.swift`  
**Usage:** All section headers in settings pages.

```swift
SettingsSectionHeader(title: "Pending Nags")
```

**Style:**
- Font: `.caption.weight(.semibold)`
- Color: `.secondary`
- Padding: 4px leading

**When to Use:**
- ✅ "Account", "Pending Nags", "About" sections
- ✅ Any future settings groups
- ❌ Never use custom Text() for headers

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

### Headers
- **Always** use `SettingsSectionHeader` for section titles.
- **Never** create inline `Text()` with custom font/color for headers.

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
| Section Header | `SettingsSectionHeader` | `Shared/SettingsComponents.swift` |
| Primary Button | `PrimaryButtonStyle` | `Shared/SettingsComponents.swift` |
| Category Chip | `TaskCategoryChip` | `Shared/SettingsComponents.swift` |
| Priority Badge | `TaskPriorityBadge` | `Shared/SettingsComponents.swift` |
| Task Card (Main) | `TaskItemView` | `Views/TaskItemView.swift` |
| Nag Card | `NagCardView` | `Views/RemindersSettingsView.swift` |

---

## Examples

### Creating a New Settings Section
```swift
VStack(alignment: .leading, spacing: 8) {
    SettingsSectionHeader(title: "New Feature")
    
    NavigationLink {
        NewFeatureView()
    } label: {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundColor(theme.tokens.accent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Feature Name")
                    .font(.subheadline.weight(.semibold))
                Text("Feature description")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(theme.tokens.cardFill)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.tokens.cardStroke, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
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

## Enforcement

Before submitting any new feature or settings page:
1. **Audit Headers**: All section headers must use `SettingsSectionHeader`.
2. **Audit Buttons**: All primary actions must use `PrimaryButtonStyle`.
3. **Audit Cards**: All task-like cards must reuse `TaskCategoryChip` and `TaskPriorityBadge`.
4. **Visual Test**: Compare side-by-side with the main To-Do list to ensure pixel-perfect parity.

**Failure to follow this guide will result in visual regressions and inconsistency.**
