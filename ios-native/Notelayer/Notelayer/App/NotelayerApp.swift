//
//  NotelayerApp.swift
//  Notelayer
//
//  Created for native iOS app
//

import SwiftUI

@main
struct NotelayerApp: App {
    @StateObject private var appStore = AppStore.shared
    
    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environmentObject(appStore)
                .onAppear {
                    Task {
                        await appStore.loadInitialData()
                    }
                }
        }
    }
}
