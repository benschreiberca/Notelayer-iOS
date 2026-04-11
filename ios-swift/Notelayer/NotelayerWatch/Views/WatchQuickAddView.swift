import SwiftUI

struct WatchQuickAddView: View {
    @EnvironmentObject var store: WatchStore
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""

    var body: some View {
        VStack(spacing: 12) {
            TextField("Task title", text: $title)

            Button("Add Task") {
                let trimmed = title.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                store.quickAddTask(title: trimmed)
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)

            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .navigationTitle("New Task")
    }
}
