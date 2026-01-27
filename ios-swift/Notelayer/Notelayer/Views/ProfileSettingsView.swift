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
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Pending Nags (Top)
                    preferencesSection
                    
                    // 2. Account
                    if authService.user != nil {
                        accountSection
                    } else {
                        signedOutSection
                    }
                    
                    // 3. About (Accordion)
                    aboutSection
                }
                .padding(20)
            }
            .background(theme.tokens.screenBackground)
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
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                // User Info Row
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
                    
                    Button {
                        forceRefresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.bold))
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .scaleEffect(isRefreshing ? 1.1 : 1.0)
                            .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.tokens.accent)
                    .disabled(isRefreshing)
                }
                .padding(16)
                
                Divider().padding(.leading, 56)
                
                // Manage Account Link
                NavigationLink {
                    ManageAccountView()
                } label: {
                    HStack {
                        Label("Manage Data & Account", systemImage: "person.badge.key")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .background(theme.tokens.cardFill)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.tokens.cardStroke, lineWidth: 1)
            )
        }
    }
    
    private var signedOutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
                
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sign in to sync")
                        .font(.headline)
                    
                    Text("Sync your notes and tasks across all your devices securely.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    showingSignIn = true
                } label: {
                    Text("Sign In")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(theme.tokens.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                Button {
                    if let url = URL(string: "https://getnotelayer.com") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image("NotelayerLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .cornerRadius(6)
                        Text("Visit getnotelayer.com")
                            .font(.footnote.weight(.medium))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .background(theme.tokens.cardFill)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.tokens.cardStroke, lineWidth: 1)
            )
        }
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pending Nags")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            
            NavigationLink {
                RemindersSettingsView()
                    .environmentObject(theme)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge.fill")
                        .font(.title3)
                        .foregroundColor(theme.tokens.accent)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("View all nags")
                            .font(.subheadline.weight(.semibold))
                        Text("Manage scheduled task nags")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(theme.tokens.cardFill)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.tokens.cardStroke, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                DisclosureGroup(isExpanded: $isAboutExpanded) {
                    VStack(spacing: 0) {
                        Divider().padding(.vertical, 8)
                        
                        HStack {
                            Text("Version")
                                .font(.subheadline)
                            Spacer()
                            Text(appVersion)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                        
                        Divider().padding(.vertical, 8)
                        
                        Button {
                            if let url = URL(string: "https://getnotelayer.com/privacy") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Text("Privacy Policy")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } label: {
                    Text("App Information")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                .padding(16)
            }
            .background(theme.tokens.cardFill)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.tokens.cardStroke, lineWidth: 1)
            )
        }
    }
    
    @ViewBuilder
    private var syncStatusIndicator: some View {
        switch authService.syncStatus {
        case .signedInSynced:
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
        case .signedInSyncError:
            Circle()
                .fill(.yellow)
                .frame(width: 8, height: 8)
        case .notSignedIn:
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
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
        isRefreshing = true
        _Concurrency.Task {
            await backendService.forceSync()
            try? await _Concurrency.Task.sleep(nanoseconds: 500_000_000) // Small delay for visual feedback
            isRefreshing = false
        }
    }
}

#Preview {
    ProfileSettingsView()
        .environmentObject(AuthService())
        .environmentObject(ThemeManager.shared)
}
