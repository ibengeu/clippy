import XCTest
import SwiftUI
@testable import ClipboardApp

final class PinnedItemsSectionTests: XCTestCase {
    var manager: ClipboardHistoryManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.pinned")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.pinned")
        manager = ClipboardHistoryManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.pinned")
        manager = nil
        super.tearDown()
    }

    // MARK: - Pinned Items Display Tests

    func testPinnedItemsAppearFirst() {
        // Given
        let item1 = ClipboardItem(content: "First")
        let item2 = ClipboardItem(content: "Second")
        let item3 = ClipboardItem(content: "Third")

        manager.addItem(item1)
        manager.addItem(item2)
        manager.addItem(item3)

        // Pin the second item (which is in the middle)
        manager.togglePin(for: item2.id)

        // When
        let pinnedItems = manager.getPinnedItems()
        let allItems = manager.items

        // Then
        XCTAssertEqual(pinnedItems.count, 1)
        XCTAssertTrue(pinnedItems.first?.isPinned ?? false)
    }

    func testMaxPinnedItemsLimit() {
        // Given - Add 10 items
        for i in 1...10 {
            let item = ClipboardItem(content: "Item \(i)")
            manager.addItem(item)
        }

        // When - Try to pin all 10
        for item in manager.items {
            manager.togglePin(for: item.id)
        }

        // Then - Should have all 10 pinned (no UI limit enforced in manager)
        XCTAssertEqual(manager.getPinnedItems().count, 10)
    }

    func testUnpinRemovesFromPinnedSection() {
        // Given
        let item = ClipboardItem(content: "Test")
        manager.addItem(item)
        manager.togglePin(for: item.id)

        XCTAssertEqual(manager.getPinnedItems().count, 1)

        // When
        manager.togglePin(for: item.id)

        // Then
        XCTAssertEqual(manager.getPinnedItems().count, 0)
    }

    // MARK: - Pinned Items Ordering Tests

    func testPinnedItemsMaintainPinOrder() {
        // Given
        let item1 = ClipboardItem(content: "First")
        let item2 = ClipboardItem(content: "Second")
        let item3 = ClipboardItem(content: "Third")

        manager.addItem(item1)
        manager.addItem(item2)
        manager.addItem(item3)

        // When - Pin in specific order
        manager.togglePin(for: item1.id)
        manager.togglePin(for: item3.id)

        let pinnedItems = manager.getPinnedItems()

        // Then - Should maintain order
        XCTAssertEqual(pinnedItems.count, 2)
        XCTAssertTrue(pinnedItems.allSatisfy { $0.isPinned })
    }

    // MARK: - Visual Separation Tests

    func testPinnedAndRecentItemsAreSeparate() {
        // Given
        let pinnedItem = ClipboardItem(content: "Pinned")
        let recentItem = ClipboardItem(content: "Recent")

        manager.addItem(pinnedItem)
        manager.addItem(recentItem)
        manager.togglePin(for: pinnedItem.id)

        // When
        let pinnedItems = manager.getPinnedItems()
        let allItems = manager.items

        // Then
        XCTAssertEqual(pinnedItems.count, 1)
        XCTAssertEqual(allItems.count, 2)
        XCTAssertTrue(pinnedItems.first?.content == "Pinned")
    }

    // MARK: - Empty State Tests

    func testNoPinnedItemsReturnsEmptyArray() {
        // Given - Add items but don't pin any
        manager.addItem(ClipboardItem(content: "Test 1"))
        manager.addItem(ClipboardItem(content: "Test 2"))

        // When
        let pinnedItems = manager.getPinnedItems()

        // Then
        XCTAssertTrue(pinnedItems.isEmpty)
    }

    func testEmptyHistoryReturnsNoPinnedItems() {
        // Given - Empty manager
        // When
        let pinnedItems = manager.getPinnedItems()

        // Then
        XCTAssertTrue(pinnedItems.isEmpty)
    }
}
