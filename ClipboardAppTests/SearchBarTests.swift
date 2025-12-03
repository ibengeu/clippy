import XCTest
@testable import ClipboardApp

final class SearchBarTests: XCTestCase {
    var manager: ClipboardHistoryManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.search")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.search")
        manager = ClipboardHistoryManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.search")
        manager = nil
        super.tearDown()
    }

    // MARK: - Search Functionality Tests

    func testSearchReturnsMatchingItems() {
        // Given
        manager.addItem(ClipboardItem(content: "Apple fruit"))
        manager.addItem(ClipboardItem(content: "Banana yellow"))
        manager.addItem(ClipboardItem(content: "Apple juice"))

        // When
        let results = manager.search(for: "Apple")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.content.contains("Apple") })
    }

    func testSearchIsCaseInsensitive() {
        // Given
        manager.addItem(ClipboardItem(content: "UPPERCASE"))
        manager.addItem(ClipboardItem(content: "lowercase"))
        manager.addItem(ClipboardItem(content: "MiXeD"))

        // When
        let results = manager.search(for: "case")

        // Then
        XCTAssertEqual(results.count, 2)
    }

    func testEmptySearchReturnsAllItems() {
        // Given
        manager.addItem(ClipboardItem(content: "Item 1"))
        manager.addItem(ClipboardItem(content: "Item 2"))
        manager.addItem(ClipboardItem(content: "Item 3"))

        // When
        let results = manager.search(for: "")

        // Then
        XCTAssertEqual(results.count, 3)
    }

    func testSearchWithNoMatches() {
        // Given
        manager.addItem(ClipboardItem(content: "Apple"))
        manager.addItem(ClipboardItem(content: "Banana"))

        // When
        let results = manager.search(for: "Orange")

        // Then
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchPartialMatch() {
        // Given
        manager.addItem(ClipboardItem(content: "SwiftClip is awesome"))
        manager.addItem(ClipboardItem(content: "Clipboard manager"))

        // When
        let results = manager.search(for: "Clip")

        // Then
        XCTAssertEqual(results.count, 2)
    }

    // MARK: - Search Performance Tests

    func testSearchWithManyItems() {
        // Given - Add 100 items
        for i in 1...100 {
            manager.addItem(ClipboardItem(content: "Item \(i)"))
        }

        // When
        let startTime = Date()
        let results = manager.search(for: "Item 5")
        let duration = Date().timeIntervalSince(startTime)

        // Then
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertLessThan(duration, 0.1) // Should complete in < 100ms
    }

    // MARK: - Search with Pinned Items

    func testSearchIncludesPinnedItems() {
        // Given
        let item1 = ClipboardItem(content: "Pinned Apple")
        let item2 = ClipboardItem(content: "Regular Apple")

        manager.addItem(item1)
        manager.addItem(item2)
        manager.togglePin(for: item1.id)

        // When
        let results = manager.search(for: "Apple")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains(where: { $0.isPinned }))
    }
}
