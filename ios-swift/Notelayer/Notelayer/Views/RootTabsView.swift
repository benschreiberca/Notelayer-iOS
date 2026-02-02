import SwiftUI

struct RootTabsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.colorScheme) private var systemColorScheme
    @StateObject private var welcomeCoordinator = WelcomeCoordinator.shared
    
    @State private var selectedTab: AppTab = .todos
    @State private var showWelcome = false
    @State private var hasCheckedWelcome = false
    
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(UndoShakeHost())
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80) // Reserve space for floating bar
            }
            
            // Floating Tab Bar (Pill style like iOS Settings Search)
            HStack(spacing: 0) {
                tabButton(tab: .notes, icon: "note.text", label: "Notes")
                tabButton(tab: .todos, icon: "checklist", label: "To-Dos")
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
            .padding(.horizontal, 60) // Narrower pill
            .padding(.bottom, 24)
        }
        .tint(theme.tokens.accent)
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear {
            updateResolvedScheme()
            checkAndShowWelcome()
        }
        .onChange(of: systemColorScheme) { newValue in
            if theme.mode == .system {
                theme.updateResolvedColorScheme(newValue)
            }
        }
        .onChange(of: theme.mode) { _ in
            updateResolvedScheme()
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeView(onDismiss: {
                welcomeCoordinator.markWelcomeAsSeen()
            })
            .environmentObject(authService)
            .environmentObject(theme)
            .presentationDetents([.large])
            .interactiveDismissDisabled()
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
}
