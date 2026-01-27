# iOS Standard Consistency - Implementation Plan

**Branch:** `ios-standard-consistency`  
**Target:** Refactor all settings/detail pages to use native iOS List + Section headers  
**Overall Progress:** `0%`

---

## Implementation Order

Refactor in order of complexity (simplest first):

1. RemindersSettingsView (already uses List, just fix header)
2. ManageAccountView (moderate refactor)
3. ProfileSettingsView (most complex - multiple sections)
4. Update documentation

---

## Tasks

- [ ] 🟥 **Step 1: Fix RemindersSettingsView**
  - [ ] 🟥 Replace custom header block with `Section("Upcoming Nags") { ... }`
  - [ ] 🟥 Remove `.padding(.horizontal, 20)`
  - [ ] 🟥 Adjust list row insets to use iOS defaults
  - [ ] 🟥 Test card width matches iOS standard

- [ ] 🟥 **Step 2: Refactor ManageAccountView**
  - [ ] 🟥 Wrap entire view in `List { ... }`
  - [ ] 🟥 Create `Section("Data") { ... }` for export functionality
  - [ ] 🟥 Create `Section("Danger Zone") { ... }` for Sign Out and Delete Account
  - [ ] 🟥 Remove custom padding and card styling
  - [ ] 🟥 Keep `PrimaryButtonStyle` for action buttons

- [ ] 🟥 **Step 3: Refactor ProfileSettingsView**
  - [ ] 🟥 Replace `ScrollView` + `VStack` with `List { ... }`
  - [ ] 🟥 Convert `preferencesSection` to `Section("Pending Nags") { ... }`
  - [ ] 🟥 Convert `accountSection` to `Section("Account") { ... }`
  - [ ] 🟥 Convert `aboutSection` to `Section("About") { ... }` (keep DisclosureGroup inside)
  - [ ] 🟥 Remove all `SettingsSectionHeader` calls
  - [ ] 🟥 Remove `.padding(20)` wrapper
  - [ ] 🟥 Use `.listStyle(.insetGrouped)` for iOS Settings-like appearance

- [ ] 🟥 **Step 4: Deprecate SettingsComponents**
  - [ ] 🟥 Remove `SettingsSectionHeader` from `Shared/SettingsComponents.swift`
  - [ ] 🟥 Keep `TaskCategoryChip`, `TaskPriorityBadge`, `PrimaryButtonStyle` (still valid)
  - [ ] 🟥 Add comment: "Use native Section() headers instead of custom components"

- [ ] 🟥 **Step 5: Update Documentation**
  - [ ] 🟥 Update `docs/UI_COMPONENT_GUIDE.md`:
    - Remove `SettingsSectionHeader` section
    - Add new section: "Use Native iOS List + Section Headers"
    - Reference `TaskEditView.swift` as the canonical pattern
    - Add example code for standard List + Section usage
  - [ ] 🟥 Add enforcement rule: "NEVER create custom header components"

- [ ] 🟥 **Step 6: Verification**
  - [ ] 🟥 Visual inspection: All cards same width across all pages
  - [ ] 🟥 Visual inspection: All headers match iOS standard style
  - [ ] 🟥 Test light/dark mode
  - [ ] 🟥 Test with multiple themes
  - [ ] 🟥 Test navigation flows (Profile → Pending Nags, Profile → Manage Account)
  - [ ] 🟥 Check linter errors

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
