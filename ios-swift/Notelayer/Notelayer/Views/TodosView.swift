import SwiftUI
import Combine

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
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        let tasks = store.tasks
        // Split once per render to avoid multiple passes over the full task list.
        let partitioned = splitTasksByCompletion(tasks)
        let doingTasks = partitioned.doing
        let doneTasks = partitioned.done
        let filteredTasks = showingDone ? doneTasks : doingTasks

        NavigationStack {
            ZStack {
                // Screen-edge Siri glow when Done is selected (no background color changes)
                if showingDone {
                    ScreenEdgeGlow(accent: theme.tokens.accent)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                
                VStack(spacing: 0) {
                    // Header with Todos, Doing/Done toggle, and menu
                    HStack {
                        Text("Todos")
                            .font(.headline)
                            .padding(.leading, 16)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: { showingDone = false }) {
                                    VStack(spacing: 3) {
                                        Text("Doing")
                                            .font(.subheadline)
                                            .foregroundColor(showingDone ? .secondary : .primary)
                                        Text("\(doingTasks.count)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Toggle("", isOn: $showingDone)
                                    .labelsHidden()
                                    .tint(theme.tokens.accent)
                                
                                Button(action: { showingDone = true }) {
                                    VStack(spacing: 3) {
                                        Text("Done")
                                            .font(.subheadline)
                                            .foregroundColor(showingDone ? .primary : .secondary)
                                        Text("\(doneTasks.count)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Menu {
                                Button {
                                    showingProfileSettings = true
                                } label: {
                                    Label("Profile & Settings", systemImage: "person.circle")
                                }
                                Button {
                                    showingAppearance = true
                                } label: {
                                    Label("Appearance", systemImage: "paintbrush")
                                }
                                Button {
                                    showingCategoryManager = true
                                } label: {
                                    Label("Manage Categories", systemImage: "tag")
                                }
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 18, weight: .semibold))
                                        .padding(10) // large hit target
                                    
                                    // Notification badge
                                    if authService.syncStatus.shouldShowBadge {
                                        Circle()
                                            .fill(authService.syncStatus.badgeColor == "red" ? Color.red : Color.yellow)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 4, y: 4)
                                            .accessibilityLabel(authService.syncStatus.badgeColor == "red" ? "Not signed in" : "Sync error")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.vertical, 8)
                    
                    // View Mode Tabs (single source of truth = viewMode)
                    Picker("View", selection: $viewMode) {
                        ForEach(TodoViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    // Page-level swipe (forgiving) — no per-row horizontal swipes.
                    TabView(selection: $viewMode) {
                        TodoListModeView(
                            tasks: filteredTasks,
                            showingDone: showingDone,
                            categories: store.categories,
                            editingTask: $editingTask,
                            sharePayload: $sharePayload
                        )
                        .tag(TodoViewMode.list)
                        
                        TodoPriorityModeView(
                            tasks: filteredTasks,
                            showingDone: showingDone,
                            categories: store.categories,
                            editingTask: $editingTask,
                            sharePayload: $sharePayload
                        )
                        .tag(TodoViewMode.priority)
                        
                        TodoCategoryModeView(
                            tasks: filteredTasks,
                            showingDone: showingDone,
                            categories: store.categories,
                            editingTask: $editingTask,
                            sharePayload: $sharePayload
                        )
                        .tag(TodoViewMode.category)
                        
                        TodoDateModeView(
                            tasks: filteredTasks,
                            showingDone: showingDone,
                            categories: store.categories,
                            editingTask: $editingTask,
                            sharePayload: $sharePayload
                        )
                        .tag(TodoViewMode.date)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    // Keyboard dismiss when tapping outside input
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editingTask) { task in
                TaskEditView(task: task, categories: store.categories)
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

// MARK: - Mode views (ScrollView + inset cards)
private struct TodoListModeView: View {
    @StateObject private var store = LocalStore.shared
    let tasks: [Task]
    let showingDone: Bool
    let categories: [Category]
    @Binding var editingTask: Task?
    @Binding var sharePayload: SharePayload?
    
    var body: some View {
        let categoryLookup = makeCategoryLookup(categories)
        ScrollView {
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
        if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
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
    @StateObject private var collapse = GroupCollapseStore.shared
    
    var body: some View {
        // Pre-group once to avoid repeated filtering in each priority lane.
        let tasksByPriority = Dictionary(grouping: tasks, by: { $0.priority })
        let categoryLookup = makeCategoryLookup(categories)
        ScrollView {
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
        if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
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
    @StateObject private var collapse = GroupCollapseStore.shared
    
    var body: some View {
        // Pre-group to avoid scanning the full task list for each category.
        let grouped = groupTasksByCategory(tasks)
        let categoryLookup = makeCategoryLookup(categories)
        ScrollView {
            LazyVStack(spacing: 12) {
                // Uncategorized group (so tasks with no categories remain visible + droppable)
                let uncategorizedTasks = grouped.uncategorized
                let uncategorizedGroupId = "category:Uncategorized"
                let isUncategorizedCollapsed = collapse.isCollapsed(mode: .category, groupId: uncategorizedGroupId)
                TodoGroupCard(
                    mode: .category,
                    groupId: uncategorizedGroupId,
                    title: "Uncategorized",
                    count: uncategorizedTasks.count,
                    canCollapse: true,
                    onToggleCollapsed: {
                        collapse.setCollapsed(!isUncategorizedCollapsed, mode: .category, groupId: uncategorizedGroupId)
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
                    if isUncategorizedCollapsed {
                        withAnimation { collapse.setCollapsed(false, mode: .category, groupId: uncategorizedGroupId) }
                    }
                    applyCategoryDrop(payload: payload, destinationCategoryId: "Uncategorized", beforeTaskId: nil)
                    return true
                }
                .padding(.horizontal, 16)
                
                ForEach(categories) { category in
                    let groupTasks = grouped.byCategory[category.id] ?? []
                    let groupId = "category:\(category.id)"
                    let isCollapsed = collapse.isCollapsed(mode: .category, groupId: groupId)
                    TodoGroupCard(
                        mode: .category,
                        groupId: groupId,
                        title: "\(category.icon) \(category.name)",
                        count: groupTasks.count,
                        canCollapse: true,
                        onToggleCollapsed: {
                            collapse.setCollapsed(!isCollapsed, mode: .category, groupId: groupId)
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
                            withAnimation { collapse.setCollapsed(false, mode: .category, groupId: groupId) }
                        }
                        applyCategoryDrop(payload: payload, destinationCategoryId: category.id, beforeTaskId: nil)
                        return true
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    private func toggleComplete(_ task: Task) {
        if task.completedAt != nil {
            store.restoreTask(id: task.id)
        } else {
            store.completeTask(id: task.id)
        }
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
        if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
            ordered.insert(draggedId, at: idx)
        } else {
            ordered.insert(draggedId, at: 0)
        }
        withAnimation {
            store.reorderTasks(orderedIds: ordered)
        }
    }
}

private enum TodoDateBucket: String, CaseIterable {
    case overdue = "Overdue"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case later = "Later"
    case noDate = "No Due Date"
}

private struct TodoDateModeView: View {
    @StateObject private var store = LocalStore.shared
    let tasks: [Task]
    let showingDone: Bool
    let categories: [Category]
    @Binding var editingTask: Task?
    @Binding var sharePayload: SharePayload?
    @StateObject private var collapse = GroupCollapseStore.shared
    
    var body: some View {
        // Pre-group to avoid repeated bucket filtering across each date section.
        let tasksByBucket = groupTasksByDateBucket(tasks)
        let categoryLookup = makeCategoryLookup(categories)
        ScrollView {
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
        if let beforeTaskId, let idx = ordered.firstIndex(of: beforeTaskId) {
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
    
    var body: some View {
        Button(action: {
            guard canCollapse else { return }
            withAnimation(.snappy) {
                onToggleCollapsed?()
            }
        }) {
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
        }
        .buttonStyle(.plain)
    }
}

private struct TodoGroupCard<Content: View>: View {
    let mode: TodoViewMode
    let groupId: String
    let title: String
    let count: Int
    let canCollapse: Bool
    let onToggleCollapsed: (() -> Void)?
    @ViewBuilder let content: () -> Content
    
    @StateObject private var collapse = GroupCollapseStore.shared
    
    var body: some View {
        let isCollapsed = canCollapse ? collapse.isCollapsed(mode: mode, groupId: groupId) : false
        InsetCard {
            VStack(alignment: .leading, spacing: 6) {
                TodoGroupCardHeader(
                    title: title,
                    count: count,
                    isCollapsed: isCollapsed,
                    canCollapse: canCollapse,
                    onToggleCollapsed: onToggleCollapsed
                )
                
                if !isCollapsed {
                    content()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
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
    /// Called when a payload is dropped; if beforeTaskId is nil, treat as drop-into-container.
    let onDropMove: (TodoDragPayload, String?) -> Bool
    
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
                        onDelete: {
                            store.deleteTask(id: task.id, undoManager: resolvedUndoManager)
                            UndoCoordinator.shared.activateResponder()
                        }
                    )
                    .dropDestination(for: TodoDragPayload.self) { items, _ in
                        guard let payload = items.first else { return false }
                        // Smooth reorder by allowing drop "before" this row.
                        return onDropMove(payload, task.id)
                    }
                }
            }
        }
        // Requested: increase padding between group headers and list cards (top & bottom)
        .padding(.vertical, 4)
    }

    private var resolvedUndoManager: UndoManager? {
        // Route delete undo registration through the same manager used by the shake responder.
        UndoCoordinator.shared.undoManager
    }
}
