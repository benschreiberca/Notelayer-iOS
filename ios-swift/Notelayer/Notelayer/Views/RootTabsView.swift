import SwiftUI

struct RootTabsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @StateObject private var welcomeCoordinator = WelcomeCoordinator.shared
    
    @State private var selectedTab: AppTab = .todos
    @State private var showWelcome = false
    @State private var hasCheckedWelcome = false
    
    var body: some View {
        ZStack {
            theme.tokens.screenBackground.ignoresSafeArea()
            ThemeBackground(preset: theme.preset)
            TabView(selection: $selectedTab) {
                NotesView()
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }
                    .tag(AppTab.notes)
                
                TodosView()
                    .tabItem {
                        Label("To-Dos", systemImage: "checklist")
                    }
                    .tag(AppTab.todos)
            }
            .background(UndoShakeHost())
        }
        .tint(theme.tokens.accent)
        .preferredColorScheme(theme.preferredColorScheme)
        .sheet(isPresented: $showWelcome) {
            WelcomeView(onDismiss: {
                welcomeCoordinator.markWelcomeAsSeen()
            })
            .environmentObject(authService)
            .environmentObject(theme)
            .presentationDetents([.large])
            .interactiveDismissDisabled()
        }
        .onAppear {
            checkAndShowWelcome()
        }
        .onChange(of: authService.user) { newValue in
            // Dismiss welcome if user signs in
            if newValue != nil && showWelcome {
                showWelcome = false
                welcomeCoordinator.markWelcomeAsSeen()
            }
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
}

private enum AppTab: Hashable {
    case notes
    case todos
}
