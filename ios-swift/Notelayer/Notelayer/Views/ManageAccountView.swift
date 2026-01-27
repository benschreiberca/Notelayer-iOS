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
            // iOS-standard Section (no custom wrappers)
            Section("Data") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Export Your Data")
                        .font(.headline)
                    Text("Download all your notes, tasks, and categories in a CSV format.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                
                Button {
                    exportData()
                } label: {
                    if isExporting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isExporting)
            }
            
            Section {
                Button(role: .destructive) {
                    signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle(isDestructive: true))
            }
            
            // iOS-standard Section (no custom wrappers)
            Section("Danger Zone") {
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Delete Account")
                                .font(.headline)
                                .foregroundStyle(.red)

                            Text("Permanently delete your NoteLayer account and all associated data. This includes all your tasks and categories stored in the cloud and on this device.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("This action cannot be undone.")
                                .font(.caption.bold())
                                .foregroundStyle(.red)
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Text("Delete Account...")
                        }
                        .buttonStyle(PrimaryButtonStyle(isDestructive: true))
                    }
                    .padding(.vertical, 8)
                } label: {
                    Label("The Big Red Button", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Manage Data & Account")
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
            ActivityViewWrapper(activityItems: [url])
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
    
    private func signOut() {
        isBusy = true
        errorMessage = ""
        defer { isBusy = false }
        
        do {
            try authService.signOut()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
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
        var csv = "Type,ID,Title,Categories,Priority,Due Date,Nag Date,Completed At,Created At,Notes\n"
        
        // Add Tasks
        for task in store.tasks {
            let type = "Task"
            let id = task.id
            let title = escapeCSV(task.title)
            let categories = escapeCSV(task.categories.joined(separator: "; "))
            let priority = task.priority.rawValue
            let dueDate = task.dueDate?.formatted() ?? ""
            let nagDate = task.reminderDate?.formatted() ?? ""
            let completedAt = task.completedAt?.formatted() ?? ""
            let createdAt = task.createdAt.formatted()
            let taskNotes = escapeCSV(task.taskNotes ?? "")
            
            csv += "\(type),\(id),\(title),\(categories),\(priority),\(dueDate),\(nagDate),\(completedAt),\(createdAt),\(taskNotes)\n"
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

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

struct ActivityViewWrapper: View {
    let activityItems: [Any]
    @State private var isPresented = false
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            // This is a dummy view to trigger the UIActivityViewController
            // from a stable place in the hierarchy.
            EmptyView()
        }
        .background(ActivityViewControllerPresenter(items: activityItems, isPresented: $isPresented))
    }
}

private struct ActivityViewControllerPresenter: UIViewControllerRepresentable {
    let items: [Any]
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                isPresented = false
            }
            
            // Present from the nearest view controller
            DispatchQueue.main.async {
                uiViewController.present(activityVC, animated: true)
            }
        }
    }
}
