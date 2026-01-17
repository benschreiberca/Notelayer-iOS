import SwiftUI

struct CategoryManagerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = LocalStore.shared
    @State private var editingCategory: Category? = nil
    @State private var showingAddCategory = false
    
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
        }
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        var categories = store.categories
        categories.move(fromOffsets: source, toOffset: destination)
        let orderedIds = categories.map { $0.id }
        store.reorderCategories(orderedIds: orderedIds)
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
                    TextField("Emoji icon", text: $icon)
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
                    TextField("Emoji icon", text: $icon)
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
