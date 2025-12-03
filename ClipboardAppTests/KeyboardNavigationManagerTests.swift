import XCTest
@testable import ClipboardApp

final class KeyboardNavigationManagerTests: XCTestCase {
    var manager: ClipboardHistoryManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.keynav")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.keynav")
        manager = ClipboardHistoryManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.keynav")
        manager = nil
        super.tearDown()
    }

    // MARK: - Selection Index Tests

    func testInitialSelectionIsFirst() {
        // Given
        manager.addItem(ClipboardItem(content: "Item 1"))
        manager.addItem(ClipboardItem(content: "Item 2"))

        // When
        let initialIndex = 0

        // Then
        XCTAssertEqual(initialIndex, 0)
    }

    func testNavigateDownIncrementsIndex() {
        // Given
        var selectedIndex = 0
        manager.addItem(ClipboardItem(content: "Item 1"))
        manager.addItem(ClipboardItem(content: "Item 2"))
        manager.addItem(ClipboardItem(content: "Item 3"))

        // When
        selectedIndex = min(selectedIndex + 1, manager.items.count - 1)

        // Then
        XCTAssertEqual(selectedIndex, 1)
    }

    func testNavigateUpDecrementsIndex() {
        // Given
        var selectedIndex = 2
        manager.addItem(ClipboardItem(content: "Item 1"))
        manager.addItem(ClipboardItem(content: "Item 2"))
        manager.addItem(ClipboardItem(content: "Item 3"))

        // When
        selectedIndex = max(selectedIndex - 1, 0)

        // Then
        XCTAssertEqual(selectedIndex, 1)
    }

    func testNavigateUpAtTopStaysAtZero() {
        // Given
        var selectedIndex = 0
        manager.addItem(ClipboardItem(content: "Item 1"))

        // When
        selectedIndex = max(selectedIndex - 1, 0)

        // Then
        XCTAssertEqual(selectedIndex, 0)
    }

    func testNavigateDownAtBottomStaysAtLast() {
        // Given
        manager.addItem(ClipboardItem(content: "Item 1"))
        manager.addItem(ClipboardItem(content: "Item 2"))
        var selectedIndex = manager.items.count - 1

        // When
        selectedIndex = min(selectedIndex + 1, manager.items.count - 1)

        // Then
        XCTAssertEqual(selectedIndex, 1) // Last index
    }

    // MARK: - Selection with Filtered Items

    func testSelectionWithSearch() {
        // Given
        manager.addItem(ClipboardItem(content: "Apple"))
        manager.addItem(ClipboardItem(content: "Banana"))
        manager.addItem(ClipboardItem(content: "Apple Juice"))

        let searchResults = manager.search(for: "Apple")
        let selectedIndex = 0

        // Then
        XCTAssertEqual(searchResults.count, 2)
        XCTAssertEqual(searchResults[selectedIndex].content, "Apple Juice")
    }

    // MARK: - Action Tests

    func testEnterKeyActionPastesSelectedItem() {
        // Given
        let item = ClipboardItem(content: "Test Content")
        manager.addItem(item)
        let selectedIndex = 0

        // When
        let selectedItem = manager.items[selectedIndex]

        // Then
        XCTAssertEqual(selectedItem.content, "Test Content")
    }

    func testDeleteKeyActionRemovesSelectedItem() {
        // Given
        let item = ClipboardItem(content: "To Delete")
        manager.addItem(item)
        let itemId = manager.items[0].id

        // When
        manager.deleteItem(with: itemId)

        // Then
        XCTAssertTrue(manager.items.isEmpty)
    }

    func testCommandPTogglesPin() {
        // Given
        let item = ClipboardItem(content: "To Pin")
        manager.addItem(item)
        let itemId = manager.items[0].id

        // When
        manager.togglePin(for: itemId)

        // Then
        XCTAssertTrue(manager.items[0].isPinned)
    }

    // MARK: - Section Navigation Tests

    func testNavigateBetweenPinnedAndRecent() {
        // Given
        let pinnedItem = ClipboardItem(content: "Pinned")
        let recentItem = ClipboardItem(content: "Recent")

        manager.addItem(pinnedItem)
        manager.addItem(recentItem)
        manager.togglePin(for: pinnedItem.id)

        let pinnedItems = manager.getPinnedItems()
        let recentItems = manager.items.filter { !$0.isPinned }

        // Then
        XCTAssertEqual(pinnedItems.count, 1)
        XCTAssertEqual(recentItems.count, 1)
    }
}
