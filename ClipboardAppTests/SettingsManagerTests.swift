import XCTest
@testable import ClipboardApp

final class SettingsManagerTests: XCTestCase {
    var settings: SettingsManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.settings")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.settings")
        settings = SettingsManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.settings")
        settings = nil
        super.tearDown()
    }

    // MARK: - General Settings Tests

    func testDefaultMaxHistorySize() {
        // Given/When
        let maxSize = settings.maxHistorySize

        // Then
        XCTAssertEqual(maxSize, 100)
    }

    func testSetMaxHistorySize() {
        // When
        settings.maxHistorySize = 200

        // Then
        XCTAssertEqual(settings.maxHistorySize, 200)
    }

    func testDefaultAutoHideTimeout() {
        // Given/When
        let timeout = settings.autoHideTimeout

        // Then
        XCTAssertEqual(timeout, 5.0)
    }

    func testSetAutoHideTimeout() {
        // When
        settings.autoHideTimeout = 10.0

        // Then
        XCTAssertEqual(settings.autoHideTimeout, 10.0)
    }

    // MARK: - Appearance Settings Tests

    func testDefaultWindowPosition() {
        // Given/When
        let position = settings.windowPosition

        // Then
        XCTAssertEqual(position, .bottomRight)
    }

    func testSetWindowPosition() {
        // When
        settings.windowPosition = .cursor

        // Then
        XCTAssertEqual(settings.windowPosition, .cursor)
    }

    // MARK: - Persistence Tests

    func testSettingsPersistAcrossInstances() {
        // Given
        settings.maxHistorySize = 250
        settings.autoHideTimeout = 15.0
        settings.windowPosition = .center

        // When - Create new instance with same UserDefaults
        let newSettings = SettingsManager(userDefaults: testUserDefaults)

        // Then
        XCTAssertEqual(newSettings.maxHistorySize, 250)
        XCTAssertEqual(newSettings.autoHideTimeout, 15.0)
        XCTAssertEqual(newSettings.windowPosition, .center)
    }

    // MARK: - Window Position Enum Tests

    func testWindowPositionEnumCases() {
        // Given/When/Then
        XCTAssertEqual(WindowPosition.cursor.rawValue, "cursor")
        XCTAssertEqual(WindowPosition.bottomRight.rawValue, "bottomRight")
        XCTAssertEqual(WindowPosition.center.rawValue, "center")
    }

    // MARK: - Reset to Defaults Tests

    func testResetToDefaults() {
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
}
