import SwiftUI

/// Full task detail — the deliberate place to read everything and complete a
/// task. Completing requires a tap on an explicit button here (or a swipe in
/// the list), so it never happens by accident.
struct WatchTaskDetailView: View {
    @EnvironmentObject private var connector: WatchConnector
    @Environment(\.dismiss) private var dismiss
    let task: WatchTaskDTO

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(task.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Circle()
                        .fill(WatchPriorityStyle.color(for: task.priority))
                        .frame(width: 9, height: 9)
                    Text(WatchPriorityStyle.label(for: task.priority))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let due = task.dueDate {
                    Label(
                        due.formatted(date: .complete, time: .omitted),
                        systemImage: "calendar"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                if !categoryChips.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(categoryChips, id: \.id) { cat in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: cat.colorHex))
                                    .frame(width: 8, height: 8)
                                Text("\(cat.icon) \(cat.name)")
                                    .font(.caption2)
                            }
                        }
                    }
                }

                if let notes = task.notes, !notes.isEmpty {
                    Divider()
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                Button {
                    connector.complete(task)
                    dismiss()
                } label: {
                    Label("Mark Complete", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var categoryChips: [WatchCategoryDTO] {
        task.categoryIds.compactMap { connector.category(for: $0) }
    }
}
