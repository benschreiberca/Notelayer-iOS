import XCTest

final class InsightsAggregatorTests: XCTestCase {
    private typealias TodoTask = Task
    private typealias TodoCategory = Category

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func utcDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ hour: Int = 0,
        _ minute: Int = 0,
        _ second: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.calendar = utcCalendar
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return components.date ?? .distantPast
    }

    private func task(
        id: String,
        title: String,
        categories: [String],
        createdAt: Date,
        completedAt: Date? = nil
    ) -> TodoTask {
        TodoTask(
            id: id,
            title: title,
            categories: categories,
            priority: .medium,
            dueDate: nil,
            completedAt: completedAt,
            taskNotes: nil,
            createdAt: createdAt,
            updatedAt: createdAt,
            orderIndex: nil
        )
    }

    private func category(
        id: String,
        name: String,
        order: Int
    ) -> TodoCategory {
        TodoCategory(
            id: id,
            name: name,
            icon: "tag",
            color: "#111111",
            order: order
        )
    }

    private func telemetryEvent(
        eventName: String = "tab_selected",
        featureKey: String,
        timestampUTC: Date,
        offsetMinutes: Int = 0,
        categoryIds: [String] = []
    ) -> InsightsTelemetryEvent {
        InsightsTelemetryEvent(
            id: UUID().uuidString,
            eventName: eventName,
            featureKey: featureKey,
            timestampUTC: timestampUTC,
            timezoneOffsetMinutesAtEvent: offsetMinutes,
            tabName: nil,
            viewName: nil,
            categoryIds: categoryIds,
            taskIdPolicyField: nil,
            metadata: [:],
            userScopeKey: "test-user"
        )
    }

    func testSnapshotTotalsAndOldestOpenTasksUseCreationDate() {
        let now = utcDate(2026, 2, 9, 12, 0)
        let oldestCreatedAt = utcDate(2026, 1, 1, 9, 0)
        let tasks = [
            task(id: "open-old", title: "Old open", categories: ["a"], createdAt: oldestCreatedAt),
            task(id: "open-new", title: "New open", categories: ["b"], createdAt: utcDate(2026, 2, 4, 8, 0)),
            task(
                id: "done-a",
                title: "Done",
                categories: ["a"],
                createdAt: utcDate(2026, 1, 30, 11, 0),
                completedAt: utcDate(2026, 2, 8, 18, 0)
            )
        ]
        let categories = [
            category(id: "a", name: "Category A", order: 0),
            category(id: "b", name: "Category B", order: 1)
        ]

        let snapshot = InsightsAggregator.buildSnapshot(
            tasks: tasks,
            categories: categories,
            telemetry: InsightsTelemetrySnapshot(scopeKey: "test-user", rawEvents: [], aggregateBuckets: []),
            selectedWindow: .days30,
            now: now,
            calendar: utcCalendar
        )

        XCTAssertEqual(snapshot.totals.all, 3)
        XCTAssertEqual(snapshot.totals.open, 2)
        XCTAssertEqual(snapshot.totals.done, 1)
        XCTAssertEqual(snapshot.oldestOpenTasksPreview.count, 2)
        XCTAssertEqual(snapshot.oldestOpenTasksDrilldown.count, 2)
        XCTAssertEqual(snapshot.oldestOpenTasksPreview.first?.taskId, "open-old")
        XCTAssertEqual(snapshot.oldestOpenTasksDrilldown.first?.taskId, "open-old")

        let expectedAge = utcCalendar.dateComponents(
            [.day],
            from: utcCalendar.startOfDay(for: oldestCreatedAt),
            to: utcCalendar.startOfDay(for: now)
        ).day
        XCTAssertEqual(snapshot.oldestOpenTasksPreview.first?.ageDays, expectedAge)

        let bucketCounts = Dictionary(uniqueKeysWithValues: snapshot.openTaskAgeBuckets.map { ($0.label, $0.count) })
        XCTAssertEqual(bucketCounts["31-60"], 1)
        XCTAssertEqual(bucketCounts["0-7"], 1)
        XCTAssertEqual(snapshot.openTaskAgeBuckets.reduce(0) { $0 + $1.count }, 2)
    }

    func testWindowBoundariesIncludeStartAndEndDays() {
        let now = utcDate(2026, 2, 9, 12, 0)
        let tasks = [
            task(id: "start", title: "Start boundary", categories: [], createdAt: utcDate(2026, 2, 3, 0, 0)),
            task(id: "end", title: "End boundary", categories: [], createdAt: utcDate(2026, 2, 9, 23, 59)),
            task(id: "outside", title: "Outside", categories: [], createdAt: utcDate(2026, 2, 2, 23, 59))
        ]

        let snapshot = InsightsAggregator.buildSnapshot(
            tasks: tasks,
            categories: [],
            telemetry: InsightsTelemetrySnapshot(scopeKey: "test-user", rawEvents: [], aggregateBuckets: []),
            selectedWindow: .days7,
            now: now,
            calendar: utcCalendar
        )

        XCTAssertEqual(snapshot.trendWindow.count, 7)
        XCTAssertEqual(snapshot.trendWindow.first?.date, utcDate(2026, 2, 3))
        XCTAssertEqual(snapshot.trendWindow.last?.date, utcDate(2026, 2, 9))
        XCTAssertEqual(snapshot.trendWindow.reduce(0) { $0 + $1.added }, 2)
    }

    func testCategoryStatsIncludeZeroCountAndUncategorized() {
        let tasks = [
            task(id: "uncat-open", title: "Uncategorized", categories: [], createdAt: utcDate(2026, 2, 1)),
            task(
                id: "a-done",
                title: "A Done",
                categories: ["a"],
                createdAt: utcDate(2026, 1, 10),
                completedAt: utcDate(2026, 2, 1)
            ),
            task(id: "b-open", title: "B Open", categories: ["b"], createdAt: utcDate(2026, 2, 5))
        ]
        let categories = [
            category(id: "a", name: "Category A", order: 0),
            category(id: "b", name: "Category B", order: 1),
            category(id: "c", name: "Category C", order: 2)
        ]

        let snapshot = InsightsAggregator.buildSnapshot(
            tasks: tasks,
            categories: categories,
            telemetry: InsightsTelemetrySnapshot(scopeKey: "test-user", rawEvents: [], aggregateBuckets: []),
            selectedWindow: .days30,
            now: utcDate(2026, 2, 9),
            calendar: utcCalendar
        )

        let byID = Dictionary(uniqueKeysWithValues: snapshot.categoryStats.map { ($0.categoryId, $0) })
        XCTAssertEqual(snapshot.categoryStats.count, 4)
        XCTAssertEqual(byID["c"]?.addedCount, 0)
        XCTAssertEqual(byID["c"]?.completedCount, 0)
        XCTAssertEqual(byID["c"]?.openCount, 0)
        XCTAssertEqual(byID[InsightsAggregator.uncategorizedCategoryId]?.addedCount, 1)
        XCTAssertEqual(byID[InsightsAggregator.uncategorizedCategoryId]?.openCount, 1)
        XCTAssertEqual(snapshot.tasksLeftUncategorized, 1)
    }

    func testCalendarExportRateUsesActiveTaskDenominator() {
        let now = utcDate(2026, 2, 9, 9, 0)
        let tasks = [
            task(id: "a-open", title: "A Open", categories: ["a"], createdAt: utcDate(2026, 1, 1)),
            task(
                id: "a-window-complete",
                title: "A Completed in window",
                categories: ["a"],
                createdAt: utcDate(2026, 1, 3),
                completedAt: utcDate(2026, 1, 20)
            ),
            task(
                id: "a-old-complete",
                title: "A Completed before window",
                categories: ["a"],
                createdAt: utcDate(2025, 12, 25),
                completedAt: utcDate(2026, 1, 5)
            )
        ]
        let telemetry = InsightsTelemetrySnapshot(
            scopeKey: "test-user",
            rawEvents: [
                telemetryEvent(
                    eventName: "calendar_export_initiated",
                    featureKey: InsightsFeatureKey.calendarExportInitiated,
                    timestampUTC: utcDate(2026, 1, 15),
                    categoryIds: ["a"]
                ),
                telemetryEvent(
                    eventName: "calendar_export_initiated",
                    featureKey: InsightsFeatureKey.calendarExportInitiated,
                    timestampUTC: utcDate(2026, 1, 16),
                    categoryIds: ["a"]
                ),
                telemetryEvent(
                    eventName: "calendar_export_initiated",
                    featureKey: InsightsFeatureKey.calendarExportInitiated,
                    timestampUTC: utcDate(2026, 1, 17),
                    categoryIds: ["a"]
                )
            ],
            aggregateBuckets: []
        )

        let snapshot = InsightsAggregator.buildSnapshot(
            tasks: tasks,
            categories: [category(id: "a", name: "Category A", order: 0)],
            telemetry: telemetry,
            selectedWindow: .days30,
            now: now,
            calendar: utcCalendar
        )

        guard let categoryA = snapshot.categoryStats.first(where: { $0.categoryId == "a" }) else {
            XCTFail("Category A missing from snapshot")
            return
        }
        XCTAssertEqual(categoryA.calendarExportCount, 3)
        XCTAssertEqual(categoryA.calendarExportRatePer100, 150.0, accuracy: 0.001)
    }

    func testTelemetryTimezoneOffsetBucketingHandlesDSTOffsets() {
        let telemetry = InsightsTelemetrySnapshot(
            scopeKey: "test-user",
            rawEvents: [
                telemetryEvent(
                    featureKey: InsightsFeatureKey.tabSelect,
                    timestampUTC: utcDate(2026, 3, 8, 9, 30),
                    offsetMinutes: -480
                ),
                telemetryEvent(
                    featureKey: InsightsFeatureKey.tabSelect,
                    timestampUTC: utcDate(2026, 3, 8, 10, 30),
                    offsetMinutes: -420
                )
            ],
            aggregateBuckets: []
        )

        let snapshot = InsightsAggregator.buildSnapshot(
            tasks: [],
            categories: [],
            telemetry: telemetry,
            selectedWindow: .days365,
            now: utcDate(2026, 3, 10),
            calendar: utcCalendar
        )

        let byHour = Dictionary(uniqueKeysWithValues: snapshot.hourBuckets.map { ($0.hour, $0) })
        XCTAssertEqual(byHour[1]?.appUsageCount, 1)
        XCTAssertEqual(byHour[3]?.appUsageCount, 1)
    }

    func testFeatureRankingTieBreakUsesRecencyThenKeyOrder() {
        let recencyTelemetry = InsightsTelemetrySnapshot(
            scopeKey: "test-user",
            rawEvents: [
                telemetryEvent(featureKey: InsightsFeatureKey.taskCreate, timestampUTC: utcDate(2026, 2, 1)),
                telemetryEvent(featureKey: InsightsFeatureKey.taskEdit, timestampUTC: utcDate(2026, 2, 5))
            ],
            aggregateBuckets: []
        )

        let recencySnapshot = InsightsAggregator.buildSnapshot(
            tasks: [],
            categories: [],
            telemetry: recencyTelemetry,
            selectedWindow: .days30,
            now: utcDate(2026, 2, 9),
            calendar: utcCalendar
        )
        XCTAssertEqual(recencySnapshot.mostUsedFeatures.first?.id, InsightsFeatureKey.taskEdit)

        let tieTelemetry = InsightsTelemetrySnapshot(
            scopeKey: "test-user",
            rawEvents: [
                telemetryEvent(featureKey: InsightsFeatureKey.taskDelete, timestampUTC: utcDate(2026, 2, 5)),
                telemetryEvent(featureKey: InsightsFeatureKey.taskEdit, timestampUTC: utcDate(2026, 2, 5))
            ],
            aggregateBuckets: []
        )

        let tieSnapshot = InsightsAggregator.buildSnapshot(
            tasks: [],
            categories: [],
            telemetry: tieTelemetry,
            selectedWindow: .days30,
            now: utcDate(2026, 2, 9),
            calendar: utcCalendar
        )
        XCTAssertEqual(tieSnapshot.mostUsedFeatures.first?.id, InsightsFeatureKey.taskDelete)
        XCTAssertEqual(tieSnapshot.mostUsedFeatures.dropFirst().first?.id, InsightsFeatureKey.taskEdit)
    }

    func testGapClassificationUsesUnusedUnderusedAndUsedThresholds() {
        let telemetry = InsightsTelemetrySnapshot(
            scopeKey: "test-user",
            rawEvents: [
                telemetryEvent(featureKey: InsightsFeatureKey.taskEdit, timestampUTC: utcDate(2026, 2, 1)),
                telemetryEvent(featureKey: InsightsFeatureKey.taskComplete, timestampUTC: utcDate(2026, 2, 1)),
                telemetryEvent(featureKey: InsightsFeatureKey.taskComplete, timestampUTC: utcDate(2026, 2, 2)),
                telemetryEvent(featureKey: InsightsFeatureKey.taskComplete, timestampUTC: utcDate(2026, 2, 3))
            ],
            aggregateBuckets: []
        )

        let snapshot = InsightsAggregator.buildSnapshot(
            tasks: [],
            categories: [],
            telemetry: telemetry,
            selectedWindow: .days30,
            now: utcDate(2026, 2, 9),
            calendar: utcCalendar
        )
        let byKey = Dictionary(uniqueKeysWithValues: snapshot.featureStats.map { ($0.featureKey, $0.gapStatus) })

        XCTAssertEqual(byKey[InsightsFeatureKey.taskCreate], .unused)
        XCTAssertEqual(byKey[InsightsFeatureKey.taskEdit], .underused)
        XCTAssertEqual(byKey[InsightsFeatureKey.taskComplete], .used)
    }

    func testTelemetryStoreScopesAreIsolated() {
        let suiteName = "InsightsTelemetryTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create isolated defaults suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = InsightsTelemetryStore(
            userDefaults: defaults,
            isEnabled: true,
            storageKey: "insights.telemetry.test.\(suiteName)"
        )

        store.setUserScope("user-a")
        store.record(
            eventName: "tab_selected",
            featureKey: InsightsFeatureKey.tabSelect,
            timestampUTC: utcDate(2026, 2, 1)
        )
        store.flushForTesting()

        store.setUserScope("user-b")
        let userBBefore = store.snapshot(scopeKey: "user-b")
        XCTAssertEqual(userBBefore.rawEvents.count, 0)

        store.record(
            eventName: "tab_selected",
            featureKey: InsightsFeatureKey.tabSelect,
            timestampUTC: utcDate(2026, 2, 2)
        )
        store.flushForTesting()

        let userA = store.snapshot(scopeKey: "user-a")
        let userB = store.snapshot(scopeKey: "user-b")
        XCTAssertEqual(userA.rawEvents.count, 1)
        XCTAssertEqual(userB.rawEvents.count, 1)
        XCTAssertTrue(userA.rawEvents.allSatisfy { $0.userScopeKey == "user-a" })
        XCTAssertTrue(userB.rawEvents.allSatisfy { $0.userScopeKey == "user-b" })
    }

    func testTelemetryStoreCompactsOlderEventsWhenCapExceeded() {
        let suiteName = "InsightsTelemetryCompaction.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Failed to create isolated defaults suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = InsightsTelemetryStore(
            userDefaults: defaults,
            isEnabled: true,
            storageKey: "insights.telemetry.compaction.\(suiteName)",
            rawEventCap: 3,
            compactionBatchSize: 2
        )
        store.setUserScope("compaction-user")

        for index in 0..<6 {
            store.record(
                eventName: "tab_selected",
                featureKey: InsightsFeatureKey.tabSelect,
                timestampUTC: utcDate(2026, 2, 1, index, 0)
            )
        }
        store.flushForTesting()

        let snapshot = store.snapshot(scopeKey: "compaction-user")
        let aggregateCount = snapshot.aggregateBuckets.reduce(0) { $0 + $1.count }
        XCTAssertLessThanOrEqual(snapshot.rawEvents.count, 3)
        XCTAssertGreaterThan(aggregateCount, 0)
        XCTAssertEqual(snapshot.rawEvents.count + aggregateCount, 6)
    }

    func testStressFixtureAggregatesLargeDataset() {
        let fixture = InsightsStressFixture.make()

        let startedAt = CFAbsoluteTimeGetCurrent()
        let snapshot = InsightsAggregator.buildSnapshot(
            tasks: fixture.tasks,
            categories: fixture.categories,
            telemetry: fixture.telemetry,
            selectedWindow: .days365,
            now: fixture.now,
            calendar: fixture.calendar
        )
        let elapsed = CFAbsoluteTimeGetCurrent() - startedAt

        XCTAssertEqual(snapshot.totals.all, 5_000)
        XCTAssertEqual(snapshot.trendWindow.count, 365)
        XCTAssertEqual(snapshot.hourBuckets.count, 24)
        XCTAssertEqual(snapshot.featureStats.count, 29)
        XCTAssertLessThan(elapsed, 5.0)
    }
}
