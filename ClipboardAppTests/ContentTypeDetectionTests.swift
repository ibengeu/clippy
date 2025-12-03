import XCTest
import AppKit
@testable import ClipboardApp

final class ContentTypeDetectionTests: XCTestCase {

    // MARK: - Content Type Enum Tests

    func testContentTypeEnumCases() {
        // Given/When/Then
        XCTAssertEqual(ContentType.text.rawValue, "text")
        XCTAssertEqual(ContentType.image.rawValue, "image")
        XCTAssertEqual(ContentType.file.rawValue, "file")
        XCTAssertEqual(ContentType.richText.rawValue, "richText")
    }

    func testContentTypeDisplayNames() {
        // Given/When/Then
        XCTAssertEqual(ContentType.text.displayName, "Text")
        XCTAssertEqual(ContentType.image.displayName, "Image")
        XCTAssertEqual(ContentType.file.displayName, "File")
        XCTAssertEqual(ContentType.richText.displayName, "Rich Text")
    }

    func testContentTypeIcons() {
        // Given/When/Then
        XCTAssertEqual(ContentType.text.icon, "doc.text")
        XCTAssertEqual(ContentType.image.icon, "photo")
        XCTAssertEqual(ContentType.file.icon, "doc")
        XCTAssertEqual(ContentType.richText.icon, "doc.richtext")
    }

    // MARK: - Detection Logic Tests

    func testDetectContentTypeFromPasteboardTypesText() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.string]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .text)
    }

    func testDetectContentTypeFromPasteboardTypesImage() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.png]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .image)
    }

    func testDetectContentTypeFromPasteboardTypesTIFF() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.tiff]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .image)
    }

    func testDetectContentTypeFromPasteboardTypesFile() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.fileURL]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .file)
    }

    func testDetectContentTypeFromPasteboardTypesRichText() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.rtf]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .richText)
    }

    func testDetectContentTypeFromPasteboardTypesHTML() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.html]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .richText)
    }

    // MARK: - Priority Tests

    func testImageTypeTakesPriorityOverText() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.string, .png]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .image)
    }

    func testFileTypeTakesPriorityOverText() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.string, .fileURL]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .file)
    }

    func testRichTextFallsBackToTextIfStringPresent() {
        // Given
        let types: [NSPasteboard.PasteboardType] = [.string, .rtf]

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        // RTF should be detected as richText
        XCTAssertEqual(contentType, .richText)
    }

    // MARK: - Empty/Nil Tests

    func testDetectContentTypeFromEmptyTypesArray() {
        // Given
        let types: [NSPasteboard.PasteboardType] = []

        // When
        let contentType = ContentTypeDetector.detectType(from: types)

        // Then
        XCTAssertEqual(contentType, .text) // Default to text
    }

    // MARK: - ClipboardItem ContentType Tests

    func testClipboardItemDefaultsToTextType() {
        // Given/When
        let item = ClipboardItem(content: "Test")

        // Then
        XCTAssertEqual(item.contentType, .text)
    }

    func testClipboardItemCanBeCreatedWithImageType() {
        // Given/When
        var item = ClipboardItem(content: "image_data")
        item.contentType = .image

        // Then
        XCTAssertEqual(item.contentType, .image)
    }
}
