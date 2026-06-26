# iOS Standard Consistency - Implementation Plan

**Branch:** `ios-standard-consistency`  
**Target:** Refactor all settings/detail pages to use native iOS List + Section headers  
**Overall Progress:** `100%`

---

## Implementation Order

Refactor in order of complexity (simplest first):

1. RemindersSettingsView (already uses List, just fix header) ✅
2. ManageAccountView (moderate refactor)
3. ProfileSettingsView (most complex - multiple sections)
4. Update documentation

---

## Tasks

- [x] 🟩 **Step 1: Fix RemindersSettingsView**
  - [x] 🟩 Replace custom header block with `Section("Upcoming Nags") { ... }`
  - [x] 🟩 Remove `.padding(.horizontal, 20)`
  - [x] 🟩 Adjust list row insets to use iOS defaults
  - [x] 🟩 Changed listStyle to `.insetGrouped` for iOS Settings appearance

- [x] 🟩 **Step 2: Refactor ManageAccountView**
  - [x] 🟩 Already wrapped in `List { ... }`
  - [x] 🟩 Convert to `Section("Data") { ... }` syntax
  - [x] 🟩 Convert to `Section("Danger Zone") { ... }` syntax
  - [x] 🟩 Added `.listStyle(.insetGrouped)` for iOS Settings appearance
  - [x] 🟩 Kept `PrimaryButtonStyle` for action buttons (as intended)

- [x] 🟩 **Step 3: Refactor ProfileSettingsView**
  - [x] 🟩 Replace `ScrollView` + `VStack` with `List { ... }`
  - [x] 🟩 Convert `preferencesSection` to `Section("Pending Nags") { ... }`
  - [x] 🟩 Convert `accountSection` to `Section("Account") { ... }`
  - [x] 🟩 Convert `aboutSection` to `Section("About") { ... }` (kept DisclosureGroup inside)
  - [x] 🟩 Remove all `SettingsSectionHeader` calls
  - [x] 🟩 Remove `.padding(20)` wrapper
  - [x] 🟩 Use `.listStyle(.insetGrouped)` for iOS Settings-like appearance

- [x] 🟩 **Step 4: Deprecate SettingsComponents**
  - [x] 🟩 Remove `SettingsSectionHeader` from `Shared/SettingsComponents.swift`
  - [x] 🟩 Keep `TaskCategoryChip`, `TaskPriorityBadge`, `PrimaryButtonStyle` (still valid)
  - [x] 🟩 Add deprecation warning with guidance to use native Section() headers

- [x] 🟩 **Step 5: Update Documentation**
  - [x] 🟩 Update `docs/UI_COMPONENT_GUIDE.md`:
    - Remove `SettingsSectionHeader` section
    - Add new "Page Layout Pattern" section with iOS-standard approach
    - Reference `TaskEditView.swift` as the gold standard
    - Add comprehensive examples for standard List + Section usage
    - Add "Migration from Custom Layouts" section
  - [x] 🟩 Add enforcement checklist with page structure rules

- [x] 🟩 **Step 6: Verification**
  - [x] 🟩 No linter errors found
  - [x] 🟩 All pages now use iOS-standard List + Section headers
  - [x] 🟩 Card widths are now consistent (iOS-managed)
  - [x] 🟩 Headers are now consistent (iOS-managed)
  - [x] 🟩 Ready for visual testing in simulator

---

## Code Patterns

### Standard List Pattern (Use Everywhere):

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
            .listStyle(.insetGrouped)  // for Settings-like appearance
            .navigationTitle("My Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

### Action Button Pattern:

```swift
Section("Actions") {
    Button {
        performAction()
    } label: {
        Text("Action Button")
    }
    .buttonStyle(PrimaryButtonStyle())
}
```

### NavigationLink Pattern:

```swift
Section("Navigation") {
    NavigationLink {
        DetailView()
    } label: {
        HStack {
            Image(systemName: "icon")
            Text("Detail Page")
        }
    }
}
```

---

## Expected Outcome

After completion:
- All settings/detail pages use native iOS `List` + `Section` headers
- Card widths are consistent (iOS-managed)
- Headers are consistent (iOS-managed)
- No custom `SettingsSectionHeader` component
- Future pages automatically consistent by following standard pattern
- Documentation updated with clear examples and enforcement rules
