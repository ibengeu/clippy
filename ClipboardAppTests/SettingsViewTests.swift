import XCTest
import SwiftUI
@testable import ClipboardApp

final class SettingsViewTests: XCTestCase {
    var settings: SettingsManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.settingsview")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.settingsview")
        settings = SettingsManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.settingsview")
        settings = nil
        super.tearDown()
    }

    // MARK: - General Tab Tests

    func testMaxHistorySizeBinding() {
        // Given
        let initialSize = settings.maxHistorySize

        // When
        settings.maxHistorySize = 200

        // Then
        XCTAssertNotEqual(settings.maxHistorySize, initialSize)
        XCTAssertEqual(settings.maxHistorySize, 200)
    }

    func testAutoHideTimeoutBinding() {
        // Given
        let initialTimeout = settings.autoHideTimeout

        // When
        settings.autoHideTimeout = 10.0

        // Then
        XCTAssertNotEqual(settings.autoHideTimeout, initialTimeout)
        XCTAssertEqual(settings.autoHideTimeout, 10.0)
    }

    func testMaxHistorySizeRange() {
        // Given/When
        settings.maxHistorySize = 50
        let minValid = settings.maxHistorySize >= 50

        settings.maxHistorySize = 500
        let maxValid = settings.maxHistorySize <= 500

        // Then
        XCTAssertTrue(minValid)
        XCTAssertTrue(maxValid)
    }

    func testAutoHideTimeoutRange() {
        // Given/When
        settings.autoHideTimeout = 3.0
        let minValid = settings.autoHideTimeout >= 3.0

        settings.autoHideTimeout = 30.0
        let maxValid = settings.autoHideTimeout <= 30.0

        // Then
        XCTAssertTrue(minValid)
        XCTAssertTrue(maxValid)
    }

    // MARK: - Appearance Tab Tests

    func testWindowPositionBinding() {
        // Given
        let initialPosition = settings.windowPosition

        // When
        settings.windowPosition = .cursor

        // Then
        XCTAssertNotEqual(settings.windowPosition, initialPosition)
        XCTAssertEqual(settings.windowPosition, .cursor)
    }

    func testWindowPositionAllCases() {
        // Given/When/Then
        let allCases = WindowPosition.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.cursor))
        XCTAssertTrue(allCases.contains(.bottomRight))
        XCTAssertTrue(allCases.contains(.center))
    }

    // MARK: - Reset to Defaults Tests

    func testResetToDefaultsRestoresAllSettings() {
        // Given
        settings.maxHistorySize = 300
        settings.autoHideTimeout = 20.0
        settings.windowPosition = .cursor

        // When
        settings.resetToDefaults()

        // Then
        XCTAssertEqual(settings.maxHistorySize, 100)
        XCTAssertEqual(settings.autoHideTimeout, 5.0)
        XCTAssertEqual(settings.windowPosition, .bottomRight)
    }

    // MARK: - Settings Persistence Tests

    func testSettingsChangesPersist() {
        // Given
        settings.maxHistorySize = 250
        settings.autoHideTimeout = 15.0
        settings.windowPosition = .center

        // When - Create new instance
        let newSettings = SettingsManager(userDefaults: testUserDefaults)

        // Then
        XCTAssertEqual(newSettings.maxHistorySize, 250)
        XCTAssertEqual(newSettings.autoHideTimeout, 15.0)
        XCTAssertEqual(newSettings.windowPosition, .center)
    }
}
