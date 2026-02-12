import Foundation

struct InsightsTaskTotals {
    let all: Int
    let open: Int
    let done: Int
}

struct InsightsDailyTrendPoint: Identifiable, Hashable {
    let date: Date
    let added: Int
    let completed: Int

    var id: Date { date }
}

struct InsightsHourBucketStat: Identifiable, Hashable {
    let hour: Int
    let addedCount: Int
    let completedCount: Int
    let appUsageCount: Int

    var id: Int { hour }
    var combinedCount: Int { addedCount + completedCount + appUsageCount }
    var label: String {
        let hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let suffix = hour < 12 ? "AM" : "PM"
        return "\(hour12)\(suffix)"
    }
}

struct InsightsCategoryUsageStat: Identifiable, Hashable {
    let categoryId: String
    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    let isUncategorized: Bool
    let addedCount: Int
    let completedCount: Int
    let openCount: Int
    let calendarExportCount: Int
    let calendarExportRatePer100: Double

    var id: String { categoryId }
    var combinedCount: Int { addedCount + completedCount + openCount }
}

struct InsightsFeatureUsageStat: Identifiable, Hashable {
    let featureKey: String
    let title: String
    let allTimeCount: Int
    let windowCount: Int
    let lastUsedAt: Date?
    let gapStatus: InsightsGapStatus

    var id: String { featureKey }
}

struct InsightsRankingItem: Identifiable, Hashable {
    let id: String
    let title: String
    let value: Int
    let subtitle: String
}

struct InsightsOldestOpenTaskSummary: Hashable, Identifiable {
    let taskId: String
    let title: String
    let createdAt: Date
    let ageDays: Int
    let categories: [String]

    var id: String { taskId }
}

enum InsightsOpenTaskAgeBucket: CaseIterable, Hashable {
    case days0to7
    case days8to14
    case days15to30
    case days31to60
    case days61to90
    case days90plus

    var label: String {
        switch self {
        case .days0to7:
            return "0-7"
        case .days8to14:
            return "8-14"
        case .days15to30:
            return "15-30"
        case .days31to60:
            return "31-60"
        case .days61to90:
            return "61-90"
        case .days90plus:
            return "90+"
        }
    }

    static func bucket(for ageDays: Int) -> InsightsOpenTaskAgeBucket {
        switch ageDays {
        case 0...7:
            return .days0to7
        case 8...14:
            return .days8to14
        case 15...30:
            return .days15to30
        case 31...60:
            return .days31to60
        case 61...90:
            return .days61to90
        default:
            return .days90plus
        }
    }
}

struct InsightsOpenTaskAgeBucketStat: Identifiable, Hashable {
    let bucket: InsightsOpenTaskAgeBucket
    let count: Int

    var id: String { bucket.label }
    var label: String { bucket.label }
}

struct InsightsSnapshotModel {
    let generatedAt: Date
    let selectedWindow: InsightsWindow
    let windowStart: Date
    let totals: InsightsTaskTotals
    let trendWindow: [InsightsDailyTrendPoint]
    let trendAllTime: [InsightsDailyTrendPoint]
    let hourBuckets: [InsightsHourBucketStat]
    let categoryStats: [InsightsCategoryUsageStat]
    let featureStats: [InsightsFeatureUsageStat]
    let oldestOpenTasksPreview: [InsightsOldestOpenTaskSummary]
    let oldestOpenTasksDrilldown: [InsightsOldestOpenTaskSummary]
    let openTaskAgeBuckets: [InsightsOpenTaskAgeBucketStat]
    let tasksLeftUncategorized: Int
    let mostUsedFeatures: [InsightsRankingItem]
    let leastUsedFeatures: [InsightsRankingItem]
    let mostUsedCategories: [InsightsRankingItem]
    let leastUsedCategories: [InsightsRankingItem]
    let mostUsedHours: [InsightsRankingItem]
    let leastUsedHours: [InsightsRankingItem]
    let taskDataFidelity: InsightsDataFidelity
    let appUsageFidelity: InsightsDataFidelity
    let calendarRateFidelity: InsightsDataFidelity
    let firstAppUsageDate: Date?
}

private struct InsightsTelemetryRecord {
    let featureKey: String
    let eventName: String
    let dayKey: String
    let dayDate: Date
    let hour: Int
    let count: Int
    let categoryIds: [String]
    let timestampForOrdering: Date
}

struct InsightsAggregator {
    static let uncategorizedCategoryId = "uncategorized"

    static func buildSnapshot(
        tasks: [Task],
        categories: [Category],
        telemetry: InsightsTelemetrySnapshot,
        selectedWindow: InsightsWindow,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> InsightsSnapshotModel {
        let todayStart = calendar.startOfDay(for: now)
        let windowStart = calendar.date(byAdding: .day, value: -(selectedWindow.rawValue - 1), to: todayStart) ?? todayStart
        let topLevelTasks = tasks.filter { $0.parentTaskId == nil }

        let totals = InsightsTaskTotals(
            all: topLevelTasks.count,
            open: topLevelTasks.filter { $0.completedAt == nil }.count,
            done: topLevelTasks.filter { $0.completedAt != nil }.count
        )

        let trendWindow = buildTaskTrend(tasks: topLevelTasks, startDate: windowStart, endDate: todayStart, calendar: calendar)
        let allTimeStart = earliestTaskDay(tasks: topLevelTasks, fallback: todayStart, calendar: calendar)
        let trendAllTime = buildTaskTrend(tasks: topLevelTasks, startDate: allTimeStart, endDate: todayStart, calendar: calendar)

        let telemetryRecords = normalizeTelemetry(snapshot: telemetry, calendar: calendar)

        let categoryStats = buildCategoryStats(
            tasks: topLevelTasks,
            categories: categories,
            telemetryRecords: telemetryRecords,
            windowStart: windowStart,
            now: now
        )
        let tasksLeftUncategorized = categoryStats.first(where: { $0.isUncategorized })?.openCount ?? 0

        let hourBuckets = buildHourBuckets(tasks: topLevelTasks, telemetryRecords: telemetryRecords, calendar: calendar)
        let oldestOpenTaskData = buildOldestOpenTaskData(tasks: topLevelTasks, now: now, calendar: calendar)

        let featureStats = buildFeatureStats(telemetryRecords: telemetryRecords, windowStart: windowStart, now: now)

        let mostUsedFeatures = rankFeatures(featureStats, order: .descending)
        let leastUsedFeatures = rankFeatures(featureStats, order: .ascending)
        let mostUsedCategories = rankCategories(categoryStats, order: .descending)
        let leastUsedCategories = rankCategories(categoryStats, order: .ascending)
        let mostUsedHours = rankHours(hourBuckets, order: .descending)
        let leastUsedHours = rankHours(hourBuckets, order: .ascending)

        return InsightsSnapshotModel(
            generatedAt: now,
            selectedWindow: selectedWindow,
            windowStart: windowStart,
            totals: totals,
            trendWindow: trendWindow,
            trendAllTime: trendAllTime,
            hourBuckets: hourBuckets,
            categoryStats: categoryStats,
            featureStats: featureStats,
            oldestOpenTasksPreview: oldestOpenTaskData.preview,
            oldestOpenTasksDrilldown: oldestOpenTaskData.drilldown,
            openTaskAgeBuckets: oldestOpenTaskData.ageBuckets,
            tasksLeftUncategorized: tasksLeftUncategorized,
            mostUsedFeatures: mostUsedFeatures,
            leastUsedFeatures: leastUsedFeatures,
            mostUsedCategories: mostUsedCategories,
            leastUsedCategories: leastUsedCategories,
            mostUsedHours: mostUsedHours,
            leastUsedHours: leastUsedHours,
            taskDataFidelity: .snapshotEstimated,
            appUsageFidelity: .eventExact,
            calendarRateFidelity: .mixed,
            firstAppUsageDate: telemetry.firstUsageDate
        )
    }

    private static func buildTaskTrend(
        tasks: [Task],
        startDate: Date,
        endDate: Date,
        calendar: Calendar
    ) -> [InsightsDailyTrendPoint] {
        var addedByDay: [Date: Int] = [:]
        var completedByDay: [Date: Int] = [:]

        for task in tasks {
            let createdDay = calendar.startOfDay(for: task.createdAt)
            if createdDay >= startDate && createdDay <= endDate {
                addedByDay[createdDay, default: 0] += 1
            }
            if let completedAt = task.completedAt {
                let completedDay = calendar.startOfDay(for: completedAt)
                if completedDay >= startDate && completedDay <= endDate {
                    completedByDay[completedDay, default: 0] += 1
                }
            }
        }

        return dateRange(from: startDate, to: endDate, calendar: calendar).map { day in
            InsightsDailyTrendPoint(
                date: day,
                added: addedByDay[day, default: 0],
                completed: completedByDay[day, default: 0]
            )
        }
    }

    private static func earliestTaskDay(tasks: [Task], fallback: Date, calendar: Calendar) -> Date {
        let candidates = tasks.flatMap { task -> [Date] in
            var values = [task.createdAt]
            if let completedAt = task.completedAt {
                values.append(completedAt)
            }
            return values
        }
        guard let minDate = candidates.min() else { return fallback }
        return calendar.startOfDay(for: minDate)
    }

    private static func buildCategoryStats(
        tasks: [Task],
        categories: [Category],
        telemetryRecords: [InsightsTelemetryRecord],
        windowStart: Date,
        now: Date
    ) -> [InsightsCategoryUsageStat] {
        var addedByCategory: [String: Int] = [:]
        var completedByCategory: [String: Int] = [:]
        var openByCategory: [String: Int] = [:]

        for task in tasks {
            if task.categories.isEmpty {
                if task.completedAt == nil {
                    openByCategory[uncategorizedCategoryId, default: 0] += 1
                }
                addedByCategory[uncategorizedCategoryId, default: 0] += 1
                if task.completedAt != nil {
                    completedByCategory[uncategorizedCategoryId, default: 0] += 1
                }
                continue
            }

            for categoryId in task.categories {
                addedByCategory[categoryId, default: 0] += 1
                if task.completedAt != nil {
                    completedByCategory[categoryId, default: 0] += 1
                } else {
                    openByCategory[categoryId, default: 0] += 1
                }
            }
        }

        var calendarExportByCategory: [String: Int] = [:]
        for record in telemetryRecords where record.featureKey == InsightsFeatureKey.calendarExportInitiated {
            if record.categoryIds.isEmpty {
                calendarExportByCategory[uncategorizedCategoryId, default: 0] += record.count
            } else {
                for categoryId in record.categoryIds {
                    calendarExportByCategory[categoryId, default: 0] += record.count
                }
            }
        }

        var activeDenominatorByCategory: [String: Int] = [:]
        for task in tasks {
            let isActiveInWindow = task.createdAt <= now && (task.completedAt == nil || task.completedAt! >= windowStart)
            guard isActiveInWindow else { continue }
            if task.categories.isEmpty {
                activeDenominatorByCategory[uncategorizedCategoryId, default: 0] += 1
            } else {
                for categoryId in Set(task.categories) {
                    activeDenominatorByCategory[categoryId, default: 0] += 1
                }
            }
        }

        let categoryMeta = categories.reduce(into: [String: Category]()) { partialResult, category in
            partialResult[category.id] = category
        }

        let allCategoryIds = Set(categories.map(\.id)).union([uncategorizedCategoryId])
        let sortedIds = allCategoryIds.sorted {
            if $0 == uncategorizedCategoryId { return false }
            if $1 == uncategorizedCategoryId { return true }
            let leftOrder = categoryMeta[$0]?.order ?? Int.max
            let rightOrder = categoryMeta[$1]?.order ?? Int.max
            if leftOrder != rightOrder {
                return leftOrder < rightOrder
            }
            return $0 < $1
        }

        return sortedIds.map { categoryId in
            let category = categoryMeta[categoryId]
            let isUncategorized = categoryId == uncategorizedCategoryId
            let exportCount = calendarExportByCategory[categoryId, default: 0]
            let denominator = activeDenominatorByCategory[categoryId, default: 0]
            let ratePer100 = denominator > 0
                ? (Double(exportCount) * 100.0 / Double(denominator))
                : 0

            return InsightsCategoryUsageStat(
                categoryId: categoryId,
                categoryName: isUncategorized ? "Uncategorized" : (category?.name ?? categoryId),
                categoryIcon: isUncategorized ? "🏷️" : (category?.icon ?? "🏷️"),
                categoryColorHex: isUncategorized ? "#6B7280" : (category?.color ?? "#6B7280"),
                isUncategorized: isUncategorized,
                addedCount: addedByCategory[categoryId, default: 0],
                completedCount: completedByCategory[categoryId, default: 0],
                openCount: openByCategory[categoryId, default: 0],
                calendarExportCount: exportCount,
                calendarExportRatePer100: ratePer100
            )
        }
    }

    private static func buildHourBuckets(
        tasks: [Task],
        telemetryRecords: [InsightsTelemetryRecord],
        calendar: Calendar
    ) -> [InsightsHourBucketStat] {
        var added: [Int: Int] = [:]
        var completed: [Int: Int] = [:]
        var usage: [Int: Int] = [:]

        for task in tasks {
            let createHour = calendar.component(.hour, from: task.createdAt)
            added[createHour, default: 0] += 1
            if let completedAt = task.completedAt {
                let completedHour = calendar.component(.hour, from: completedAt)
                completed[completedHour, default: 0] += 1
            }
        }

        for record in telemetryRecords {
            usage[record.hour, default: 0] += record.count
        }

        return (0..<24).map { hour in
            InsightsHourBucketStat(
                hour: hour,
                addedCount: added[hour, default: 0],
                completedCount: completed[hour, default: 0],
                appUsageCount: usage[hour, default: 0]
            )
        }
    }

    private static func buildOldestOpenTaskData(
        tasks: [Task],
        now: Date,
        calendar: Calendar
    ) -> (
        preview: [InsightsOldestOpenTaskSummary],
        drilldown: [InsightsOldestOpenTaskSummary],
        ageBuckets: [InsightsOpenTaskAgeBucketStat]
    ) {
        let summaries = tasks
            .filter { $0.completedAt == nil }
            .map { task in
                let createdDay = calendar.startOfDay(for: task.createdAt)
                let currentDay = calendar.startOfDay(for: now)
                let ageDays = max(0, calendar.dateComponents([.day], from: createdDay, to: currentDay).day ?? 0)
                return InsightsOldestOpenTaskSummary(
                    taskId: task.id,
                    title: task.title,
                    createdAt: task.createdAt,
                    ageDays: ageDays,
                    categories: task.categories
                )
            }
            .sorted {
                if $0.ageDays != $1.ageDays {
                    return $0.ageDays > $1.ageDays
                }
                if $0.createdAt != $1.createdAt {
                    return $0.createdAt < $1.createdAt
                }
                return $0.taskId < $1.taskId
            }

        var bucketCounts = Dictionary(
            uniqueKeysWithValues: InsightsOpenTaskAgeBucket.allCases.map { ($0, 0) }
        )
        for summary in summaries {
            let bucket = InsightsOpenTaskAgeBucket.bucket(for: summary.ageDays)
            bucketCounts[bucket, default: 0] += 1
        }

        let ageBuckets = InsightsOpenTaskAgeBucket.allCases.map { bucket in
            InsightsOpenTaskAgeBucketStat(
                bucket: bucket,
                count: bucketCounts[bucket, default: 0]
            )
        }

        return (
            preview: Array(summaries.prefix(3)),
            drilldown: Array(summaries.prefix(50)),
            ageBuckets: ageBuckets
        )
    }

    private static func buildFeatureStats(
        telemetryRecords: [InsightsTelemetryRecord],
        windowStart: Date,
        now: Date
    ) -> [InsightsFeatureUsageStat] {
        let catalog = featureCatalog()
        var allTimeCounts: [String: Int] = [:]
        var windowCounts: [String: Int] = [:]
        var lastUsed: [String: Date] = [:]

        for record in telemetryRecords {
            allTimeCounts[record.featureKey, default: 0] += record.count
            if record.timestampForOrdering >= windowStart && record.timestampForOrdering <= now {
                windowCounts[record.featureKey, default: 0] += record.count
            }
            let existing = lastUsed[record.featureKey] ?? .distantPast
            if record.timestampForOrdering > existing {
                lastUsed[record.featureKey] = record.timestampForOrdering
            }
        }

        let catalogCounts = catalog.map { windowCounts[$0.key, default: 0] }
        let p25 = percentile25(values: catalogCounts)
        let threshold = max(3, p25)

        return catalog.map { item in
            let countInWindow = windowCounts[item.key, default: 0]
            let status: InsightsGapStatus
            if countInWindow == 0 {
                status = .unused
            } else if countInWindow < threshold {
                status = .underused
            } else {
                status = .used
            }
            return InsightsFeatureUsageStat(
                featureKey: item.key,
                title: item.title,
                allTimeCount: allTimeCounts[item.key, default: 0],
                windowCount: countInWindow,
                lastUsedAt: lastUsed[item.key],
                gapStatus: status
            )
        }
    }

    private enum RankOrder {
        case ascending
        case descending
    }

    private static func rankFeatures(_ stats: [InsightsFeatureUsageStat], order: RankOrder, limit: Int = 5) -> [InsightsRankingItem] {
        let sorted = stats.sorted {
            if $0.allTimeCount != $1.allTimeCount {
                return order == .descending ? $0.allTimeCount > $1.allTimeCount : $0.allTimeCount < $1.allTimeCount
            }
            let leftDate = $0.lastUsedAt ?? .distantPast
            let rightDate = $1.lastUsedAt ?? .distantPast
            if leftDate != rightDate {
                return leftDate > rightDate
            }
            return $0.featureKey < $1.featureKey
        }

        return Array(sorted.prefix(limit)).map {
            InsightsRankingItem(
                id: $0.featureKey,
                title: $0.title,
                value: $0.allTimeCount,
                subtitle: $0.gapStatus.rawValue
            )
        }
    }

    private static func rankCategories(_ stats: [InsightsCategoryUsageStat], order: RankOrder, limit: Int = 5) -> [InsightsRankingItem] {
        let sorted = stats.sorted {
            if $0.combinedCount != $1.combinedCount {
                return order == .descending ? $0.combinedCount > $1.combinedCount : $0.combinedCount < $1.combinedCount
            }
            return $0.categoryName < $1.categoryName
        }
        return Array(sorted.prefix(limit)).map {
            InsightsRankingItem(
                id: $0.categoryId,
                title: "\($0.categoryIcon) \($0.categoryName)",
                value: $0.combinedCount,
                subtitle: "Added \($0.addedCount) • Done \($0.completedCount)"
            )
        }
    }

    private static func rankHours(_ stats: [InsightsHourBucketStat], order: RankOrder, limit: Int = 5) -> [InsightsRankingItem] {
        let sorted = stats.sorted {
            if $0.combinedCount != $1.combinedCount {
                return order == .descending ? $0.combinedCount > $1.combinedCount : $0.combinedCount < $1.combinedCount
            }
            return $0.hour < $1.hour
        }
        return Array(sorted.prefix(limit)).map {
            InsightsRankingItem(
                id: "hour-\($0.hour)",
                title: $0.label,
                value: $0.combinedCount,
                subtitle: "Added \($0.addedCount) • Done \($0.completedCount) • App \($0.appUsageCount)"
            )
        }
    }

    private static func normalizeTelemetry(
        snapshot: InsightsTelemetrySnapshot,
        calendar: Calendar
    ) -> [InsightsTelemetryRecord] {
        var records: [InsightsTelemetryRecord] = []
        records.reserveCapacity(snapshot.rawEvents.count + snapshot.aggregateBuckets.count)

        for event in snapshot.rawEvents {
            let dayHour = dayKeyAndHour(timestampUTC: event.timestampUTC, timezoneOffsetMinutes: event.timezoneOffsetMinutesAtEvent)
            let dayDate = parseDayKey(dayHour.dayKey, calendar: calendar) ?? event.timestampUTC
            records.append(
                InsightsTelemetryRecord(
                    featureKey: event.featureKey,
                    eventName: event.eventName,
                    dayKey: dayHour.dayKey,
                    dayDate: dayDate,
                    hour: dayHour.hour,
                    count: 1,
                    categoryIds: event.categoryIds,
                    timestampForOrdering: event.timestampUTC
                )
            )
        }

        for bucket in snapshot.aggregateBuckets {
            let dayDate = parseDayKey(bucket.dayKey, calendar: calendar) ?? Date.distantPast
            let timestamp = calendar.date(bySettingHour: bucket.hour, minute: 0, second: 0, of: dayDate) ?? dayDate
            records.append(
                InsightsTelemetryRecord(
                    featureKey: bucket.featureKey,
                    eventName: bucket.eventName,
                    dayKey: bucket.dayKey,
                    dayDate: dayDate,
                    hour: bucket.hour,
                    count: bucket.count,
                    categoryIds: bucket.categoryIds,
                    timestampForOrdering: timestamp
                )
            )
        }

        return records
    }

    private static func featureCatalog() -> [(key: String, title: String)] {
        [
            (InsightsFeatureKey.taskCreate, "Tasks Created"),
            (InsightsFeatureKey.taskEdit, "Tasks Edited"),
            (InsightsFeatureKey.taskComplete, "Tasks Completed"),
            (InsightsFeatureKey.taskRestore, "Completed Tasks Reopened"),
            (InsightsFeatureKey.taskDelete, "Tasks Deleted"),
            (InsightsFeatureKey.taskReorder, "Task Reorders"),
            (InsightsFeatureKey.dueDateSet, "Due Dates Added"),
            (InsightsFeatureKey.dueDateCleared, "Due Dates Removed"),
            (InsightsFeatureKey.reminderSet, "Reminders Added"),
            (InsightsFeatureKey.reminderCleared, "Reminders Removed"),
            (InsightsFeatureKey.reminderPermissionPrompted, "Reminder Permission Requests"),
            (InsightsFeatureKey.reminderPermissionDenied, "Reminder Permission Denials"),
            (InsightsFeatureKey.calendarExportInitiated, "Calendar Export Attempts"),
            (InsightsFeatureKey.calendarExportPresented, "Calendar Export Screens Opened"),
            (InsightsFeatureKey.calendarExportPermissionDenied, "Calendar Export Permission Denials"),
            (InsightsFeatureKey.categoryCreate, "Categories Created"),
            (InsightsFeatureKey.categoryRename, "Category Renames"),
            (InsightsFeatureKey.categoryReorder, "Category Reorders"),
            (InsightsFeatureKey.categoryDelete, "Categories Deleted"),
            (InsightsFeatureKey.categoryAssign, "Category Assignments"),
            (InsightsFeatureKey.tabSelect, "Tab Switches"),
            (InsightsFeatureKey.viewOpen, "# of detailed Task views"),
            (InsightsFeatureKey.viewDuration, "Time Spent in Views"),
            (InsightsFeatureKey.todosModeSwitch, "To-Do View Mode Switches"),
            (InsightsFeatureKey.todosFilterChange, "Doing/Done Filter Changes"),
            (InsightsFeatureKey.notesUsage, "Notes Tab Opens"),
            (InsightsFeatureKey.themeChange, "Theme Changes"),
            (InsightsFeatureKey.profileSettingsOpen, "Profile and Settings Opens"),
            (InsightsFeatureKey.insightsDrilldownOpen, "# of Insight analytics views")
        ]
    }

    private static func percentile25(values: [Int]) -> Int {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let index = Int(floor(Double(sorted.count - 1) * 0.25))
        return sorted[max(0, min(index, sorted.count - 1))]
    }

    private static func dateRange(from start: Date, to end: Date, calendar: Calendar) -> [Date] {
        guard start <= end else { return [] }
        var dates: [Date] = []
        var cursor = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        while cursor <= endDay {
            dates.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return dates
    }

    private static func dayKeyAndHour(timestampUTC: Date, timezoneOffsetMinutes: Int) -> (dayKey: String, hour: Int) {
        let shiftedDate = timestampUTC.addingTimeInterval(Double(timezoneOffsetMinutes * 60))
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let components = utcCalendar.dateComponents([.year, .month, .day, .hour], from: shiftedDate)
        let year = components.year ?? 1970
        let month = components.month ?? 1
        let day = components.day ?? 1
        let hour = components.hour ?? 0
        let dayKey = String(format: "%04d-%02d-%02d", year, month, day)
        return (dayKey, hour)
    }

    private static func parseDayKey(_ dayKey: String, calendar: Calendar) -> Date? {
        let parts = dayKey.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components).map { calendar.startOfDay(for: $0) }
    }
}
