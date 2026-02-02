import SwiftUI

struct TaskInputView: View {
    @StateObject private var store = LocalStore.shared
    @State private var title = ""
    @State private var selectedCategories: Set<String> = []
    @State private var priority: Priority = .medium
    @State private var isExpanded = false
    @FocusState private var isTitleFocused: Bool
    
    let defaultPriority: Priority
    let defaultCategories: Set<String>
    private let defaultDueDate: Date?
    private let creationContext: CreationContext
    let onTaskCreated: (String) -> Void
    
    private enum CreationContext {
        case standard
        case dateLens
    }
    
    /// Standard task input used by List/Priority/Category lenses.
    /// Regression guard: this initializer MUST NOT set `defaultDueDate`.
    init(defaultPriority: Priority = .medium, defaultCategories: Set<String> = [], onTaskCreated: @escaping (String) -> Void = { _ in }) {
        self.defaultPriority = defaultPriority
        self.defaultCategories = defaultCategories
        self.defaultDueDate = nil
        self.creationContext = .standard
        self.onTaskCreated = onTaskCreated
        _priority = State(initialValue: defaultPriority)
        _selectedCategories = State(initialValue: defaultCategories)
    }
    
    /// Date-lens-only task input: new tasks inherit the active date group’s due date.
    init(dateGroupDueDate: Date?, defaultPriority: Priority = .medium, defaultCategories: Set<String> = [], onTaskCreated: @escaping (String) -> Void = { _ in }) {
        self.defaultPriority = defaultPriority
        self.defaultCategories = defaultCategories
        self.defaultDueDate = dateGroupDueDate
        self.creationContext = .dateLens
        self.onTaskCreated = onTaskCreated
        _priority = State(initialValue: defaultPriority)
        _selectedCategories = State(initialValue: defaultCategories)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Input Row
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                TextField("New task...", text: $title)
                    .textFieldStyle(.plain)
                    .focused($isTitleFocused)
                    .onSubmit {
                        submitTask()
                    }
                    .onTapGesture {
                        isExpanded = true
                    }
                
                if !title.isEmpty {
                    Button(action: submitTask) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                // Expand and focus when tapping anywhere in the input row, including the plus icon.
                isExpanded = true
                isTitleFocused = true
            }
            
            // Expanded Options
            if isExpanded || !title.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.sortedCategories) { category in
                                CategoryChip(
                                    category: category,
                                    isSelected: selectedCategories.contains(category.id),
                                    onTap: {
                                        if selectedCategories.contains(category.id) {
                                            selectedCategories.remove(category.id)
                                        } else {
                                            selectedCategories.insert(category.id)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Priority
                    HStack(spacing: 12) {
                        Text("Priority:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Priority.allCases, id: \.self) { p in
                                    PriorityButton(
                                        priority: p,
                                        isSelected: priority == p,
                                        onTap: {
                                            priority = p
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
    
    private func submitTask() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Regression check: only the Date lens is allowed to create tasks with an inherited due date.
        assert(creationContext == .dateLens || defaultDueDate == nil, "defaultDueDate should only be set when TaskInputView is used from the Date lens")
        
        let task = Task(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            categories: Array(selectedCategories),
            priority: priority,
            dueDate: defaultDueDate
        )
        
        let taskId = store.addTask(task)
        onTaskCreated(taskId)

        // Close the keyboard when a task is submitted.
        isTitleFocused = false

        // Reset
        title = ""
        selectedCategories = defaultCategories
        priority = defaultPriority
        isExpanded = false
    }
}

struct CategoryChip: View {
    @EnvironmentObject private var theme: ThemeManager
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(category.icon)
                Text(category.name)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? categoryColor.opacity(0.22) : .clear)
            .foregroundColor(categoryColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.clear : categoryColor, lineWidth: 1.2)
            )
            .cornerRadius(16)
        }
    }

    private var categoryColor: Color {
        Color(hex: category.color) ?? theme.tokens.accent
    }
}

struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(priority.label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? priorityColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
    
    private var priorityColor: Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        case .deferred: return .gray
        }
    }
}
