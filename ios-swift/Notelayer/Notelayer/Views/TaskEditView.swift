import SwiftUI

struct TaskEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = LocalStore.shared
    
    let task: Task
    @State private var title: String
    @State private var selectedCategories: Set<String>
    @State private var priority: Priority
    @State private var dueDate: Date?
    @State private var taskNotes: String
    @State private var showDatePicker = false
    
    init(task: Task, categories: [Category]) {
        self.task = task
        _title = State(initialValue: task.title)
        _selectedCategories = State(initialValue: Set(task.categories))
        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate)
        _taskNotes = State(initialValue: task.taskNotes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Title") {
                    TextField("Task title", text: $title)
                        .font(.title3.weight(.semibold))
                        .onChange(of: title) { newValue in
                            if newValue.count > 200 {
                                title = String(newValue.prefix(200))
                            }
                        }
                }
                
                Section("Categories") {
                    ForEach(store.categories) { category in
                        HStack {
                            Text(category.icon)
                            Text(category.name)
                            Spacer()
                            if selectedCategories.contains(category.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedCategories.contains(category.id) {
                                selectedCategories.remove(category.id)
                            } else {
                                selectedCategories.insert(category.id)
                            }
                        }
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.label).tag(p)
                        }
                    }
                }
                
                Section("Due Date") {
                    Button {
                        if dueDate == nil {
                            dueDate = Date()
                        }
                        showDatePicker = true
                    } label: {
                        HStack {
                            Text("Due Date")
                            Spacer()
                            if let dueDate = dueDate {
                                Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Tap to set date & time")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if let dueDate = dueDate {
                        Button(role: .destructive) {
                            self.dueDate = nil
                        } label: {
                            Text("Remove Due Date")
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $taskNotes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(role: .destructive) {
                        store.deleteTask(id: task.id)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Task")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selectedDate: Binding(
                    get: { dueDate ?? Date() },
                    set: { dueDate = $0 }
                ))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func saveTask() {
        store.updateTask(id: task.id) { task in
            task.title = title
            task.categories = Array(selectedCategories)
            task.priority = priority
            task.dueDate = dueDate
            task.taskNotes = taskNotes.isEmpty ? nil : taskNotes
        }
    }
    
}

struct DatePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationStack {
            List {
                DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
            }
            .navigationTitle("Select Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
