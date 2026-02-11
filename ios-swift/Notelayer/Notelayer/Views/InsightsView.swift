import SwiftUI
import Charts

private enum InsightsRoute: Hashable {
    case trend
    case category
    case usage
    case gap
    case oldestOpen
}

private struct DataRowModel: Identifiable, Hashable {
    let id: String
    let iconText: String?
    let primaryText: String
    let secondaryText: String?
    let trailingValueText: String?

    init(
        id: String,
        iconText: String? = nil,
        primaryText: String,
        secondaryText: String?,
        trailingValueText: String?
    ) {
        self.id = id
        self.iconText = iconText
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.trailingValueText = trailingValueText
    }
}

private struct DataRowView: View {
    let row: DataRowModel

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    if let iconText = row.iconText {
                        Text(iconText)
                    }
                    Text(row.primaryText)
                        .lineLimit(1)
                }
                if let secondaryText = row.secondaryText {
                    Text(secondaryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            if let trailingValueText = row.trailingValueText {
                Text(trailingValueText)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct DataRowsSection: View {
    let title: String
    let rows: [DataRowModel]
    let emptyMessage: String?

    init(title: String, rows: [DataRowModel], emptyMessage: String? = nil) {
        self.title = title
        self.rows = rows
        self.emptyMessage = emptyMessage
    }

    var body: some View {
        Section(title) {
            if rows.isEmpty {
                if let emptyMessage {
                    Text(emptyMessage)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(rows) { row in
                    DataRowView(row: row)
                }
            }
        }
    }
}

struct InsightsView: View {
    @StateObject private var store = LocalStore.shared
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedWindow: InsightsWindow = .days30
    @State private var isLoading = true
    @State private var snapshotModel: InsightsSnapshotModel? = nil
    @State private var isDataCoverageExpanded = false

    @State private var showingProfileSettings = false
    @State private var showingAppearance = false
    @State private var showingCategoryManager = false

    @State private var viewSession: AnalyticsViewSession? = nil
    @State private var profileViewSession: AnalyticsViewSession? = nil
    @State private var appearanceViewSession: AnalyticsViewSession? = nil
    @State private var categoryViewSession: AnalyticsViewSession? = nil

    private var hasAnyUsageData: Bool {
        guard let snapshotModel else { return false }
        return snapshotModel.totals.all > 0 || snapshotModel.featureStats.contains(where: { $0.allTimeCount > 0 })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading || snapshotModel == nil {
                    ProgressView("Loading Insights…")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 120)
                } else {
                    let snapshot = snapshotModel!
                    LazyVStack(spacing: 12) {
                        dataCoverageCard
                        oldestOpenTasksSnapshotCard(snapshot: snapshot)

                        if hasAnyUsageData {
                            totalsCard(snapshot: snapshot)
                            trendCard(snapshot: snapshot)
                            categorySnapshotCard(snapshot: snapshot)
                            usageSnapshotCard(snapshot: snapshot)
                            timeOfDaySnapshotCard(snapshot: snapshot)
                            gapAnalysisSnapshotCard(snapshot: snapshot)
                        } else {
                            emptyStateCard
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AppHeaderLogo()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    topRightGearMenu
                }
            }
            .navigationDestination(for: InsightsRoute.self) { route in
                switch route {
                case .trend:
                    if let snapshotModel {
                        InsightsTrendDetailView(snapshot: snapshotModel, selectedWindow: selectedWindow)
                    }
                case .category:
                    if let snapshotModel {
                        InsightsCategoryDetailView(snapshot: snapshotModel)
                    }
                case .usage:
                    if let snapshotModel {
                        InsightsUsageDetailView(snapshot: snapshotModel)
                    }
                case .gap:
                    if let snapshotModel {
                        InsightsGapDetailView(snapshot: snapshotModel)
                    }
                case .oldestOpen:
                    if let snapshotModel {
                        InsightsOldestOpenTasksDetailView(snapshot: snapshotModel)
                    }
                }
            }
            .sheet(isPresented: $showingProfileSettings) {
                ProfileSettingsView()
                    .environmentObject(authService)
                    .environmentObject(theme)
                    .onAppear {
                        profileViewSession = AnalyticsService.shared.trackViewOpen(
                            viewName: AnalyticsViewName.profileSettings,
                            tabName: AnalyticsTabName.insights,
                            source: AnalyticsViewName.insightsOverview
                        )
                    }
                    .onDisappear {
                        AnalyticsService.shared.trackViewDuration(profileViewSession)
                        profileViewSession = nil
                    }
            }
            .sheet(isPresented: $showingAppearance) {
                AppearanceView()
                    .preferredColorScheme(theme.preferredColorScheme)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        appearanceViewSession = AnalyticsService.shared.trackViewOpen(
                            viewName: AnalyticsViewName.appearance,
                            tabName: AnalyticsTabName.insights,
                            source: AnalyticsViewName.insightsOverview
                        )
                    }
                    .onDisappear {
                        AnalyticsService.shared.trackViewDuration(appearanceViewSession)
                        appearanceViewSession = nil
                    }
            }
            .sheet(isPresented: $showingCategoryManager) {
                CategoryManagerView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .onAppear {
                        categoryViewSession = AnalyticsService.shared.trackViewOpen(
                            viewName: AnalyticsViewName.categoryManager,
                            tabName: AnalyticsTabName.insights,
                            source: AnalyticsViewName.insightsOverview
                        )
                    }
                    .onDisappear {
                        AnalyticsService.shared.trackViewDuration(categoryViewSession)
                        categoryViewSession = nil
                    }
            }
            .onAppear {
                if isLoading {
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
                refreshSnapshot()
                viewSession = AnalyticsService.shared.trackViewOpen(
                    viewName: AnalyticsViewName.insightsOverview,
                    tabName: AnalyticsTabName.insights
                )
            }
            .onDisappear {
                AnalyticsService.shared.trackViewDuration(viewSession)
                viewSession = nil
            }
            .onReceive(NotificationCenter.default.publisher(for: .insightsTelemetryDidUpdate)) { _ in
                refreshSnapshot()
            }
            .onReceive(store.$tasks) { _ in refreshSnapshot() }
            .onReceive(store.$categories) { _ in refreshSnapshot() }
            .onChange(of: selectedWindow) { _ in refreshSnapshot() }
        }
    }

    private var dataCoverageCard: some View {
        let snapshot = snapshotModel
        return InsetCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Notelayer Data Insights (Experimental Feature)")
                        .font(.headline)
                    Spacer()
                    Image(systemName: isDataCoverageExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.tokens.textSecondary)
                }

                if let firstUsage = snapshot?.firstAppUsageDate {
                    Text("App usage tracking started \(firstUsage.formatted(date: .abbreviated, time: .omitted)).")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(theme.tokens.accent)
                } else {
                    Text("No usage telemetry has been captured yet on this device.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(theme.tokens.accent)
                }

                if isDataCoverageExpanded {
                    Text("Task totals and trends are calculated from tasks stored on this device.")
                        .font(.footnote)
                        .foregroundStyle(theme.tokens.textSecondary)
                    Text("Feature and app usage metrics are captured while you use Notelayer on this device.")
                        .font(.footnote)
                        .foregroundStyle(theme.tokens.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isDataCoverageExpanded.toggle()
            }
        }
    }

    private var emptyStateCard: some View {
        InsetCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("No Insights Yet")
                    .font(.headline)
                Text("Create or complete tasks to populate historical analytics.")
                    .font(.subheadline)
                    .foregroundStyle(theme.tokens.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func totalsCard(snapshot: InsightsSnapshotModel) -> some View {
        InsetCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Task Totals")
                    .font(.headline)
                HStack {
                    metricPill(title: "All", value: snapshot.totals.all)
                    metricPill(title: "Open", value: snapshot.totals.open)
                    metricPill(title: "Done", value: snapshot.totals.done)
                }
            }
        }
    }

    private func oldestOpenTasksSnapshotCard(snapshot: InsightsSnapshotModel) -> some View {
        NavigationLink(value: InsightsRoute.oldestOpen) {
            InsetCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Oldest Open Tasks")
                        .font(.headline)

                    if snapshot.oldestOpenTasksPreview.isEmpty {
                        Text("All caught up. No open tasks waiting right now.")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(theme.tokens.accent)
                    } else {
                        ForEach(snapshot.oldestOpenTasksPreview) { openTask in
                            HStack(spacing: 10) {
                                Text("\(openTask.ageDays)d")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(theme.tokens.textSecondary)
                                    .frame(width: 38, alignment: .leading)
                                Text(openTask.title)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                        Text("Showing up to 3 oldest open tasks.")
                            .font(.footnote)
                            .foregroundStyle(theme.tokens.textSecondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsOldestOpenDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        })
    }

    private func trendCard(snapshot: InsightsSnapshotModel) -> some View {
        NavigationLink(value: InsightsRoute.trend) {
            InsetCard {
                VStack(alignment: .leading, spacing: 10) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Historical Tasks")
                                .font(.headline)
                            Picker("Window", selection: $selectedWindow) {
                                ForEach(InsightsWindow.allCases) { window in
                                    Text(window.title).tag(window)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    } else {
                        HStack {
                            Text("Historical Tasks")
                                .font(.headline)
                            Spacer()
                            Picker("Window", selection: $selectedWindow) {
                                ForEach(InsightsWindow.allCases) { window in
                                    Text(window.title).tag(window)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 220)
                        }
                    }

                    Chart(snapshot.trendWindow) { point in
                        LineMark(x: .value("Day", point.date), y: .value("Count", point.added))
                            .foregroundStyle(by: .value("Series", "Added"))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                        LineMark(x: .value("Day", point.date), y: .value("Count", point.completed))
                            .foregroundStyle(by: .value("Series", "Completed"))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                            .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                    }
                    .chartForegroundStyleScale([
                        "Added": theme.tokens.accent,
                        "Completed": Color.green
                    ])
                    .chartLegend(position: .bottom, spacing: 12)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 210)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Tasks added and completed trend")
                    .accessibilityValue("Added \(snapshot.trendWindow.reduce(0) { $0 + $1.added }), completed \(snapshot.trendWindow.reduce(0) { $0 + $1.completed }) over \(selectedWindow.rawValue) days")

                    Text("Compare added vs completed tasks across \(selectedWindow.rawValue) days.")
                        .font(.footnote)
                        .foregroundStyle(theme.tokens.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsTrendDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        })
    }

    private func categorySnapshotCard(snapshot: InsightsSnapshotModel) -> some View {
        let top = Array(snapshot.categoryStats.sorted(by: { $0.combinedCount > $1.combinedCount }).prefix(6))
        return NavigationLink(value: InsightsRoute.category) {
            InsetCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Category Usage")
                        .font(.headline)

                    Chart(top) { stat in
                        BarMark(
                            x: .value("Count", stat.addedCount),
                            y: .value("Category", stat.categoryName)
                        )
                        .foregroundStyle(by: .value("Series", "Added"))
                        .position(by: .value("Series", "Added"))

                        BarMark(
                            x: .value("Count", stat.completedCount),
                            y: .value("Category", stat.categoryName)
                        )
                        .foregroundStyle(by: .value("Series", "Completed"))
                        .position(by: .value("Series", "Completed"))
                    }
                    .chartForegroundStyleScale([
                        "Added": theme.tokens.accent.opacity(0.85),
                        "Completed": differentiateWithoutColor ? Color.primary : Color.green.opacity(0.8)
                    ])
                    .chartLegend(position: .bottom, spacing: 12)
                    .frame(height: 220)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Added and completed tasks by category")

                    Text("Includes uncategorized and zero-count categories in detail.")
                        .font(.footnote)
                        .foregroundStyle(theme.tokens.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsCategoryDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        })
    }

    private func usageSnapshotCard(snapshot: InsightsSnapshotModel) -> some View {
        let topFeatures = Array(snapshot.mostUsedFeatures.prefix(5))
        return NavigationLink(value: InsightsRoute.usage) {
            InsetCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Feature Usage")
                        .font(.headline)

                    Chart(topFeatures) { item in
                        BarMark(
                            x: .value("Feature", item.title),
                            y: .value("Events", item.value)
                        )
                        .foregroundStyle(theme.tokens.accent)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 180)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Most used features")

                    Text("Most/least used rankings are available in detail view.")
                        .font(.footnote)
                        .foregroundStyle(theme.tokens.textSecondary)
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsUsageDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        })
    }

    private func timeOfDaySnapshotCard(snapshot: InsightsSnapshotModel) -> some View {
        NavigationLink(value: InsightsRoute.usage) {
            InsetCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Time of Day")
                        .font(.headline)

                    Chart(snapshot.hourBuckets) { hour in
                        LineMark(
                            x: .value("Hour", hour.hour),
                            y: .value("Count", hour.addedCount)
                        )
                        .foregroundStyle(by: .value("Series", "Added"))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                        LineMark(
                            x: .value("Hour", hour.hour),
                            y: .value("Count", hour.completedCount)
                        )
                        .foregroundStyle(by: .value("Series", "Completed"))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                        .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                        LineMark(
                            x: .value("Hour", hour.hour),
                            y: .value("Count", hour.appUsageCount)
                        )
                        .foregroundStyle(by: .value("Series", "App Usage"))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [2, 3]))
                        .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                    }
                    .chartForegroundStyleScale([
                        "Added": theme.tokens.accent,
                        "Completed": differentiateWithoutColor ? Color.primary.opacity(0.8) : Color.green,
                        "App Usage": differentiateWithoutColor ? Color.secondary : Color.orange
                    ])
                    .chartLegend(position: .bottom, spacing: 12)
                    .frame(height: 200)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Time of day patterns for task and app usage")
                    .accessibilityValue("Most active hour \(snapshot.mostUsedHours.first?.title ?? "N/A")")
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsUsageDetail,
                "tab_name": AnalyticsTabName.insights,
                "source_view": "time_of_day_card"
            ])
        })
    }

    private func gapAnalysisSnapshotCard(snapshot: InsightsSnapshotModel) -> some View {
        let unused = snapshot.featureStats.filter { $0.gapStatus == .unused }.count
        let underused = snapshot.featureStats.filter { $0.gapStatus == .underused }.count
        let used = snapshot.featureStats.filter { $0.gapStatus == .used }.count
        return NavigationLink(value: InsightsRoute.gap) {
            InsetCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Features You're Using in the App")
                        .font(.headline)
                    Text("See which features are active in the current insights window and which still need attention.")
                        .font(.footnote)
                        .foregroundStyle(theme.tokens.textSecondary)
                    HStack {
                        metricPill(title: "Used", value: used)
                        metricPill(title: "Underused", value: underused)
                        metricPill(title: "Unused", value: unused)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsGapDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        })
    }

    private var topRightGearMenu: some View {
        AppHeaderGearMenu(
            onAppearance: { showingAppearance = true },
            onCategoryManager: { showingCategoryManager = true },
            onProfileSettings: { showingProfileSettings = true }
        )
    }

    private func metricPill(title: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.tokens.textSecondary)
            Text("\(value)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(theme.tokens.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(theme.tokens.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func refreshSnapshot() {
        snapshotModel = InsightsAggregator.buildSnapshot(
            tasks: store.tasks,
            categories: store.sortedCategories,
            telemetry: InsightsTelemetryStore.shared.snapshot(),
            selectedWindow: selectedWindow
        )
    }
}

private struct InsightsTrendDetailView: View {
    let snapshot: InsightsSnapshotModel
    let selectedWindow: InsightsWindow
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                InsetCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Trend (\(selectedWindow.rawValue) Days)")
                            .font(.headline)
                        Chart(snapshot.trendWindow) { point in
                            LineMark(x: .value("Date", point.date), y: .value("Count", point.added))
                                .foregroundStyle(by: .value("Series", "Added"))
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                            LineMark(x: .value("Date", point.date), y: .value("Count", point.completed))
                                .foregroundStyle(by: .value("Series", "Completed"))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                                .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                        }
                        .chartForegroundStyleScale([
                            "Added": Color.blue,
                            "Completed": differentiateWithoutColor ? Color.primary : Color.green
                        ])
                        .chartLegend(position: .bottom, spacing: 12)
                        .frame(height: 240)
                    }
                }

                InsetCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All-Time Overview")
                            .font(.headline)
                        Chart(snapshot.trendAllTime) { point in
                            AreaMark(x: .value("Date", point.date), y: .value("Count", point.added))
                                .foregroundStyle(.blue.opacity(0.2))
                            LineMark(x: .value("Date", point.date), y: .value("Count", point.added))
                                .foregroundStyle(by: .value("Series", "Added"))
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            LineMark(x: .value("Date", point.date), y: .value("Count", point.completed))
                                .foregroundStyle(by: .value("Series", "Completed"))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                        }
                        .chartForegroundStyleScale([
                            "Added": Color.blue,
                            "Completed": differentiateWithoutColor ? Color.primary : Color.green
                        ])
                        .chartLegend(position: .bottom, spacing: 12)
                        .frame(height: 240)
                    }
                }
            }
            .padding(16)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
        }
        .navigationTitle("Historical Tasks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsTrendDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        }
    }
}

private struct InsightsCategoryDetailView: View {
    let snapshot: InsightsSnapshotModel

    var body: some View {
        List {
            Section("Added vs. Completed") {
                Chart(snapshot.categoryStats) { stat in
                    BarMark(x: .value("Category", stat.categoryName), y: .value("Added", stat.addedCount))
                        .foregroundStyle(.blue.opacity(0.8))
                    BarMark(x: .value("Category", stat.categoryName), y: .value("Completed", stat.completedCount))
                        .foregroundStyle(.green.opacity(0.8))
                }
                .frame(height: 260)
            }

            DataRowsSection(
                title: "Tasks Left per Category",
                rows: snapshot.categoryStats.map { stat in
                    DataRowModel(
                        id: "open-\(stat.id)",
                        iconText: stat.categoryIcon,
                        primaryText: stat.categoryName,
                        secondaryText: nil,
                        trailingValueText: "\(stat.openCount)"
                    )
                }
            )

            DataRowsSection(
                title: "Calendar Export by Category",
                rows: snapshot.categoryStats.map { stat in
                    DataRowModel(
                        id: "export-\(stat.id)",
                        iconText: stat.categoryIcon,
                        primaryText: stat.categoryName,
                        secondaryText: "\(String(format: "%.1f", stat.calendarExportRatePer100)) per 100 active",
                        trailingValueText: "\(stat.calendarExportCount)"
                    )
                }
            )
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
        }
        .navigationTitle("Category Insights")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsCategoryDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        }
    }
}

private struct InsightsUsageDetailView: View {
    let snapshot: InsightsSnapshotModel
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        List {
            Section("Hourly Usage") {
                Chart(snapshot.hourBuckets) { hour in
                    LineMark(x: .value("Hour", hour.hour), y: .value("Count", hour.addedCount))
                        .foregroundStyle(by: .value("Series", "Added"))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                    LineMark(x: .value("Hour", hour.hour), y: .value("Count", hour.completedCount))
                        .foregroundStyle(by: .value("Series", "Completed"))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                        .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                    LineMark(x: .value("Hour", hour.hour), y: .value("Count", hour.appUsageCount))
                        .foregroundStyle(by: .value("Series", "App Usage"))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [2, 3]))
                        .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                }
                .chartForegroundStyleScale([
                    "Added": Color.blue,
                    "Completed": differentiateWithoutColor ? Color.primary : Color.green,
                    "App Usage": differentiateWithoutColor ? Color.secondary : Color.orange
                ])
                .chartLegend(position: .bottom, spacing: 12)
                .frame(height: 220)
            }

            DataRowsSection(
                title: "Most Used Features",
                rows: snapshot.mostUsedFeatures.map { item in
                    DataRowModel(
                        id: "most-feature-\(item.id)",
                        primaryText: item.title,
                        secondaryText: nil,
                        trailingValueText: "\(item.value)"
                    )
                }
            )

            DataRowsSection(
                title: "Least Used Features",
                rows: snapshot.leastUsedFeatures.map { item in
                    DataRowModel(
                        id: "least-feature-\(item.id)",
                        primaryText: item.title,
                        secondaryText: nil,
                        trailingValueText: "\(item.value)"
                    )
                }
            )

            DataRowsSection(
                title: "Most Active Hours",
                rows: snapshot.mostUsedHours.map { item in
                    DataRowModel(
                        id: "most-hour-\(item.id)",
                        primaryText: item.title,
                        secondaryText: nil,
                        trailingValueText: "\(item.value)"
                    )
                }
            )

            DataRowsSection(
                title: "Least Active Hours",
                rows: snapshot.leastUsedHours.map { item in
                    DataRowModel(
                        id: "least-hour-\(item.id)",
                        primaryText: item.title,
                        secondaryText: nil,
                        trailingValueText: "\(item.value)"
                    )
                }
            )
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
        }
        .navigationTitle("Usage Patterns")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsUsageDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        }
    }
}

private struct InsightsOldestOpenTasksDetailView: View {
    let snapshot: InsightsSnapshotModel

    var body: some View {
        List {
            Section("Open Tasks by Age (Days)") {
                Chart(snapshot.openTaskAgeBuckets) { bucket in
                    BarMark(
                        x: .value("Age Bucket", bucket.label),
                        y: .value("Open Tasks", bucket.count)
                    )
                    .foregroundStyle(.blue.opacity(0.8))
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 220)
            }

            DataRowsSection(
                title: "Oldest Open Tasks",
                rows: snapshot.oldestOpenTasksDrilldown.map { openTask in
                    DataRowModel(
                        id: openTask.id,
                        primaryText: openTask.title,
                        secondaryText: nil,
                        trailingValueText: "\(openTask.ageDays)d"
                    )
                },
                emptyMessage: "All caught up. No open tasks waiting right now."
            )

            if snapshot.totals.open > snapshot.oldestOpenTasksDrilldown.count {
                Section {
                    Text("Showing the 50 oldest open tasks out of \(snapshot.totals.open) open tasks.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
        }
        .navigationTitle("Oldest Open Tasks")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsOldestOpenDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        }
    }
}

private struct InsightsGapDetailView: View {
    let snapshot: InsightsSnapshotModel

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Window shows how many times each feature was used in the current insights window. All-time shows total usage since tracking started on this device.")
                    Text("Unused means zero window usage. Underused means usage is below the current window baseline. Used means usage meets or exceeds that baseline.")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            DataRowsSection(title: "Unused", rows: dataRows(for: .unused), emptyMessage: "None")
            DataRowsSection(title: "Underused", rows: dataRows(for: .underused), emptyMessage: "None")
            DataRowsSection(title: "Used", rows: dataRows(for: .used), emptyMessage: "None")
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: AppBottomClearance.contentBottomSpacerHeight)
        }
        .navigationTitle("Features You're Using in the App")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.logEvent(AnalyticsEventName.insightsDrilldownOpened, params: [
                "view_name": AnalyticsViewName.insightsGapDetail,
                "tab_name": AnalyticsTabName.insights
            ])
        }
    }

    private func dataRows(for status: InsightsGapStatus) -> [DataRowModel] {
        let features = snapshot.featureStats.filter { $0.gapStatus == status }
        return features.map { feature in
            DataRowModel(
                id: "gap-\(status.rawValue)-\(feature.id)",
                primaryText: feature.title,
                secondaryText: "All-Time \(feature.allTimeCount)",
                trailingValueText: "\(feature.windowCount)"
            )
        }
    }
}
