import XCTest
@testable import ClipboardCore

final class ClipboardItemTests: XCTestCase {

    // MARK: - Initialization Tests

    func testClipboardItemInitializationWithPlainText() throws {
        // Given
        let content = "Hello, World!"
        let sourceApp = "Xcode"

        // When
        let item = ClipboardItem(
            content: content,
            type: .text,
            sourceApp: sourceApp
        )

        // Then
        XCTAssertEqual(item.content, content)
        XCTAssertEqual(item.type, .text)
        XCTAssertEqual(item.sourceApp, sourceApp)
        XCTAssertNotNil(item.id)
        XCTAssertNotNil(item.timestamp)
        XCTAssertFalse(item.isPinned)
    }

    func testClipboardItemInitializationWithImage() throws {
        // Given
        let imageData = Data([0xFF, 0xD8, 0xFF, 0xE0]) // JPEG header
        let sourceApp = "Preview"

        // When
        let item = ClipboardItem(
            content: imageData,
            type: .image,
            sourceApp: sourceApp
        )

        // Then
        XCTAssertEqual(item.type, .image)
        XCTAssertEqual(item.sourceApp, sourceApp)
        XCTAssertNotNil(item.rawData)
    }

    func testClipboardItemInitializationWithURL() throws {
        // Given
        let url = URL(string: "https://example.com")!
        let sourceApp = "Safari"

        // When
        let item = ClipboardItem(
            content: url.absoluteString,
            type: .url,
            sourceApp: sourceApp
        )

        // Then
        XCTAssertEqual(item.type, .url)
        XCTAssertEqual(item.content, url.absoluteString)
    }

    func testClipboardItemInitializationWithFileURL() throws {
        // Given
        let fileURL = URL(fileURLWithPath: "/Users/test/document.pdf")
        let sourceApp = "Finder"

        // When
        let item = ClipboardItem(
            content: fileURL.path,
            type: .file,
            sourceApp: sourceApp
        )

        // Then
        XCTAssertEqual(item.type, .file)
        XCTAssertEqual(item.content, fileURL.path)
    }

    func testClipboardItemInitializationWithHTML() throws {
        // Given
        let htmlContent = "<html><body><h1>Hello</h1></body></html>"
        let sourceApp = "Safari"

        // When
        let item = ClipboardItem(
            content: htmlContent,
            type: .html,
            sourceApp: sourceApp
        )

        // Then
        XCTAssertEqual(item.type, .html)
        XCTAssertEqual(item.content, htmlContent)
    }

    func testClipboardItemInitializationWithRTF() throws {
        // Given
        let rtfContent = "{\\rtf1\\ansi\\deff0 {\\b Hello World}}"
        let sourceApp = "TextEdit"

        // When
        let item = ClipboardItem(
            content: rtfContent,
            type: .rtf,
            sourceApp: sourceApp
        )

        // Then
        XCTAssertEqual(item.type, .rtf)
        XCTAssertEqual(item.content, rtfContent)
    }

    func testClipboardItemInitializationWithCode() throws {
        // Given
        let codeContent = "func hello() { print(\"Hello\") }"
        let sourceApp = "Xcode"

        // When
        let item = ClipboardItem(
            content: codeContent,
            type: .code,
            sourceApp: sourceApp,
            metadata: ["language": "swift"]
        )

        // Then
        XCTAssertEqual(item.type, .code)
        XCTAssertEqual(item.content, codeContent)
        XCTAssertEqual(item.metadata?["language"] as? String, "swift")
    }

    func testClipboardItemInitializationWithColor() throws {
        // Given
        let colorHex = "#FF5733"
        let sourceApp = "Sketch"

        // When
        let item = ClipboardItem(
            content: colorHex,
            type: .color,
            sourceApp: sourceApp
        )

        // Then
        XCTAssertEqual(item.type, .color)
        XCTAssertEqual(item.content, colorHex)
    }

    // MARK: - Pin/Unpin Tests

    func testPinClipboardItem() throws {
        // Given
        var item = ClipboardItem(
            content: "Test",
            type: .text,
            sourceApp: "Test"
        )

        // When
        item.pin()

        // Then
        XCTAssertTrue(item.isPinned)
    }

    func testUnpinClipboardItem() throws {
        // Given
        var item = ClipboardItem(
            content: "Test",
            type: .text,
            sourceApp: "Test"
        )
        item.pin()

        // When
        item.unpin()

        // Then
        XCTAssertFalse(item.isPinned)
    }

    func testTogglePinClipboardItem() throws {
        // Given
        var item = ClipboardItem(
            content: "Test",
            type: .text,
            sourceApp: "Test"
        )

        // When
        item.togglePin()

        // Then
        XCTAssertTrue(item.isPinned)

        // When
        item.togglePin()

        // Then
        XCTAssertFalse(item.isPinned)
    }

    // MARK: - Preview Text Tests

    func testPreviewTextForShortText() throws {
        // Given
        let content = "Short text"
        let item = ClipboardItem(
            content: content,
            type: .text,
            sourceApp: "Test"
        )

        // When
        let preview = item.previewText(maxLines: 3, maxLength: 100)

        // Then
        XCTAssertEqual(preview, content)
    }

    func testPreviewTextForLongText() throws {
        // Given
        let content = String(repeating: "A", count: 500)
        let item = ClipboardItem(
            content: content,
            type: .text,
            sourceApp: "Test"
        )

        // When
        let preview = item.previewText(maxLines: 3, maxLength: 100)

        // Then
        XCTAssertLessThanOrEqual(preview.count, 103) // 100 + "..."
        XCTAssertTrue(preview.hasSuffix("..."))
    }

    func testPreviewTextForMultilineText() throws {
        // Given
        let content = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
        let item = ClipboardItem(
            content: content,
            type: .text,
            sourceApp: "Test"
        )

        // When
        let preview = item.previewText(maxLines: 3, maxLength: 1000)

        // Then
        let lines = preview.components(separatedBy: "\n")
        XCTAssertLessThanOrEqual(lines.count, 3)
    }

    // MARK: - Character Count Tests

    func testCharacterCount() throws {
        // Given
        let content = "Hello, World!"
        let item = ClipboardItem(
            content: content,
            type: .text,
            sourceApp: "Test"
        )

        // When
        let count = item.characterCount

        // Then
        XCTAssertEqual(count, 13)
    }

    func testCharacterCountForEmptyContent() throws {
        // Given
        let item = ClipboardItem(
            content: "",
            type: .text,
            sourceApp: "Test"
        )

        // When
        let count = item.characterCount

        // Then
        XCTAssertEqual(count, 0)
    }

    // MARK: - Equality Tests

    func testEqualityBasedOnContent() throws {
        // Given
        let item1 = ClipboardItem(
            content: "Same content",
            type: .text,
            sourceApp: "App1"
        )
        let item2 = ClipboardItem(
            content: "Same content",
            type: .text,
            sourceApp: "App2"
        )

        // Then
        XCTAssertTrue(item1.hasSameContent(as: item2))
    }

    func testInequalityBasedOnContent() throws {
        // Given
        let item1 = ClipboardItem(
            content: "Content 1",
            type: .text,
            sourceApp: "App1"
        )
        let item2 = ClipboardItem(
            content: "Content 2",
            type: .text,
            sourceApp: "App1"
        )

        // Then
        XCTAssertFalse(item1.hasSameContent(as: item2))
    }

    func testInequalityBasedOnType() throws {
        // Given
        let item1 = ClipboardItem(
            content: "Same",
            type: .text,
            sourceApp: "App1"
        )
        let item2 = ClipboardItem(
            content: "Same",
            type: .html,
            sourceApp: "App1"
        )

        // Then
        XCTAssertFalse(item1.hasSameContent(as: item2))
    }
}
