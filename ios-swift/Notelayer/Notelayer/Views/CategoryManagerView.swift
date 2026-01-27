import SwiftUI

struct CategoryManagerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = LocalStore.shared
    @State private var editingCategory: Category? = nil
    @State private var showingAddCategory = false
    @State private var pendingDeleteCategory: Category? = nil
    @State private var pendingDeleteTaskCount = 0
    @State private var showingDeleteDialog = false
    @State private var showingBulkRenameSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.categories) { category in
                    HStack {
                        Circle()
                            .fill(Color(hex: category.color) ?? .accentColor)
                            .frame(width: 10, height: 10)
                        Text(category.icon)
                            .font(.title2)
                        Text(category.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingCategory = category
                    }
                }
                .onMove(perform: moveCategories)
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingCategory) { category in
                CategoryEditView(category: category)
            }
            .sheet(isPresented: $showingAddCategory) {
                CategoryAddView()
            }
            .sheet(isPresented: $showingBulkRenameSheet, onDismiss: clearPendingDelete) {
                if let category = pendingDeleteCategory {
                    CategoryBulkRenameView(
                        sourceCategory: category,
                        taskCount: pendingDeleteTaskCount,
                        onComplete: clearPendingDelete
                    )
                }
            }
            .confirmationDialog(
                "Delete Category?",
                isPresented: $showingDeleteDialog,
                titleVisibility: .visible
            ) {
                Button("Delete Category", role: .destructive) {
                    if let category = pendingDeleteCategory {
                        store.deleteCategory(id: category.id)
                    }
                    clearPendingDelete()
                }
                Button("Bulk Rename Tasks") {
                    showingBulkRenameSheet = true
                }
                Button("Cancel", role: .cancel) {
                    clearPendingDelete()
                }
            } message: {
                Text("This category has \(taskCountLabel(pendingDeleteTaskCount)). Delete it or bulk rename those tasks.")
            }
        }
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        var categories = store.categories
        categories.move(fromOffsets: source, toOffset: destination)
        let orderedIds = categories.map { $0.id }
        store.reorderCategories(orderedIds: orderedIds)
    }

    private func deleteCategories(at offsets: IndexSet) {
        guard let index = offsets.first, index < store.categories.count else { return }
        let category = store.categories[index]
        let taskCount = store.tasks.filter { $0.categories.contains(category.id) }.count
        // Only prompt when the category is still in use by tasks.
        if taskCount == 0 {
            store.deleteCategory(id: category.id)
            return
        }
        pendingDeleteCategory = category
        pendingDeleteTaskCount = taskCount
        showingDeleteDialog = true
    }

    private func clearPendingDelete() {
        pendingDeleteCategory = nil
        pendingDeleteTaskCount = 0
        showingBulkRenameSheet = false
    }

    private func taskCountLabel(_ count: Int) -> String {
        count == 1 ? "1 task" : "\(count) tasks"
    }
}

struct CategoryEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = LocalStore.shared
    
    let category: Category
    @State private var name: String
    @State private var icon: String
    @State private var color: Color
    
    init(category: Category) {
        self.category = category
        _name = State(initialValue: category.name)
        _icon = State(initialValue: category.icon)
        _color = State(initialValue: Color(hex: category.color) ?? .accentColor)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }
                
                Section("Icon") {
                    EmojiTextField(text: $icon, placeholder: "Emoji icon")
                }

                Section("Color") {
                    ColorPicker("Category Color", selection: $color, supportsOpacity: false)
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateCategory(id: category.id) { category in
                            category.name = name
                            category.icon = icon
                            category.color = color.toHex() ?? CategoryColorDefaults.defaultHex(forCategoryId: category.id)
                        }
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct CategoryAddView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = LocalStore.shared
    @State private var name = ""
    @State private var icon = "🏷️"
    @State private var color: Color = .accentColor
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }
                
                Section("Icon") {
                    EmojiTextField(text: $icon, placeholder: "Emoji icon")
                }

                Section("Color") {
                    ColorPicker("Category Color", selection: $color, supportsOpacity: false)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let id = UUID().uuidString
                        let category = Category(
                            id: id,
                            name: name,
                            icon: icon,
                            color: color.toHex() ?? CategoryColorDefaults.defaultHex(forCategoryId: id)
                        )
                        store.addCategory(category)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

private struct CategoryBulkRenameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = LocalStore.shared

    let sourceCategory: Category
    let taskCount: Int
    let onComplete: () -> Void
    @State private var selectedCategoryId: String = ""

    private var availableCategories: [Category] {
        store.categories.filter { $0.id != sourceCategory.id }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Reassign \(taskCountLabel(taskCount)) from \"\(sourceCategory.name)\" to:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Target Category") {
                    if availableCategories.isEmpty {
                        Text("No other categories available.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableCategories) { category in
                            HStack {
                                Text(category.icon)
                                Text(category.name)
                                Spacer()
                                if selectedCategoryId == category.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCategoryId = category.id
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bulk Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onComplete()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Rename") {
                        // Reassign tasks before removing the category.
                        store.deleteCategory(id: sourceCategory.id, reassignTo: selectedCategoryId)
                        onComplete()
                        dismiss()
                    }
                    .disabled(selectedCategoryId.isEmpty)
                }
            }
        }
        .onAppear {
            if selectedCategoryId.isEmpty {
                selectedCategoryId = availableCategories.first?.id ?? ""
            }
        }
    }

    private func taskCountLabel(_ count: Int) -> String {
        count == 1 ? "1 task" : "\(count) tasks"
    }
}
