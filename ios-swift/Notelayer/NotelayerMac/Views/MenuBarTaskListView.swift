import SwiftUI

struct MenuBarTaskListView: View {
    @EnvironmentObject var service: MacFirebaseService
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var selectedPriority: MacTaskPriority = .medium
    @FocusState private var addFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checklist")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("Notelayer")
                    .font(.headline)
                Spacer()
                Button {
                    Task { await service.fetchTasks() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Button {
                    service.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Quick-add field (always visible)
            HStack(spacing: 8) {
                TextField("Add a task…", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .focused($addFieldFocused)
                    .onSubmit { addTask() }

                Picker("", selection: $selectedPriority) {
                    ForEach(MacTaskPriority.allCases, id: \.self) { p in
                        Label(p.label, systemImage: p.systemImage).tag(p)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(width: 30)

                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(newTaskTitle.isEmpty ? .secondary : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(newTaskTitle.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Task list
            if service.tasks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No active tasks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(service.tasks) { task in
                            TaskRowView(task: task)
                            if task.id != service.tasks.last?.id {
                                Divider().padding(.leading, 40)
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
            }

            Divider()

            // Footer
            HStack {
                Text("\(service.tasks.count) active")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .task { await service.fetchTasks() }
    }

    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        newTaskTitle = ""
        Task { await service.addTask(title: title, priority: selectedPriority) }
    }
}

private struct TaskRowView: View {
    @EnvironmentObject var service: MacFirebaseService
    let task: MacTask
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            // Priority indicator dot
            Circle()
                .fill(Color(hex: task.priority.color) ?? .accentColor)
                .frame(width: 8, height: 8)

            Text(task.title)
                .font(.body)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isHovering {
                Button {
                    Task { await service.completeTask(id: task.id) }
                } label: {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovering ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.1) : Color.clear)
        .onHover { isHovering = $0 }
        .animation(.easeInOut(duration: 0.12), value: isHovering)
    }
}

private extension Color {
    init?(hex: String) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else { return nil }
        self = Color(
            red: Double((value >> 16) & 0xFF) / 255.0,
            green: Double((value >> 8) & 0xFF) / 255.0,
            blue: Double(value & 0xFF) / 255.0
        )
    }
}
