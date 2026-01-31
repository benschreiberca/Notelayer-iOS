import SwiftUI
import Combine
import EventKit
import UIKit
import UniformTypeIdentifiers

enum TodoViewMode: String, CaseIterable {
    case list = "List"
    case priority = "Priority"
    case category = "Category"
    case date = "Date"
}

struct TodosView: View {
    @StateObject private var store = LocalStore.shared
    @State private var showingDone = false
    @State private var editingTask: Task? = nil
    @State private var showingCategoryManager = false
    @State private var showingAppearance = false
    @State private var showingProfileSettings = false
    @State private var viewMode: TodoViewMode = .list
    @State private var sharePayload: SharePayload? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var calendarExportError: CalendarExportError? = nil
    @State private var calendarEditSession: CalendarEventEditSession? = nil
    @State private var taskToSetReminder: Task? = nil
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    
    // Header constants
    private let expandedHeaderHeight: CGFloat = 130
    private let collapsedHeaderHeight: CGFloat = 100
    
    private var isSqueezed: Bool {
        scrollOffset < -20
    }
    
    private var headerHeight: CGFloat {
        isSqueezed ? collapsedHeaderHeight : expandedHeaderHeight
    }
    
    private var logoSize: CGFloat {
        isSqueezed ? 28 : 36
    }
    
    private var headerOffset: CGFloat {
        // Allow header to scroll off screen if "squeezed hard"
        if scrollOffset < -100 {
            return scrollOffset + 100
        }
        return 0
    }

    var body: some View {
        let tasks = store.tasks
        let partitioned = splitTasksByCompletion(tasks)
        let doingTasks = partitioned.doing
        let doneTasks = partitioned.done
        let filteredTasks = showingDone ? doneTasks : doingTasks

        NavigationStack {
            ZStack(alignment: .top) {
                // Main Content
                TabView(selection: $viewMode) {
                    TodoListModeView(
                        tasks: filteredTasks,
                        showingDone: showingDone,
                        categories: store.sortedCategories,
                        editingTask: $editingTask,
                        sharePayload: $sharePayload,
                        scrollOffset: $scrollOffset,
                        onExportToCalendar: { task in
                            _Concurrency.Task { await exportTaskToCalendar(task) }
                        },
                        onSetReminder: { setReminder(for: $0) },
                        onRemoveReminder: { removeReminder(for: $0) }
                    )
                    .tag(TodoViewMode.list)
                    
                    TodoPriorityModeView(
                        tasks: filteredTasks,
                        showingDone: showingDone,
                        categories: store.sortedCategories,
                        editingTask: $editingTask,
                        sharePayload: $sharePayload,
                        scrollOffset: $scrollOffset,
                        onExportToCalendar: { task in
                            _Concurrency.Task { await exportTaskToCalendar(task) }
                        },
                        onSetReminder: { setReminder(for: $0) },
                        onRemoveReminder: { removeReminder(for: $0) }
                    )
                    .tag(TodoViewMode.priority)
                    
                    TodoCategoryModeView(
                        tasks: filteredTasks,
                        showingDone: showingDone,
                        categories: store.sortedCategories,
                        editingTask: $editingTask,
                        sharePayload: $sharePayload,
                        scrollOffset: $scrollOffset,
                        onExportToCalendar: { task in
                            _Concurrency.Task { await exportTaskToCalendar(task) }
                        },
                        onSetReminder: { setReminder(for: $0) },
                        onRemoveReminder: { removeReminder(for: $0) }
                    )
                    .tag(TodoViewMode.category)
                    
                    TodoDateModeView(
                        tasks: filteredTasks,
                        showingDone: showingDone,
                        categories: store.sortedCategories,
                        editingTask: $editingTask,
                        sharePayload: $sharePayload,
                        scrollOffset: $scrollOffset,
                        onExportToCalendar: { task in
                            _Concurrency.Task { await exportTaskToCalendar(task) }
                        },
                        onSetReminder: { setReminder(for: $0) },
                        onRemoveReminder: { removeReminder(for: $0) }
                    )
                    .tag(TodoViewMode.date)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .padding(.top, expandedHeaderHeight) // Fixed spacing to prevent jump
                
                // Dynamic Squeezing Header
                VStack(spacing: 0) {
                    // Top Row: Logo, Toggle, Gear
                    HStack(spacing: 12) {
                        Image("NotelayerLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: logoSize, height: logoSize)
                            .clipShape(RoundedRectangle(cornerRadius: logoSize * 0.22, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        
                        Spacer()
                        
                        // Doing/Done Toggle
                        HStack(spacing: 8) {
                            Button(action: { withAnimation { showingDone = false } }) {
                                VStack(spacing: 2) {
                                    Text("Doing")
                                        .font(isSqueezed ? .caption : .subheadline)
                                        .fontWeight(showingDone ? .regular : .bold)
                                        .foregroundColor(showingDone ? .secondary : .primary)
                                    Text("\(doingTasks.count)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Toggle("", isOn: $showingDone)
                                .labelsHidden()
                                .tint(theme.tokens.accent)
                                .scaleEffect(isSqueezed ? 0.8 : 1.0)
                            
                            Button(action: { withAnimation { showingDone = true } }) {
                                VStack(spacing: 2) {
                                    Text("Done")
                                        .font(isSqueezed ? .caption : .subheadline)
                                        .fontWeight(showingDone ? .bold : .regular)
                                        .foregroundColor(showingDone ? .primary : .secondary)
                                    Text("\(doneTasks.count)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Gear Menu
                        Menu {
                            Button { showingAppearance = true } label: { Label("Colour Theme", systemImage: "paintbrush") }
                            Button { showingCategoryManager = true } label: { Label("Manage Categories", systemImage: "tag") }
                            Button { showingProfileSettings = true } label: { Label("Profile & Settings", systemImage: "person.circle") }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: isSqueezed ? 18 : 22))
                                    .foregroundStyle(.secondary)
                                    .padding(8)
                                
                                if authService.syncStatus.shouldShowBadge {
                                    Circle()
                                        .fill(authService.syncStatus.badgeColor == "red" ? Color.red : Color.yellow)
                                        .frame(width: 10, height: 10)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(.systemBackground), lineWidth: 1.5)
                                        )
                                        .offset(x: -6, y: 6) // Aggressive overlap from top-right corner
                                        .accessibilityLabel(authService.syncStatus.badgeColor == "red" ? "Not signed in" : "Sync error")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, isSqueezed ? 4 : 12)
                    .padding(.bottom, isSqueezed ? 4 : 12)
                    
                    // Bottom Row: View Picker
                    Picker("View", selection: $viewMode) {
                        ForEach(TodoViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, isSqueezed ? 8 : 12)
                    .scaleEffect(isSqueezed ? 0.95 : 1.0)
                    
                    Divider()
                        .opacity(isSqueezed ? 1 : 0)
                }
                .background(
                    ZStack {
                        theme.tokens.screenBackground
                        ThemeBackground(preset: theme.preset)
                    }
                    .opacity(isSqueezed ? 0.95 : 0)
                    .blur(radius: isSqueezed ? 10 : 0)
                    .ignoresSafeArea()
                )
                .background(.ultraThinMaterial.opacity(isSqueezed ? 1 : 0))
                .offset(y: headerOffset)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSqueezed)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: headerOffset)
            }
            .background(ThemeBackground(preset: theme.preset)) // Apply wallpaper here too
            .navigationBarHidden(true)
            .sheet(item: $editingTask) { task in
                TaskEditView(task: task, categories: store.sortedCategories)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingCategoryManager) {
                CategoryManagerView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAppearance) {
                AppearanceView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingProfileSettings) {
                ProfileSettingsView()
                    .environmentObject(authService)
                    .environmentObject(theme)
            }
            .sheet(item: $sharePayload) { payload in
                ShareSheet(items: payload.items)
            }
            .alert("Calendar Export Failed", isPresented: .constant(calendarExportError != nil)) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    calendarExportError = nil
                }
                Button("OK") {
                    calendarExportError = nil
                }
            } message: {
                if let error = calendarExportError {
                    Text(error.localizedDescription)
                }
            }
            .sheet(item: $calendarEditSession) { session in
                CalendarEventEditView(
                    event: session.event,
                    eventStore: session.store,
                    onSaved: {
                        calendarEditSession = nil
                    },
                    onCancelled: {
                        calendarEditSession = nil
                    }
                )
            }
            .sheet(item: $taskToSetReminder) { task in
                ReminderPickerSheet(
                    task: task,
                    onSave: { date in
                        _Concurrency.Task {
                            await store.setReminder(for: task.id, at: date)
                        }
                    }
                )
                .environmentObject(theme)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenTaskFromNotification"))) { notification in
                if let taskId = notification.userInfo?["taskId"] as? String,
                   let task = store.tasks.first(where: { $0.id == taskId }) {
                    editingTask = task
                }
            }
            .onAppear {
                // Process shared items AFTER backend has time to sync
                // This prevents Firebase from overwriting newly added tasks
                NSLog("👀 [TodosView] onAppear - waiting for backend sync before processing shared items")
                
                // Wait 2 seconds for initial sync to complete, then process shared items
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    NSLog("🔄 [TodosView] Backend sync should be done, processing shared items NOW")
                    LocalStore.shared.processSharedItems()
                }
            }
        }
    }
    
    // MARK: - Reminder Handlers
    
    private func setReminder(for task: Task) {
        taskToSetReminder = task
    }
    
    private func removeReminder(for task: Task) {
        _Concurrency.Task {
            await store.removeReminder(for: task.id)
        }
    }
    
    private func exportTaskToCalendar(_ task: Task) async {
        let manager = CalendarExportManager.shared
        
        // Request permission if needed
        guard await manager.requestCalendarAccess() else {
            await MainActor.run {
                calendarExportError = .permissionDenied
            }
            return
        }
        
        // Prepare the event
        do {
            let event = try await manager.prepareEvent(for: task, categories: store.sortedCategories)
            await MainActor.run {
                calendarEditSession = CalendarEventEditSession(event: event, store: manager.eventStoreForUI)
            }
        } catch let error as CalendarExportError {
            await MainActor.run {
                calendarExportError = error
            }
        } catch {
            await MainActor.run {
                calendarExportError = .unknown(error)
            }
        }
    }
    
    private struct ScreenEdgeGlow: View {
        let accent: Color
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .strokeBorder(glowGradient, lineWidth: 10)
                .blur(radius: 18)
                .opacity(0.55)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: UUID())
                .padding(6)
        }

        private var glowGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.55),
                    accent.opacity(0.55),
                    Color.green.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Shared helpers
private func taskSortKey(_ task: Task) -> Int {
    task.orderIndex ?? 0
}

private func sortedByOrderIndexDesc(_ tasks: [Task]) -> [Task] {
    tasks.sorted { taskSortKey($0) > taskSortKey($1) }
}

private func splitTasksByCompletion(_ tasks: [Task]) -> (doing: [Task], done: [Task]) {
    var doing: [Task] = []
    var done: [Task] = []
    doing.reserveCapacity(tasks.count)
    done.reserveCapacity(tasks.count / 4)
    for task in tasks {
        if task.completedAt == nil {
            doing.append(task)
        } else {
            done.append(task)
        }
    }
    return (doing, done)
}

private func makeCategoryLookup(_ categories: [Category]) -> [String: Category] {
    Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
}

private func groupTasksByCategory(_ tasks: [Task]) -> (uncategorized: [Task], byCategory: [String: [Task]]) {
    var uncategorized: [Task] = []
    var byCategory: [String: [Task]] = [:]
    for task in tasks {
        if task.categories.isEmpty {
            uncategorized.append(task)
        } else {
            for categoryId in task.categories {
                byCategory[categoryId, default: []].append(task)
            }
        }
    }
    return (uncategorized, byCategory)
}

private func groupTasksByDateBucket(_ tasks: [Task]) -> [TodoDateBucket: [Task]] {
    var grouped: [TodoDateBucket: [Task]] = [:]
    for task in tasks {
        let bucket = bucketForDueDate(task.dueDate)
        grouped[bucket, default: []].append(task)
    }
    return grouped
}

private func dueDateForBucket(_ bucket: TodoDateBucket, now: Date = Date(), calendar: Calendar = .current) -> Date? {
    switch bucket {
    case .overdue:
        return calendar.date(byAdding: .day, value: -1, to: now) ?? now
    case .today:
        return now
    case .tomorrow:
        return calendar.date(byAdding: .day, value: 1, to: now) ?? now
    case .thisWeek:
        return calendar.date(byAdding: .day, value: 3, to: now) ?? now
    case .later:
        return calendar.date(byAdding: .day, value: 14, to: now) ?? now
    case .noDate:
        return nil
    }
}

private func bucketForDueDate(_ dueDate: Date?, now: Date = Date(), calendar: Calendar = .current) -> TodoDateBucket {
    guard let dueDate else { return .noDate }
    if calendar.isDateInToday(dueDate) { return .today }
    if calendar.isDateInTomorrow(dueDate) { return .tomorrow }
    if dueDate < now { return .overdue }
    if calendar.isDate(dueDate, equalTo: now, toGranularity: .weekOfYear) { return .thisWeek }
    return .later
}

private enum TodoDateBucket: String, CaseIterable {
    case overdue = "Overdue"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case later = "Later"
    case noDate = "No Due Date"
}

private let endDropTaskId = "__end__"

// MARK: - Mode views (ScrollView + inset cards)
private struct TodoListModeView: View {
    @StateObject private var store = LocalStore.shared
    let tasks: [Task]
    let showingDone: Bool
    let categories: [Category]
    @Binding var editingTask: Task?
    @Binding var sharePayload: SharePayload?
    @Binding var scrollOffset: CGFloat
    let onExportToCalendar: (Task) -> Void
    let onSetReminder: (Task) -> Void
    let onRemoveReminder: (Task) -> Void
    
    var body: some View {
        let categoryLookup = makeCategoryLookup(categories)
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            LazyVStack(spacing: 12) {
                TodoGroupCard(
                    mode: .list,
                    groupId: "all",
                    title: "All",
                    count: tasks.count,
                    canCollapse: false,
                    onToggleCollapsed: nil
                ) {
                    if !showingDone {
                        TaskInputView(defaultPriority: .medium, defaultCategories: [], onTaskCreated: { _ in })
                    }
                    TodoGroupTaskList(
                        tasks: sortedByOrderIndexDesc(tasks),
                        categoryLookup: categoryLookup,
                        sourceGroupId: "all",
                        onToggleComplete: toggleComplete,
                        onTap: { editingTask = $0 },
                        onShare: { sharePayload = SharePayload(items: [$0.title]) },
                        onCopy: { UIPasteboard.general.string = $0.title },
                        onAddToCalendar: onExportToCalendar,
                        onSetReminder: onSetReminder,
                        onRemoveReminder: onRemoveReminder,
                        onDropMove: { payload, beforeTaskId in
                            reorderWithinSameGroup(draggedId: payload.taskId, beforeTaskId: beforeTaskId)
                            return true
                        }
                    )
                }
                .dropDestination(for: TodoDragPayload.self) { items, _ in
                    guard let payload = items.first else { return false }
                    reorderWithinSameGroup(draggedId: payload.taskId, beforeTaskId: nil)
                    return true
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { Keyboard.dismiss() }
        )
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
    
    private func toggleComplete(_ task: Task) {
        if task.completedAt != nil {
            store.restoreTask(id: task.id)
        } else {
            store.completeTask(id: task.id)
        }
    }
    
    private func reorderWithinSameGroup(draggedId: String, beforeTaskId: String?) {
        var ordered = sortedByOrderIndexDesc(tasks).map { $0.id }
        ordered.removeAll { $0 == draggedId }
        if beforeTaskId == endDropTaskId {
            ordered.append(draggedId)
        } else if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
            ordered.insert(draggedId, at: idx)
        } else {
            ordered.insert(draggedId, at: 0)
        }
        withAnimation {
            store.reorderTasks(orderedIds: ordered)
        }
    }
}

private struct TodoPriorityModeView: View {
    @StateObject private var store = LocalStore.shared
    let tasks: [Task]
    let showingDone: Bool
    let categories: [Category]
    @Binding var editingTask: Task?
    @Binding var sharePayload: SharePayload?
    @Binding var scrollOffset: CGFloat
    let onExportToCalendar: (Task) -> Void
    let onSetReminder: (Task) -> Void
    let onRemoveReminder: (Task) -> Void
    @StateObject private var collapse = GroupCollapseStore.shared
    
    var body: some View {
        // Pre-group once to avoid repeated filtering in each priority lane.
        let tasksByPriority = Dictionary(grouping: tasks, by: { $0.priority })
        let categoryLookup = makeCategoryLookup(categories)
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            LazyVStack(spacing: 12) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    let groupTasks = tasksByPriority[priority] ?? []
                    let groupId = "priority:\(priority.rawValue)"
                    let isCollapsed = collapse.isCollapsed(mode: .priority, groupId: groupId)
                    
                    TodoGroupCard(
                        mode: .priority,
                        groupId: groupId,
                        title: priority.label,
                        count: groupTasks.count,
                        canCollapse: true,
                        onToggleCollapsed: {
                            collapse.setCollapsed(!isCollapsed, mode: .priority, groupId: groupId)
                        }
                    ) {
                        TodoGroupTaskList(
                            tasks: sortedByOrderIndexDesc(groupTasks),
                            categoryLookup: categoryLookup,
                            sourceGroupId: priority.rawValue,
                            onToggleComplete: toggleComplete,
                            onTap: { editingTask = $0 },
                            onShare: { sharePayload = SharePayload(items: [$0.title]) },
                            onCopy: { UIPasteboard.general.string = $0.title },
                            onAddToCalendar: onExportToCalendar,
                            onSetReminder: onSetReminder,
                            onRemoveReminder: onRemoveReminder,
                            onDropMove: { payload, beforeTaskId in
                                applyPriorityDrop(payload: payload, destination: priority, beforeTaskId: beforeTaskId)
                                return true
                            }
                        )
                        if !showingDone {
                            // Keep the new task input below active tasks in grouped views.
                            TaskInputView(defaultPriority: priority, defaultCategories: [], onTaskCreated: { _ in })
                                .padding(.top, 6)
                        }
                    }
                    .dropDestination(for: TodoDragPayload.self) { items, _ in
                        guard let payload = items.first else { return false }
                        if isCollapsed {
                            withAnimation { collapse.setCollapsed(false, mode: .priority, groupId: groupId) }
                        }
                        applyPriorityDrop(payload: payload, destination: priority, beforeTaskId: nil)
                        return true
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { Keyboard.dismiss() }
        )
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
    
    private func toggleComplete(_ task: Task) {
        if task.completedAt != nil {
            store.restoreTask(id: task.id)
        } else {
            store.completeTask(id: task.id)
        }
    }
    
    private func applyPriorityDrop(payload: TodoDragPayload, destination: Priority, beforeTaskId: String?) {
        let draggedId = payload.taskId
        
        // Update active grouping field (priority) only if changing groups.
        store.updateTask(id: draggedId) { task in
            task.priority = destination
        }
        
        // Reorder within destination group (supports same-group smooth reorder too).
        let visible = store.tasks.filter { showingDone ? $0.completedAt != nil : $0.completedAt == nil }
        let groupTasks = visible.filter { $0.priority == destination }
        var ordered = sortedByOrderIndexDesc(groupTasks).map { $0.id }
        ordered.removeAll { $0 == draggedId }
        if beforeTaskId == endDropTaskId {
            ordered.append(draggedId)
        } else if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
            ordered.insert(draggedId, at: idx)
        } else {
            ordered.insert(draggedId, at: 0)
        }
        withAnimation {
            store.reorderTasks(orderedIds: ordered)
        }
    }
}

private struct TodoCategoryModeView: View {
    @StateObject private var store = LocalStore.shared
    let tasks: [Task]
    let showingDone: Bool
    let categories: [Category]
    @Binding var editingTask: Task?
    @Binding var sharePayload: SharePayload?
    @Binding var scrollOffset: CGFloat
    let onExportToCalendar: (Task) -> Void
    let onSetReminder: (Task) -> Void
    let onRemoveReminder: (Task) -> Void
    @StateObject private var collapse = GroupCollapseStore.shared
    @State private var dragCollapsedGroupIds: Set<String> = []
    @State private var targetedGroupKey: String? = nil
    @State private var activeGroupDragKey: String? = nil
    
    var body: some View {
        // Pre-group to avoid scanning the full task list for each category.
        let grouped = groupTasksByCategory(tasks)
        let categoryLookup = makeCategoryLookup(categories)
        let uncategorizedGroupKey = "uncategorized"
        let uncategorizedGroupId = "category:Uncategorized"
        let uncategorizedIndex = min(max(store.uncategorizedPosition, 0), categories.count)
        let beforeCategories = Array(categories.prefix(uncategorizedIndex))
        let afterCategories = Array(categories.dropFirst(uncategorizedIndex))
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            LazyVStack(spacing: 12) {
                ForEach(beforeCategories) { category in
                    groupDropSlot(targetKey: category.id)
                    categoryGroupCard(
                        category: category,
                        grouped: grouped,
                        categoryLookup: categoryLookup
                    )
                }
                
                groupDropSlot(targetKey: uncategorizedGroupKey)
                uncategorizedGroupCard(
                    grouped: grouped,
                    categoryLookup: categoryLookup,
                    groupId: uncategorizedGroupId,
                    groupKey: uncategorizedGroupKey
                )
                
                ForEach(afterCategories) { category in
                    groupDropSlot(targetKey: category.id)
                    categoryGroupCard(
                        category: category,
                        grouped: grouped,
                        categoryLookup: categoryLookup
                    )
                }
                Color.clear
                    .frame(height: 1)
                groupDropSlot(targetKey: "_end", isEndSlot: true)
            }
            .padding(.vertical, 12)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { Keyboard.dismiss() }
        )
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }

    private func categoryGroupCard(
        category: Category,
        grouped: (uncategorized: [Task], byCategory: [String: [Task]]),
        categoryLookup: [String: Category]
    ) -> some View {
        let groupTasks = grouped.byCategory[category.id] ?? []
        let collapseGroupId = "category:\(category.id)"
        let isCollapsed = collapse.isCollapsed(mode: .category, groupId: collapseGroupId)
        return TodoGroupCard(
            mode: .category,
            groupId: collapseGroupId,
            title: "\(category.icon) \(category.name)",
            count: groupTasks.count,
            canCollapse: true,
            onToggleCollapsed: {
                collapse.setCollapsed(!isCollapsed, mode: .category, groupId: collapseGroupId)
            },
            dragPayload: CategoryGroupDragPayload(groupId: category.id),
            onDragStart: {
                activeGroupDragKey = category.id
                handleGroupDragStart(groupKey: category.id, collapseGroupId: collapseGroupId, isCollapsed: isCollapsed)
            }
        ) {
            TodoGroupTaskList(
                tasks: sortedByOrderIndexDesc(groupTasks),
                categoryLookup: categoryLookup,
                sourceGroupId: category.id,
                onToggleComplete: toggleComplete,
                onTap: { editingTask = $0 },
                onShare: { sharePayload = SharePayload(items: [$0.title]) },
                onCopy: { UIPasteboard.general.string = $0.title },
                onAddToCalendar: onExportToCalendar,
                onSetReminder: onSetReminder,
                onRemoveReminder: onRemoveReminder,
                onDropMove: { payload, beforeTaskId in
                    applyCategoryDrop(payload: payload, destinationCategoryId: category.id, beforeTaskId: beforeTaskId)
                    return true
                }
            )
            if !showingDone {
                // Keep the new task input below active tasks in grouped views.
                TaskInputView(defaultPriority: .medium, defaultCategories: [category.id], onTaskCreated: { _ in })
                    .padding(.top, 6)
            }
        }
        .dropDestination(for: TodoDragPayload.self) { items, _ in
            guard let payload = items.first else { return false }
            if isCollapsed {
                withAnimation { collapse.setCollapsed(false, mode: .category, groupId: collapseGroupId) }
            }
            applyCategoryDrop(payload: payload, destinationCategoryId: category.id, beforeTaskId: nil)
            return true
        }
        .padding(.horizontal, 16)
    }

    private func uncategorizedGroupCard(
        grouped: (uncategorized: [Task], byCategory: [String: [Task]]),
        categoryLookup: [String: Category],
        groupId: String,
        groupKey: String
    ) -> some View {
        let uncategorizedTasks = grouped.uncategorized
        let isCollapsed = collapse.isCollapsed(mode: .category, groupId: groupId)
        return TodoGroupCard(
            mode: .category,
            groupId: groupId,
            title: "Uncategorized",
            count: uncategorizedTasks.count,
            canCollapse: true,
            onToggleCollapsed: {
                collapse.setCollapsed(!isCollapsed, mode: .category, groupId: groupId)
            },
            dragPayload: CategoryGroupDragPayload(groupId: groupKey),
            onDragStart: {
                activeGroupDragKey = groupKey
                handleGroupDragStart(groupKey: groupKey, collapseGroupId: groupId, isCollapsed: isCollapsed)
            }
        ) {
            TodoGroupTaskList(
                tasks: sortedByOrderIndexDesc(uncategorizedTasks),
                categoryLookup: categoryLookup,
                sourceGroupId: "Uncategorized",
                onToggleComplete: toggleComplete,
                onTap: { editingTask = $0 },
                onShare: { sharePayload = SharePayload(items: [$0.title]) },
                onCopy: { UIPasteboard.general.string = $0.title },
                onAddToCalendar: onExportToCalendar,
                onSetReminder: onSetReminder,
                onRemoveReminder: onRemoveReminder,
                onDropMove: { payload, beforeTaskId in
                    applyCategoryDrop(payload: payload, destinationCategoryId: "Uncategorized", beforeTaskId: beforeTaskId)
                    return true
                }
            )
            if !showingDone {
                // Keep the new task input below active tasks in grouped views.
                TaskInputView(defaultPriority: .medium, defaultCategories: [], onTaskCreated: { _ in })
                    .padding(.top, 6)
            }
        }
        .dropDestination(for: TodoDragPayload.self) { items, _ in
            guard let payload = items.first else { return false }
            if isCollapsed {
                withAnimation { collapse.setCollapsed(false, mode: .category, groupId: groupId) }
            }
            applyCategoryDrop(payload: payload, destinationCategoryId: "Uncategorized", beforeTaskId: nil)
            return true
        }
        .padding(.horizontal, 16)
    }
    
    private func toggleComplete(_ task: Task) {
        if task.completedAt != nil {
            store.restoreTask(id: task.id)
        } else {
            store.completeTask(id: task.id)
        }
    }

    private func handleGroupDragStart(groupKey: String, collapseGroupId: String, isCollapsed: Bool) {
        if !isCollapsed {
            collapse.setCollapsed(true, mode: .category, groupId: collapseGroupId)
            dragCollapsedGroupIds.insert(collapseGroupId)
        }
        triggerGroupHaptic()
    }

    private func groupDropSlot(targetKey: String, isEndSlot: Bool = false) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 8)
            .contentShape(Rectangle())
            .onDrop(
                of: [UTType.notelayerCategoryGroupDragPayload],
                delegate: CategoryGroupDropDelegate(
                    targetKey: targetKey,
                    activeDragKey: $activeGroupDragKey,
                    targetedKey: $targetedGroupKey,
                    onReorder: { draggedKey in
                        let beforeKey = isEndSlot ? nil : targetKey
                        applyCategoryGroupReorder(payload: CategoryGroupDragPayload(groupId: draggedKey), beforeGroupKey: beforeKey)
                    }
                )
            )
            .overlay(alignment: .top) {
                if targetedGroupKey == targetKey {
                    Divider()
                }
            }
    }


    private func restoreCollapsedGroupIfNeeded(for groupKey: String) {
        let collapseGroupId = groupKey == "uncategorized" ? "category:Uncategorized" : "category:\(groupKey)"
        guard dragCollapsedGroupIds.contains(collapseGroupId) else { return }
        collapse.setCollapsed(false, mode: .category, groupId: collapseGroupId)
        dragCollapsedGroupIds.remove(collapseGroupId)
    }

    private func applyCategoryGroupReorder(payload: CategoryGroupDragPayload, beforeGroupKey: String?) {
        let uncategorizedGroupKey = "uncategorized"
        let orderedCategoryIds = categories.map { $0.id }
        let uncategorizedIndex = min(max(store.uncategorizedPosition, 0), orderedCategoryIds.count)
        var groupIds = orderedCategoryIds
        groupIds.insert(uncategorizedGroupKey, at: uncategorizedIndex)
        guard let fromIndex = groupIds.firstIndex(of: payload.groupId) else {
            restoreCollapsedGroupIfNeeded(for: payload.groupId)
            return
        }
        groupIds.remove(at: fromIndex)
        if let beforeGroupKey, let toIndex = groupIds.firstIndex(of: beforeGroupKey) {
            groupIds.insert(payload.groupId, at: toIndex)
        } else {
            groupIds.append(payload.groupId)
        }
        let updatedUncategorizedIndex = groupIds.firstIndex(of: uncategorizedGroupKey) ?? 0
        store.setUncategorizedPosition(updatedUncategorizedIndex)
        let updatedCategoryIds = groupIds.filter { $0 != uncategorizedGroupKey }
        store.reorderCategories(orderedIds: updatedCategoryIds)
        restoreCollapsedGroupIfNeeded(for: payload.groupId)
        triggerGroupHaptic()
    }

    private func triggerGroupHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func applyCategoryDrop(payload: TodoDragPayload, destinationCategoryId: String, beforeTaskId: String?) {
        let draggedId = payload.taskId
        let sourceCategoryId = payload.sourceGroupId
        
        // Update active grouping field (category): remove source group label + add destination label.
        store.updateTask(id: draggedId) { task in
            var cats = task.categories
            if sourceCategoryId != "Uncategorized" {
                cats.removeAll { $0 == sourceCategoryId }
            }
            if destinationCategoryId != "Uncategorized" {
                if !cats.contains(destinationCategoryId) {
                    cats.append(destinationCategoryId)
                }
            }
            task.categories = cats
        }
        
        // Reorder within destination category group.
        let visible = store.tasks.filter { showingDone ? $0.completedAt != nil : $0.completedAt == nil }
        let groupTasks: [Task] = {
            if destinationCategoryId == "Uncategorized" {
                return visible.filter { $0.categories.isEmpty }
            }
            return visible.filter { $0.categories.contains(destinationCategoryId) }
        }()
        var ordered = sortedByOrderIndexDesc(groupTasks).map { $0.id }
        ordered.removeAll { $0 == draggedId }
        if beforeTaskId == endDropTaskId {
            ordered.append(draggedId)
        } else if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
            ordered.insert(draggedId, at: idx)
        } else {
            ordered.insert(draggedId, at: 0)
        }
        withAnimation {
            store.reorderTasks(orderedIds: ordered)
        }
    }
}

private struct CategoryGroupDropDelegate: DropDelegate {
    let targetKey: String
    @Binding var activeDragKey: String?
    @Binding var targetedKey: String?
    let onReorder: (String) -> Void

    func validateDrop(info: DropInfo) -> Bool {
        activeDragKey != nil || info.hasItemsConforming(to: [UTType.notelayerCategoryGroupDragPayload])
    }

    func dropEntered(info: DropInfo) {
        targetedKey = targetKey
    }

    func dropExited(info: DropInfo) {
        if targetedKey == targetKey {
            targetedKey = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        if let draggedKey = activeDragKey {
            onReorder(draggedKey)
            targetedKey = nil
            activeDragKey = nil
            return true
        }
        guard let provider = info.itemProviders(for: [UTType.notelayerCategoryGroupDragPayload]).first else { return false }
        provider.loadDataRepresentation(forTypeIdentifier: UTType.notelayerCategoryGroupDragPayload.identifier) { data, _ in
            guard let data, let payload = try? JSONDecoder().decode(CategoryGroupDragPayload.self, from: data) else { return }
            _Concurrency.Task { @MainActor in
                onReorder(payload.groupId)
            }
        }
        targetedKey = nil
        return true
    }
}

private struct TodoDateModeView: View {
    @StateObject private var store = LocalStore.shared
    let tasks: [Task]
    let showingDone: Bool
    let categories: [Category]
    @Binding var editingTask: Task?
    @Binding var sharePayload: SharePayload?
    @Binding var scrollOffset: CGFloat
    let onExportToCalendar: (Task) -> Void
    let onSetReminder: (Task) -> Void
    let onRemoveReminder: (Task) -> Void
    @StateObject private var collapse = GroupCollapseStore.shared
    
    var body: some View {
        // Pre-group to avoid repeated bucket filtering across each date section.
        let tasksByBucket = groupTasksByDateBucket(tasks)
        let categoryLookup = makeCategoryLookup(categories)
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
            .frame(height: 0)
            LazyVStack(spacing: 12) {
                ForEach(TodoDateBucket.allCases, id: \.self) { bucket in
                    let groupTasks = tasksByBucket[bucket] ?? []
                    let groupId = "date:\(bucket.rawValue)"
                    let isCollapsed = collapse.isCollapsed(mode: .date, groupId: groupId)
                    
                    TodoGroupCard(
                        mode: .date,
                        groupId: groupId,
                        title: bucket.rawValue,
                        count: groupTasks.count,
                        canCollapse: true,
                        onToggleCollapsed: {
                            collapse.setCollapsed(!isCollapsed, mode: .date, groupId: groupId)
                        }
                    ) {
                        TodoGroupTaskList(
                            tasks: sortedByOrderIndexDesc(groupTasks),
                            categoryLookup: categoryLookup,
                            sourceGroupId: bucket.rawValue,
                            onToggleComplete: toggleComplete,
                            onTap: { editingTask = $0 },
                            onShare: { sharePayload = SharePayload(items: [$0.title]) },
                            onCopy: { UIPasteboard.general.string = $0.title },
                            onAddToCalendar: onExportToCalendar,
                            onSetReminder: onSetReminder,
                            onRemoveReminder: onRemoveReminder,
                            onDropMove: { payload, beforeTaskId in
                                applyDateDrop(payload: payload, destinationBucket: bucket, beforeTaskId: beforeTaskId)
                                return true
                            }
                        )
                        if !showingDone {
                            // Keep the new task input below active tasks in grouped views.
                            // Date lens only: new tasks inherit the active bucket's due date.
                            TaskInputView(dateGroupDueDate: dueDateForBucket(bucket), defaultPriority: .medium, defaultCategories: [], onTaskCreated: { _ in })
                                .padding(.top, 6)
                        }
                    }
                    .dropDestination(for: TodoDragPayload.self) { items, _ in
                        guard let payload = items.first else { return false }
                        if isCollapsed {
                            withAnimation { collapse.setCollapsed(false, mode: .date, groupId: groupId) }
                        }
                        applyDateDrop(payload: payload, destinationBucket: bucket, beforeTaskId: nil)
                        return true
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { Keyboard.dismiss() }
        )
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
    
    private func toggleComplete(_ task: Task) {
        if task.completedAt != nil {
            store.restoreTask(id: task.id)
        } else {
            store.completeTask(id: task.id)
        }
    }
    
    private func applyDateDrop(payload: TodoDragPayload, destinationBucket: TodoDateBucket, beforeTaskId: String?) {
        let draggedId = payload.taskId
        let newDueDate = dueDateForBucket(destinationBucket)
        
        store.updateTask(id: draggedId) { task in
            task.dueDate = newDueDate
        }
        
        let visible = store.tasks.filter { showingDone ? $0.completedAt != nil : $0.completedAt == nil }
        let groupTasks = visible.filter { bucketForDueDate($0.dueDate) == destinationBucket }
        var ordered = sortedByOrderIndexDesc(groupTasks).map { $0.id }
        ordered.removeAll { $0 == draggedId }
        if beforeTaskId == endDropTaskId {
            ordered.append(draggedId)
        } else if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
            ordered.insert(draggedId, at: idx)
        } else {
            ordered.insert(draggedId, at: 0)
        }
        withAnimation {
            store.reorderTasks(orderedIds: ordered)
        }
    }
}

private struct TodoGroupCardHeader: View {
    let title: String
    let count: Int
    let isCollapsed: Bool
    let canCollapse: Bool
    let onToggleCollapsed: (() -> Void)?
    let dragPayload: CategoryGroupDragPayload?
    let onDragStart: (() -> Void)?
    
    init(
        title: String,
        count: Int,
        isCollapsed: Bool,
        canCollapse: Bool,
        onToggleCollapsed: (() -> Void)?,
        dragPayload: CategoryGroupDragPayload? = nil,
        onDragStart: (() -> Void)? = nil
    ) {
        self.title = title
        self.count = count
        self.isCollapsed = isCollapsed
        self.canCollapse = canCollapse
        self.onToggleCollapsed = onToggleCollapsed
        self.dragPayload = dragPayload
        self.onDragStart = onDragStart
    }
    
    var body: some View {
        Group {
            if let dragPayload {
                headerContent()
                    .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                        if isPressing {
                            onDragStart?()
                        }
                    }, perform: {})
                    .draggable(dragPayload)
            } else {
                headerContent()
            }
        }
    }

    private func headerContent() -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Spacer(minLength: 0)
            
            Text("\(count)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule(style: .continuous).fill(Color(.tertiarySystemBackground)))
            
            if canCollapse {
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            guard canCollapse else { return }
            withAnimation(.snappy) {
                onToggleCollapsed?()
            }
            Keyboard.dismiss()
        }
    }
}

private struct TodoGroupCard<Content: View>: View {
    let mode: TodoViewMode
    let groupId: String
    let title: String
    let count: Int
    let canCollapse: Bool
    let onToggleCollapsed: (() -> Void)?
    let dragPayload: CategoryGroupDragPayload?
    let onDragStart: (() -> Void)?
    @ViewBuilder let content: () -> Content
    
    @StateObject private var collapse = GroupCollapseStore.shared

    init(
        mode: TodoViewMode,
        groupId: String,
        title: String,
        count: Int,
        canCollapse: Bool,
        onToggleCollapsed: (() -> Void)?,
        dragPayload: CategoryGroupDragPayload? = nil,
        onDragStart: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.mode = mode
        self.groupId = groupId
        self.title = title
        self.count = count
        self.canCollapse = canCollapse
        self.onToggleCollapsed = onToggleCollapsed
        self.dragPayload = dragPayload
        self.onDragStart = onDragStart
        self.content = content
    }
    
    var body: some View {
        let isCollapsed = canCollapse ? collapse.isCollapsed(mode: mode, groupId: groupId) : false
        InsetCard {
            VStack(alignment: .leading, spacing: 6) {
                TodoGroupCardHeader(
                    title: title,
                    count: count,
                    isCollapsed: isCollapsed,
                    canCollapse: canCollapse,
                    onToggleCollapsed: onToggleCollapsed,
                    dragPayload: dragPayload,
                    onDragStart: onDragStart
                )
                
                if !isCollapsed {
                    content()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .contentShape(Rectangle())
    }
}

final class GroupCollapseStore: ObservableObject {
    static let shared = GroupCollapseStore()
    
    private let appGroupIdentifier = "group.com.notelayer.app"
    private let key = "com.notelayer.app.todos.groupCollapse"
    
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    @Published private(set) var collapsed: Set<String> = []
    
    private init() {
        load()
    }
    
    func isCollapsed(mode: TodoViewMode, groupId: String) -> Bool {
        collapsed.contains("\(mode.rawValue)|\(groupId)")
    }
    
    func setCollapsed(_ isCollapsed: Bool, mode: TodoViewMode, groupId: String) {
        let k = "\(mode.rawValue)|\(groupId)"
        if isCollapsed {
            collapsed.insert(k)
        } else {
            collapsed.remove(k)
        }
        save()
    }
    
    private func load() {
        if let arr = userDefaults.array(forKey: key) as? [String] {
            collapsed = Set(arr)
        }
    }
    
    private func save() {
        userDefaults.set(Array(collapsed), forKey: key)
    }
}

private struct TaskRowDropDelegate: DropDelegate {
    let targetTaskId: String?
    let isEndZone: Bool
    @Binding var hoveredTaskId: String?
    @Binding var isEndTargeted: Bool
    let onDropMove: (TodoDragPayload, String?) -> Bool

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [UTType.notelayerTodoDragPayload])
    }

    func dropEntered(info: DropInfo) {
        if isEndZone {
            hoveredTaskId = nil
            isEndTargeted = true
        } else if let targetTaskId {
            hoveredTaskId = targetTaskId
            isEndTargeted = false
        } else {
            hoveredTaskId = nil
            isEndTargeted = true
        }
    }

    func dropExited(info: DropInfo) {
        if let targetTaskId, hoveredTaskId == targetTaskId {
            hoveredTaskId = nil
        }
        if targetTaskId == nil || isEndZone {
            isEndTargeted = false
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let provider = info.itemProviders(for: [UTType.notelayerTodoDragPayload]).first else { return false }
        provider.loadDataRepresentation(forTypeIdentifier: UTType.notelayerTodoDragPayload.identifier) { data, _ in
            guard let data, let payload = try? JSONDecoder().decode(TodoDragPayload.self, from: data) else { return }
            let beforeId = isEndZone ? endDropTaskId : targetTaskId
            _Concurrency.Task { @MainActor in
                _ = onDropMove(payload, beforeId)
            }
        }
        hoveredTaskId = nil
        isEndTargeted = false
        return true
    }
}

private struct TodoGroupTaskList: View {
    @StateObject private var store = LocalStore.shared
    let tasks: [Task]
    let categoryLookup: [String: Category]
    /// Identifier representing the group the rows are being rendered within (used as drag sourceGroupId).
    let sourceGroupId: String
    let onToggleComplete: (Task) -> Void
    let onTap: (Task) -> Void
    let onShare: (Task) -> Void
    let onCopy: (Task) -> Void
    let onAddToCalendar: (Task) -> Void
    let onSetReminder: (Task) -> Void
    let onRemoveReminder: (Task) -> Void
    /// Called when a payload is dropped; if beforeTaskId is nil, treat as drop-into-container.
    let onDropMove: (TodoDragPayload, String?) -> Bool
    @State private var hoveredTaskId: String? = nil
    @State private var isEndDropTargeted = false
    
    var body: some View {
        VStack(spacing: 8) {
            if tasks.isEmpty {
                Text("Drop here")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .dropDestination(for: TodoDragPayload.self) { items, _ in
                        guard let payload = items.first else { return false }
                        return onDropMove(payload, nil)
                    }
            } else {
                ForEach(tasks) { task in
                    TaskItemView(
                        task: task,
                        categoryLookup: categoryLookup,
                        onToggleComplete: { onToggleComplete(task) },
                        onTap: { onTap(task) }
                    )
                    .contentShape(Rectangle())
                    .draggable(TodoDragPayload(taskId: task.id, sourceGroupId: sourceGroupId))
                    .rowContextMenu(
                        shareTitle: "Share…",
                        onShare: { onShare(task) },
                        onCopy: { onCopy(task) },
                        onAddToCalendar: { onAddToCalendar(task) },
                        hasReminder: task.reminderDate != nil,
                        onSetReminder: { onSetReminder(task) },
                        onRemoveReminder: { onRemoveReminder(task) },
                        onDelete: {
                            store.deleteTask(id: task.id, undoManager: resolvedUndoManager)
                            UndoCoordinator.shared.activateResponder()
                        }
                    )
                    .onDrop(
                        of: [UTType.notelayerTodoDragPayload],
                        delegate: TaskRowDropDelegate(
                            targetTaskId: task.id,
                            isEndZone: false,
                            hoveredTaskId: $hoveredTaskId,
                            isEndTargeted: $isEndDropTargeted,
                            onDropMove: onDropMove
                        )
                    )
                    .overlay(alignment: .top) {
                        if hoveredTaskId == task.id {
                            Divider()
                        }
                    }
                }
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 14)
                    .contentShape(Rectangle())
                    .onDrop(
                        of: [UTType.notelayerTodoDragPayload],
                        delegate: TaskRowDropDelegate(
                            targetTaskId: nil,
                            isEndZone: true,
                            hoveredTaskId: $hoveredTaskId,
                            isEndTargeted: $isEndDropTargeted,
                            onDropMove: onDropMove
                        )
                    )
                    .overlay(alignment: .top) {
                        if isEndDropTargeted {
                            Divider()
                        }
                    }
            }
        }
        // Requested: increase padding between group headers and list cards (top & bottom)
        .padding(.vertical, 4)
        .simultaneousGesture(TapGesture().onEnded { Keyboard.dismiss() })
    }

    private var resolvedUndoManager: UndoManager? {
        // Route delete undo registration through the same manager used by the shake responder.
        UndoCoordinator.shared.undoManager
    }
}

// Preference key for tracking scroll offset
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
