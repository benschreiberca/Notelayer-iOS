import XCTest

final class VoiceTaskParserTests: XCTestCase {
    private func category(id: String, name: String) -> Category {
        Category(id: id, name: name, icon: "tag", color: "#222222", order: 0)
    }

    func testParseSplitsIntoGranularDrafts() {
        let categories = [
            category(id: "work", name: "Work Projects"),
            category(id: "finance", name: "Finance and Investing")
        ]

        let transcript = "Call the client then review the bank statement and file expense report"
        let drafts = VoiceTaskParser.parse(transcript: transcript, existingCategories: categories)

        XCTAssertGreaterThanOrEqual(drafts.count, 2)
        XCTAssertTrue(drafts.allSatisfy { !$0.title.isEmpty })
    }

    func testFallbackTitleUsesSixWordsAndCapsLength() {
        let transcript = "this is a very long sentence that should be trimmed heavily because it keeps going forever"
        let drafts = VoiceTaskParser.parse(transcript: transcript, existingCategories: [])
        guard let first = drafts.first else {
            XCTFail("Expected at least one draft")
            return
        }

        XCTAssertLessThanOrEqual(first.title.count, 55)
        XCTAssertLessThanOrEqual(first.title.split(separator: " ").count, 6)
    }

    func testCategoryGuessMapsOnlyToExistingCategories() {
        let categories = [
            category(id: "finance", name: "Finance and Investing"),
            category(id: "home", name: "Home")
        ]

        let transcript = "check my banking app and invest in index fund"
        let drafts = VoiceTaskParser.parse(transcript: transcript, existingCategories: categories)
        guard let first = drafts.first else {
            XCTFail("Expected at least one draft")
            return
        }

        XCTAssertTrue(first.categories.allSatisfy { ["finance", "home"].contains($0) })
    }

    func testNeedsReviewMarksLowConfidenceDrafts() {
        let transcript = "um maybe something later"
        let drafts = VoiceTaskParser.parse(transcript: transcript, existingCategories: [])
        guard let first = drafts.first else {
            XCTFail("Expected at least one draft")
            return
        }

        XCTAssertTrue(first.needsReview)
    }

    // MARK: - Date parsing

    private func makeNow() -> Date {
        // Fixed reference: Wednesday, 2026-06-24 10:00 local.
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 24
        components.hour = 10
        return Calendar.current.date(from: components) ?? Date()
    }

    func testParsesTomorrow() {
        let now = makeNow()
        let drafts = VoiceTaskParser.parse(transcript: "call the dentist tomorrow", existingCategories: [], now: now)
        guard let due = drafts.first?.dueDate else {
            XCTFail("Expected a due date")
            return
        }
        let expected = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now))
        XCTAssertEqual(Calendar.current.startOfDay(for: due), expected)
    }

    func testParsesNextWeekday() {
        let now = makeNow() // Wednesday
        let drafts = VoiceTaskParser.parse(transcript: "submit report next Monday", existingCategories: [], now: now)
        guard let due = drafts.first?.dueDate else {
            XCTFail("Expected a due date")
            return
        }
        // Next Monday from Wednesday 6/24 is 6/29.
        XCTAssertEqual(Calendar.current.component(.weekday, from: due), 2)
        XCTAssertGreaterThan(due, now)
    }

    func testParsesInNDays() {
        let now = makeNow()
        let drafts = VoiceTaskParser.parse(transcript: "renew passport in 3 days", existingCategories: [], now: now)
        guard let due = drafts.first?.dueDate else {
            XCTFail("Expected a due date")
            return
        }
        let expected = Calendar.current.date(byAdding: .day, value: 3, to: Calendar.current.startOfDay(for: now))
        XCTAssertEqual(Calendar.current.startOfDay(for: due), expected)
    }

    // MARK: - Priority parsing

    func testParsesHighPriority() {
        let drafts = VoiceTaskParser.parse(transcript: "fix the leak urgent", existingCategories: [])
        XCTAssertEqual(drafts.first?.priority, .high)
    }

    func testParsesLowPriority() {
        let drafts = VoiceTaskParser.parse(transcript: "organize bookshelf low priority", existingCategories: [])
        XCTAssertEqual(drafts.first?.priority, .low)
    }

    // MARK: - Title cleaning

    func testTitleStripsDateAndPriorityPhrases() {
        let drafts = VoiceTaskParser.parse(transcript: "call mom tomorrow urgent", existingCategories: [])
        guard let title = drafts.first?.title.lowercased() else {
            XCTFail("Expected a draft")
            return
        }
        XCTAssertTrue(title.contains("call mom"))
        XCTAssertFalse(title.contains("tomorrow"))
        XCTAssertFalse(title.contains("urgent"))
    }
}
