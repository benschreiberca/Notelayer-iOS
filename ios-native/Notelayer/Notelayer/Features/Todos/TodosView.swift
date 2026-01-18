//
//  TodosView.swift
//  Notelayer
//
//  Todos list view with multiple view modes
//

import SwiftUI

struct TodosView: View {
    @EnvironmentObject var appStore: AppStore
    @State private var editingTask: Task? = nil
    @State private var isBulkMode = false
    @State private var selectedTaskIds: Set<String> = []
    @State private var showCategoryManager = false
    
    var displayedTasks: [Task] {
        appStore.showDoneTasks ? appStore.completedTasks : appStore.activeTasks
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View tabs
                Picker("View", selection: $appStore.todoView) {
                    Text("List").tag(TodoView.list)
                    Text("Priority").tag(TodoView.priority)
                    Text("Category").tag(TodoView.category)
                    Text("Date").tag(TodoView.date)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                Group {
                    switch appStore.todoView {
                    case .list:
                        listView
                    case .priority:
                        PriorityView(
                            tasks: displayedTasks,
                            onEdit: { editingTask = $0 },
                            showInputs: !appStore.showDoneTasks,
                            selectionMode: isBulkMode,
                            selectedTaskIds: selectedTaskIds,
                            onToggleSelect: { id in
                                if selectedTaskIds.contains(id) {
                                    selectedTaskIds.remove(id)
                                } else {
                                    selectedTaskIds.insert(id)
                                }
                            }
                        )
                        .environmentObject(appStore)
                    case .category:
                        CategoryView(
                            tasks: displayedTasks,
                            onEdit: { editingTask = $0 },
                            showInputs: !appStore.showDoneTasks,
                            selectionMode: isBulkMode,
                            selectedTaskIds: selectedTaskIds,
                            onToggleSelect: { id in
                                if selectedTaskIds.contains(id) {
                                    selectedTaskIds.remove(id)
                                } else {
                                    selectedTaskIds.insert(id)
                                }
                            }
                        )
                        .environmentObject(appStore)
                    case .date:
                        DateView(
                            tasks: displayedTasks,
                            onEdit: { editingTask = $0 },
                            showInputs: !appStore.showDoneTasks,
                            selectionMode: isBulkMode,
                            selectedTaskIds: selectedTaskIds,
                            onToggleSelect: { id in
                                if selectedTaskIds.contains(id) {
                                    selectedTaskIds.remove(id)
                                } else {
                                    selectedTaskIds.insert(id)
                                }
                            }
                        )
                        .environmentObject(appStore)
                    }
                }
            }
            .navigationTitle("To-Dos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showCategoryManager = true
                        }) {
                            Label("Manage Categories", systemImage: "tag")
                        }
                        Button(action: {
                            isBulkMode.toggle()
                            if !isBulkMode {
                                selectedTaskIds.removeAll()
                            }
                        }) {
                            Label(isBulkMode ? "Cancel Selection" : "Select", systemImage: isBulkMode ? "xmark.circle" : "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Toggle(isOn: Binding(
                        get: { !appStore.showDoneTasks },
                        set: { appStore.showDoneTasks = !$0 }
                    )) {
                        Text(appStore.showDoneTasks ? "Done" : "Doing")
                            .font(.caption)
                    }
                    .toggleStyle(.button)
                }
            }
            .sheet(item: $editingTask) { task in
                TaskEditView(task: task)
                    .environmentObject(appStore)
            }
            .sheet(isPresented: $showCategoryManager) {
                CategoryManagerView()
                    .environmentObject(appStore)
            }
        }
    }
    
    private var listView: some View {
        List {
            if !appStore.showDoneTasks {
                Section {
                    // Regression guard: List lens should NOT set a due date by default.
                    TaskInput(defaultDueDate: nil)
                        .environmentObject(appStore)
                }
            }
            
            if displayedTasks.isEmpty {
                Section {
                    Text(appStore.showDoneTasks ? "No completed tasks yet" : "All caught up! Add a task above.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
            } else {
                ForEach(displayedTasks) { task in
                    TaskItem(
                        task: task,
                        onEdit: { editingTask = $0 },
                        selectionMode: isBulkMode,
                        selected: selectedTaskIds.contains(task.id),
                        onSelectToggle: { id in
                            if selectedTaskIds.contains(id) {
                                selectedTaskIds.remove(id)
                            } else {
                                selectedTaskIds.insert(id)
                            }
                        }
                    )
                    .environmentObject(appStore)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                }
                .onMove { source, destination in
                    var reordered = displayedTasks
                    reordered.move(fromOffsets: source, toOffset: destination)
                    appStore.reorderTasks(orderedIds: reordered.map { $0.id })
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
