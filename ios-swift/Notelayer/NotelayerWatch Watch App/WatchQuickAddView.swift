import SwiftUI

struct WatchQuickAddView: View {
    @State private var title = ""
    var onAdd: (String) -> Void = { _ in }

    var body: some View {
        VStack {
            TextField("Task title", text: $title)
            Button("Add") {
                onAdd(title)
                title = ""
            }
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .navigationTitle("New Task")
    }
}
