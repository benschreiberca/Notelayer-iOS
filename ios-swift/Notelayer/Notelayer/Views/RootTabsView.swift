import SwiftUI
import UIKit

struct RootTabsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.colorScheme) private var systemColorScheme
    @StateObject private var welcomeCoordinator = WelcomeCoordinator.shared
    
    @State private var selectedTab: AppTab = .todos
    @State private var showWelcome = false
    @State private var hasCheckedWelcome = false
    @State private var lastSelectedTab: AppTab = .todos
    @State private var tabViewSession: AnalyticsViewSession? = nil
    @State private var welcomeViewSession: AnalyticsViewSession? = nil
    @State private var isKeyboardVisible = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            theme.tokens.screenBackground.ignoresSafeArea()
            ThemeBackground(configuration: theme.configuration)
            
            // Content
            Group {
                switch selectedTab {
                case .notes:
                    NotesView()
                case .todos:
                    TodosView()
                case .insights:
                    InsightsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(UndoShakeHost())
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: isKeyboardVisible ? 0 : 80) // Reserve space for floating bar only when visible
            }
            
            // Floating Tab Bar (Pill style like iOS Settings Search)
            if !isKeyboardVisible {
                HStack(spacing: 0) {
                    tabButton(tab: .notes, icon: "note.text", label: "Notes")
                    tabButton(tab: .todos, icon: "checklist", label: "To-Dos")
                    tabButton(tab: .insights, icon: "chart.xyaxis.line", label: "Insights")
                }
                .padding(4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
                .padding(.horizontal, 26) // Fits three tabs while preserving floating pill feel
                .padding(.bottom, 24)
            }
        }
        .tint(theme.tokens.accent)
        .preferredColorScheme(theme.preferredColorScheme)
        .animation(.easeInOut(duration: 0.2), value: isKeyboardVisible)
        .onAppear {
            updateResolvedScheme()
            checkAndShowWelcome()
            tabViewSession = AnalyticsService.shared.trackViewOpen(
                viewName: viewName(for: selectedTab),
                tabName: tabName(for: selectedTab),
                source: "App Launch"
            )
        }
        .onChange(of: systemColorScheme) { newValue in
            if theme.mode == .system {
                theme.updateResolvedColorScheme(newValue)
            }
        }
        .onChange(of: theme.mode) { _ in
            updateResolvedScheme()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .onChange(of: selectedTab) { newValue in
            AnalyticsService.shared.trackViewDuration(tabViewSession)
            AnalyticsService.shared.trackTabSelected(
                tabName: tabName(for: newValue),
                previousTab: tabName(for: lastSelectedTab)
            )
            lastSelectedTab = newValue
            tabViewSession = AnalyticsService.shared.trackViewOpen(
                viewName: viewName(for: newValue),
                tabName: tabName(for: newValue),
                source: "Tab Switch"
            )
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeView(onDismiss: {
                welcomeCoordinator.markWelcomeAsSeen()
            })
            .environmentObject(authService)
            .environmentObject(theme)
            .presentationDetents([.large])
            .interactiveDismissDisabled()
            .onAppear {
                welcomeViewSession = AnalyticsService.shared.trackViewOpen(viewName: AnalyticsViewName.welcome)
            }
            .onDisappear {
                AnalyticsService.shared.trackViewDuration(welcomeViewSession)
                welcomeViewSession = nil
            }
        }
        .onChange(of: authService.user) { newValue in
            // Dismiss welcome if user signs in
            if newValue != nil && showWelcome {
                showWelcome = false
                welcomeCoordinator.markWelcomeAsSeen()
            }
        }
    }
    
    private func tabButton(tab: AppTab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .medium))
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? theme.tokens.accent : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(theme.tokens.accent.opacity(0.12))
                            .matchedGeometryEffect(id: "tabHighlight", in: tabNamespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
    
    @Namespace private var tabNamespace

    private func tabName(for tab: AppTab) -> String {
        switch tab {
        case .notes:
            return AnalyticsTabName.notes
        case .todos:
            return AnalyticsTabName.todos
        case .insights:
            return AnalyticsTabName.insights
        }
    }

    private func viewName(for tab: AppTab) -> String {
        switch tab {
        case .notes:
            return AnalyticsViewName.notes
        case .todos:
            return AnalyticsViewName.todosList
        case .insights:
            return AnalyticsViewName.insightsOverview
        }
    }
    
    private func checkAndShowWelcome() {
        guard !hasCheckedWelcome else { return }
        hasCheckedWelcome = true
        
        let isSignedIn = authService.user != nil
        if welcomeCoordinator.shouldShowWelcome(isSignedIn: isSignedIn) {
            // Show welcome after 0.5s delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showWelcome = true
            }
        }
    }

    private func updateResolvedScheme() {
        switch theme.mode {
        case .system:
            theme.updateResolvedColorScheme(systemColorScheme)
        case .light:
            theme.updateResolvedColorScheme(.light)
        case .dark:
            theme.updateResolvedColorScheme(.dark)
        }
    }
}

private enum AppTab: Hashable {
    case notes
    case todos
    case insights
}
