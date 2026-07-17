#if targetEnvironment(macCatalyst)
import SwiftUI

/// Native Mac desktop shell. Replaces the iOS floating tab bar with a proper
/// `NavigationSplitView`: a sidebar of views + categories + tools on the left,
/// and the reused task/insights/settings content on the right.
///
/// Only compiled for Mac Catalyst — iPhone/iPad keep `RootTabsView`.
struct MacRootView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.colorScheme) private var systemColorScheme
    @StateObject private var store = LocalStore.shared
    @StateObject private var welcomeCoordinator = WelcomeCoordinator.shared

    @State private var selection: MacSidebarItem = .view(.list)
    @State private var viewMode: TodoViewMode = .list
    @State private var isSearchActive = false
    @State private var categoryJump: String? = nil
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showWelcome = false
    @State private var hasCheckedWelcome = false

    private var insightsEnabled: Bool { store.experimentalFeaturesEnabled }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } detail: {
            detail
        }
        .tint(theme.tokens.accent)
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear {
            configureMacWindow()
            updateResolvedScheme()
            checkAndShowWelcome()
        }
        .onChange(of: systemColorScheme) { newValue in
            if theme.mode == .system { theme.updateResolvedColorScheme(newValue) }
        }
        .onChange(of: theme.mode) { _ in updateResolvedScheme() }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToCategoryInTodos)) { note in
            if let categoryId = note.userInfo?["categoryId"] as? String {
                selectCategory(categoryId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openOnboardingRequested)) { _ in
            hasCheckedWelcome = true
            showWelcome = true
        }
        .onChange(of: authService.user) { newValue in
            if newValue != nil && showWelcome {
                showWelcome = false
                welcomeCoordinator.markWelcomeAsSeen()
            }
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeView(onDismiss: { welcomeCoordinator.markWelcomeAsSeen() })
                .withThemeAppearance()
                .environmentObject(authService)
                .environmentObject(theme)
                .presentationDetents([.large])
                .interactiveDismissDisabled()
        }
    }

    private func checkAndShowWelcome() {
        guard !hasCheckedWelcome else { return }
        hasCheckedWelcome = true
        if welcomeCoordinator.shouldShowWelcome() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showWelcome = true }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(selection: $selection) {
            Section("Views") {
                ForEach(TodoViewMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: icon(for: mode))
                        .tag(MacSidebarItem.view(mode))
                }
            }

            if !store.sortedCategories.isEmpty {
                Section("Categories") {
                    ForEach(store.sortedCategories) { category in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: category.color) ?? theme.tokens.accent)
                                .frame(width: 10, height: 10)
                            Text("\(category.icon) \(category.name)")
                                .lineLimit(1)
                        }
                        .tag(MacSidebarItem.category(category.id))
                    }
                }
            }

            Section {
                if insightsEnabled {
                    Label("Insights", systemImage: "chart.xyaxis.line")
                        .tag(MacSidebarItem.insights)
                }
                Label("Settings", systemImage: "gearshape")
                    .tag(MacSidebarItem.settings)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Notelayer")
        .onChange(of: selection) { newValue in
            switch newValue {
            case .view(let mode):
                viewMode = mode
                categoryJump = nil
            case .category(let id):
                viewMode = .category
                categoryJump = id
            default:
                break
            }
        }
    }

    // MARK: - Detail

    @ViewBuilder
    private var detail: some View {
        switch selection {
        case .view, .category:
            TodosView(
                isSearchActive: $isSearchActive,
                categoryJump: $categoryJump,
                externalViewMode: $viewMode
            )
            .background(UndoShakeHost())
        case .insights:
            InsightsView()
        case .settings:
            ProfileSettingsView()
        }
    }

    // MARK: - Helpers

    private func selectCategory(_ id: String) {
        selection = .category(id)
        viewMode = .category
        categoryJump = id
    }

    private func icon(for mode: TodoViewMode) -> String {
        switch mode {
        case .list: return "list.bullet"
        case .priority: return "flag"
        case .category: return "folder"
        case .date: return "calendar"
        }
    }

    private func configureMacWindow() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 720, height: 560)
        windowScene.titlebar?.titleVisibility = .hidden
        windowScene.titlebar?.toolbar = nil
    }

    private func updateResolvedScheme() {
        switch theme.mode {
        case .system: theme.updateResolvedColorScheme(systemColorScheme)
        case .light: theme.updateResolvedColorScheme(.light)
        case .dark: theme.updateResolvedColorScheme(.dark)
        }
    }
}

/// A selectable item in the Mac sidebar.
enum MacSidebarItem: Hashable {
    case view(TodoViewMode)
    case category(String)
    case insights
    case settings
}
#endif
