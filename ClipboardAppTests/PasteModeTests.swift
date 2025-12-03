import XCTest
@testable import ClipboardApp

final class PasteModeTests: XCTestCase {

    // MARK: - Plain Text Conversion Tests

    func testStripFormattingRemovesHTMLTags() {
        // Given
        let htmlContent = "<b>Bold</b> and <i>italic</i> text"

        // When
        let plainText = StringFormatter.stripFormatting(from: htmlContent)

        // Then
        XCTAssertEqual(plainText, "Bold and italic text")
    }

    func testStripFormattingRemovesRichTextFormatting() {
        // Given
        let richText = "Text with **bold** and _italic_"

        // When
        let plainText = StringFormatter.stripFormatting(from: richText)

        // Then
        XCTAssertEqual(plainText, "Text with bold and italic")
    }

    func testStripFormattingPreservesPlainText() {
        // Given
        let plainContent = "Just plain text"

        // When
        let result = StringFormatter.stripFormatting(from: plainContent)

        // Then
        XCTAssertEqual(result, plainContent)
    }

    func testStripFormattingRemovesMultipleSpaces() {
        // Given
        let content = "Text  with   multiple    spaces"

        // When
        let plainText = StringFormatter.stripFormatting(from: content)

        // Then
        XCTAssertEqual(plainText, "Text with multiple spaces")
    }

    func testStripFormattingTrimsWhitespace() {
        // Given
        let content = "  Text with leading and trailing spaces  "

        // When
        let plainText = StringFormatter.stripFormatting(from: content)

        // Then
        XCTAssertEqual(plainText, "Text with leading and trailing spaces")
    }

    // MARK: - Paste Mode Enum Tests

    func testPasteModeEnumCases() {
        // Given/When/Then
        XCTAssertEqual(PasteMode.withFormatting.rawValue, "withFormatting")
        XCTAssertEqual(PasteMode.plainText.rawValue, "plainText")
    }

    func testPasteModeDisplayNames() {
        // Given/When/Then
        XCTAssertEqual(PasteMode.withFormatting.displayName, "With Formatting")
        XCTAssertEqual(PasteMode.plainText.displayName, "Plain Text")
    }

    // MARK: - Paste Content Preparation Tests

    func testPrepareContentWithFormattingKeepsOriginal() {
        // Given
        let content = "<b>Rich</b> text content"

        // When
        let prepared = StringFormatter.prepareForPaste(content, mode: .withFormatting)

        // Then
        XCTAssertEqual(prepared, content)
    }

    func testPrepareContentPlainTextStripsFormatting() {
        // Given
        let content = "<b>Rich</b> text content"

        // When
        let prepared = StringFormatter.prepareForPaste(content, mode: .plainText)

        // Then
        XCTAssertEqual(prepared, "Rich text content")
    }

    // MARK: - Empty Content Tests

    func testStripFormattingHandlesEmptyString() {
        // Given
        let content = ""

        // When
        let result = StringFormatter.stripFormatting(from: content)

        // Then
        XCTAssertEqual(result, "")
    }

    func testPrepareForPasteHandlesEmptyString() {
        // Given
        let content = ""

        // When
        let withFormatting = StringFormatter.prepareForPaste(content, mode: .withFormatting)
        let plainText = StringFormatter.prepareForPaste(content, mode: .plainText)

        // Then
        XCTAssertEqual(withFormatting, "")
        XCTAssertEqual(plainText, "")
    }
}
