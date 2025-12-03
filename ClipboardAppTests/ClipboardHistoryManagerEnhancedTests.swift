import XCTest
@testable import ClipboardApp

final class ClipboardHistoryManagerEnhancedTests: XCTestCase {
    var manager: ClipboardHistoryManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.enhanced")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.enhanced")
        manager = ClipboardHistoryManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.enhanced")
        manager = nil
        super.tearDown()
    }

    // MARK: - Pin/Unpin Tests

    func testTogglePin() {
        // Given
        let item = ClipboardItem(content: "Test")
        manager.addItem(item)

        // When
        manager.togglePin(for: item.id)

        // Then
        XCTAssertTrue(manager.items.first?.isPinned ?? false)
    }

    func testTogglePinTwiceUnpins() {
        // Given
        let item = ClipboardItem(content: "Test")
        manager.addItem(item)
        manager.togglePin(for: item.id)

        // When
        manager.togglePin(for: item.id)

        // Then
        XCTAssertFalse(manager.items.first?.isPinned ?? true)
    }

    func testGetPinnedItems() {
        // Given
        let item1 = ClipboardItem(content: "Pinned 1")
        let item2 = ClipboardItem(content: "Not pinned")
        let item3 = ClipboardItem(content: "Pinned 2")

        manager.addItem(item1)
        manager.addItem(item2)
        manager.addItem(item3)

        manager.togglePin(for: item1.id)
        manager.togglePin(for: item3.id)

        // When
        let pinnedItems = manager.getPinnedItems()

        // Then
        XCTAssertEqual(pinnedItems.count, 2)
        XCTAssertTrue(pinnedItems.allSatisfy { $0.isPinned })
    }

    // MARK: - Access Tracking Tests

    func testIncrementAccessCount() {
        // Given
        let item = ClipboardItem(content: "Test")
        manager.addItem(item)

        // When
        manager.incrementAccessCount(for: item.id)
        manager.incrementAccessCount(for: item.id)

        // Then
        XCTAssertEqual(manager.items.first?.accessCount, 2)
    }

    func testUpdateLastAccessed() {
        // Given
        let item = ClipboardItem(content: "Test")
        manager.addItem(item)
        let beforeUpdate = Date()

        // When
        manager.updateLastAccessed(for: item.id)

        // Then
        XCTAssertNotNil(manager.items.first?.lastAccessedDate)
        if let lastAccessed = manager.items.first?.lastAccessedDate {
            XCTAssertGreaterThanOrEqual(lastAccessed, beforeUpdate)
        }
    }

    // MARK: - Sensitive Content Tests

    func testMarkAsSensitive() {
        // Given
        let item = ClipboardItem(content: "Password123")
        manager.addItem(item)

        // When
        manager.markAsSensitive(for: item.id)

        // Then
        XCTAssertTrue(manager.items.first?.isSensitive ?? false)
    }

    func testGetRedactedContent() {
        // Given
        var item = ClipboardItem(content: "Sensitive password")
        item.isSensitive = true

        // When
        let redacted = manager.getRedactedContent(for: item)

        // Then
        XCTAssertEqual(redacted, "••••••••")
    }

    func testGetRedactedContentForNonSensitive() {
        // Given
        let item = ClipboardItem(content: "Public content")

        // When
        let redacted = manager.getRedactedContent(for: item)

        // Then
        XCTAssertEqual(redacted, "Public content")
    }

    // MARK: - Sorting Tests

    func testSortByRecency() {
        // Given
        let old = ClipboardItem(content: "Old", timestamp: Date().addingTimeInterval(-100))
        let new = ClipboardItem(content: "New", timestamp: Date())
        let middle = ClipboardItem(content: "Middle", timestamp: Date().addingTimeInterval(-50))

        manager.addItem(middle)
        manager.addItem(old)
        manager.addItem(new)

        // When
        let sorted = manager.sortByRecency()

        // Then
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].content, "New")
        XCTAssertEqual(sorted[1].content, "Middle")
        XCTAssertEqual(sorted[2].content, "Old")
    }

    func testSortByFrequency() {
        // Given
        let item1 = ClipboardItem(content: "Least used")
        let item2 = ClipboardItem(content: "Most used")
        let item3 = ClipboardItem(content: "Medium used")

        manager.addItem(item1)
        manager.addItem(item2)
        manager.addItem(item3)

        manager.incrementAccessCount(for: item2.id)
        manager.incrementAccessCount(for: item2.id)
        manager.incrementAccessCount(for: item2.id)
        manager.incrementAccessCount(for: item3.id)

        // When
        let sorted = manager.sortByFrequency()

        // Then
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].content, "Most used")
        XCTAssertEqual(sorted[1].content, "Medium used")
        XCTAssertEqual(sorted[2].content, "Least used")
    }

    // MARK: - FIFO Removal Tests

    func testFIFORemovalWhenLimitReached() {
        // Given - Set max history to 5
        manager.maxHistorySize = 5

        // Add 5 items
        for i in 1...5 {
            let item = ClipboardItem(content: "Item \(i)")
            manager.addItem(item)
        }

        XCTAssertEqual(manager.items.count, 5)

        // When - Add 6th item
        let newItem = ClipboardItem(content: "Item 6")
        manager.addItem(newItem)

        // Then - Should still be 5 items, oldest removed
        XCTAssertEqual(manager.items.count, 5)
        XCTAssertTrue(manager.items.contains(where: { $0.content == "Item 6" }))
        XCTAssertFalse(manager.items.contains(where: { $0.content == "Item 1" }))
    }

    func testFIFODoesNotRemovePinnedItems() {
        // Given - Set max history to 3
        manager.maxHistorySize = 3

        // Add 3 items, pin the first one
        let item1 = ClipboardItem(content: "Pinned Old")
        let item2 = ClipboardItem(content: "Item 2")
        let item3 = ClipboardItem(content: "Item 3")

        manager.addItem(item1)
        manager.addItem(item2)
        manager.addItem(item3)
        manager.togglePin(for: item1.id)

        // When - Add 4th item
        let item4 = ClipboardItem(content: "Item 4")
        manager.addItem(item4)

        // Then - Should remove item2 (oldest non-pinned), keep pinned item1
        XCTAssertEqual(manager.items.count, 3)
        XCTAssertTrue(manager.items.contains(where: { $0.content == "Pinned Old" }))
        XCTAssertFalse(manager.items.contains(where: { $0.content == "Item 2" }))
        XCTAssertTrue(manager.items.contains(where: { $0.content == "Item 4" }))
    }

    // MARK: - Persistence Tests

    func testPinnedItemsPersist() {
        // Given
        let item = ClipboardItem(content: "Pinned")
        manager.addItem(item)
        manager.togglePin(for: item.id)

        // When - Create new manager with same UserDefaults
        let newManager = ClipboardHistoryManager(userDefaults: testUserDefaults)

        // Then
        XCTAssertEqual(newManager.items.count, 1)
        XCTAssertTrue(newManager.items.first?.isPinned ?? false)
    }
}
