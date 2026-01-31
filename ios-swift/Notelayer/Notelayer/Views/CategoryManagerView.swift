import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct CategoryManagerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = LocalStore.shared
    @State private var editingCategory: Category? = nil
    @State private var showingAddCategory = false
    @State private var pendingDeleteCategory: Category? = nil
    @State private var pendingDeleteTaskCount = 0
    @State private var showingDeleteDialog = false
    @State private var showingBulkRenameSheet = false
    @State private var targetedCategoryId: String? = nil
    @State private var activeCategoryDragId: String? = nil
    
    var body: some View {
        NavigationStack {
            let categories = store.sortedCategories
            List {
                ForEach(categories) { category in
                    VStack(spacing: 0) {
                        categoryDropSlot(targetId: category.id)
                        HStack {
                            Circle()
                                .fill(Color(hex: category.color) ?? .accentColor)
                                .frame(width: 10, height: 10)
                            Text(category.icon)
                                .font(.title2)
                            Text(category.name)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingCategory = category
                        }
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                            if isPressing {
                                activeCategoryDragId = category.id
                                triggerHaptic()
                            }
                        }, perform: {})
                        .draggable(CategoryGroupDragPayload(groupId: category.id))
                    }
                }
                .onDelete(perform: deleteCategories)
                
                if !categories.isEmpty {
                    categoryDropSlot(targetId: "_end", isEndSlot: true)
                        .listRowSeparator(.hidden)
                }
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
    
    private func deleteCategories(at offsets: IndexSet) {
        guard let index = offsets.first, index < store.sortedCategories.count else { return }
        let category = store.sortedCategories[index]
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

    private func applyCategoryReorder(draggedId: String, before targetId: String?) {
        var orderedIds = store.sortedCategories.map { $0.id }
        guard let fromIndex = orderedIds.firstIndex(of: draggedId) else { return }
        orderedIds.remove(at: fromIndex)
        if let targetId, let toIndex = orderedIds.firstIndex(of: targetId) {
            orderedIds.insert(draggedId, at: toIndex)
        } else {
            orderedIds.append(draggedId)
        }
        store.reorderCategories(orderedIds: orderedIds)
        triggerHaptic()
    }

    private func categoryDropSlot(targetId: String, isEndSlot: Bool = false) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 8)
            .contentShape(Rectangle())
            .onDrop(
                of: [UTType.notelayerCategoryGroupDragPayload],
                delegate: CategoryRowDropDelegate(
                    targetId: targetId,
                    activeDragId: $activeCategoryDragId,
                    targetedId: $targetedCategoryId,
                    onReorder: { draggedId in
                        let beforeId = isEndSlot ? nil : targetId
                        applyCategoryReorder(draggedId: draggedId, before: beforeId)
                    }
                )
            )
            .overlay(alignment: .top) {
                if targetedCategoryId == targetId {
                    Divider()
                }
            }
    }

    private func triggerHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

private struct CategoryRowDropDelegate: DropDelegate {
    let targetId: String
    @Binding var activeDragId: String?
    @Binding var targetedId: String?
    let onReorder: (String) -> Void

    func validateDrop(info: DropInfo) -> Bool {
        activeDragId != nil || info.hasItemsConforming(to: [UTType.notelayerCategoryGroupDragPayload])
    }

    func dropEntered(info: DropInfo) {
        targetedId = targetId
    }

    func dropExited(info: DropInfo) {
        if targetedId == targetId {
            targetedId = nil
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        if let draggedId = activeDragId {
            onReorder(draggedId)
            targetedId = nil
            activeDragId = nil
            return true
        }
        guard let provider = info.itemProviders(for: [UTType.notelayerCategoryGroupDragPayload]).first else { return false }
        provider.loadDataRepresentation(forTypeIdentifier: UTType.notelayerCategoryGroupDragPayload.identifier) { data, _ in
            guard let data, let payload = try? JSONDecoder().decode(CategoryGroupDragPayload.self, from: data) else { return }
            _Concurrency.Task { @MainActor in
                onReorder(payload.groupId)
            }
        }
        targetedId = nil
        return true
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
        store.sortedCategories.filter { $0.id != sourceCategory.id }
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
