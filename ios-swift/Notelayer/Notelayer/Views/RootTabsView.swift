import SwiftUI
import UIKit

enum AppBottomClearance {
    static let tabRowHeight: CGFloat = 56
    static let contentBottomSpacerHeight: CGFloat = tabRowHeight * 2
    static let tabBottomPadding: CGFloat = 12
    /// Max width of the floating tab bar. Keeps it from stretching across an iPad.
    static let tabBarMaxWidth: CGFloat = 420
}

struct RootTabsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.colorScheme) private var systemColorScheme
    @StateObject private var welcomeCoordinator = WelcomeCoordinator.shared
    @StateObject private var store = LocalStore.shared
    @StateObject private var voiceStore = VoiceStateStore.shared

    @State private var selectedTab: AppTab = .todos
    @State private var showWelcome = false
    @State private var hasCheckedWelcome = false
    @State private var lastSelectedTab: AppTab = .todos
    @State private var tabViewSession: AnalyticsViewSession? = nil
    @State private var welcomeViewSession: AnalyticsViewSession? = nil
    @State private var isKeyboardVisible = false
    @State private var showVoiceCaptureSheet = false
    @State private var isSearchActive = false
    @State private var voicePulse = false
    @State private var pendingCategoryJump: String? = nil

    private var insightsEnabled: Bool {
        store.experimentalFeaturesEnabled
    }

    private var visibleTabs: [AppTab] {
        [.todos, .insights]
    }

    private var shouldShowVoiceButton: Bool {
        selectedTab == .todos && insightsEnabled && !isKeyboardVisible
    }

    private var shouldShowSearchButton: Bool {
        selectedTab == .todos && !isKeyboardVisible
    }

    private var isScreenshotGenerationMode: Bool {
        ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "true" ||
        ProcessInfo.processInfo.arguments.contains("--screenshot-generation")
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            theme.tokens.screenBackground.ignoresSafeArea()
            ThemeBackground(configuration: theme.configuration)

            Group {
                switch selectedTab {
                case .notes:
                    NotesView()
                case .todos:
                    TodosView(isSearchActive: $isSearchActive, categoryJump: $pendingCategoryJump)
                case .insights:
                    InsightsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(UndoShakeHost())

            if !isKeyboardVisible {
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(visibleTabs, id: \.self) { tab in
                            tabButton(tab: tab, icon: tab.iconName, label: tab.title)
                        }
                    }
                    .padding(4)
                    .frame(minHeight: AppBottomClearance.tabRowHeight)
                    // Cap the bar width so it doesn't stretch edge-to-edge on iPad;
                    // on iPhone the screen is narrower than the cap so it still fills.
                    .frame(maxWidth: AppBottomClearance.tabBarMaxWidth)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 26)
                .padding(.bottom, AppBottomClearance.tabBottomPadding)
            }

            if shouldShowSearchButton || shouldShowVoiceButton {
                VStack(spacing: 16) {
                    if shouldShowSearchButton {
                        Button {
                            isSearchActive.toggle()
                        } label: {
                            Image(systemName: isSearchActive ? "xmark" : "magnifyingglass")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(isSearchActive ? theme.tokens.accent : .white)
                                .frame(width: 58, height: 58)
                                .background(
                                    Circle()
                                        .fill(isSearchActive ? Color.white : theme.tokens.accent)
                                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isSearchActive ? "Close search" : "Search tasks")
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.18), value: isSearchActive)
                    }

                    if shouldShowVoiceButton {
                        ZStack {
                            // Pulse rings when recording
                            if voiceStore.isRecording {
                                ForEach([0, 1], id: \.self) { ringIndex in
                                    Circle()
                                        .stroke(theme.tokens.accent.opacity(voicePulse ? 0 : 0.45), lineWidth: 2)
                                        .frame(
                                            width: 58 + (voicePulse ? 32 : 0),
                                            height: 58 + (voicePulse ? 32 : 0)
                                        )
                                        .animation(
                                            .easeOut(duration: 1.1)
                                                .repeatForever(autoreverses: false)
                                                .delay(Double(ringIndex) * 0.55),
                                            value: voicePulse
                                        )
                                }
                            }

                            Button {
                                if selectedTab != .todos {
                                    selectedTab = .todos
                                }
                                showVoiceCaptureSheet = true
                            } label: {
                                Image(systemName: "waveform.and.mic")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 58, height: 58)
                                    .background(
                                        Circle()
                                            .fill(voiceStore.isRecording ? Color.red : theme.tokens.accent)
                                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Voice task entry")
                        }
                        .transition(.scale.combined(with: .opacity))
                        .onChange(of: voiceStore.isRecording) { recording in
                            voicePulse = false
                            if recording {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    voicePulse = true
                                }
                            }
                        }
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, AppBottomClearance.tabRowHeight + AppBottomClearance.tabBottomPadding + 20)
            }
        }
        .tint(theme.tokens.accent)
        .preferredColorScheme(theme.preferredColorScheme)
        .animation(.easeInOut(duration: 0.2), value: isKeyboardVisible)
        .animation(.easeInOut(duration: 0.2), value: shouldShowVoiceButton)
        .animation(.easeInOut(duration: 0.2), value: shouldShowSearchButton)
        .onAppear {
            configureMacWindowIfNeeded()
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
        .onReceive(NotificationCenter.default.publisher(for: .openOnboardingRequested)) { _ in
            hasCheckedWelcome = true
            showWelcome = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToCategoryInTodos)) { note in
            if let categoryId = note.userInfo?["categoryId"] as? String {
                pendingCategoryJump = categoryId
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = .todos }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenTaskFromNotification"))) { _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selectedTab = .todos }
        }
        .onChange(of: selectedTab) { newValue in
            if newValue != .todos { isSearchActive = false }
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

            if newValue == .insights {
                store.recordInsightsInteraction()
            }
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeView(onDismiss: {
                welcomeCoordinator.markWelcomeAsSeen()
            })
            .withThemeAppearance()
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
        .sheet(isPresented: $showVoiceCaptureSheet) {
            VoiceCaptureSheet()
                .withThemeAppearance()
                .adaptiveSheetDetents()
                .environmentObject(theme)
        }
        .sheet(
            isPresented: Binding(
                get: { voiceStore.isVoiceStagingPresented && insightsEnabled },
                set: { shouldPresent in
                    if !shouldPresent {
                        voiceStore.isVoiceStagingPresented = false
                    }
                }
            )
        ) {
            VoiceStagingView()
                .withThemeAppearance()
                .adaptiveSheetDetents(compact: [.large])
                .environmentObject(theme)
        }
        .onChange(of: authService.user) { newValue in
            if newValue != nil && showWelcome {
                showWelcome = false
                welcomeCoordinator.markWelcomeAsSeen()
            }
        }
    }

    private func tabButton(tab: AppTab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            guard selectedTab != tab else { return }
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
        .accessibilityIdentifier(tab.accessibilityIdentifier)
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
        if isScreenshotGenerationMode {
            showWelcome = false
            welcomeCoordinator.markWelcomeAsSeen()
            return
        }

        if welcomeCoordinator.shouldShowWelcome() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showWelcome = true
            }
        }
    }


    /// On Mac (Catalyst) give the window a sensible minimum size and hide the
    /// title bar so the app reads as a real desktop app, not a stretched iPad
    /// window. No-op on iOS/iPadOS.
    private func configureMacWindowIfNeeded() {
        #if targetEnvironment(macCatalyst)
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 480, height: 660)
        windowScene.titlebar?.titleVisibility = .hidden
        windowScene.titlebar?.toolbar = nil
        #endif
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

private enum AppTab: Hashable, CaseIterable {
    case notes
    case todos
    case insights

    var title: String {
        switch self {
        case .notes:
            return "Notes"
        case .todos:
            return "To-Dos"
        case .insights:
            return "Insights"
        }
    }

    var iconName: String {
        switch self {
        case .notes:
            return "note.text"
        case .todos:
            return "checklist"
        case .insights:
            return "chart.xyaxis.line"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .notes:
            return "app-tab-notes"
        case .todos:
            return "app-tab-todos"
        case .insights:
            return "app-tab-insights"
        }
    }
}
