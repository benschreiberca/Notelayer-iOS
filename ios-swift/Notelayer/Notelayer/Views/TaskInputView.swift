import SwiftUI

struct TaskInputView: View {
    @StateObject private var store = LocalStore.shared
    @State private var title = ""
    @State private var selectedCategories: Set<String> = []
    @State private var priority: Priority = .medium
    @State private var isExpanded = false
    
    let defaultPriority: Priority
    let defaultCategories: Set<String>
    let onTaskCreated: (String) -> Void
    
    init(defaultPriority: Priority = .medium, defaultCategories: Set<String> = [], onTaskCreated: @escaping (String) -> Void = { _ in }) {
        self.defaultPriority = defaultPriority
        self.defaultCategories = defaultCategories
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
            
            // Expanded Options
            if isExpanded || !title.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.categories) { category in
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
                    .padding(.horizontal)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
    
    private func submitTask() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let task = Task(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            categories: Array(selectedCategories),
            priority: priority
        )
        
        let taskId = store.addTask(task)
        onTaskCreated(taskId)
        
        // Reset
        title = ""
        selectedCategories = defaultCategories
        priority = defaultPriority
        isExpanded = false
    }
}

struct CategoryChip: View {
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
            .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray5))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(16)
        }
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
