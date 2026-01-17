//
//  CategoryManagerView.swift
//  Notelayer
//
//  Category management view
//

import SwiftUI

struct CategoryManagerView: View {
    @EnvironmentObject var appStore: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var formMode: FormMode? = nil
    @State private var formName: String = ""
    @State private var formIcon: String = "🏷️"
    @State private var formColor: String = ""
    @State private var editingCategoryId: CategoryId? = nil
    
    enum FormMode {
        case add
        case edit(CategoryId)
    }
    
    private var colorOptions: [String] {
        var colors = Set<String>()
        for category in Category.defaults {
            colors.insert(category.color)
        }
        for category in appStore.categories {
            colors.insert(category.color)
        }
        return Array(colors).sorted()
    }
    
    var body: some View {
        NavigationStack {
            List {
                if formMode != nil {
                    Section("Category Details") {
                        TextField("Name", text: $formName)
                        TextField("Icon", text: $formIcon)
                            .autocorrectionDisabled()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(colorOptions, id: \.self) { color in
                                    Button(action: {
                                        formColor = color
                                    }) {
                                        Circle()
                                            .fill(colorForString(color))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(formColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        HStack {
                            Button("Cancel") {
                                resetForm()
                            }
                            Spacer()
                            Button("Save") {
                                saveCategory()
                            }
                            .disabled(formName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                
                Section {
                    ForEach(appStore.categories) { category in
                        HStack {
                            Circle()
                                .fill(colorForString(category.color))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(category.icon)
                                        .font(.system(size: 16))
                                )
                            
                            VStack(alignment: .leading) {
                                Text(category.name)
                                    .font(.body)
                                Text(category.id)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingCategoryId = category.id
                            formMode = .edit(category.id)
                            formName = category.name
                            formIcon = category.icon
                            formColor = category.color
                        }
                    }
                    .onMove { source, destination in
                        var reordered = appStore.categories
                        reordered.move(fromOffsets: source, toOffset: destination)
                        appStore.reorderCategories(orderedIds: reordered.map { $0.id })
                    }
                } header: {
                    HStack {
                        Text("Categories")
                        Spacer()
                        Button(action: {
                            resetForm()
                            formMode = .add
                            formName = ""
                            formIcon = "🏷️"
                            formColor = colorOptions.first ?? Category.defaults.first?.color ?? ""
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetForm() {
        formMode = nil
        formName = ""
        formIcon = "🏷️"
        formColor = ""
        editingCategoryId = nil
    }
    
    private func saveCategory() {
        let trimmedName = formName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Check for duplicate names (case-insensitive)
        let isDuplicate = appStore.categories.contains { category in
            category.name.trimmingCharacters(in: .whitespaces).lowercased() == trimmedName.lowercased() &&
            category.id != editingCategoryId
        }
        
        guard !isDuplicate else {
            // TODO: Show error alert
            return
        }
        
        let icon = formIcon.trimmingCharacters(in: .whitespaces).isEmpty ? "🏷️" : formIcon
        let color = formColor.isEmpty ? (colorOptions.first ?? Category.defaults.first?.color ?? "") : formColor
        
        if case .edit(let categoryId) = formMode {
            if let existing = appStore.categories.first(where: { $0.id == categoryId }) {
                var updated = existing
                updated.name = trimmedName
                updated.icon = icon
                updated.color = color
                appStore.updateCategory(id: categoryId, updates: updated)
            }
        } else {
            let newCategory = Category(
                id: IDGenerator.generate(),
                name: trimmedName,
                icon: icon,
                color: color
            )
            appStore.addCategory(newCategory)
        }
        
        resetForm()
    }
    
    private func colorForString(_ colorName: String) -> Color {
        // Map color names to actual colors
        // Since web uses CSS classes, we'll use a simple mapping
        switch colorName {
        case "category-house": return .orange
        case "category-garage": return .blue
        case "category-printing": return .purple
        case "category-vehicle": return .red
        case "category-tech": return .green
        case "category-finance": return .yellow
        case "category-shopping": return .pink
        case "category-travel": return .cyan
        default: return .gray
        }
    }
}
