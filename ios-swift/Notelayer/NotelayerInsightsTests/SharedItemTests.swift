import XCTest

final class SharedItemTests: XCTestCase {
    func testLegacyPayloadDecodesWithSafeDefaults() throws {
        let legacyJSON = """
        {
          "id": "legacy-1",
          "title": "Legacy Task",
          "text": "Some shared body",
          "sourceApp": "ChatGPT",
          "categories": ["finance"],
          "priority": "medium"
        }
        """
        let data = try XCTUnwrap(legacyJSON.data(using: .utf8))
        let item = try JSONDecoder().decode(SharedItem.self, from: data)

        XCTAssertEqual(item.destination, .task)
        XCTAssertEqual(item.status, .pending)
        XCTAssertEqual(item.retryCount, 0)
        XCTAssertFalse(item.wasTruncated)
        XCTAssertTrue(item.taskDrafts.isEmpty)
    }

    func testMarkedFailedUpdatesFailureMetadata() {
        let item = SharedItem(title: "Example")
        let failed = item.markedFailed(reason: "parse failed")

        XCTAssertEqual(failed.status, .failed)
        XCTAssertEqual(failed.lastError, "parse failed")
        XCTAssertEqual(failed.retryCount, 1)
    }

    func testRoundTripPreservesDraftsAndDestination() throws {
        let item = SharedItem(
            title: "Imported task list",
            destination: .taskBatch,
            taskDrafts: [
                SharedTaskDraft(title: "Step 1"),
                SharedTaskDraft(title: "Step 2")
            ],
            wasTruncated: true
        )

        let encoded = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(SharedItem.self, from: encoded)

        XCTAssertEqual(decoded.destination, .taskBatch)
        XCTAssertEqual(decoded.taskDrafts.count, 2)
        XCTAssertTrue(decoded.wasTruncated)
    }
}
