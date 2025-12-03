import XCTest
@testable import ClipboardApp

final class ClipboardItemEnhancedTests: XCTestCase {

    // MARK: - Pin Property Tests

    func testItemInitializedAsNotPinned() {
        // Given/When
        let item = ClipboardItem(content: "Test")

        // Then
        XCTAssertFalse(item.isPinned)
    }

    func testItemCanBePinned() {
        // Given
        var item = ClipboardItem(content: "Test")

        // When
        item.isPinned = true

        // Then
        XCTAssertTrue(item.isPinned)
    }

    // MARK: - Content Type Tests

    func testDefaultContentTypeIsText() {
        // Given/When
        let item = ClipboardItem(content: "Test")

        // Then
        XCTAssertEqual(item.contentType, .text)
    }

    func testContentTypeCanBeSet() {
        // Given/When
        let item = ClipboardItem(content: "Test", contentType: .image)

        // Then
        XCTAssertEqual(item.contentType, .image)
    }

    // MARK: - Sensitive Flag Tests

    func testItemInitializedAsNotSensitive() {
        // Given/When
        let item = ClipboardItem(content: "Test")

        // Then
        XCTAssertFalse(item.isSensitive)
    }

    func testItemCanBeMarkedSensitive() {
        // Given
        var item = ClipboardItem(content: "Password123")

        // When
        item.isSensitive = true

        // Then
        XCTAssertTrue(item.isSensitive)
    }

    // MARK: - Source App Tests

    func testSourceAppDefaultsToNil() {
        // Given/When
        let item = ClipboardItem(content: "Test")

        // Then
        XCTAssertNil(item.sourceApp)
    }

    func testSourceAppCanBeSet() {
        // Given/When
        let item = ClipboardItem(content: "Test", sourceApp: "com.apple.Safari")

        // Then
        XCTAssertEqual(item.sourceApp, "com.apple.Safari")
    }

    // MARK: - Access Count Tests

    func testAccessCountDefaultsToZero() {
        // Given/When
        let item = ClipboardItem(content: "Test")

        // Then
        XCTAssertEqual(item.accessCount, 0)
    }

    func testAccessCountCanBeIncremented() {
        // Given
        var item = ClipboardItem(content: "Test")

        // When
        item.accessCount += 1

        // Then
        XCTAssertEqual(item.accessCount, 1)
    }

    // MARK: - Last Accessed Date Tests

    func testLastAccessedDateDefaultsToNil() {
        // Given/When
        let item = ClipboardItem(content: "Test")

        // Then
        XCTAssertNil(item.lastAccessedDate)
    }

    func testLastAccessedDateCanBeSet() {
        // Given
        var item = ClipboardItem(content: "Test")
        let now = Date()

        // When
        item.lastAccessedDate = now

        // Then
        XCTAssertNotNil(item.lastAccessedDate)
        XCTAssertEqual(item.lastAccessedDate, now)
    }

    // MARK: - Codable Compatibility Tests

    func testEnhancedItemIsCodable() throws {
        // Given
        var item = ClipboardItem(content: "Test")
        item.isPinned = true
        item.contentType = .image
        item.isSensitive = true
        item.sourceApp = "com.test.app"
        item.accessCount = 5
        item.lastAccessedDate = Date()

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(ClipboardItem.self, from: data)

        // Then
        XCTAssertEqual(item.id, decodedItem.id)
        XCTAssertEqual(item.content, decodedItem.content)
        XCTAssertEqual(item.isPinned, decodedItem.isPinned)
        XCTAssertEqual(item.contentType, decodedItem.contentType)
        XCTAssertEqual(item.isSensitive, decodedItem.isSensitive)
        XCTAssertEqual(item.sourceApp, decodedItem.sourceApp)
        XCTAssertEqual(item.accessCount, decodedItem.accessCount)
    }

    // MARK: - Backward Compatibility Test

    func testBackwardCompatibilityWithOldData() throws {
        // Given - old data format (without new properties)
        let oldJSON = """
        {
            "id": "123e4567-e89b-12d3-a456-426614174000",
            "content": "Test content",
            "timestamp": 694310400.0,
            "isFavorite": false,
            "category": "General"
        }
        """

        // When
        let decoder = JSONDecoder()
        let data = oldJSON.data(using: .utf8)!
        let item = try decoder.decode(ClipboardItem.self, from: data)

        // Then - new properties should have defaults
        XCTAssertEqual(item.content, "Test content")
        XCTAssertFalse(item.isPinned)
        XCTAssertEqual(item.contentType, .text)
        XCTAssertFalse(item.isSensitive)
        XCTAssertNil(item.sourceApp)
        XCTAssertEqual(item.accessCount, 0)
        XCTAssertNil(item.lastAccessedDate)
    }

    // MARK: - Pinned vs Favorite Distinction

    func testPinnedAndFavoriteAreIndependent() {
        // Given
        var item = ClipboardItem(content: "Test")

        // When
        item.isPinned = true
        item.isFavorite = false

        // Then
        XCTAssertTrue(item.isPinned)
        XCTAssertFalse(item.isFavorite)

        // When
        item.isFavorite = true
        item.isPinned = false

        // Then
        XCTAssertFalse(item.isPinned)
        XCTAssertTrue(item.isFavorite)
    }
}
