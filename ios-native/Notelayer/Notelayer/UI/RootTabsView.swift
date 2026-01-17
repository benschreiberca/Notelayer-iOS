 the//
//  RootTabsView.swift
//  Notelayer
//
//  Root navigation with two tabs: Notes and Todos
//

import SwiftUI

struct RootTabsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "doc.text")
                }
                .tag(0)
            
            TodosView()
                .tabItem {
                    Label("To-Dos", systemImage: "checkmark.square")
                }
                .tag(1)
        }
    }
}

#Preview {
    RootTabsView()
        .environmentObject(AppStore.shared)
}
