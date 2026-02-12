import SwiftUI
import UIKit

enum AppBottomClearance {
    static let tabRowHeight: CGFloat = 56
    static let contentBottomSpacerHeight: CGFloat = tabRowHeight * 2
    static let tabBottomPadding: CGFloat = 12
}

struct RootTabsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.colorScheme) private var systemColorScheme
    @StateObject private var welcomeCoordinator = WelcomeCoordinator.shared
    @StateObject private var store = LocalStore.shared

    @State private var selectedTab: AppTab = .todos
    @State private var showWelcome = false
    @State private var hasCheckedWelcome = false
    @State private var lastSelectedTab: AppTab = .todos
    @State private var tabViewSession: AnalyticsViewSession? = nil
    @State private var welcomeViewSession: AnalyticsViewSession? = nil
    @State private var isKeyboardVisible = false
    @State private var showVoiceCaptureSheet = false
    @State private var showInsightsHintBanner = false
    @State private var showLockedInsightsMessage = false
    @State private var isGenieTransitionActive = false

    private var insightsEnabled: Bool {
        store.experimentalFeaturesEnabled
    }

    private var visibleTabs: [AppTab] {
        if insightsEnabled {
            return AppTab.allCases
        }
        return AppTab.allCases.filter { $0 != .insights }
    }

    private var shouldShowVoiceButton: Bool {
        selectedTab == .todos && insightsEnabled && !isKeyboardVisible
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
                    TodosView()
                case .insights:
                    InsightsView()
                        .scaleEffect(isGenieTransitionActive ? 0.2 : 1.0, anchor: .topTrailing)
                        .opacity(isGenieTransitionActive ? 0 : 1)
                        .offset(
                            x: isGenieTransitionActive ? 180 : 0,
                            y: isGenieTransitionActive ? -220 : 0
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(UndoShakeHost())

            if !isKeyboardVisible {
                HStack(spacing: 0) {
                    ForEach(visibleTabs, id: \.self) { tab in
                        tabButton(tab: tab, icon: tab.iconName, label: tab.title)
                    }
                }
                .padding(4)
                .frame(minHeight: AppBottomClearance.tabRowHeight)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
                .padding(.horizontal, 26)
                .padding(.bottom, AppBottomClearance.tabBottomPadding)
            }

            if shouldShowVoiceButton {
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
                                .fill(theme.tokens.accent)
                                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                        )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 24)
                .padding(.bottom, AppBottomClearance.tabRowHeight + AppBottomClearance.tabBottomPadding + 20)
                .accessibilityLabel("Voice task entry")
                .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay(alignment: .top) {
            VStack(spacing: 8) {
                if showLockedInsightsMessage {
                    bannerRow(
                        text: "Enable this feature in Experimental Features.",
                        dismissAction: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showLockedInsightsMessage = false
                            }
                        }
                    )
                }

                if showInsightsHintBanner {
                    bannerRow(
                        text: "Insights is available in Experimental Features. Open Insights to view analytics.",
                        dismissAction: {
                            store.dismissInsightsHint()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showInsightsHintBanner = false
                            }
                        }
                    )
                }
            }
            .padding(.top, 10)
        }
        .tint(theme.tokens.accent)
        .preferredColorScheme(theme.preferredColorScheme)
        .animation(.easeInOut(duration: 0.2), value: isKeyboardVisible)
        .animation(.easeInOut(duration: 0.2), value: showInsightsHintBanner)
        .animation(.easeInOut(duration: 0.2), value: shouldShowVoiceButton)
        .onAppear {
            updateResolvedScheme()
            handleExperimentalVisibilityChange(triggeredByUser: false)
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
        .onReceive(NotificationCenter.default.publisher(for: .experimentalFeaturesDidChange)) { notification in
            let oldValue = notification.userInfo?["oldValue"] as? Bool ?? store.experimentalFeaturesEnabled
            let newValue = notification.userInfo?["newValue"] as? Bool ?? store.experimentalFeaturesEnabled
            handleExperimentalVisibilityChange(triggeredByUser: oldValue && !newValue)
        }
        .onReceive(NotificationCenter.default.publisher(for: .openOnboardingRequested)) { _ in
            guard insightsEnabled else { return }
            hasCheckedWelcome = true
            showWelcome = true
        }
        .onChange(of: store.experimentalFeaturesPreference) { _ in
            handleExperimentalVisibilityChange(triggeredByUser: false)
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

            if newValue == .insights {
                store.recordInsightsInteraction()
                showInsightsHintBanner = false
            }
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
        .sheet(isPresented: $showVoiceCaptureSheet) {
            VoiceCaptureSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .environmentObject(theme)
        }
        .sheet(
            isPresented: Binding(
                get: { store.isVoiceStagingPresented && insightsEnabled },
                set: { shouldPresent in
                    if !shouldPresent {
                        store.isVoiceStagingPresented = false
                    }
                }
            )
        ) {
            VoiceStagingView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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

    private func bannerRow(text: String, dismissAction: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(theme.tokens.accent)
            Text(text)
                .font(.footnote)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 4)
            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
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
        guard store.experimentalFeaturesEnabled else { return }

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

    private func handleExperimentalVisibilityChange(triggeredByUser: Bool) {
        if !insightsEnabled {
            showInsightsHintBanner = false
            showVoiceCaptureSheet = false
            if store.isVoiceStagingPresented {
                store.clearVoiceStaging()
            }
            if selectedTab == .insights {
                transitionToDefaultListView(withGenie: triggeredByUser)
            }
            return
        }

        checkAndShowWelcome()
        refreshInsightsHintBanner()
    }

    private func refreshInsightsHintBanner() {
        guard !isScreenshotGenerationMode else {
            showInsightsHintBanner = false
            return
        }
        guard insightsEnabled else {
            showInsightsHintBanner = false
            return
        }
        guard selectedTab != .insights else {
            showInsightsHintBanner = false
            return
        }
        guard store.shouldShowInsightsHint() else {
            showInsightsHintBanner = false
            return
        }

        store.markInsightsHintShown()
        withAnimation(.easeInOut(duration: 0.2)) {
            showInsightsHintBanner = true
        }
    }

    private func transitionToDefaultListView(withGenie: Bool) {
        showLockedInsightsMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showLockedInsightsMessage = false
            }
        }

        if withGenie {
            withAnimation(.easeInOut(duration: 0.35)) {
                isGenieTransitionActive = true
            }
        }

        if selectedTab != .todos {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selectedTab = .todos
            }
        }

        if withGenie {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                isGenieTransitionActive = false
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
