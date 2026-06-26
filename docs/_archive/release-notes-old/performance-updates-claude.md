# Release Notes: performance-updates-claude
**Date**: 2026-04-11
**Base**: main
**Run type**: Branch

---

## Branch Summary

A focused performance and render-efficiency pass targeting the SwiftUI view update pipeline. No new features. No behavior changes. All user-visible effects are improvements in responsiveness.

### What Changed

**VoiceStateStore extraction (`Data/VoiceStateStore.swift` — new file)**
Voice recording and staging state (`isRecording`, `isVoiceStagingPresented`, `stagingDrafts`, `sourceTranscript`) was removed from `LocalStore` and moved into a new isolated `VoiceStateStore` singleton. Before this, every voice state change (start recording, stop recording, stage drafts) published on `LocalStore`, causing all 14+ views subscribed to `LocalStore` to redraw — including every task row. `VoiceStateStore` handles its own UserDefaults persistence using the same app group logic. Views that previously read from `store.isVoiceRecording` or `store.isVoiceStagingPresented` were updated to reference `voiceStore` instead: `RootTabsView`, `VoiceCaptureSheet`, `VoiceStagingView`.

**TodosView task cache (`Views/TodosView.swift`)**
The doing/done task split was previously computed inline in every `body` render: `splitTasksByCompletion(store.tasks)` ran on every `LocalStore` publish, regardless of whether `tasks` actually changed. Replaced with `@State private var cachedDoingTasks` and `@State private var cachedDoneTasks`, updated only via `.onChange(of: store.tasks)` and `.onChange(of: store.experimentalFeaturesPreference)`. Also moved `store.sortedCategories` (which sorts the categories array each call) to a single `let sortedCategories` at the top of body instead of calling it 4 times in the TabView initializers.

**Mode view grouping — direct body computation (no @State cache)**
The four mode views (`TodoListModeView`, `TodoPriorityModeView`, `TodoCategoryModeView`, `TodoDateModeView`) previously cached their grouping dictionaries in `@State` and updated them via `.onChange(of: tasks)`. `.onChange` fires *after* body renders — so marking a task done caused: render with stale cache (task still visible in "doing") → `.onChange` fires → `recomputeCache()` → second render (task now correctly moved). This was the visible lag on task complete/restore. Removed all `@State` caches and `recomputeCache()` functions; groupings are now computed directly as `let` constants at the top of each `body`. The computation is O(n) dict building and takes microseconds for typical list sizes.

**Subtask lookup O(n²) → O(n) (`TodoGroupTaskList`)**
`store.subtasks(for: taskId)` was called inside a `ForEach` loop, making each call filter the entire tasks array. Pre-builds a `[String: [Task]]` dictionary before the `ForEach` — one pass over tasks, then O(1) lookup per row.

**LazyView for non-default tabs**
SwiftUI's page `TabView` eagerly instantiates all page views at render time. Priority, Category, and Date mode views were wrapped in a `LazyView` wrapper (`init(_ build: @autoclosure @escaping () -> Content)`), deferring their creation until the user first navigates to that tab.

**NSDataDetector caching (`Views/TaskEditView.swift`)**
`detectedURLs` was a computed property that created a new `NSDataDetector` (regex compilation) on every body render of TaskEditView. Changed to a `static let linkDetector` (compiled once, shared across all instances) and a `@State private var detectedURLs` updated only via `onAppear` and `.onChange(of: taskNotes)`.

**InsightsView debounce (`Views/InsightsView.swift`)**
`refreshSnapshot()` — which runs a full `InsightsAggregator.buildSnapshot()` — was triggered on every `store.$tasks` and `store.$categories` publish with no debounce. When rapidly toggling tasks, this ran the full aggregation on each individual toggle. Added `.debounce(for: .milliseconds(300), scheduler: RunLoop.main)` to both publishers; rapid bursts collapse into a single rebuild after 300ms of inactivity.

**Body modifier chain split (`Views/TodosView.swift`)**
The main TodosView navigation content had 18+ chained modifiers on a single view, causing the Swift type-checker to time out at line 355. Sheets were moved to be applied on the `NavigationStack` result in `body`, and behavioral modifiers (onReceive, onAppear, onDisappear, onChange) remain on the inner VStack content. Split passes the type-checker without affecting behavior.

**Equatable conformance (`Data/Models.swift`)**
`Task` and `Category` gain `Equatable` conformance (synthesized by the compiler). Required for `.onChange(of:)` to compile on arrays of these types.

### What Was Left Out of Scope

- Removing `@StateObject private var store = LocalStore.shared` from mode views — they need it for write operations (`completeTask`, `restoreTask`, `reorderTasks`, etc.). Eliminating the subscription would require passing all mutations as closures, a larger and riskier refactor.
- Moving grouping/filtering to a background queue — not necessary at current task list sizes; the operations are sub-millisecond.
- InsightsView snapshot partial updates — full rebuild on window change is acceptable; partial update logic would add significant complexity.

---

## Changelog Entry

### Changed
- Task complete/restore now takes effect immediately on screen — removed a render-cycle lag caused by `@State` caches in mode views that updated via `.onChange` (after body render) rather than directly in body
- Voice recording and staging state moved to isolated `VoiceStateStore`; task list views no longer redraw on voice state changes
- Priority, Category, and Date view modes are now lazily instantiated — only created when the user first navigates to them, reducing startup work
- `sortedCategories` computed once per `TodosView` render cycle instead of 4 times
- `NSDataDetector` in task editor is now a shared static instance; URL detection in task notes only re-runs when the notes field actually changes
- Insights analytics snapshot is now debounced (300ms) after task or category changes, preventing full aggregation on every task toggle

### Fixed
- Swift type-checker timeout in `TodosView` body caused by an 18+ modifier chain on a single view (sheets moved outside `NavigationStack`)
- Subtask lookup was O(n²) — each task row in a group triggered a full scan of the tasks array; now O(n) total via a pre-built dictionary

---

## App Store / TestFlight Notes

This update is a performance pass focused on making the app feel more responsive during everyday use.

The most noticeable change: checking a task off (or un-checking it) now happens instantly on screen. Previously, a subtle lag caused the task to appear in the wrong state for a brief moment before snapping to the correct position. That render delay is gone.

A few other improvements you might notice:

- The app starts slightly faster on first open because the Priority, Category, and Date views are no longer created until you first visit them.
- If you use voice task entry, toggling tasks in your list is no longer affected by recording state — the two are now fully independent.
- If you have the Insights tab enabled, it no longer rebuilds its analytics every time you check a task off. It now waits for a brief pause before recalculating, so rapid task toggling doesn't cause unnecessary work.

No features were added or removed. This update is entirely about responsiveness and reliability under the hood.

---

## GitHub Release Notes

**performance-updates-claude** — SwiftUI render efficiency pass

This branch eliminates several redundant render cycles and expensive inline computations that had accumulated over the course of adding features to the Todos screen.

**What changed:**

- **Task complete/restore is now instant** — Mode views previously used `@State` caches updated via `.onChange`, which fires *after* body renders. This caused a visible one-frame lag where a task appeared in the wrong state after being toggled. Groupings are now computed directly in body as `let` constants (microseconds at typical list sizes) so the correct state is always shown on the first render.

- **VoiceStateStore isolation** — Voice state (`isRecording`, `isVoiceStagingPresented`, `stagingDrafts`) was removed from `LocalStore` into a new `VoiceStateStore` singleton. All 14+ views observing `LocalStore` no longer redraw on voice state changes.

- **Lazy tab instantiation** — Priority, Category, and Date mode views are now deferred via `LazyView` and only created when the user first visits them.

- **NSDataDetector as static** — The regex detector used to scan task notes for links was reconstructed on every body render; it's now a `static let` compiled once.

- **InsightsView debounce** — Full analytics snapshot rebuild is now debounced 300ms after tasks/categories change, preventing cascading rebuilds during rapid task toggling.

- **Subtask O(n) lookup** — Subtask lookup inside `ForEach` was O(n) per task; now a single pre-built dictionary makes it O(1) per row.

- **`Equatable` on Task and Category** — Enables proper `.onChange(of:)` usage on arrays of these types.

---

## Marketing Copy

**Headline**: Notelayer is faster where it counts — checking off tasks now happens instantly, with no delay.

- Tapping a task as done now registers on screen immediately. The subtle rendering lag that occasionally caused a task to "flicker" before moving is gone.
- The app starts faster — view modes you haven't visited yet are no longer initialized at launch.
- Voice task entry is fully decoupled from the task list — recording something no longer causes the list to redraw.
