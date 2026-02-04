import SwiftUI

struct NotesView: View {
    @StateObject private var store = LocalStore.shared
    @State private var sharePayload: SharePayload? = nil
    @State private var showingProfileSettings = false
    @State private var showingAppearance = false
    @State private var showingCategoryManager = false
    @State private var viewSession: AnalyticsViewSession? = nil
    @State private var profileViewSession: AnalyticsViewSession? = nil
    @State private var appearanceViewSession: AnalyticsViewSession? = nil
    @State private var categoryViewSession: AnalyticsViewSession? = nil
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.notes) { note in
                            InsetCard {
                                Text(note.text)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .contentShape(Rectangle())
                            .rowContextMenu(
                                shareTitle: "Share…",
                                onShare: {
                                    sharePayload = SharePayload(items: [note.text])
                                },
                                onCopy: {
                                    UIPasteboard.general.string = note.text
                                }
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 12)
                }
                
                // Gear icon overlay
                VStack {
                    HStack {
                        Spacer()
                        
                        Menu {
                            Button {
                                showingAppearance = true
                            } label: {
                                Label("Colour Theme", systemImage: "paintbrush")
                            }
                            Button {
                                showingCategoryManager = true
                            } label: {
                                Label("Manage Categories", systemImage: "tag")
                            }
                            Button {
                                showingProfileSettings = true
                            } label: {
                                Label("Profile & Settings", systemImage: "person.circle")
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.secondary)
                                    .padding(8)
                                
                                // Notification badge (iOS Home Screen style overlap)
                                if authService.syncStatus.shouldShowBadge {
                                    Circle()
                                        .fill(authService.syncStatus.badgeColor == "red" ? Color.red : Color.yellow)
                                        .frame(width: 10, height: 10)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(.systemBackground), lineWidth: 1.5)
                                        )
                                        .offset(x: -6, y: 6) // Aggressive overlap from top-right corner
                                        .accessibilityLabel(authService.syncStatus.badgeColor == "red" ? "Not signed in" : "Sync error")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                store.load()
                viewSession = AnalyticsService.shared.trackViewOpen(
                    viewName: AnalyticsViewName.notes,
                    tabName: AnalyticsTabName.notes
                )
            }
            .onDisappear {
                AnalyticsService.shared.trackViewDuration(viewSession)
                viewSession = nil
            }
            .sheet(item: $sharePayload) { payload in
                ShareSheet(items: payload.items)
            }
            .sheet(isPresented: $showingProfileSettings) {
                ProfileSettingsView()
                    .environmentObject(authService)
                    .environmentObject(theme)
                    .onAppear {
                        profileViewSession = AnalyticsService.shared.trackViewOpen(
                            viewName: AnalyticsViewName.profileSettings,
                            tabName: AnalyticsTabName.notes,
                            source: AnalyticsViewName.notes
                        )
                    }
                    .onDisappear {
                        AnalyticsService.shared.trackViewDuration(profileViewSession)
                        profileViewSession = nil
                    }
            }
            .sheet(isPresented: $showingAppearance) {
                AppearanceView()
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        appearanceViewSession = AnalyticsService.shared.trackViewOpen(
                            viewName: AnalyticsViewName.appearance,
                            tabName: AnalyticsTabName.notes,
                            source: AnalyticsViewName.notes
                        )
                    }
                    .onDisappear {
                        AnalyticsService.shared.trackViewDuration(appearanceViewSession)
                        appearanceViewSession = nil
                    }
            }
            .sheet(isPresented: $showingCategoryManager) {
                CategoryManagerView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        categoryViewSession = AnalyticsService.shared.trackViewOpen(
                            viewName: AnalyticsViewName.categoryManager,
                            tabName: AnalyticsTabName.notes,
                            source: AnalyticsViewName.notes
                        )
                    }
                    .onDisappear {
                        AnalyticsService.shared.trackViewDuration(categoryViewSession)
                        categoryViewSession = nil
                    }
            }
        }
    }
}
