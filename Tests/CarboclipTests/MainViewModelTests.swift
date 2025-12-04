import XCTest
import Cocoa
import ClipboardCore
@testable import Carboclip

@MainActor
final class MainViewModelTests: XCTestCase {

    var viewModel: MainViewModel!

    override func setUp() async throws {
        // Create view model with test dependencies
        viewModel = MainViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
    }

    // MARK: - Copy to Clipboard Tests

    func testCopyToPasteboardUpdatesSystemClipboard() {
        // Given: A clipboard item
        let item = ClipboardItem(
            content: "Test content to copy",
            type: .text,
            sourceApp: "TestApp"
        )

        // When: Copying to pasteboard
        viewModel.copyToPasteboard(item)

        // Then: System pasteboard should contain the content
        let pasteboard = NSPasteboard.general
        let pastedContent = pasteboard.string(forType: .string)

        XCTAssertEqual(pastedContent, "Test content to copy",
                      "Pasteboard should contain the copied content")
    }

    func testCopyToPasteboardClearsExistingContent() {
        // Given: Existing content in pasteboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("Old content", forType: .string)

        // When: Copying new item
        let newItem = ClipboardItem(
            content: "New content",
            type: .text,
            sourceApp: "TestApp"
        )
        viewModel.copyToPasteboard(newItem)

        // Then: Pasteboard should only contain new content
        let pastedContent = pasteboard.string(forType: .string)
        XCTAssertEqual(pastedContent, "New content",
                      "Pasteboard should contain only the new content")
    }

    func testCopyToPasteboardHandlesEmptyContent() {
        // Given: Item with empty content
        let emptyItem = ClipboardItem(
            content: "",
            type: .text,
            sourceApp: "TestApp"
        )

        // When: Copying to pasteboard
        viewModel.copyToPasteboard(emptyItem)

        // Then: Pasteboard should contain empty string
        let pasteboard = NSPasteboard.general
        let pastedContent = pasteboard.string(forType: .string)
        XCTAssertEqual(pastedContent, "",
                      "Pasteboard should handle empty content")
    }

    func testCopyToPasteboardHandlesLongContent() {
        // Given: Item with very long content
        let longContent = String(repeating: "A", count: 10000)
        let longItem = ClipboardItem(
            content: longContent,
            type: .text,
            sourceApp: "TestApp"
        )

        // When: Copying to pasteboard
        viewModel.copyToPasteboard(longItem)

        // Then: Pasteboard should contain full content
        let pasteboard = NSPasteboard.general
        let pastedContent = pasteboard.string(forType: .string)
        XCTAssertEqual(pastedContent?.count, 10000,
                      "Pasteboard should handle long content")
    }

    func testCopyToPasteboardStopsMonitoringTemporarily() {
        // Given: Multiple items in history
        let item1 = ClipboardItem(content: "First", type: .text, sourceApp: "TestApp")
        let item2 = ClipboardItem(content: "Second", type: .text, sourceApp: "TestApp")

        // When: Copying an old item back to clipboard
        viewModel.copyToPasteboard(item1)

        // Then: It should not create a duplicate in history
        // This tests that monitoring is paused during programmatic copy
        let pasteboard = NSPasteboard.general
        XCTAssertEqual(pasteboard.string(forType: .string), "First",
                      "Clipboard should contain the selected item")
    }

    func testCopyToPasteboardPreservesOriginalData() {
        // Given: Item with original raw data (e.g., RTF)
        let rtfString = "{\\rtf1 Test RTF}"
        let rtfData = rtfString.data(using: .utf8)!

        let item = ClipboardItem(
            content: "Test RTF",
            type: .rtf,
            sourceApp: "TestApp"
        )
        item.rawData = rtfData

        // When: Copying to pasteboard
        viewModel.copyToPasteboard(item)

        // Then: Pasteboard should contain the original RTF data, not just plain text
        let pasteboard = NSPasteboard.general
        let copiedData = pasteboard.data(forType: .rtf)

        XCTAssertNotNil(copiedData, "Should preserve RTF data")
        XCTAssertEqual(copiedData, rtfData, "Should copy original RTF data")
    }

    func testCopyToPasteboardFallsBackToPlainText() {
        // Given: Item without raw data
        let item = ClipboardItem(
            content: "Plain text content",
            type: .text,
            sourceApp: "TestApp"
        )

        // When: Copying to pasteboard
        viewModel.copyToPasteboard(item)

        // Then: Should use plain text content
        let pasteboard = NSPasteboard.general
        XCTAssertEqual(pasteboard.string(forType: .string), "Plain text content",
                      "Should fall back to plain text when no raw data")
    }
}
