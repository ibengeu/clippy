import XCTest
@testable import ClipboardApp

final class ContentRedactionTests: XCTestCase {
    var manager: ClipboardHistoryManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.redaction")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.redaction")
        manager = ClipboardHistoryManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.redaction")
        manager = nil
        super.tearDown()
    }

    // MARK: - Sensitive Content Marking Tests

    func testMarkItemAsSensitive() {
        // Given
        let item = ClipboardItem(content: "password123")
        manager.addItem(item)

        // When
        manager.markAsSensitive(for: item.id)

        // Then
        let updatedItem = manager.items.first { $0.id == item.id }
        XCTAssertTrue(updatedItem?.isSensitive ?? false)
    }

    func testMarkItemAsNotSensitive() {
        // Given
        let item = ClipboardItem(content: "password123")
        manager.addItem(item)
        manager.markAsSensitive(for: item.id)

        // When
        manager.markAsNotSensitive(for: item.id)

        // Then
        let updatedItem = manager.items.first { $0.id == item.id }
        XCTAssertFalse(updatedItem?.isSensitive ?? true)
    }

    // MARK: - Redacted Content Tests

    func testGetRedactedContentReturnsDotsForSensitive() {
        // Given
        var item = ClipboardItem(content: "password123")
        item.isSensitive = true

        // When
        let redacted = manager.getRedactedContent(for: item)

        // Then
        XCTAssertEqual(redacted, "••••••••")
    }

    func testGetRedactedContentReturnsOriginalForNonSensitive() {
        // Given
        let item = ClipboardItem(content: "Hello World")

        // When
        let redacted = manager.getRedactedContent(for: item)

        // Then
        XCTAssertEqual(redacted, "Hello World")
    }

    func testRedactedContentAlwaysEightDots() {
        // Given
        var shortItem = ClipboardItem(content: "pw")
        shortItem.isSensitive = true
        var longItem = ClipboardItem(content: "very long password with many characters")
        longItem.isSensitive = true

        // When
        let shortRedacted = manager.getRedactedContent(for: shortItem)
        let longRedacted = manager.getRedactedContent(for: longItem)

        // Then
        XCTAssertEqual(shortRedacted, "••••••••")
        XCTAssertEqual(longRedacted, "••••••••")
    }

    // MARK: - Display Content Tests

    func testGetDisplayContentReturnsSensitiveIndicatorWhenRedacted() {
        // Given
        var item = ClipboardItem(content: "password123")
        item.isSensitive = true

        // When
        let display = manager.getDisplayContent(for: item)

        // Then
        XCTAssertEqual(display, "•••••••• (sensitive)")
    }

    func testGetDisplayContentReturnsOriginalWhenNotSensitive() {
        // Given
        let item = ClipboardItem(content: "Hello World")

        // When
        let display = manager.getDisplayContent(for: item)

        // Then
        XCTAssertEqual(display, "Hello World")
    }

    // MARK: - Actual Content Access Tests

    func testGetActualContentAlwaysReturnsOriginal() {
        // Given
        var sensitiveItem = ClipboardItem(content: "password123")
        sensitiveItem.isSensitive = true
        let normalItem = ClipboardItem(content: "Hello")

        // When
        let sensitiveActual = manager.getActualContent(for: sensitiveItem)
        let normalActual = manager.getActualContent(for: normalItem)

        // Then
        XCTAssertEqual(sensitiveActual, "password123")
        XCTAssertEqual(normalActual, "Hello")
    }

    // MARK: - Auto-Redaction Tests

    func testAddItemWithSourceAppMarksSensitive() {
        // Given
        let content = "password123"
        let sensitiveApp = "com.agilebits.onepassword7"
        var item = ClipboardItem(content: content)
        item.sourceApp = sensitiveApp

        // When
        manager.addItem(item, autoDetectSensitive: true)

        // Then
        let addedItem = manager.items.first
        XCTAssertTrue(addedItem?.isSensitive ?? false)
    }

    func testAddItemWithRegularAppDoesNotMarkSensitive() {
        // Given
        let content = "Hello World"
        let regularApp = "com.apple.Safari"
        var item = ClipboardItem(content: content)
        item.sourceApp = regularApp

        // When
        manager.addItem(item, autoDetectSensitive: true)

        // Then
        let addedItem = manager.items.first
        XCTAssertFalse(addedItem?.isSensitive ?? true)
    }

    func testAddItemWithoutAutoDetectDoesNotMarkSensitive() {
        // Given
        let content = "password123"
        let sensitiveApp = "com.agilebits.onepassword7"
        var item = ClipboardItem(content: content)
        item.sourceApp = sensitiveApp

        // When
        manager.addItem(item, autoDetectSensitive: false)

        // Then
        let addedItem = manager.items.first
        XCTAssertFalse(addedItem?.isSensitive ?? true)
    }

    // MARK: - Search with Sensitive Items Tests

    func testSearchDoesNotMatchRedactedContent() {
        // Given
        var sensitiveItem = ClipboardItem(content: "password123")
        sensitiveItem.isSensitive = true
        let normalItem = ClipboardItem(content: "password in text")
        manager.addItem(sensitiveItem)
        manager.addItem(normalItem)

        // When
        let results = manager.search(for: "password")

        // Then - Should only find the non-sensitive item
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, normalItem.id)
    }

    func testSearchCanFindSensitiveItemsByOriginalContent() {
        // Given
        var sensitiveItem = ClipboardItem(content: "password123")
        sensitiveItem.isSensitive = true
        manager.addItem(sensitiveItem)

        // When - Search with includeRedacted flag
        let results = manager.searchIncludingSensitive(for: "password")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, sensitiveItem.id)
    }
}
