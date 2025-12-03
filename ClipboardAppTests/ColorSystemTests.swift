import XCTest
import SwiftUI
@testable import ClipboardApp

final class ColorSystemTests: XCTestCase {

    // MARK: - Hex Color Initialization Tests

    func testColorFromHexString() {
        // Given
        let hexString = "#2979FF"

        // When
        let color = Color(hex: hexString)

        // Then
        XCTAssertNotNil(color)
    }

    func testColorFromHexWithoutHash() {
        // Given
        let hexString = "2979FF"

        // When
        let color = Color(hex: hexString)

        // Then
        XCTAssertNotNil(color)
    }

    func testInvalidHexReturnsNil() {
        // Given
        let invalidHex = "GGGGGG"

        // When
        let color = Color(hex: invalidHex)

        // Then
        XCTAssertNil(color)
    }

    // MARK: - Brand Color Tests

    func testSwiftClipPrimaryColor() {
        // Given/When
        let primaryColor = Color.swiftClipPrimary

        // Then
        XCTAssertNotNil(primaryColor)
    }

    func testSwiftClipAccentColor() {
        // Given/When
        let accentColor = Color.swiftClipAccent

        // Then
        XCTAssertNotNil(accentColor)
    }

    func testSwiftClipBackgroundLightColor() {
        // Given/When
        let bgLight = Color.swiftClipBackgroundLight

        // Then
        XCTAssertNotNil(bgLight)
    }

    func testSwiftClipBackgroundDarkColor() {
        // Given/When
        let bgDark = Color.swiftClipBackgroundDark

        // Then
        XCTAssertNotNil(bgDark)
    }

    func testSwiftClipTextPrimaryColor() {
        // Given/When
        let textPrimary = Color.swiftClipTextPrimary

        // Then
        XCTAssertNotNil(textPrimary)
    }

    func testSwiftClipTextSecondaryColor() {
        // Given/When
        let textSecondary = Color.swiftClipTextSecondary

        // Then
        XCTAssertNotNil(textSecondary)
    }

    // MARK: - Adaptive Background Color Tests

    func testSwiftClipAdaptiveBackgroundExists() {
        // Given/When
        let adaptiveBg = Color.swiftClipBackground

        // Then
        XCTAssertNotNil(adaptiveBg)
    }

    func testSwiftClipAdaptiveTextExists() {
        // Given/When
        let adaptiveText = Color.swiftClipText

        // Then
        XCTAssertNotNil(adaptiveText)
    }
}
