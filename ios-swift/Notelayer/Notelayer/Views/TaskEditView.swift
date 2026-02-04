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
    @State private var calendarEditSession: CalendarEventEditSession? = nil
    @State private var showReminderPicker = false
    @State private var showCustomDatePicker = false
    @State private var customDate = Date()
    
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
                TaskEditorTitleSection(title: $title)

                if !store.sortedCategories.isEmpty {
                    TaskEditorCategorySection(
                        categories: store.sortedCategories,
                        selectedIds: $selectedCategories,
                        chipSize: .large
                    )
                }

                TaskEditorPrioritySection(priority: $priority)
                
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
                
                Section("Nag") {
                    if let reminderDate = task.reminderDate {
                        // Tappable reminder row to edit time
                        Button {
                            customDate = reminderDate // Pre-populate with current time
                            showCustomDatePicker = true
                        } label: {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(reminderDate.formatted(date: .abbreviated, time: .shortened))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text(relativeTimeText(for: reminderDate))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button(role: .destructive) {
                            _Concurrency.Task {
                                await store.removeReminder(for: task.id)
                            }
                        } label: {
                            Text("Stop nagging me")
                        }
                    } else {
                        Button {
                            showReminderPicker = true
                        } label: {
                            HStack {
                                Text("Nag me later")
                                Spacer()
                                Image(systemName: "bell.badge.plus")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                TaskEditorNotesSection(notes: $taskNotes, links: detectedURLs)
                
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
            .scrollDismissesKeyboard(.immediately)
            .background(KeyboardDismissRecognizer())
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
            .sheet(isPresented: $showReminderPicker) {
                ReminderPickerSheet(
                    task: task,
                    onSave: { date in
                        _Concurrency.Task {
                            await store.setReminder(for: task.id, at: date)
                        }
                    }
                )
            }
            .sheet(isPresented: $showCustomDatePicker) {
                CustomDatePickerSheet(
                    selectedDate: $customDate,
                    onSave: { date in
                        _Concurrency.Task {
                            await store.setReminder(for: task.id, at: date)
                        }
                        showCustomDatePicker = false
                    },
                    onCancel: {
                        showCustomDatePicker = false
                    }
                )
            }
        }
    }
    
    /// Detected URLs in task notes for tappable links
    private var detectedURLs: [URL] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: taskNotes, range: NSRange(taskNotes.startIndex..., in: taskNotes)) ?? []
        return matches.compactMap { match in
            Range(match.range, in: taskNotes).flatMap { URL(string: String(taskNotes[$0])) }
        }
    }
    
    /// Format relative time text (e.g., "In 2 hours", "Tomorrow at 9:00 AM")
    private func relativeTimeText(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
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

        AnalyticsService.shared.logEvent(AnalyticsEventName.calendarExportInitiated, params: [
            "view_name": AnalyticsViewName.taskEdit,
            "has_due_date": dueDate != nil,
            "has_reminder": task.reminderDate != nil
        ])
        
        // Request permission if needed
        guard await manager.requestCalendarAccess() else {
            await MainActor.run {
                calendarExportError = .permissionDenied
                AnalyticsService.shared.logEvent(AnalyticsEventName.calendarExportPermissionDenied, params: [
                    "view_name": AnalyticsViewName.taskEdit
                ])
            }
            return
        }
        
        // Prepare the event
        do {
            let event = try await manager.prepareEvent(for: task, categories: store.sortedCategories)
            await MainActor.run {
                calendarEditSession = CalendarEventEditSession(event: event, store: manager.eventStoreForUI)
                AnalyticsService.shared.logEvent(AnalyticsEventName.calendarExportPresented, params: [
                    "view_name": AnalyticsViewName.taskEdit
                ])
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
