//
//  TaskEditView.swift
//  Notelayer
//
//  Task edit sheet
//

import SwiftUI

struct TaskEditView: View {
    @EnvironmentObject var appStore: AppStore
    @Environment(\.dismiss) var dismiss
    let task: Task
    
    @State private var title: String
    @State private var selectedCategories: Set<CategoryId>
    @State private var priority: Priority
    @State private var dueDate: Date?
    @State private var taskNotes: String
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _selectedCategories = State(initialValue: Set(task.categories))
        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate)
        _taskNotes = State(initialValue: task.taskNotes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Task title", text: $title)
                }
                
                Section("Categories") {
                    ForEach(appStore.categories) { category in
                        Toggle(isOn: Binding(
                            get: { selectedCategories.contains(category.id) },
                            set: { isOn in
                                if isOn {
                                    selectedCategories.insert(category.id)
                                } else {
                                    selectedCategories.remove(category.id)
                                }
                            }
                        )) {
                            HStack {
                                Text(category.icon)
                                Text(category.name)
                            }
                        }
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $taskNotes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                }
            }
        }
    }
    
    private func save() {
        appStore.updateTask(
            id: task.id,
            title: title,
            categories: Array(selectedCategories),
            priority: priority,
            taskNotes: taskNotes.isEmpty ? nil : taskNotes
        )
        dismiss()
    }
}
