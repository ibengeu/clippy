import XCTest
import SwiftUI
@testable import ClipboardApp

final class TypographyTests: XCTestCase {

    // MARK: - Font Modifier Tests

    func testSwiftClipTitleFontExists() {
        // Given
        let text = Text("Test")

        // When
        let styledText = text.swiftClipTitle()

        // Then
        XCTAssertNotNil(styledText)
    }

    func testSwiftClipHeadlineFontExists() {
        // Given
        let text = Text("Test")

        // When
        let styledText = text.swiftClipHeadline()

        // Then
        XCTAssertNotNil(styledText)
    }

    func testSwiftClipBodyFontExists() {
        // Given
        let text = Text("Test")

        // When
        let styledText = text.swiftClipBody()

        // Then
        XCTAssertNotNil(styledText)
    }

    func testSwiftClipCaptionFontExists() {
        // Given
        let text = Text("Test")

        // When
        let styledText = text.swiftClipCaption()

        // Then
        XCTAssertNotNil(styledText)
    }

    func testSwiftClipCaptionSmallFontExists() {
        // Given
        let text = Text("Test")

        // When
        let styledText = text.swiftClipCaptionSmall()

        // Then
        XCTAssertNotNil(styledText)
    }

    // MARK: - Font Weight Tests

    func testSwiftClipTitleBoldExists() {
        // Given
        let text = Text("Test")

        // When
        let styledText = text.swiftClipTitleBold()

        // Then
        XCTAssertNotNil(styledText)
    }

    func testSwiftClipBodyMediumExists() {
        // Given
        let text = Text("Test")

        // When
        let styledText = text.swiftClipBodyMedium()

        // Then
        XCTAssertNotNil(styledText)
    }

    // MARK: - Direct Font Access Tests

    func testSwiftClipFontSizeTitle() {
        // Given/When
        let font = Font.swiftClipTitle

        // Then
        XCTAssertNotNil(font)
    }

    func testSwiftClipFontSizeHeadline() {
        // Given/When
        let font = Font.swiftClipHeadline

        // Then
        XCTAssertNotNil(font)
    }

    func testSwiftClipFontSizeBody() {
        // Given/When
        let font = Font.swiftClipBody

        // Then
        XCTAssertNotNil(font)
    }

    func testSwiftClipFontSizeCaption() {
        // Given/When
        let font = Font.swiftClipCaption

        // Then
        XCTAssertNotNil(font)
    }
}
