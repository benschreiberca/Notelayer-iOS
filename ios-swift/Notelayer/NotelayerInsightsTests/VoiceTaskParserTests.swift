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
}
