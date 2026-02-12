import SwiftUI

struct VoiceStagingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = LocalStore.shared

    @State private var drafts: [VoiceParsedTaskDraft] = LocalStore.shared.voiceStagingDrafts
    @State private var showDiscardPrompt = false
    @State private var showValidationAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Review before saving. Nothing gets added to your task list until you confirm.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                ForEach(Array(drafts.enumerated()), id: \.element.id) { index, _ in
                    draftEditor(index: index)
                }
                .onDelete { offsets in
                    drafts.remove(atOffsets: offsets)
                    syncDraftsToStore()
                }
                .onMove { source, destination in
                    drafts.move(fromOffsets: source, toOffset: destination)
                    syncDraftsToStore()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Voice Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if drafts.isEmpty {
                            store.clearVoiceStaging()
                            dismiss()
                        } else {
                            showDiscardPrompt = true
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save All") {
                        saveAllDrafts()
                    }
                    .disabled(drafts.isEmpty)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        addDraft()
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
        }
        .interactiveDismissDisabled(true)
        .alert("Discard staged voice tasks?", isPresented: $showDiscardPrompt) {
            Button("Continue Editing", role: .cancel) {}
            Button("Discard", role: .destructive) {
                store.clearVoiceStaging()
                dismiss()
            }
        } message: {
            Text("Your staged tasks will be removed.")
        }
        .alert("Missing required fields", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Each task needs a title before it can be saved.")
        }
        .onAppear {
            drafts = store.voiceStagingDrafts
        }
    }

    @ViewBuilder
    private func draftEditor(index: Int) -> some View {
        if drafts.indices.contains(index) {
            Section("Task \(index + 1)") {
                if drafts[index].needsReview {
                    Text("Needs Review")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }

                TextField("Task title", text: binding(for: index, keyPath: \.title))
                if drafts[index].title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Title is required")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                TextField("Notes", text: binding(for: index, keyPath: \.notes), axis: .vertical)
                    .lineLimit(2...6)

                Picker("Priority", selection: binding(for: index, keyPath: \.priority)) {
                    ForEach(Priority.allCases) { priority in
                        Text(priority.label).tag(priority)
                    }
                }

                Toggle("Has Date", isOn: Binding(
                    get: { drafts[index].dueDate != nil },
                    set: { hasDate in
                        if hasDate {
                            drafts[index].dueDate = drafts[index].dueDate ?? Calendar.current.startOfDay(for: Date())
                        } else {
                            drafts[index].dueDate = nil
                        }
                        syncDraftsToStore()
                    }
                ))

                if drafts[index].dueDate != nil {
                    DatePicker(
                        "Due Date",
                        selection: Binding(
                            get: { drafts[index].dueDate ?? Date() },
                            set: { newDate in
                                drafts[index].dueDate = newDate
                                syncDraftsToStore()
                            }
                        ),
                        displayedComponents: [.date]
                    )
                }

                categoryChips(index: index)

                Button("Save This Task") {
                    saveSingleDraft(index: index)
                }
                .disabled(drafts[index].title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    @ViewBuilder
    private func categoryChips(index: Int) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.sortedCategories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: drafts[index].categories.contains(category.id),
                        onTap: {
                            if drafts[index].categories.contains(category.id) {
                                drafts[index].categories.removeAll { $0 == category.id }
                            } else {
                                drafts[index].categories.append(category.id)
                            }
                            drafts[index].categories.sort()
                            syncDraftsToStore()
                        }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func binding<Value>(for index: Int, keyPath: WritableKeyPath<VoiceParsedTaskDraft, Value>) -> Binding<Value> {
        Binding(
            get: { drafts[index][keyPath: keyPath] },
            set: { newValue in
                drafts[index][keyPath: keyPath] = newValue
                syncDraftsToStore()
            }
        )
    }

    private func addDraft() {
        drafts.append(
            VoiceParsedTaskDraft(
                title: "",
                notes: "",
                categories: [],
                priority: .medium,
                dueDate: nil,
                confidenceScore: 1.0,
                needsReview: false
            )
        )
        syncDraftsToStore()
    }

    private func saveSingleDraft(index: Int) {
        guard drafts.indices.contains(index) else { return }
        let draft = drafts[index]
        guard validate([draft]) else {
            showValidationAlert = true
            return
        }

        persistDraft(draft)
        drafts.remove(at: index)
        syncDraftsToStore()

        if drafts.isEmpty {
            store.clearVoiceStaging()
            dismiss()
        }
    }

    private func saveAllDrafts() {
        guard validate(drafts) else {
            showValidationAlert = true
            return
        }

        drafts.forEach(persistDraft(_:))
        drafts = []
        store.clearVoiceStaging()
        dismiss()
    }

    private func validate(_ drafts: [VoiceParsedTaskDraft]) -> Bool {
        drafts.allSatisfy { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func persistDraft(_ draft: VoiceParsedTaskDraft) {
        let notes = draft.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let task = Task(
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            categories: draft.categories,
            priority: draft.priority,
            dueDate: draft.dueDate,
            taskNotes: notes.isEmpty ? nil : notes
        )
        _ = store.addTask(task)
    }

    private func syncDraftsToStore() {
        store.updateVoiceStagingDrafts(drafts)
    }
}
