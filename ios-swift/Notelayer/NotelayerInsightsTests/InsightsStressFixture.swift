import Foundation

enum InsightsStressFixture {
    struct Payload {
        let tasks: [Task]
        let categories: [Category]
        let telemetry: InsightsTelemetrySnapshot
        let now: Date
        let calendar: Calendar
    }

    static func make(
        taskCount: Int = 5_000,
        eventCount: Int = 50_000
    ) -> Payload {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let now = Date(timeIntervalSince1970: 1_770_912_000) // 2026-02-09 12:00 UTC

        let categories: [Category] = (0..<8).map { idx in
            Category(
                id: "c\(idx)",
                name: "Category \(idx)",
                icon: "tag",
                color: "#336699",
                order: idx
            )
        }

        var tasks: [Task] = []
        tasks.reserveCapacity(taskCount)

        for idx in 0..<taskCount {
            let dayOffset = idx % 540
            let hourOffset = idx % 24
            let minuteOffset = idx % 60
            let createdAt = calendar.date(
                byAdding: .minute,
                value: -((dayOffset * 24 * 60) + (hourOffset * 60) + minuteOffset),
                to: now
            ) ?? now

            let categoryA = "c\(idx % categories.count)"
            let categoryB = "c\((idx + 3) % categories.count)"
            let assignedCategories = idx % 4 == 0 ? [categoryA, categoryB] : [categoryA]

            var completedAt: Date?
            if idx % 3 == 0 {
                completedAt = calendar.date(byAdding: .hour, value: (idx % 120) + 1, to: createdAt)
            }

            tasks.append(
                Task(
                    id: "task-\(idx)",
                    title: "Task \(idx)",
                    categories: assignedCategories,
                    priority: .medium,
                    dueDate: nil,
                    completedAt: completedAt,
                    taskNotes: nil,
                    createdAt: createdAt,
                    updatedAt: createdAt,
                    orderIndex: idx
                )
            )
        }

        let featureKeys = [
            InsightsFeatureKey.taskCreate,
            InsightsFeatureKey.taskComplete,
            InsightsFeatureKey.taskEdit,
            InsightsFeatureKey.reminderSet,
            InsightsFeatureKey.reminderCleared,
            InsightsFeatureKey.calendarExportInitiated,
            InsightsFeatureKey.tabSelect,
            InsightsFeatureKey.viewOpen,
            InsightsFeatureKey.themeChange,
            InsightsFeatureKey.profileSettingsOpen
        ]

        var events: [InsightsTelemetryEvent] = []
        events.reserveCapacity(eventCount)

        for idx in 0..<eventCount {
            let minuteOffset = idx % (540 * 24 * 60)
            let timestamp = calendar.date(byAdding: .minute, value: -minuteOffset, to: now) ?? now
            let featureKey = featureKeys[idx % featureKeys.count]
            let eventName = featureKey
            let offset = [-480, -420, 0, 60][idx % 4]
            let categoryId = "c\(idx % categories.count)"
            let categoryIds = idx % 9 == 0 ? [categoryId, "c\((idx + 1) % categories.count)"] : [categoryId]

            events.append(
                InsightsTelemetryEvent(
                    id: "event-\(idx)",
                    eventName: eventName,
                    featureKey: featureKey,
                    timestampUTC: timestamp,
                    timezoneOffsetMinutesAtEvent: offset,
                    tabName: idx % 2 == 0 ? "Todos" : "Insights",
                    viewName: idx % 2 == 0 ? "Todos / List" : "Insights / Overview",
                    categoryIds: categoryIds,
                    taskIdPolicyField: idx % 5 == 0 ? "task-\(idx % taskCount)" : nil,
                    metadata: [:],
                    userScopeKey: "stress"
                )
            )
        }

        let telemetry = InsightsTelemetrySnapshot(
            scopeKey: "stress",
            rawEvents: events,
            aggregateBuckets: []
        )

        return Payload(
            tasks: tasks,
            categories: categories,
            telemetry: telemetry,
            now: now,
            calendar: calendar
        )
    }
}
