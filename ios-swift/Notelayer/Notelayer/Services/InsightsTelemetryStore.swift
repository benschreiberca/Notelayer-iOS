import Foundation

extension Notification.Name {
    static let insightsTelemetryDidUpdate = Notification.Name("Notelayer.InsightsTelemetry.DidUpdate")
}

struct InsightsTelemetryEvent: Codable, Identifiable, Hashable {
    let id: String
    let eventName: String
    let featureKey: String
    let timestampUTC: Date
    let timezoneOffsetMinutesAtEvent: Int
    let tabName: String?
    let viewName: String?
    let categoryIds: [String]
    let taskIdPolicyField: String?
    let metadata: [String: String]
    let userScopeKey: String
}

struct InsightsTelemetryAggregateBucket: Codable, Hashable {
    let dayKey: String
    let hour: Int
    let eventName: String
    let featureKey: String
    let tabName: String?
    let viewName: String?
    let categoryIds: [String]
    var count: Int
    let userScopeKey: String
}

struct InsightsTelemetrySnapshot {
    let scopeKey: String
    let rawEvents: [InsightsTelemetryEvent]
    let aggregateBuckets: [InsightsTelemetryAggregateBucket]

    var firstUsageDate: Date? {
        let firstRaw = rawEvents.min(by: { $0.timestampUTC < $1.timestampUTC })?.timestampUTC
        let firstAggregate = aggregateBuckets
            .compactMap { Self.date(fromDayKey: $0.dayKey) }
            .min()
        if let firstRaw, let firstAggregate {
            return min(firstRaw, firstAggregate)
        }
        return firstRaw ?? firstAggregate
    }

    private static func date(fromDayKey dayKey: String) -> Date? {
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
        return Calendar.current.date(from: components)
    }
}

private struct InsightsTelemetryScopeState: Codable {
    var rawEvents: [InsightsTelemetryEvent] = []
    var aggregateBuckets: [InsightsTelemetryAggregateBucket] = []
}

private struct InsightsTelemetryPersistedStore: Codable {
    var schemaVersion: Int
    var currentScopeKey: String
    var states: [String: InsightsTelemetryScopeState]
}

/// Local telemetry store used by Insights for per-device usage analytics.
/// Data is namespaced by auth user scope to avoid account mixing.
final class InsightsTelemetryStore {
    static let shared = InsightsTelemetryStore()

    private let queue = DispatchQueue(label: "com.notelayer.insights.telemetry")
    private let schemaVersion = 1
    private let storageKey: String
    private let rawEventCap: Int
    private let compactionBatchSize: Int
    private let anonymousScope = "anonymous"
    private let userDefaults: UserDefaults
    private let isEnabled: Bool
    private var storage: InsightsTelemetryPersistedStore
    private static let defaultStorageKey = "com.notelayer.app.insights.telemetry.store.v1"

    private static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "true" ||
        ProcessInfo.processInfo.arguments.contains("--screenshot-generation")
    }

    private static func defaultUserDefaults() -> UserDefaults {
        let appGroupIdentifier =
            isScreenshotMode ? "group.com.notelayer.app.screenshots" : "group.com.notelayer.app"
        return UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }

    init(
        userDefaults: UserDefaults? = nil,
        isEnabled: Bool? = nil,
        storageKey: String = InsightsTelemetryStore.defaultStorageKey,
        rawEventCap: Int = 120_000,
        compactionBatchSize: Int = 20_000
    ) {
        self.userDefaults = userDefaults ?? Self.defaultUserDefaults()
        self.isEnabled = isEnabled ?? !Self.isScreenshotMode
        self.storageKey = storageKey
        self.rawEventCap = max(1, rawEventCap)
        self.compactionBatchSize = max(1, compactionBatchSize)
        storage = InsightsTelemetryPersistedStore(
            schemaVersion: schemaVersion,
            currentScopeKey: anonymousScope,
            states: [anonymousScope: InsightsTelemetryScopeState()]
        )
        storage = loadPersistedStore()
        migrateIfNeeded()
    }

    func setUserScope(_ userId: String?) {
        let scope = normalizedScopeKey(from: userId)
        queue.sync {
            if storage.currentScopeKey == scope {
                return
            }
            storage.currentScopeKey = scope
            if storage.states[scope] == nil {
                storage.states[scope] = InsightsTelemetryScopeState()
            }
            persistLocked()
        }
        postUpdate()
    }

    func currentScopeKey() -> String {
        queue.sync { storage.currentScopeKey }
    }

    func clearScopeData(_ scopeKey: String) {
        queue.sync {
            let scope = normalizedScopeKey(from: scopeKey)
            storage.states[scope] = InsightsTelemetryScopeState()
            persistLocked()
        }
        postUpdate()
    }

    func record(
        eventName: String,
        featureKey: String,
        tabName: String? = nil,
        viewName: String? = nil,
        categoryIds: [String] = [],
        taskIdPolicyField: String? = nil,
        metadata: [String: String] = [:],
        timestampUTC: Date = Date(),
        timezoneOffsetMinutesAtEvent: Int? = nil
    ) {
        guard isEnabled else { return }

        queue.async {
            let scope = self.storage.currentScopeKey
            var scoped = self.storage.states[scope] ?? InsightsTelemetryScopeState()
            let offsetMinutes = timezoneOffsetMinutesAtEvent ?? Self.timezoneOffsetMinutes(for: timestampUTC)

            let normalizedCategories = categoryIds
                .filter { !$0.isEmpty }
                .sorted()

            let event = InsightsTelemetryEvent(
                id: UUID().uuidString,
                eventName: eventName,
                featureKey: featureKey,
                timestampUTC: timestampUTC,
                timezoneOffsetMinutesAtEvent: offsetMinutes,
                tabName: tabName,
                viewName: viewName,
                categoryIds: normalizedCategories,
                taskIdPolicyField: taskIdPolicyField,
                metadata: metadata,
                userScopeKey: scope
            )
            scoped.rawEvents.append(event)
            self.compactIfNeeded(scope: scope, scoped: &scoped)
            self.storage.states[scope] = scoped
            self.persistLocked()
            self.postUpdate()
        }
    }

    func snapshot(scopeKey: String? = nil) -> InsightsTelemetrySnapshot {
        queue.sync {
            let scope = normalizedScopeKey(from: scopeKey ?? storage.currentScopeKey)
            let scoped = storage.states[scope] ?? InsightsTelemetryScopeState()
            return InsightsTelemetrySnapshot(
                scopeKey: scope,
                rawEvents: scoped.rawEvents,
                aggregateBuckets: scoped.aggregateBuckets
            )
        }
    }

    // Ensures async telemetry writes are drained before assertions in tests.
    func flushForTesting() {
        queue.sync {}
    }

    private func compactIfNeeded(scope: String, scoped: inout InsightsTelemetryScopeState) {
        guard scoped.rawEvents.count > rawEventCap else { return }

        let extra = scoped.rawEvents.count - rawEventCap
        let chunkSize = max(compactionBatchSize, extra)
        let boundedChunkSize = min(chunkSize, scoped.rawEvents.count)
        let compacted = Array(scoped.rawEvents.prefix(boundedChunkSize))
        scoped.rawEvents.removeFirst(boundedChunkSize)

        var aggregateMap: [String: InsightsTelemetryAggregateBucket] = [:]
        for bucket in scoped.aggregateBuckets {
            let key = bucketKey(
                dayKey: bucket.dayKey,
                hour: bucket.hour,
                eventName: bucket.eventName,
                featureKey: bucket.featureKey,
                tabName: bucket.tabName,
                viewName: bucket.viewName,
                categoryIds: bucket.categoryIds,
                scopeKey: scope
            )
            aggregateMap[key] = bucket
        }

        for event in compacted {
            let dayHour = Self.dayKeyAndHour(
                timestampUTC: event.timestampUTC,
                timezoneOffsetMinutes: event.timezoneOffsetMinutesAtEvent
            )
            let key = bucketKey(
                dayKey: dayHour.dayKey,
                hour: dayHour.hour,
                eventName: event.eventName,
                featureKey: event.featureKey,
                tabName: event.tabName,
                viewName: event.viewName,
                categoryIds: event.categoryIds,
                scopeKey: scope
            )
            if var existing = aggregateMap[key] {
                existing.count += 1
                aggregateMap[key] = existing
            } else {
                aggregateMap[key] = InsightsTelemetryAggregateBucket(
                    dayKey: dayHour.dayKey,
                    hour: dayHour.hour,
                    eventName: event.eventName,
                    featureKey: event.featureKey,
                    tabName: event.tabName,
                    viewName: event.viewName,
                    categoryIds: event.categoryIds,
                    count: 1,
                    userScopeKey: scope
                )
            }
        }

        scoped.aggregateBuckets = aggregateMap.values.sorted {
            if $0.dayKey != $1.dayKey {
                return $0.dayKey < $1.dayKey
            }
            if $0.hour != $1.hour {
                return $0.hour < $1.hour
            }
            return $0.featureKey < $1.featureKey
        }
    }

    private func bucketKey(
        dayKey: String,
        hour: Int,
        eventName: String,
        featureKey: String,
        tabName: String?,
        viewName: String?,
        categoryIds: [String],
        scopeKey: String
    ) -> String {
        let tab = tabName ?? "-"
        let view = viewName ?? "-"
        let cats = categoryIds.joined(separator: ",")
        return "\(scopeKey)|\(dayKey)|\(hour)|\(eventName)|\(featureKey)|\(tab)|\(view)|\(cats)"
    }

    private func normalizedScopeKey(from raw: String?) -> String {
        guard let raw, !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return anonymousScope
        }
        return raw
    }

    private func loadPersistedStore() -> InsightsTelemetryPersistedStore {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return storage
        }

        if let decoded = try? JSONDecoder().decode(InsightsTelemetryPersistedStore.self, from: data) {
            return decoded
        }

        // Migration fallback: old single-scope raw event array.
        if let legacyEvents = try? JSONDecoder().decode([InsightsTelemetryEvent].self, from: data) {
            return InsightsTelemetryPersistedStore(
                schemaVersion: schemaVersion,
                currentScopeKey: anonymousScope,
                states: [
                    anonymousScope: InsightsTelemetryScopeState(
                        rawEvents: legacyEvents,
                        aggregateBuckets: []
                    )
                ]
            )
        }

        return storage
    }

    private func migrateIfNeeded() {
        queue.sync {
            if storage.schemaVersion == schemaVersion {
                if storage.states[storage.currentScopeKey] == nil {
                    storage.states[storage.currentScopeKey] = InsightsTelemetryScopeState()
                }
                persistLocked()
                return
            }

            storage.schemaVersion = schemaVersion
            if storage.states[storage.currentScopeKey] == nil {
                storage.states[storage.currentScopeKey] = InsightsTelemetryScopeState()
            }
            persistLocked()
        }
    }

    private func persistLocked() {
        guard let data = try? JSONEncoder().encode(storage) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    private func postUpdate() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .insightsTelemetryDidUpdate, object: nil)
        }
    }

    private static func timezoneOffsetMinutes(for date: Date) -> Int {
        TimeZone.current.secondsFromGMT(for: date) / 60
    }

    private static func dayKeyAndHour(timestampUTC: Date, timezoneOffsetMinutes: Int) -> (dayKey: String, hour: Int) {
        let shiftedDate = timestampUTC.addingTimeInterval(Double(timezoneOffsetMinutes * 60))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: shiftedDate)
        let year = components.year ?? 1970
        let month = components.month ?? 1
        let day = components.day ?? 1
        let hour = components.hour ?? 0
        let dayKey = String(format: "%04d-%02d-%02d", year, month, day)
        return (dayKey, hour)
    }
}
