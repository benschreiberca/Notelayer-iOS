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
        let title = inferTitle(from: cleaned)

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

    private static func inferPriority(from text: String) -> Priority {
        let lowercased = text.lowercased()
        if ["urgent", "asap", "critical", "high priority"].contains(where: { lowercased.contains($0) }) {
            return .high
        }
        if ["someday", "later", "defer", "not urgent"].contains(where: { lowercased.contains($0) }) {
            return .deferred
        }
        if ["low priority", "minor"].contains(where: { lowercased.contains($0) }) {
            return .low
        }
        return .medium
    }

    private static func hasExplicitPrioritySignal(in text: String) -> Bool {
        let lowercased = text.lowercased()
        return ["urgent", "asap", "high priority", "low priority", "someday", "defer", "later"].contains {
            lowercased.contains($0)
        }
    }

    private static func inferDate(from text: String, now: Date) -> Date? {
        let lowercased = text.lowercased()
        let calendar = Calendar.current

        if lowercased.contains("today") {
            return calendar.startOfDay(for: now)
        }
        if lowercased.contains("tomorrow") {
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
        }
        if lowercased.contains("next week") {
            return calendar.date(byAdding: .day, value: 7, to: calendar.startOfDay(for: now))
        }

        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue),
           let match = detector.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
           let detectedDate = match.date {
            return detectedDate
        }

        return nil
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
