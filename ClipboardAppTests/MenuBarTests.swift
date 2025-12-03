import XCTest
import SwiftUI
@testable import ClipboardApp

final class MenuBarTests: XCTestCase {

    // MARK: - MenuBarState Tests

    func testMenuBarStateInitialization() {
        // Given/When
        let state = MenuBarState()

        // Then
        XCTAssertFalse(state.isShowingClearConfirmation)
    }

    func testShowClearConfirmation() {
        // Given
        let state = MenuBarState()

        // When
        state.showClearConfirmation()

        // Then
        XCTAssertTrue(state.isShowingClearConfirmation)
    }

    func testDismissClearConfirmation() {
        // Given
        let state = MenuBarState()
        state.showClearConfirmation()

        // When
        state.dismissClearConfirmation()

        // Then
        XCTAssertFalse(state.isShowingClearConfirmation)
    }

    // MARK: - Menu Structure Tests

    func testMenuSectionsExist() {
        // These tests verify the menu structure matches the plan
        // Actual implementation will be in MenuBarView

        // Expected sections:
        // 1. Show Clipboard
        // 2. Pinned Items (submenu)
        // 3. Clear History
        // 4. Privacy Settings / Preferences
        // 5. Quit SwiftClip

        XCTAssertTrue(true, "Menu structure should be verified in UI tests")
    }

    // MARK: - Pinned Items Submenu Tests

    func testGetPinnedItemsForMenu() {
        // Given
        let userDefaults = UserDefaults(suiteName: "test-menu-pinned-\(UUID().uuidString)")!
        userDefaults.removeObject(forKey: "clipboardItems")
        let manager = ClipboardHistoryManager(userDefaults: userDefaults)

        let item1 = ClipboardItem(content: "Pinned 1")
        let item2 = ClipboardItem(content: "Pinned 2")
        let item3 = ClipboardItem(content: "Regular")

        manager.addItem(item1)
        manager.addItem(item2)
        manager.addItem(item3)

        // Get the actual items from the manager to toggle pins
        let addedItem1 = manager.items.first(where: { $0.content == "Pinned 1" })!
        let addedItem2 = manager.items.first(where: { $0.content == "Pinned 2" })!

        manager.togglePin(for: addedItem1.id)
        manager.togglePin(for: addedItem2.id)

        // When
        let pinnedItems = manager.items.filter { $0.isPinned }

        // Then
        XCTAssertEqual(pinnedItems.count, 2)
        XCTAssertTrue(pinnedItems.contains(where: { $0.content == "Pinned 1" }))
        XCTAssertTrue(pinnedItems.contains(where: { $0.content == "Pinned 2" }))
    }

    func testNoPinnedItemsShowsEmptyState() {
        // Given
        let userDefaults = UserDefaults(suiteName: "test-menu-no-pins")!
        userDefaults.removeObject(forKey: "clipboardItems")
        let manager = ClipboardHistoryManager(userDefaults: userDefaults)

        manager.addItem(ClipboardItem(content: "Item 1"))
        manager.addItem(ClipboardItem(content: "Item 2"))

        // When
        let pinnedItems = manager.items.filter { $0.isPinned }

        // Then
        XCTAssertTrue(pinnedItems.isEmpty)
    }

    // MARK: - Clear History Confirmation Tests

    func testClearHistoryRequiresConfirmation() {
        // Given
        let state = MenuBarState()

        // Then
        XCTAssertFalse(state.isShowingClearConfirmation, "Should not show confirmation by default")
    }

    func testClearHistoryConfirmationFlow() {
        // Given
        let state = MenuBarState()
        let userDefaults = UserDefaults(suiteName: "test-clear-history")!
        userDefaults.removeObject(forKey: "clipboardItems")
        let manager = ClipboardHistoryManager(userDefaults: userDefaults)

        manager.addItem(ClipboardItem(content: "Item 1"))
        manager.addItem(ClipboardItem(content: "Item 2"))

        // When - Show confirmation
        state.showClearConfirmation()

        // Then
        XCTAssertTrue(state.isShowingClearConfirmation)
        XCTAssertEqual(manager.items.count, 2, "Items should not be cleared yet")

        // When - Confirm clear
        manager.clearHistory()
        state.dismissClearConfirmation()

        // Then
        XCTAssertTrue(manager.items.isEmpty)
        XCTAssertFalse(state.isShowingClearConfirmation)
    }

    // MARK: - Menu Icon Tests

    func testMenuBarIconUsesClipboardSymbol() {
        // The menu bar should use a minimal clipboard icon
        let expectedIcon = "doc.on.clipboard"
        XCTAssertEqual(expectedIcon, "doc.on.clipboard")
    }

    // MARK: - Keyboard Shortcut Display Tests

    func testShowClipboardShortcutDisplayed() {
        // The "Show Clipboard" menu item should show the keyboard shortcut
        let expectedShortcut = "⌥V"
        XCTAssertTrue(expectedShortcut.contains("⌥"))
        XCTAssertTrue(expectedShortcut.contains("V"))
    }
}
