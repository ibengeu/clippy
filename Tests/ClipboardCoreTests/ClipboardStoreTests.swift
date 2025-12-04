import XCTest
@testable import ClipboardCore

final class ClipboardStoreTests: XCTestCase {

    var store: ClipboardStore!
    var tempDirectory: URL!

    override func setUp() {
        super.setUp()

        // Create temp directory for testing
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        store = ClipboardStore(storageURL: tempDirectory.appendingPathComponent("test_store.json"))
    }

    override func tearDown() {
        store = nil

        // Clean up temp directory
        try? FileManager.default.removeItem(at: tempDirectory)

        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testStoreInitialization() throws {
        XCTAssertNotNil(store)
        XCTAssertEqual(store.count, 0)
        XCTAssertTrue(store.isEmpty)
    }

    // MARK: - Add Item Tests

    func testAddItem() throws {
        // Given
        let item = ClipboardItem(content: "Test", type: .text, sourceApp: "TestApp")

        // When
        store.add(item)

        // Then
        XCTAssertEqual(store.count, 1)
        XCTAssertFalse(store.isEmpty)
    }

    func testAddMultipleItems() throws {
        // Given
        let item1 = ClipboardItem(content: "Test 1", type: .text, sourceApp: "App1")
        let item2 = ClipboardItem(content: "Test 2", type: .text, sourceApp: "App2")
        let item3 = ClipboardItem(content: "Test 3", type: .text, sourceApp: "App3")

        // When
        store.add(item1)
        store.add(item2)
        store.add(item3)

        // Then
        XCTAssertEqual(store.count, 3)
    }

    func testAddDuplicateItem() throws {
        // Given
        let item1 = ClipboardItem(content: "Test", type: .text, sourceApp: "App")
        let item2 = ClipboardItem(content: "Test", type: .text, sourceApp: "App")

        // When
        store.add(item1)
        store.add(item2)

        // Then - should not add duplicate
        XCTAssertEqual(store.count, 1)
    }

    // MARK: - Remove Item Tests

    func testRemoveItem() throws {
        // Given
        let item = ClipboardItem(content: "Test", type: .text, sourceApp: "App")
        store.add(item)

        // When
        store.remove(item)

        // Then
        XCTAssertEqual(store.count, 0)
        XCTAssertTrue(store.isEmpty)
    }

    func testRemoveItemById() throws {
        // Given
        let item = ClipboardItem(content: "Test", type: .text, sourceApp: "App")
        store.add(item)

        // When
        store.remove(byId: item.id)

        // Then
        XCTAssertEqual(store.count, 0)
    }

    func testRemoveNonexistentItem() throws {
        // Given
        let item = ClipboardItem(content: "Test", type: .text, sourceApp: "App")

        // When
        store.remove(item)

        // Then - should not crash
        XCTAssertEqual(store.count, 0)
    }

    // MARK: - Retrieve Item Tests

    func testGetAllItems() throws {
        // Given
        let item1 = ClipboardItem(content: "Test 1", type: .text, sourceApp: "App1")
        let item2 = ClipboardItem(content: "Test 2", type: .text, sourceApp: "App2")
        store.add(item1)
        store.add(item2)

        // When
        let items = store.getAllItems()

        // Then
        XCTAssertEqual(items.count, 2)
    }

    func testGetItemById() throws {
        // Given
        let item = ClipboardItem(content: "Test", type: .text, sourceApp: "App")
        store.add(item)

        // When
        let retrieved = store.getItem(byId: item.id)

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.id, item.id)
        XCTAssertEqual(retrieved?.content, item.content)
    }

    func testGetNonexistentItemById() throws {
        // When
        let retrieved = store.getItem(byId: UUID())

        // Then
        XCTAssertNil(retrieved)
    }

    // MARK: - Clear Tests

    func testClearAll() throws {
        // Given
        store.add(ClipboardItem(content: "Test 1", type: .text, sourceApp: "App"))
        store.add(ClipboardItem(content: "Test 2", type: .text, sourceApp: "App"))
        store.add(ClipboardItem(content: "Test 3", type: .text, sourceApp: "App"))

        // When
        store.clear()

        // Then
        XCTAssertEqual(store.count, 0)
        XCTAssertTrue(store.isEmpty)
    }

    // MARK: - Max Items Tests

    func testMaxItemsLimit() throws {
        // Given
        store.maxItems = 5

        // When - add more than max
        for i in 0..<10 {
            store.add(ClipboardItem(content: "Test \(i)", type: .text, sourceApp: "App"))
        }

        // Then - should only keep the most recent maxItems
        XCTAssertEqual(store.count, 5)
    }

    func testMaxItemsPreservesPinnedItems() throws {
        // Given
        store.maxItems = 3
        let pinnedItem = ClipboardItem(content: "Pinned", type: .text, sourceApp: "App")
        pinnedItem.pin()
        store.add(pinnedItem)

        // When - add more items than max
        for i in 0..<5 {
            store.add(ClipboardItem(content: "Test \(i)", type: .text, sourceApp: "App"))
        }

        // Then - pinned item should still be there
        XCTAssertTrue(store.count >= 3)
        let items = store.getAllItems()
        XCTAssertTrue(items.contains { $0.id == pinnedItem.id })
    }

    // MARK: - Persistence Tests

    func testSaveToDisk() throws {
        // Given
        store.add(ClipboardItem(content: "Test 1", type: .text, sourceApp: "App"))
        store.add(ClipboardItem(content: "Test 2", type: .code, sourceApp: "Xcode"))

        // When
        try store.save()

        // Then - file should exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.storageURL.path))
    }

    func testLoadFromDisk() throws {
        // Given
        let item1 = ClipboardItem(content: "Test 1", type: .text, sourceApp: "App")
        let item2 = ClipboardItem(content: "Test 2", type: .code, sourceApp: "Xcode")
        store.add(item1)
        store.add(item2)
        try store.save()

        // When - create new store and load
        let newStore = ClipboardStore(storageURL: store.storageURL)
        try newStore.load()

        // Then
        XCTAssertEqual(newStore.count, 2)
        let items = newStore.getAllItems()
        XCTAssertTrue(items.contains { $0.content == "Test 1" })
        XCTAssertTrue(items.contains { $0.content == "Test 2" })
    }

    func testLoadFromNonexistentFile() throws {
        // Given
        let nonexistentURL = tempDirectory.appendingPathComponent("nonexistent.json")
        let newStore = ClipboardStore(storageURL: nonexistentURL)

        // When/Then - should not throw, just return empty store
        try newStore.load()
        XCTAssertEqual(newStore.count, 0)
    }

    func testAutoSave() throws {
        // Given
        store.autoSave = true

        // When
        store.add(ClipboardItem(content: "Test", type: .text, sourceApp: "App"))

        // Small delay to allow async save
        Thread.sleep(forTimeInterval: 0.1)

        // Then - file should exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.storageURL.path))
    }

    // MARK: - Update Item Tests

    func testUpdateItem() throws {
        // Given
        let item = ClipboardItem(content: "Original", type: .text, sourceApp: "App")
        store.add(item)

        // When
        item.pin()
        store.update(item)

        // Then
        let retrieved = store.getItem(byId: item.id)
        XCTAssertTrue(retrieved?.isPinned ?? false)
    }

    // MARK: - Recent Items Tests

    func testGetRecentItems() throws {
        // Given
        let now = Date()
        for i in 0..<10 {
            let item = ClipboardItem(
                timestamp: now.addingTimeInterval(Double(-i * 60)),
                content: "Test \(i)",
                type: .text,
                sourceApp: "App"
            )
            store.add(item)
        }

        // When
        let recent = store.getRecentItems(limit: 5)

        // Then
        XCTAssertEqual(recent.count, 5)
        // Should be sorted by most recent first
        XCTAssertEqual(recent[0].content, "Test 0")
        XCTAssertEqual(recent[4].content, "Test 4")
    }

    // MARK: - Pinned Items Tests

    func testGetPinnedItems() throws {
        // Given
        let item1 = ClipboardItem(content: "Test 1", type: .text, sourceApp: "App")
        let item2 = ClipboardItem(content: "Test 2", type: .text, sourceApp: "App")
        let item3 = ClipboardItem(content: "Test 3", type: .text, sourceApp: "App")

        item1.pin()
        item3.pin()

        store.add(item1)
        store.add(item2)
        store.add(item3)

        // When
        let pinned = store.getPinnedItems()

        // Then
        XCTAssertEqual(pinned.count, 2)
        XCTAssertTrue(pinned.allSatisfy { $0.isPinned })
    }

    // MARK: - Contains Tests

    func testContainsItem() throws {
        // Given
        let item = ClipboardItem(content: "Test", type: .text, sourceApp: "App")
        store.add(item)

        // When/Then
        XCTAssertTrue(store.contains(item))
    }

    func testDoesNotContainItem() throws {
        // Given
        let item = ClipboardItem(content: "Test", type: .text, sourceApp: "App")

        // When/Then
        XCTAssertFalse(store.contains(item))
    }

    // MARK: - Performance Tests

    func testAddPerformance() throws {
        measure {
            let tempStore = ClipboardStore()
            for i in 0..<1000 {
                tempStore.add(ClipboardItem(content: "Test \(i)", type: .text, sourceApp: "App"))
            }
        }
    }

    func testRetrievePerformance() throws {
        // Given - populate store
        for i in 0..<1000 {
            store.add(ClipboardItem(content: "Test \(i)", type: .text, sourceApp: "App"))
        }

        // When/Then
        measure {
            _ = store.getAllItems()
        }
    }

    func testSavePerformance() throws {
        // Given - populate store
        for i in 0..<300 {
            store.add(ClipboardItem(content: "Test \(i)", type: .text, sourceApp: "App"))
        }

        // When/Then
        measure {
            try? store.save()
        }
    }

    func testLoadPerformance() throws {
        // Given - save 300 items
        for i in 0..<300 {
            store.add(ClipboardItem(content: "Test \(i)", type: .text, sourceApp: "App"))
        }
        try store.save()

        // When/Then
        measure {
            let tempStore = ClipboardStore(storageURL: store.storageURL)
            try? tempStore.load()
        }
    }

    // MARK: - Thread Safety Tests

    func testConcurrentAdds() throws {
        // Given
        let expectation = XCTestExpectation(description: "Concurrent adds complete")
        expectation.expectedFulfillmentCount = 10

        // When - add items concurrently
        for i in 0..<10 {
            DispatchQueue.global().async {
                self.store.add(ClipboardItem(content: "Test \(i)", type: .text, sourceApp: "App"))
                expectation.fulfill()
            }
        }

        // Then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(store.count, 10)
    }
}
