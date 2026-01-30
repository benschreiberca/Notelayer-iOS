import SwiftUI

/// Shared task title section used by Task Detail and Share Sheet editors.
struct TaskEditorTitleSection: View {
    @Binding var title: String
    var placeholder: String = "Task title"
    var maxLength: Int = 200
    var lineLimit: ClosedRange<Int> = 1...10
    var focus: FocusState<Bool>.Binding? = nil

    var body: some View {
        Section("Title") {
            titleField
        }
    }

    private var titleField: some View {
        Group {
            if let focus = focus {
                TextField(placeholder, text: $title, axis: .vertical)
                    .focused(focus)
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title3.weight(.semibold))
                    .onChange(of: title) { newValue in
                        if newValue.count > maxLength {
                            title = String(newValue.prefix(maxLength))
                        }
                    }
            } else {
                TextField(placeholder, text: $title, axis: .vertical)
                    .lineLimit(lineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title3.weight(.semibold))
                    .onChange(of: title) { newValue in
                        if newValue.count > maxLength {
                            title = String(newValue.prefix(maxLength))
                        }
                    }
            }
        }
    }
}

/// Shared category chip section for selecting task categories.
struct TaskEditorCategorySection: View {
    let categories: [Category]
    @Binding var selectedIds: Set<String>
    var chipSize: CategoryChipSize = .standard

    var body: some View {
        Section("Categories") {
            CategoryChipGridView(
                categories: categories,
                selectedIds: $selectedIds,
                size: chipSize
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Shared segmented priority picker section.
struct TaskEditorPrioritySection: View {
    @Binding var priority: Priority

    var body: some View {
        Section("Priority") {
            Picker("Priority", selection: $priority) {
                ForEach(Priority.allCases, id: \.id) { p in
                    Text(p.label).tag(p)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

/// Shared notes editor with optional detected links list.
struct TaskEditorNotesSection: View {
    @Binding var notes: String
    let links: [URL]
    var minHeight: CGFloat = 100

    var body: some View {
        Section("Notes") {
            VStack(alignment: .leading, spacing: 8) {
                TextEditor(text: $notes)
                    .frame(minHeight: minHeight)

                if !links.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Links:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        ForEach(links, id: \.self) { url in
                            Link(destination: url) {
                                HStack(spacing: 6) {
                                    Image(systemName: "link")
                                        .font(.caption2)
                                    Text(url.absoluteString)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Shared URL editor that shows a tappable link when valid.
struct TaskEditorURLSection: View {
    @Binding var urlText: String

    var body: some View {
        Section("URL") {
            TextField("https://", text: $urlText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)

            if let url = URL(string: urlText), !urlText.isEmpty {
                Link(destination: url) {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .font(.caption2)
                        Text(url.absoluteString)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}
