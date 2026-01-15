import SwiftUI

struct RootTabsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @State private var selectedTab: AppTab = .todos
    
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
                        Label("Todos", systemImage: "checklist")
                    }
                    .tag(AppTab.todos)
            }
        }
        .tint(theme.tokens.accent)
        .preferredColorScheme(theme.preferredColorScheme)
    }
}

private enum AppTab: Hashable {
    case notes
    case todos
}
