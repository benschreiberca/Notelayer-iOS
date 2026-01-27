import SwiftUI
import EventKit

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
    @State private var calendarExportError: CalendarExportError? = nil
    @State private var calendarEventToEdit: (event: EKEvent, store: EKEventStore)? = nil
    
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
                    
                    if dueDate != nil {
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
                        store.deleteTask(id: task.id, undoManager: resolvedUndoManager)
                        UndoCoordinator.shared.activateResponder()
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
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        _Concurrency.Task {
                            await exportTaskToCalendar()
                        }
                    } label: {
                        Label("Add to Calendar", systemImage: "calendar.badge.plus")
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
            .sheet(item: Binding(
                get: { calendarEventToEdit.map { TaskEditSheetIdentifier(event: $0.event, store: $0.store) } },
                set: { calendarEventToEdit = $0.map { ($0.event, $0.store) } }
            )) { identifier in
                CalendarEventEditView(
                    event: identifier.event,
                    eventStore: identifier.store,
                    onSaved: {
                        calendarEventToEdit = nil
                    },
                    onCancelled: {
                        calendarEventToEdit = nil
                    }
                )
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
    
    private func exportTaskToCalendar() async {
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
            let event = try await manager.prepareEvent(for: task, categories: store.categories)
            await MainActor.run {
                calendarEventToEdit = (event, manager.eventStoreForUI)
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
    
    private var resolvedUndoManager: UndoManager? {
        // Route delete undo registration through the same manager used by the shake responder.
        UndoCoordinator.shared.undoManager
    }
}

// Helper struct to make the event identifiable for the sheet
private struct TaskEditSheetIdentifier: Identifiable {
    let id = UUID()
    let event: EKEvent
    let store: EKEventStore
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
