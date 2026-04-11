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
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AppHeaderLogo()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    AppHeaderGearMenu(
                        onAppearance: { showingAppearance = true },
                        onCategoryManager: { showingCategoryManager = true },
                        onProfileSettings: { showingProfileSettings = true }
                    )
                }
            }
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
                    .withThemeAppearance()
            }
            .sheet(isPresented: $showingProfileSettings) {
                ProfileSettingsView()
                    .withThemeAppearance()
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
                    .withThemeAppearance()
                    .presentationDetents([.medium, .large])
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
                    .withThemeAppearance()
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
