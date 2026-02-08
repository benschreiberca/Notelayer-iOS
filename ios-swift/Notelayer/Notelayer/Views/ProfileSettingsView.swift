import SwiftUI

/// Profile & Settings page showing auth status, sync info, and sign-in options.
struct ProfileSettingsView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var backendService: FirebaseBackendService
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSignIn = false
    @State private var isBusy = false
    @State private var errorMessage = ""
    @State private var isRefreshing = false
    @State private var isAboutExpanded = false
    
    var body: some View {
        NavigationStack {
            // iOS-standard List layout (like Settings app)
            List {
                // 1. Pending Nags (Top)
                preferencesSection
                
                // 2. Account (conditional: signed in vs signed out)
                if authService.user != nil {
                    accountSection
                } else {
                    signedOutSection
                }
                
                // 3. About (Accordion)
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingSignIn) {
                SignInSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // iOS-standard Section for signed-in account
    private var accountSection: some View {
        Section("Account") {
            // User Info Row with sync status
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundStyle(theme.tokens.accent)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(authService.authMethodDisplay ?? "Signed In")
                        .font(.subheadline.weight(.semibold))
                    
                    HStack(spacing: 4) {
                        syncStatusIndicator
                            .scaleEffect(isRefreshing ? 1.2 : 1.0)
                            .opacity(isRefreshing ? 0.6 : 1.0)
                            .animation(isRefreshing ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: isRefreshing)
                        
                        syncStatusText
                            .opacity(isRefreshing ? 0.7 : 1.0)
                            .animation(isRefreshing ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: isRefreshing)
                    }
                }
                
                Spacer()
                
                // Manual refresh disabled to avoid crashes/freezes; sync is automatic.
            }
            
            // Manage Account Link
            NavigationLink {
                ManageAccountView()
            } label: {
                Label("Manage Data & Account", systemImage: "person.badge.key")
            }
        }
    }
    
    // iOS-standard Section for signed-out state
    private var signedOutSection: some View {
        Section("Account") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sign in to sync")
                    .font(.headline)
                
                Text("Sync your notes and tasks across all your devices securely.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            
            Button {
                showingSignIn = true
            } label: {
                Text("Sign In")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    // iOS-standard Section for reminders/nags
    private var preferencesSection: some View {
        Section("Pending Nags") {
            NavigationLink {
                RemindersSettingsView()
                    .environmentObject(theme)
            } label: {
                Label("View all nags", systemImage: "bell.badge.fill")
            }
        }
    }
    
    // iOS-standard Section for app information
    private var aboutSection: some View {
        Section("About") {
            // Website link (always visible) - with custom app icon
            Link(destination: URL(string: "https://getnotelayer.com")!) {
                HStack(spacing: 12) {
                    Image("NotelayerLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text("Visit getnotelayer.com")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // DisclosureGroup for collapsible app info
            DisclosureGroup("App Information", isExpanded: $isAboutExpanded) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
                
                Link(destination: URL(string: "https://getnotelayer.com/privacy")!) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var syncStatusIndicator: some View {
        // Use iOS-standard badge style (like notification badges)
        switch authService.syncStatus {
        case .signedInSynced:
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundStyle(.green)
        case .signedInSyncError:
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(.yellow)
        case .notSignedIn:
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundStyle(.red)
        }
    }
    
    @ViewBuilder
    private var syncStatusText: some View {
        switch authService.syncStatus {
        case .signedInSynced(let lastSync):
            Text("Last synced \(relativeTime(from: lastSync))")
                .font(.subheadline)
        case .signedInSyncError(let error):
            Text("Sync error: \(error)")
                .font(.subheadline)
                .foregroundStyle(.orange)
        case .notSignedIn:
            Text("Not signed in")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func signOut() {
        isBusy = true
        errorMessage = ""
        defer { isBusy = false }
        
        do {
            try authService.signOut()
            // Optionally dismiss after sign out
            // dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func forceRefresh() {
        guard authService.user != nil else {
            #if DEBUG
            print("⚠️ [ProfileSettingsView] Force refresh skipped: no signed-in user")
            #endif
            return
        }
        guard !isRefreshing else { return }
        isRefreshing = true
        _Concurrency.Task { @MainActor in
            defer { isRefreshing = false }
            await backendService.forceSync()
            try? await _Concurrency.Task.sleep(nanoseconds: 500_000_000) // Small delay for visual feedback
        }
    }
}

#Preview {
    ProfileSettingsView()
        .environmentObject(AuthService())
        .environmentObject(ThemeManager.shared)
}
