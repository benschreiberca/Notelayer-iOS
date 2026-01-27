import SwiftUI
import UniformTypeIdentifiers

struct ManageAccountView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var backendService: FirebaseBackendService
    @EnvironmentObject private var theme: ThemeManager
    @StateObject private var store = LocalStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteConfirmation = false
    @State private var isBusy = false
    @State private var errorMessage = ""
    @State private var exportURL: URL?
    @State private var isExporting = false
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Your Data")
                        .font(.headline)
                    Text("Download all your notes, tasks, and categories in a CSV format.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        exportData()
                    } label: {
                        if isExporting {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Label("Export to CSV", systemImage: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(theme.tokens.accent)
                    .disabled(isExporting)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Data")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    Text("Permanently delete your NoteLayer account and all associated data. This includes all your notes, tasks, and categories stored in the cloud and on this device.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("This action cannot be undone.")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Text("Delete Account...")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Danger Zone")
            }
        }
        .navigationTitle("Manage Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Permanently", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you absolutely sure? All your data will be permanently erased.")
        }
        .sheet(item: $exportURL) { url in
            ActivityView(activityItems: [url])
        }
        .overlay {
            if isBusy {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView()
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func exportData() {
        isExporting = true
        
        _Concurrency.Task {
            let csvString = generateCSV()
            let fileName = "Notelayer_Export_\(Date().formatted(date: .abbreviated, time: .omitted)).csv"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
                await MainActor.run {
                    self.exportURL = tempURL
                    self.isExporting = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to export data: \(error.localizedDescription)"
                    self.isExporting = false
                }
            }
        }
    }
    
    private func generateCSV() -> String {
        var csv = "Type,ID,Title/Text,Categories,Priority,Due Date,Completed At,Created At,Notes\n"
        
        // Add Tasks
        for task in store.tasks {
            let type = "Task"
            let id = task.id
            let title = escapeCSV(task.title)
            let categories = escapeCSV(task.categories.joined(separator: "; "))
            let priority = task.priority.rawValue
            let dueDate = task.dueDate?.formatted() ?? ""
            let completedAt = task.completedAt?.formatted() ?? ""
            let createdAt = task.createdAt.formatted()
            let taskNotes = escapeCSV(task.taskNotes ?? "")
            
            csv += "\(type),\(id),\(title),\(categories),\(priority),\(dueDate),\(completedAt),\(createdAt),\(taskNotes)\n"
        }
        
        // Add Notes
        for note in store.notes {
            let type = "Note"
            let id = note.id.uuidString
            let text = escapeCSV(note.text)
            let createdAt = note.createdAt.formatted()
            
            csv += "\(type),\(id),\(text),,,,,\(createdAt),\n"
        }
        
        return csv
    }
    
    private func escapeCSV(_ text: String) -> String {
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
    
    private func deleteAccount() {
        isBusy = true
        errorMessage = ""
        
        _Concurrency.Task {
            do {
                try await backendService.deleteAllUserData()
                try await authService.deleteAccount()
                isBusy = false
                dismiss()
            } catch {
                isBusy = false
                errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
