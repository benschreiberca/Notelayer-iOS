import SwiftUI

/// Profile & Settings page showing auth status, sync info, and sign-in options.
struct ProfileSettingsView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSignIn = false
    @State private var showAbout = false
    @State private var isBusy = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if authService.user != nil {
                        signedInSection
                    } else {
                        signedOutSection
                    }
                    
                    notificationsSection
                    
                    aboutSection
                }
                .padding(20)
            }
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
    
    private var signedInSection: some View {
        InsetCard {
            VStack(alignment: .leading, spacing: 16) {
                // Auth method
                VStack(alignment: .leading, spacing: 4) {
                    Text("Signed in with")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let method = authService.authMethodDisplay {
                        Text(method)
                            .font(.body)
                    }
                }
                
                Divider()
                
                // Sync status
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sync Status")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        syncStatusIndicator
                        syncStatusText
                    }
                }
                
                Divider()
                
                // Sign out button
                Button(role: .destructive) {
                    signOut()
                } label: {
                    Text("Sign Out")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isBusy)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
    }
    
    private var signedOutSection: some View {
        VStack(spacing: 16) {
            InsetCard {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign in to sync")
                            .font(.title3.bold())
                        
                        Text("Sync your notes and tasks across all your devices")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        showingSignIn = true
                    } label: {
                        Text("Sign In")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            // Notelayer website link
            Button {
                if let url = URL(string: "https://getnotelayer.com") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image("NotelayerLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Visit Notelayer")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("getnotelayer.com")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notifications")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            
            NavigationLink {
                RemindersSettingsView()
                    .environmentObject(theme)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge")
                        .font(.title3)
                        .foregroundColor(theme.tokens.accent)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reminders")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("Manage task notifications")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    showAbout.toggle()
                }
            } label: {
                HStack {
                    Text("About the app")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: showAbout ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if showAbout {
                InsetCard {
                    VStack(alignment: .leading, spacing: 12) {
                        // App version
                        HStack {
                            Text("Version")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(appVersion)
                        }
                        .font(.subheadline)
                        
                        Divider()
                        
                        // Privacy policy placeholder
                        Button {
                            // TODO: Open privacy policy
                        } label: {
                            HStack {
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
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
}

#Preview {
    ProfileSettingsView()
        .environmentObject(AuthService())
        .environmentObject(ThemeManager.shared)
}
