import Foundation

struct VoiceTaskParser {
    static let confidenceThreshold = 0.65

    static func parse(transcript: String, existingCategories: [Category], now: Date = Date()) -> [VoiceParsedTaskDraft] {
        let normalized = normalizeTranscript(transcript)
        guard !normalized.isEmpty else { return [] }

        var segments = splitIntoSegments(normalized)
        if segments.isEmpty {
            segments = [normalized]
        }

        return segments.map { segment in
            parseSegment(segment, existingCategories: existingCategories, now: now)
        }
    }

    private static func parseSegment(_ segment: String, existingCategories: [Category], now: Date) -> VoiceParsedTaskDraft {
        let cleaned = removeLeadingFillerWords(from: segment)
        let guessedCategories = inferCategories(from: cleaned, existingCategories: existingCategories)
        let priority = inferPriority(from: cleaned)
        let dueDate = inferDate(from: cleaned, now: now)
        // Build the title from text with recognized date/priority phrases removed, so
        // "call mom tomorrow urgent" becomes "call mom" rather than echoing the signals.
        let title = inferTitle(from: stripSignalPhrases(from: cleaned))

        var confidence = 0.45
        if !guessedCategories.isEmpty { confidence += 0.2 }
        if dueDate != nil { confidence += 0.15 }
        if hasExplicitPrioritySignal(in: cleaned) { confidence += 0.1 }
        if cleaned.count >= 12 { confidence += 0.1 }
        confidence = min(confidence, 0.95)

        return VoiceParsedTaskDraft(
            title: title,
            notes: cleaned,
            categories: guessedCategories,
            priority: priority,
            dueDate: dueDate,
            confidenceScore: confidence,
            needsReview: confidence < confidenceThreshold
        )
    }

    private static func normalizeTranscript(_ transcript: String) -> String {
        transcript
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func splitIntoSegments(_ transcript: String) -> [String] {
        var working = transcript
        let regexSeparators: [String] = [
            "(?i)\\band then\\b",
            "(?i)\\bthen\\b",
            "\\n+",
            "[\\.;]"
        ]

        for separator in regexSeparators {
            working = working.replacingOccurrences(of: separator, with: "|", options: .regularExpression)
        }
        working = working.replacingOccurrences(of: "(?i),\\s+and\\s+", with: "|", options: .regularExpression)

        var segments = working
            .split(separator: "|")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if segments.count == 1,
           let first = segments.first,
           first.split(separator: " ").count >= 12,
           first.localizedCaseInsensitiveContains(" and ") {
            segments = first
                .components(separatedBy: " and ")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        return segments
    }

    private static func removeLeadingFillerWords(from text: String) -> String {
        text
            .replacingOccurrences(
                of: "(?i)^(um|uh|please|hey|okay|ok)\\s+",
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func inferCategories(from text: String, existingCategories: [Category]) -> [String] {
        let lowercased = text.lowercased()
        var matches: [String] = []

        for category in existingCategories {
            let keywords = categoryKeywords(for: category)
            if keywords.contains(where: { lowercased.contains($0) }) {
                matches.append(category.id)
            }
        }

        if !matches.isEmpty {
            return Array(Set(matches)).sorted()
        }

        let synonymMap: [(terms: [String], categoryMatcher: (Category) -> Bool)] = [
            (["bank", "banking", "bill", "finance", "invest", "money"], { category in
                let name = category.name.lowercased()
                return name.contains("finance") || name.contains("bank") || name.contains("invest")
            }),
            (["home", "house", "clean", "repair"], { $0.name.lowercased().contains("home") || $0.name.lowercased().contains("house") }),
            (["work", "project", "meeting", "client"], { $0.name.lowercased().contains("work") || $0.name.lowercased().contains("project") }),
            (["health", "doctor", "fitness"], { $0.name.lowercased().contains("health") || $0.name.lowercased().contains("wellness") })
        ]

        for synonym in synonymMap {
            if synonym.terms.contains(where: { lowercased.contains($0) }),
               let matched = existingCategories.first(where: synonym.categoryMatcher) {
                return [matched.id]
            }
        }

        return []
    }

    private static func categoryKeywords(for category: Category) -> [String] {
        let words = category.name
            .lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { $0.count >= 3 }
        return Array(Set(words + [category.id.lowercased()]))
    }

    /// Priority signal phrases, grouped by the priority they imply. Ordered so the
    /// most specific multi-word phrases are checked first.
    private static let highPriorityPhrases = ["high priority", "top priority", "urgent", "urgently", "asap", "critical", "important"]
    private static let deferredPriorityPhrases = ["not urgent", "no rush", "someday", "eventually", "whenever", "defer", "later"]
    private static let lowPriorityPhrases = ["low priority", "minor", "trivial", "nice to have"]

    private static func inferPriority(from text: String) -> Priority {
        let lowercased = text.lowercased()
        if highPriorityPhrases.contains(where: { lowercased.contains($0) }) {
            return .high
        }
        if deferredPriorityPhrases.contains(where: { lowercased.contains($0) }) {
            return .deferred
        }
        if lowPriorityPhrases.contains(where: { lowercased.contains($0) }) {
            return .low
        }
        return .medium
    }

    private static func hasExplicitPrioritySignal(in text: String) -> Bool {
        let lowercased = text.lowercased()
        let all = highPriorityPhrases + deferredPriorityPhrases + lowPriorityPhrases
        return all.contains { lowercased.contains($0) }
    }

    /// Weekday names mapped to `Calendar` weekday numbers (Sunday = 1).
    private static let weekdayNames: [(name: String, weekday: Int)] = [
        ("sunday", 1), ("monday", 2), ("tuesday", 3), ("wednesday", 4),
        ("thursday", 5), ("friday", 6), ("saturday", 7)
    ]

    private static func inferDate(from text: String, now: Date) -> Date? {
        let lowercased = text.lowercased()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)

        if lowercased.contains("today") || lowercased.contains("tonight") {
            return startOfToday
        }
        if lowercased.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: startOfToday)
        }
        if lowercased.contains("next week") {
            return calendar.date(byAdding: .day, value: 7, to: startOfToday)
        }
        if lowercased.contains("this weekend") || lowercased.contains("on the weekend") {
            return nextOccurrence(of: 7, after: now, calendar: calendar, allowToday: true) // Saturday
        }

        // "in N days" / "in N weeks"
        if let relative = relativeOffsetDate(from: lowercased, startOfToday: startOfToday, calendar: calendar) {
            return relative
        }

        // Weekday names: "next Monday", "on Friday", "this Thursday".
        for (name, weekday) in weekdayNames where lowercased.contains(name) {
            let allowToday = !lowercased.contains("next \(name)")
            return nextOccurrence(of: weekday, after: now, calendar: calendar, allowToday: allowToday)
        }

        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue),
           let match = detector.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
           let detectedDate = match.date {
            return detectedDate
        }

        return nil
    }

    /// Parse "in N days" / "in N weeks" into an absolute start-of-day date.
    private static func relativeOffsetDate(from lowercased: String, startOfToday: Date, calendar: Calendar) -> Date? {
        guard let regex = try? NSRegularExpression(pattern: #"\bin\s+(\d+)\s+(day|days|week|weeks)\b"#) else {
            return nil
        }
        let range = NSRange(lowercased.startIndex..., in: lowercased)
        guard let match = regex.firstMatch(in: lowercased, options: [], range: range),
              match.numberOfRanges >= 3,
              let countRange = Range(match.range(at: 1), in: lowercased),
              let unitRange = Range(match.range(at: 2), in: lowercased),
              let count = Int(lowercased[countRange]) else {
            return nil
        }
        let unit = lowercased[unitRange]
        let days = unit.hasPrefix("week") ? count * 7 : count
        return calendar.date(byAdding: .day, value: days, to: startOfToday)
    }

    /// Next start-of-day occurrence of the given weekday. When `allowToday` is false,
    /// today is skipped even if it matches (handles "next Monday").
    private static func nextOccurrence(of weekday: Int, after now: Date, calendar: Calendar, allowToday: Bool) -> Date? {
        let startOfToday = calendar.startOfDay(for: now)
        let todayWeekday = calendar.component(.weekday, from: startOfToday)
        var delta = (weekday - todayWeekday + 7) % 7
        if delta == 0 && !allowToday {
            delta = 7
        }
        return calendar.date(byAdding: .day, value: delta, to: startOfToday)
    }

    /// Remove recognized date and priority phrases so titles read as the core action.
    private static func stripSignalPhrases(from text: String) -> String {
        var working = text
        let datePhrases = [
            "(?i)\\bthis weekend\\b", "(?i)\\bon the weekend\\b", "(?i)\\bnext week\\b",
            "(?i)\\btomorrow\\b", "(?i)\\btonight\\b", "(?i)\\btoday\\b",
            "(?i)\\bin\\s+\\d+\\s+(day|days|week|weeks)\\b"
        ]
        let weekdayPhrases = weekdayNames.flatMap { name in
            ["(?i)\\bnext \(name.name)\\b", "(?i)\\bthis \(name.name)\\b", "(?i)\\bon \(name.name)\\b", "(?i)\\b\(name.name)\\b"]
        }
        let priorityPhrases = (highPriorityPhrases + deferredPriorityPhrases + lowPriorityPhrases)
            .map { "(?i)\\b\(NSRegularExpression.escapedPattern(for: $0))\\b" }

        for phrase in datePhrases + weekdayPhrases + priorityPhrases {
            working = working.replacingOccurrences(of: phrase, with: " ", options: .regularExpression)
        }
        // Collapse whitespace and strip dangling connectors left behind by removals.
        working = working.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        working = working.replacingOccurrences(of: "(?i)\\s*\\b(by|on|at|for)\\s*$", with: "", options: .regularExpression)
        let trimmed = working.trimmingCharacters(in: .whitespacesAndNewlines)
        // Never return empty — fall back to the original text if stripping removed everything.
        return trimmed.isEmpty ? text : trimmed
    }

    private static func inferTitle(from text: String) -> String {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else {
            return "New task"
        }

        let words = cleaned
            .split(separator: " ")
            .map(String.init)

        let firstSixWords = words.prefix(6).joined(separator: " ")
        return truncatedTitle(firstSixWords)
    }

    private static func truncatedTitle(_ title: String) -> String {
        let maxLength = 55
        if title.count <= maxLength {
            return title
        }
        let prefix = title.prefix(max(0, maxLength - 1))
        return "\(prefix)…"
    }
}
