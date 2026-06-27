import SwiftUI

/// Quick task entry on the watch. The text field surfaces watchOS dictation and
/// Scribble automatically, so users can speak or scribble a task title.
struct WatchQuickAddView: View {
    @EnvironmentObject private var connector: WatchConnector
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        VStack(spacing: 12) {
            TextField("New task", text: $title)
                .textFieldStyle(.automatic)
                .submitLabel(.done)
                .onSubmit(add)

            Button(action: add) {
                Label("Add", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .tint(WatchPriorityStyle.accent)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 4)
        .navigationTitle("Add Task")
    }

    private func add() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        connector.addTask(title: trimmed)
        dismiss()
    }
}
