import SwiftUI

struct WatchQuickAddView: View {
    var onAdd: (String) -> Void
    @State private var title = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("Task title", text: $title)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { submit() }

                Button("Add Task") { submit() }
                    .buttonStyle(.borderedProminent)
                    .tint(WatchPriorityStyle.accent)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationTitle("New Task")
            .onAppear { focused = true }
        }
    }

    private func submit() {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        onAdd(t)
    }
}
