import XCTest
import AppKit
@testable import ClipboardApp

final class CursorProximalPositioningTests: XCTestCase {
    var positioner: WindowPositioner!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.positioning")!
    var settings: SettingsManager!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.positioning")
        settings = SettingsManager(userDefaults: testUserDefaults)
        positioner = WindowPositioner(settings: settings)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.positioning")
        settings = nil
        positioner = nil
        super.tearDown()
    }

    // MARK: - Cursor Position Tests

    func testCalculatePositionNearCursor() {
        // Given
        let cursorLocation = NSPoint(x: 500, y: 500)
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        settings.windowPosition = .cursor

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Should be offset from cursor (bottom-right preferred)
        XCTAssertGreaterThan(position.x, cursorLocation.x)
        XCTAssertLessThan(position.y, cursorLocation.y)
    }

    func testCalculatePositionBottomRight() {
        // Given
        let cursorLocation = NSPoint(x: 500, y: 500)
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        settings.windowPosition = .bottomRight

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Should be at bottom-right of screen
        XCTAssertGreaterThan(position.x, screenBounds.maxX - windowSize.width - 50)
        XCTAssertLessThan(position.y, 100)
    }

    func testCalculatePositionCenter() {
        // Given
        let cursorLocation = NSPoint(x: 500, y: 500)
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        settings.windowPosition = .center

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Should be near center of screen
        let expectedX = (screenBounds.width - windowSize.width) / 2
        let expectedY = (screenBounds.height - windowSize.height) / 2
        XCTAssertEqual(position.x, expectedX, accuracy: 10)
        XCTAssertEqual(position.y, expectedY, accuracy: 10)
    }

    // MARK: - Boundary Detection Tests

    func testPositionStaysWithinScreenBounds() {
        // Given
        let cursorLocation = NSPoint(x: 1900, y: 50) // Near edge
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        settings.windowPosition = .cursor

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Window should fit within screen
        XCTAssertGreaterThanOrEqual(position.x, screenBounds.minX)
        XCTAssertGreaterThanOrEqual(position.y, screenBounds.minY)
        XCTAssertLessThanOrEqual(position.x + windowSize.width, screenBounds.maxX)
        XCTAssertLessThanOrEqual(position.y + windowSize.height, screenBounds.maxY)
    }

    func testCursorNearRightEdgeFallsBackToLeft() {
        // Given
        let cursorLocation = NSPoint(x: 1850, y: 500) // Near right edge
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        settings.windowPosition = .cursor

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Should position to left of cursor instead
        XCTAssertLessThan(position.x, cursorLocation.x)
    }

    func testCursorNearTopEdgeFallsBackToBottom() {
        // Given
        let cursorLocation = NSPoint(x: 500, y: 1000) // Near top
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        settings.windowPosition = .cursor

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Should position below cursor instead
        XCTAssertLessThan(position.y, cursorLocation.y)
    }

    // MARK: - Offset Tests

    func testCursorOffsetDistance() {
        // Given
        let cursorLocation = NSPoint(x: 500, y: 500)
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)
        settings.windowPosition = .cursor

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Should be at least 20px away from cursor
        let distance = sqrt(pow(position.x - cursorLocation.x, 2) + pow(position.y - cursorLocation.y, 2))
        XCTAssertGreaterThanOrEqual(distance, 20)
    }

    // MARK: - Multi-Monitor Tests

    func testSecondaryScreenPositioning() {
        // Given - Secondary screen to the right
        let cursorLocation = NSPoint(x: 2500, y: 500) // On second monitor
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 1920, y: 0, width: 1920, height: 1080) // Second screen
        settings.windowPosition = .cursor

        // When
        let position = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Should be within second screen bounds
        XCTAssertGreaterThanOrEqual(position.x, screenBounds.minX)
        XCTAssertLessThanOrEqual(position.x + windowSize.width, screenBounds.maxX)
    }

    func testGetScreenForCursorLocation() {
        // Given
        let cursorLocation = NSPoint(x: 500, y: 500)

        // When
        let screen = positioner.getScreenContaining(point: cursorLocation)

        // Then - Should return a screen
        XCTAssertNotNil(screen)
    }

    // MARK: - Settings Integration Tests

    func testSettingsChangeUpdatesPositioning() {
        // Given
        let cursorLocation = NSPoint(x: 500, y: 500)
        let windowSize = NSSize(width: 350, height: 280)
        let screenBounds = NSRect(x: 0, y: 0, width: 1920, height: 1080)

        // When - Change from cursor to center
        settings.windowPosition = .cursor
        let cursorPosition = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        settings.windowPosition = .center
        let centerPosition = positioner.calculateWindowPosition(
            cursorLocation: cursorLocation,
            windowSize: windowSize,
            screenBounds: screenBounds
        )

        // Then - Positions should be different
        XCTAssertNotEqual(cursorPosition.x, centerPosition.x)
        XCTAssertNotEqual(cursorPosition.y, centerPosition.y)
    }
}
