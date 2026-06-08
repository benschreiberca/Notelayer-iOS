# Implementation Plan: Nav Simplification, Experimental Graduation, Onboarding Overhaul & Insights Deep Links

Status: Not Started
Last Updated: 2026-06-06
Owner: TBD
Source PRD: this document (sections "PRD Summary" below)

**Overall Progress:** `0%`

Progress legend: ⬜ Not started · 🟨 In progress · 🟩 Done · 🟥 Blocked

| Feature | Status | Progress |
|---|---|---|
| F1 — Remove Notes tab | ⬜ | 0% |
| F2 — Experimental features always-on | ⬜ | 0% |
| F3 — Onboarding overhaul | ⬜ | 0% |
| F4 — Insights drilldown deep links | ⬜ | 0% |

---

## How To Use This Document (for the implementer)

- Implement **one feature at a time, in order: F1 → F2 → F3 → F4.** Each is independent and shippable on its own.
- After finishing each numbered step, change its `⬜` to `🟩` and update the percentage in the table above and the **Overall Progress** line.
- Do **not** start the next feature until the current feature's "Validation" checklist fully passes.
- Build the app after every feature with: `xcodebuild -scheme Notelayer -destination 'platform=iOS Simulator,name=iPhone 15' build` (or open in Xcode and ⌘B). The build MUST succeed before marking a feature done.
- **Golden rule for performance (read before touching any view):** Do not add work to a SwiftUI `body`. Do not add new `@Published` observations that fire on scroll. Do not add `.onChange` handlers that run heavy logic. Reuse the existing caching pattern (`recomputeTaskCache()` in `TodosView`). When in doubt, copy an existing pattern in the same file rather than inventing a new one.

---

## PRD Summary (context)

Four changes to Notelayer iOS (SwiftUI app under `ios-swift/Notelayer/Notelayer/`):

1. **F1** — Hide the "Notes" tab so the tab bar shows only **To-Dos** and **Insights**. Keep all Notes code intact.
2. **F2** — Remove the "Experimental Features" toggle; treat `experimentalFeaturesEnabled` as permanently `true` for everyone.
3. **F3** — Replace the existing 3-step onboarding (`WelcomeView`) with a cleaner 4-step flow inspired by Duolingo/Noom (value-first, one-idea-per-screen, progress shown, celebratory finish). Replayable from the gear menu for all users.
4. **F4** — Make two Insights drilldown lists tappable so a tap jumps the user back into the To-Dos tab at the right place (category view for a category row; task editor for an oldest-open-task row).

### Design system rules (apply to ALL UI work, F3 + F4)
- Backgrounds: `theme.tokens.screenBackground` + `ThemeBackground(configuration: theme.configuration)`.
- Cards: `RoundedRectangle(cornerRadius: 12, style: .continuous)` filled with `.ultraThinMaterial`, OR reuse the existing `InsetCard` component.
- Primary action color: `theme.tokens.accent`. Secondary text: `theme.tokens.textSecondary` (or `.secondary`).
- Buttons: primary = `.borderedProminent`; row taps = `Button { } label: { }` with `.buttonStyle(.plain)`.
- Icons: SF Symbols only. No custom image assets except the existing `AppHeaderLogo`.
- Tinting: `.tint(theme.tokens.accent)`.

---

## FEATURE 1 — Remove "Notes" Tab

**Goal:** Tab bar shows exactly To-Dos and Insights. No Notes code deleted.

**File:** `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`

### Steps
- [ ] ⬜ **F1.1** In `RootTabsView`, find the computed property `visibleTabs` (currently around lines 36–41). Replace its entire body so it always returns exactly two tabs in this order:
  ```swift
  private var visibleTabs: [AppTab] {
      [.todos, .insights]
  }
  ```
  Do not remove the `insightsEnabled` property or the `AppTab` enum cases. Only change what `visibleTabs` returns.
- [ ] ⬜ **F1.2** Do NOT modify `NotesView.swift`, the `Note` model in `LocalStore.swift`, the `.notes` enum case, or the `switch selectedTab` block (the `.notes:` case stays — it is simply unreachable from the tab bar).

### Validation (must all pass before F1 is done)
- [ ] ⬜ Build succeeds.
- [ ] ⬜ Launch app. Tab bar shows exactly two pills: **To-Dos** and **Insights**. No "Notes" pill.
- [ ] ⬜ Tapping each tab still works; no crash; default tab is To-Dos.
- [ ] ⬜ Scrolling in To-Dos and Insights is as smooth as before (no new lag).

### Performance / risk notes
- This is a pure subtraction (one fewer view in a `ForEach`). It can only reduce work per frame, never increase it. Zero performance risk.

---

## FEATURE 2 — Experimental Features Always On

**Goal:** Every user gets all features; remove the toggle and the now-pointless banners/branches. The simplest, lowest-risk change is to make the read accessor return `true` and remove the UI affordance — NOT to rip out every `if` branch (leaving the branches is safe because they now always take the `true` path).

**Files:**
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift`
- `ios-swift/Notelayer/Notelayer/Views/Shared/AppTabHeaderComponents.swift`
- `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift`
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift`

### Steps
- [ ] ⬜ **F2.1** In `LocalStore.swift`, find the computed property (around line 102):
  ```swift
  var experimentalFeaturesEnabled: Bool {
      experimentalFeaturesPreference.isEnabled
  }
  ```
  Change it to:
  ```swift
  var experimentalFeaturesEnabled: Bool {
      true
  }
  ```
  Leave everything else in `LocalStore` (the `experimentalFeaturesPreference` property, the `setExperimentalFeaturesEnabled` method, the UserDefaults keys, the `experimentalFeaturesDidChange` notification) untouched. They become inert but harmless.
- [ ] ⬜ **F2.2** In `AppTabHeaderComponents.swift`, inside `AppHeaderGearMenu`'s `Menu { }` block, **delete the entire `Toggle(...)` block** that toggles experimental features (currently lines ~50–62, the one whose label uses `systemImage: "flask"`). Delete only that `Toggle`.
- [ ] ⬜ **F2.3** In the same `Menu`, find the `if store.experimentalFeaturesEnabled { Button { ... "Onboarding Guide" ... } }` block (lines ~42–48). **Remove the `if store.experimentalFeaturesEnabled` wrapper** so the "Onboarding Guide" button is always shown. Keep the button itself exactly as-is.
- [ ] ⬜ **F2.4** In `RootTabsView.swift`, remove the two banner states that only existed to explain the toggle:
  - Delete the `@State private var showInsightsHintBanner` and `@State private var showLockedInsightsMessage` declarations.
  - In the `.overlay(alignment: .top) { ... }` block, delete the two `if showLockedInsightsMessage { ... }` and `if showInsightsHintBanner { ... }` branches (lines ~177–203). If this leaves the overlay empty, delete the whole `.overlay(alignment: .top)` modifier.
  - Delete the `.animation(..., value: showInsightsHintBanner)` modifier line.
  - Delete the helper methods that are now unused: `refreshInsightsHintBanner()`, and the body of `transitionToDefaultListView` (this whole method can be deleted — see next bullet). Also delete the now-unused `bannerRow(...)` helper.
  - In `handleExperimentalVisibilityChange(triggeredByUser:)`: since `insightsEnabled` is now always `true`, the `if !insightsEnabled { ... }` block is dead. Simplify the method body to just:
    ```swift
    private func handleExperimentalVisibilityChange(triggeredByUser: Bool) {
        checkAndShowWelcome()
    }
    ```
    Then delete `transitionToDefaultListView(withGenie:)` and the `isGenieTransitionActive` state plus its uses in the `InsightsView()` case `.scaleEffect/.opacity/.offset` modifiers (replace those three modifiers with nothing — render `InsightsView()` plainly).
  - Remove the `.onReceive(... .experimentalFeaturesDidChange ...)` block and the `.onChange(of: store.experimentalFeaturesPreference)` block (they no longer do anything meaningful).
  - In `checkAndShowWelcome()`, remove the line `guard store.experimentalFeaturesEnabled else { return }` (it's always true now).
  - In the `.onReceive(... .openOnboardingRequested ...)` block, remove the `guard insightsEnabled else { return }` line.
  - **Caution:** after these edits, re-read the file top-to-bottom and delete any property/method that is now unreferenced (the Swift compiler will warn; fix every "unused" warning by removing the dead code). Do not leave half-deleted references.
- [ ] ⬜ **F2.5** In `InsightsView.swift`, in `dataCoverageCard` (line ~317), change the title text from `"Notelayer Data Insights (Experimental Feature)"` to `"Notelayer Data Insights"`.

### Validation
- [ ] ⬜ Build succeeds with **zero new warnings** about unused variables/methods.
- [ ] ⬜ Gear menu no longer shows "Experimental Features" toggle.
- [ ] ⬜ Gear menu shows "Onboarding Guide" for a fresh install (toggle removed, still visible).
- [ ] ⬜ Insights tab is always present and opens normally.
- [ ] ⬜ No "Enable this feature in Experimental Features" or "Insights is available in Experimental Features" banners ever appear.
- [ ] ⬜ Voice button and Insights drilldowns all work.
- [ ] ⬜ Scrolling unchanged.

### Performance / risk notes
- Returning a constant from `experimentalFeaturesEnabled` removes a property read per call — neutral to positive.
- Removing the genie-transition `.scaleEffect/.offset/.opacity` modifiers removes per-frame animation work from the Insights container — small positive.
- Risk: dead-code removal can break compilation if a reference is missed. Mitigation: rely on the compiler; fix every warning before marking done.

---

## FEATURE 3 — Onboarding Overhaul

**Goal:** Replace the 3-step flow (`video | cues | presets`) with a 4-step flow (`welcome | categories | taskEntry | done`). Same sheet presentation, same `WelcomeCoordinator` trigger, replayable from gear menu.

**Primary file:** `ios-swift/Notelayer/Notelayer/Views/WelcomeView.swift` (rewrite the view body and steps; keep the `OnboardingPreset` struct and its presets — they are reused).

**Secondary (already wired, verify only):** `RootTabsView.swift` presents `WelcomeView` via `.sheet(isPresented: $showWelcome)`; the gear menu posts `.openOnboardingRequested`. After F2, the onboarding guide is always available. No new wiring needed beyond what F2 produced — just verify.

### Reference principles (from Duolingo/Noom teardowns — keep the flow ≤4 screens, <90s)
- Value before commitment; one idea per screen; show progress; explain "why" inline; celebrate at the end; never block on push-notification permission.

### Steps
- [ ] ⬜ **F3.1** In `WelcomeView.swift`, replace the `OnboardingStep` enum with:
  ```swift
  private enum OnboardingStep: Int, CaseIterable {
      case welcome, categories, taskEntry, done
  }
  ```
  Keep the existing `OnboardingPreset` struct and its three presets unchanged. Add a fourth selectable option for "Start blank" handled in the UI (do not add it to `OnboardingPreset.all`; instead add a separate `@State private var startBlank = false` OR represent blank as `selectedPresetID == "blank"` — choose the `"blank"` id approach and guard `selectedPreset` to fall back to `.everydayBalance` only for category lookup, and skip applying categories when blank).
- [ ] ⬜ **F3.2** Add state to `WelcomeView`:
  ```swift
  @State private var step: OnboardingStep = .welcome
  @State private var firstTaskText: String = ""
  @State private var didAddFirstTask = false
  ```
  Remove the old `canSkipVideo` state and the old `.onAppear` timer that set it.
- [ ] ⬜ **F3.3** Add a progress indicator subview shown on steps 2–4 (not on welcome). Use simple dots:
  ```swift
  private var progressDots: some View {
      HStack(spacing: 6) {
          ForEach(OnboardingStep.allCases, id: \.self) { s in
              Capsule()
                  .fill(s.rawValue <= step.rawValue ? theme.tokens.accent : Color.secondary.opacity(0.25))
                  .frame(width: s == step ? 22 : 8, height: 8)
                  .animation(.easeInOut(duration: 0.2), value: step)
          }
      }
  }
  ```
- [ ] ⬜ **F3.4** **Step 1 — Welcome.** Build `welcomeStep`:
  - Centered `AppHeaderLogo(size: 72)`.
  - Headline `Text("Your tasks. Actually organised.").font(.title2.bold())`.
  - Sub-line `Text("Takes about 60 seconds to get set up.").font(.subheadline).foregroundStyle(.secondary)`.
  - Primary button `Button("Get Started") { step = .categories }.buttonStyle(.borderedProminent).tint(theme.tokens.accent)`.
  - No skip button on this screen.
- [ ] ⬜ **F3.5** **Step 2 — Categories.** Build `categoriesStep` by adapting the existing `presetsStep`:
  - Show `progressDots` at top.
  - Heading `Text("What does your life look like?").font(.title3.bold())`.
  - Sub-copy `Text("Pick a starting point — you can always customise later.")`.
  - Keep the three existing preset cards exactly as styled in the current `presetsStep` (accent border + checkmark on selection).
  - Add a fourth card "Start blank" with id `"blank"`, no category preview line, same selection styling.
  - Single primary button whose label is `"Start with \(selectedPreset.name)"` when a preset is chosen, or `"Start blank"` when blank is selected. On tap:
    - If blank: do not apply categories.
    - Else: `store.applyOnboardingPresetCategories(selectedPreset.makeCategories())` (existing method).
    - Then `step = .taskEntry`.
  - Remove the old "Keep Current Categories" button.
- [ ] ⬜ **F3.6** **Step 3 — Add first task.** Build `taskEntryStep`:
  - `progressDots` at top.
  - Heading `Text("Add something on your mind").font(.title3.bold())`.
  - Sub-copy `Text("Even one task. You can add more anytime.")`.
  - A `TextField("e.g. Call the dentist", text: $firstTaskText)` styled inside an `.ultraThinMaterial` rounded rectangle (cornerRadius 12) — match the app's input look; do NOT import or reuse `TaskInputView` directly (it carries extra dependencies) — a styled `TextField` is sufficient and lower-risk.
  - A primary button `Button("Add Task") { addFirstTask() }` disabled when `firstTaskText.trimmingCharacters(in: .whitespaces).isEmpty`.
  - A small secondary text link `Button("Skip for now") { step = .done }.font(.footnote).foregroundStyle(.secondary)`.
  - `addFirstTask()` implementation:
    ```swift
    private func addFirstTask() {
        let trimmed = firstTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addTask(title: trimmed)   // VERIFY exact LocalStore API name before use — see F3.7
        didAddFirstTask = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { step = .done }
    }
    ```
- [ ] ⬜ **F3.7** **Verify the task-creation API.** Before writing `addFirstTask`, grep `LocalStore.swift` for the existing add-task method (e.g. `func addTask` / `func createTask`). Use the EXACT signature that the rest of the app uses to create a plain top-level task with just a title. If it requires more parameters (categories, priority), pass sensible defaults (no categories, default priority) matching how `TaskInputView` calls it. Do not invent an API.
- [ ] ⬜ **F3.8** **Step 4 — Done.** Build `doneStep`:
  - `progressDots` (all filled).
  - `Image(systemName: "checkmark.circle.fill").font(.system(size: 56)).foregroundStyle(theme.tokens.accent)` with a scale-in spring on appear.
  - Heading `Text("You're set up.").font(.title2.bold())`.
  - Sub-line: `Text(didAddFirstTask ? "Your first task is waiting." : "Your categories are ready.")`.
  - Primary button `Button("Let's go") { finishOnboarding() }.buttonStyle(.borderedProminent)`.
- [ ] ⬜ **F3.9** Update the `body`: keep the `NavigationStack { ZStack { background; ScrollView { switch step ... } } }` shape. Change the toolbar:
  - Remove the trailing "Next" button logic (navigation is now via in-content buttons).
  - Keep a leading "Skip" button ONLY on `.categories` and `.taskEntry`? No — per PRD, skip is only on Step 3. Remove the toolbar "Skip" entirely; the only skip is the "Skip for now" link in `taskEntryStep`.
  - `navigationTitle` can be set to `""` or removed; the welcome step provides its own heading.
- [ ] ⬜ **F3.10** Keep `finishOnboarding()` exactly as the existing implementation (`onDismiss(); dismiss()`). The `onDismiss` closure (set in `RootTabsView`) already calls `welcomeCoordinator.markWelcomeAsSeen()`.
- [ ] ⬜ **F3.11** Delete the now-unused `videoStep`, `cuesStep`, `cueRow(...)`, and `canSkipVideo` references. Remove the old `presetsStep` only after `categoriesStep` fully replaces it. Fix all compiler warnings for unused code.
- [ ] ⬜ **F3.12** **Replay correctness.** When launched via the gear menu ("Onboarding Guide" → posts `.openOnboardingRequested` → `RootTabsView` sets `showWelcome = true`), the same `WelcomeView` is shown from `step = .welcome`. This is acceptable per PRD (replay restarts the flow). No extra code needed. Verify the gear-menu path resets to step `.welcome` each time (it does, because `WelcomeView` is recreated per sheet presentation, so `@State step` re-initialises to `.welcome`).

### Validation
- [ ] ⬜ Build succeeds, no unused-code warnings.
- [ ] ⬜ Fresh install (delete app first): onboarding auto-appears at Welcome step within ~0.5s.
- [ ] ⬜ All 4 steps navigate forward via their buttons; progress dots advance.
- [ ] ⬜ Selecting a preset and finishing creates those categories (check Manage Categories).
- [ ] ⬜ Selecting "Start blank" creates no new categories.
- [ ] ⬜ Adding a first task in Step 3 results in that task appearing in To-Dos after finishing.
- [ ] ⬜ "Skip for now" in Step 3 advances to Done with sub-line "Your categories are ready."
- [ ] ⬜ "Let's go" dismisses and lands in To-Dos; onboarding does NOT reappear on next launch.
- [ ] ⬜ Gear menu → "Onboarding Guide" replays the flow from Welcome.
- [ ] ⬜ Light + dark mode both render correctly (theme tokens used throughout).
- [ ] ⬜ Sheet scrolls smoothly; no jank on step transitions.

### Performance / risk notes
- The sheet is presented on demand and torn down on dismiss — it adds no cost to the main To-Dos/Insights scroll paths.
- Use `ScrollView` (not `List`) and avoid per-frame timers (the old video timer is removed). Step transitions use cheap `withAnimation`.
- Risk: wrong task-creation API. Mitigation: F3.7 mandates verifying the real signature first.

---

## FEATURE 4 — Insights Drilldown Deep Links → Main Experience

**Goal:** Two drilldown lists become tappable:
- **4a** "Tasks Left per Category" rows (in `InsightsCategoryDetailView`) → switch to To-Dos in **Category** mode, scrolled to that category.
- **4b** "Oldest Open Tasks" rows (in `InsightsOldestOpenTasksDetailView`) → switch to To-Dos and open that task's editor.

**Mechanism:** `NotificationCenter` (matches existing `OpenTaskFromNotification` and `openOnboardingRequested` patterns). **Reuse the EXISTING `OpenTaskFromNotification` for 4b** — `TodosView` already listens for it (lines ~222–229) and opens the editor by `taskId`. Only 4a needs a new notification.

**Files:**
- `ios-swift/Notelayer/Notelayer/Data/LocalStore.swift` (one new Notification.Name)
- `ios-swift/Notelayer/Notelayer/Views/InsightsView.swift` (make rows tappable, post notifications)
- `ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift` (observe new notification, switch tab)
- `ios-swift/Notelayer/Notelayer/Views/TodosView.swift` (handle category jump: switch mode + scroll)

### Steps
- [ ] ⬜ **F4.1** In `LocalStore.swift`, in the existing `extension Notification.Name { ... }` (line ~18), add:
  ```swift
  static let navigateToCategoryInTodos = Notification.Name("Notelayer.Navigation.CategoryInTodos")
  ```
  (4b reuses `NSNotification.Name("OpenTaskFromNotification")` — do not add a new one for tasks.)
- [ ] ⬜ **F4.2** **4b — Oldest Open Tasks rows.** In `InsightsView.swift`, inside `InsightsOldestOpenTasksDetailView`, the "Oldest Open Tasks" `DataRowsSection` currently renders static rows from `snapshot.oldestOpenTasksDrilldown`. Replace that `DataRowsSection` usage with an inline `Section` whose rows are tappable buttons:
  ```swift
  Section("Oldest Open Tasks") {
      if snapshot.oldestOpenTasksDrilldown.isEmpty {
          Text("All caught up. No open tasks waiting right now.")
              .foregroundStyle(.secondary)
      } else {
          ForEach(snapshot.oldestOpenTasksDrilldown) { openTask in
              Button {
                  NotificationCenter.default.post(
                      name: NSNotification.Name("OpenTaskFromNotification"),
                      object: nil,
                      userInfo: ["taskId": openTask.taskId]
                  )
              } label: {
                  HStack {
                      Text(openTask.title).lineLimit(1)
                      Spacer(minLength: 8)
                      Text("\(openTask.ageDays)d").monospacedDigit().foregroundStyle(.secondary)
                      Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                  }
              }
              .buttonStyle(.plain)
          }
      }
  }
  ```
  Keep the existing "Showing the 50 oldest..." footer Section below it unchanged.
- [ ] ⬜ **F4.3** **4a — Category rows.** In `InsightsView.swift`, inside `InsightsCategoryDetailView`, the "Tasks Left per Category" `DataRowsSection` renders rows from `snapshot.categoryStats`. Replace it with a tappable `Section`:
  ```swift
  Section("Tasks Left per Category") {
      ForEach(snapshot.categoryStats) { stat in
          Button {
              NotificationCenter.default.post(
                  name: .navigateToCategoryInTodos,
                  object: nil,
                  userInfo: ["categoryId": stat.categoryId]
              )
          } label: {
              HStack {
                  if let icon = stat.categoryIcon { Text(icon) }
                  Text(stat.categoryName).lineLimit(1)
                  Spacer(minLength: 8)
                  Text("\(stat.openCount)").monospacedDigit().foregroundStyle(.secondary)
                  Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
              }
          }
          .buttonStyle(.plain)
      }
  }
  ```
  (Verify `stat.categoryIcon` is the correct optional property name; if it's non-optional, drop the `if let`.)
- [ ] ⬜ **F4.4** **Dismiss the Insights nav stack on tap (both 4a and 4b).** Because the taps happen inside `navigationDestination` detail views pushed onto `InsightsView`'s `NavigationStack`, posting a notification alone leaves the Insights stack pushed. After switching tabs in `RootTabsView` (next step), the Insights stack is off-screen so this is cosmetically fine; **do not** add programmatic pop logic in this pass (keep change surface minimal). Document this as accepted behavior: returning to Insights shows the last drilldown until the user navigates back. (If the user later wants auto-pop, that's a follow-up.)
- [ ] ⬜ **F4.5** In `RootTabsView.swift`, add ONE new observer near the existing `.onReceive(... .openOnboardingRequested ...)`:
  ```swift
  .onReceive(NotificationCenter.default.publisher(for: .navigateToCategoryInTodos)) { note in
      if let categoryId = note.userInfo?["categoryId"] as? String {
          pendingCategoryJump = categoryId
          withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = .todos }
      }
  }
  ```
  Add state `@State private var pendingCategoryJump: String? = nil`. Pass it into `TodosView`:
  - Change the `TodosView(isSearchActive: $isSearchActive)` call in the `switch selectedTab` to `TodosView(isSearchActive: $isSearchActive, categoryJump: $pendingCategoryJump)`.
  - **Note on 4b:** `OpenTaskFromNotification` is already handled inside `TodosView`, but `TodosView` only receives it while it is in the hierarchy. Since both tabs' views may not all be alive, add a sibling observer in `RootTabsView` to force the tab switch first:
    ```swift
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenTaskFromNotification"))) { _ in
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = .todos }
    }
    ```
    (TodosView's own observer then opens the editor. Posting once delivers to both observers.)
- [ ] ⬜ **F4.6** In `TodosView.swift`:
  - Add input: `@Binding var categoryJump: String?` (add to the struct's properties). Update any `#Preview`/call sites if present (there is one call site in `RootTabsView` from F4.5; also check `RootTabsView`'s `.notes`/screenshot seeders don't construct `TodosView` — grep to confirm).
  - Wrap the category-mode `ScrollView`/scaffold in a `ScrollViewReader` and tag each category group with `.id("catjump:\(category.id)")`. The category groups are rendered in `TodoCategoryModeView` (a separate private struct), so the cleanest minimal approach is: when `categoryJump` is set, (1) set `viewMode = .category`, (2) post the id down to `TodoCategoryModeView` via a second binding OR via an `@State` the scaffold reads. **Lowest-risk approach:** add `@Binding var scrollTargetCategoryId: String?` to `TodoCategoryModeView`, wrap its `LazyVStack` in `ScrollViewReader { proxy in ... }`, add `.id("catjump:\(category.id)")` to each `categoryGroupCard(...)` call, and add `.onChange(of: scrollTargetCategoryId) { id in if let id { withAnimation { proxy.scrollTo("catjump:\(id)", anchor: .top) }; scrollTargetCategoryId = nil } }`.
  - In `TodosView`, add `.onChange(of: categoryJump) { id in if let id { viewMode = .category; /* forward to category mode */ categoryScrollTarget = id; categoryJump = nil } }` where `categoryScrollTarget` is a new `@State` passed as `scrollTargetCategoryId` binding into `TodoCategoryModeView`.
  - **Do not** add any work to `body` beyond passing bindings. The scroll happens once, triggered by `onChange`, not per frame.
- [ ] ⬜ **F4.7** Confirm `InsightsCategoryDetailView` and `InsightsOldestOpenTasksDetailView` are `private struct`s in `InsightsView.swift` — the notification posts work regardless of access level since `NotificationCenter` is global. No access-level changes needed.

### Validation
- [ ] ⬜ Build succeeds, no warnings.
- [ ] ⬜ Insights → Category Detail: each "Tasks Left per Category" row shows a chevron and is tappable.
- [ ] ⬜ Tapping a category row switches to the To-Dos tab, in Category view mode, scrolled so that category is visible near the top.
- [ ] ⬜ Insights → Oldest Open Tasks: each row shows a chevron and is tappable.
- [ ] ⬜ Tapping an oldest-task row switches to To-Dos and opens that exact task's editor sheet.
- [ ] ⬜ Tapping a row for a task/category that still exists never crashes; a stale id (deleted task) is a silent no-op (the existing `OpenTaskFromNotification` handler already guards with `first(where:)`).
- [ ] ⬜ Charts and non-deep-linked rows (calendar export, feature usage) are unchanged.
- [ ] ⬜ Scrolling in both Insights detail lists and the To-Dos category view is smooth; the added `ScrollViewReader` does not introduce lag (it wraps existing content only).

### Performance / risk notes
- `ScrollViewReader` wrapping an existing `LazyVStack` adds negligible overhead and does not change cell recycling. `.id(...)` on existing rows is cheap.
- The scroll action runs once per tap via `onChange`, then clears the target — no repeated work.
- Reusing `OpenTaskFromNotification` avoids new state-management surface in `TodosView`.
- Risk: passing a new `@Binding` to `TodosView` requires updating its single call site (F4.5). Mitigation: grep for `TodosView(` to find all call sites before building.

---

## Cross-Cutting Validation (run once, after all four features)
- [ ] ⬜ Full clean build succeeds; zero new warnings.
- [ ] ⬜ Cold launch on simulator + one physical device: no hang, tabs responsive.
- [ ] ⬜ Smooth-scroll sanity in To-Dos (all 4 view modes) and Insights (overview + each drilldown) — compare against pre-change feel; must be equal or better. (Ref: `docs/Low_Risk_Responsiveness_Optimization_Implementation_Plan.md`.)
- [ ] ⬜ Light and dark mode visual pass.
- [ ] ⬜ Onboarding fresh-install + replay both work.
- [ ] ⬜ Deep links both work and never crash on stale ids.
- [ ] ⬜ Update this file's status table + Overall Progress to 100% and set Status: Complete.

## Notes for the implementer
- Grep before you edit: confirm exact property/method names (`addTask`, `categoryIcon`, `TodosView(` call sites) rather than assuming.
- One feature per commit/PR keeps review and rollback simple.
- If any step's assumption turns out wrong (API name, property optionality), STOP and re-grep; do not guess.
