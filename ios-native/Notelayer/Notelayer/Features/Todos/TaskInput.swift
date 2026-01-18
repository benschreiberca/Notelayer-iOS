//
//  TaskInput.swift
//  Notelayer
//
//  Task input component
//

import SwiftUI

struct TaskInput: View {
    @EnvironmentObject var appStore: AppStore
    var defaultCategories: [CategoryId] = []
    var defaultPriority: Priority = .medium
    /// When non-nil, newly created tasks will inherit this due date (used by the Date lens only).
    var defaultDueDate: Date? = nil
    var onTaskCreated: ((String) -> Void)?
    
    @State private var title: String = ""
    @State private var selectedCategories: [CategoryId] = []
    @State private var priority: Priority = .medium
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Input row
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                TextField("New task...", text: $title)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        handleSubmit()
                    }
                    .onTapGesture {
                        isExpanded = true
                    }
                
                if !title.isEmpty {
                    Button(action: handleSubmit) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Expanded options
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(appStore.categories) { category in
                                Button(action: {
                                    toggleCategory(category.id)
                                }) {
                                    HStack(spacing: 4) {
                                        Text(category.icon)
                                        Text(category.name)
                                            .font(.system(size: 12))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategories.contains(category.id) ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedCategories.contains(category.id) ? .white : .primary)
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    // Priority
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            Text("Priority:")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            ForEach(Priority.allCases, id: \.self) { p in
                                Button(action: {
                                    priority = p
                                }) {
                                    Text(p.displayName)
                                        .font(.system(size: 12))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(priority == p ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(priority == p ? .white : .primary)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            selectedCategories = defaultCategories
            priority = defaultPriority
        }
    }
    
    private func handleSubmit() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let taskId = appStore.addTask(
            title: title.trimmingCharacters(in: .whitespaces),
            categories: selectedCategories,
            priority: priority,
            dueDate: defaultDueDate
        )
        
        title = ""
        selectedCategories = defaultCategories
        priority = defaultPriority
        isExpanded = false
        onTaskCreated?(taskId)
    }
    
    private func toggleCategory(_ categoryId: CategoryId) {
        if selectedCategories.contains(categoryId) {
            selectedCategories.removeAll { $0 == categoryId }
        } else {
            selectedCategories.append(categoryId)
        }
    }
}
