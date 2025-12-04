import XCTest
@testable import ClipboardCore

final class SettingsManagerTests: XCTestCase {

    var settings: SettingsManager!
    var testDefaults: UserDefaults!
    var suiteName: String!

    override func setUp() {
        super.setUp()

        // Use a test suite name to avoid conflicts
        suiteName = "com.carboclip.tests.\(UUID().uuidString)"
        testDefaults = UserDefaults(suiteName: suiteName)!
        settings = SettingsManager(userDefaults: testDefaults)
    }

    override func tearDown() {
        // Clean up
        testDefaults.removePersistentDomain(forName: suiteName)
        settings = nil
        testDefaults = nil
        suiteName = nil

        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testDefaultSettings() throws {
        XCTAssertEqual(settings.maxHistoryItems, 300)
        XCTAssertEqual(settings.pollingInterval, 0.3)
        XCTAssertTrue(settings.launchAtLogin)
        XCTAssertFalse(settings.encryptDatabase)
        XCTAssertTrue(settings.keepRichFormats)
        XCTAssertEqual(settings.theme, .system)
    }

    // MARK: - Max History Items Tests

    func testSetMaxHistoryItems() throws {
        // When
        settings.maxHistoryItems = 500

        // Then
        XCTAssertEqual(settings.maxHistoryItems, 500)
    }

    func testMaxHistoryItemsPersistence() throws {
        // Given
        settings.maxHistoryItems = 150

        // When - create new settings manager with same defaults
        let newSettings = SettingsManager(userDefaults: testDefaults)

        // Then
        XCTAssertEqual(newSettings.maxHistoryItems, 150)
    }

    func testMaxHistoryItemsRange() throws {
        // When - set below minimum
        settings.maxHistoryItems = 10

        // Then - should clamp to minimum
        XCTAssertEqual(settings.maxHistoryItems, 50)

        // When - set above maximum
        settings.maxHistoryItems = 5000

        // Then - should clamp to maximum
        XCTAssertEqual(settings.maxHistoryItems, 1000)
    }

    // MARK: - Polling Interval Tests

    func testSetPollingInterval() throws {
        // When
        settings.pollingInterval = 0.5

        // Then
        XCTAssertEqual(settings.pollingInterval, 0.5)
    }

    func testPollingIntervalPersistence() throws {
        // Given
        settings.pollingInterval = 1.0

        // When
        let newSettings = SettingsManager(userDefaults: testDefaults)

        // Then
        XCTAssertEqual(newSettings.pollingInterval, 1.0)
    }

    func testPollingIntervalRange() throws {
        // When - set below minimum
        settings.pollingInterval = 0.05

        // Then - should clamp to minimum
        XCTAssertEqual(settings.pollingInterval, 0.1)

        // When - set above maximum
        settings.pollingInterval = 10.0

        // Then - should clamp to maximum
        XCTAssertEqual(settings.pollingInterval, 5.0)
    }

    // MARK: - Excluded Applications Tests

    func testAddExcludedApplication() throws {
        // When
        settings.addExcludedApplication("Xcode")

        // Then
        XCTAssertTrue(settings.excludedApplications.contains("Xcode"))
    }

    func testRemoveExcludedApplication() throws {
        // Given
        settings.addExcludedApplication("Xcode")

        // When
        settings.removeExcludedApplication("Xcode")

        // Then
        XCTAssertFalse(settings.excludedApplications.contains("Xcode"))
    }

    func testExcludedApplicationsPersistence() throws {
        // Given
        settings.addExcludedApplication("Xcode")
        settings.addExcludedApplication("Safari")

        // When
        let newSettings = SettingsManager(userDefaults: testDefaults)

        // Then
        XCTAssertTrue(newSettings.excludedApplications.contains("Xcode"))
        XCTAssertTrue(newSettings.excludedApplications.contains("Safari"))
    }

    func testIsApplicationExcluded() throws {
        // Given
        settings.addExcludedApplication("Xcode")

        // Then
        XCTAssertTrue(settings.isApplicationExcluded("Xcode"))
        XCTAssertFalse(settings.isApplicationExcluded("Safari"))
    }

    func testClearExcludedApplications() throws {
        // Given
        settings.addExcludedApplication("Xcode")
        settings.addExcludedApplication("Safari")

        // When
        settings.clearExcludedApplications()

        // Then
        XCTAssertTrue(settings.excludedApplications.isEmpty)
    }

    // MARK: - Boolean Settings Tests

    func testLaunchAtLogin() throws {
        // When
        settings.launchAtLogin = false

        // Then
        XCTAssertFalse(settings.launchAtLogin)

        // When
        settings.launchAtLogin = true

        // Then
        XCTAssertTrue(settings.launchAtLogin)
    }

    func testEncryptDatabase() throws {
        // When
        settings.encryptDatabase = true

        // Then
        XCTAssertTrue(settings.encryptDatabase)
    }

    func testKeepRichFormats() throws {
        // When
        settings.keepRichFormats = false

        // Then
        XCTAssertFalse(settings.keepRichFormats)
    }

    func testShowMenuBarIcon() throws {
        // When
        settings.showMenuBarIcon = false

        // Then
        XCTAssertFalse(settings.showMenuBarIcon)
    }

    // MARK: - Theme Tests

    func testSetTheme() throws {
        // When
        settings.theme = .dark

        // Then
        XCTAssertEqual(settings.theme, .dark)
    }

    func testThemePersistence() throws {
        // Given
        settings.theme = .light

        // When
        let newSettings = SettingsManager(userDefaults: testDefaults)

        // Then
        XCTAssertEqual(newSettings.theme, .light)
    }

    // MARK: - Hotkey Tests

    func testSetHotkey() throws {
        // Given
        let hotkey = Hotkey(keyCode: 9, modifiers: [.command, .control])

        // When
        settings.globalHotkey = hotkey

        // Then
        XCTAssertEqual(settings.globalHotkey?.keyCode, 9)
        XCTAssertEqual(settings.globalHotkey?.modifiers, [.command, .control])
    }

    func testHotkeyPersistence() throws {
        // Given
        let hotkey = Hotkey(keyCode: 9, modifiers: [.command, .control])
        settings.globalHotkey = hotkey

        // When
        let newSettings = SettingsManager(userDefaults: testDefaults)

        // Then
        XCTAssertEqual(newSettings.globalHotkey?.keyCode, 9)
        XCTAssertTrue(newSettings.globalHotkey?.modifiers.contains(.command) ?? false)
        XCTAssertTrue(newSettings.globalHotkey?.modifiers.contains(.control) ?? false)
    }

    func testClearHotkey() throws {
        // Given
        let hotkey = Hotkey(keyCode: 9, modifiers: [.command])
        settings.globalHotkey = hotkey

        // When
        settings.globalHotkey = nil

        // Then
        XCTAssertNil(settings.globalHotkey)
    }

    // MARK: - Reset Tests

    func testResetToDefaults() throws {
        // Given - modify settings
        settings.maxHistoryItems = 500
        settings.pollingInterval = 1.0
        settings.launchAtLogin = false
        settings.theme = .dark
        settings.addExcludedApplication("Xcode")

        // When
        settings.resetToDefaults()

        // Then
        XCTAssertEqual(settings.maxHistoryItems, 300)
        XCTAssertEqual(settings.pollingInterval, 0.3)
        XCTAssertTrue(settings.launchAtLogin)
        XCTAssertEqual(settings.theme, .system)
        XCTAssertTrue(settings.excludedApplications.isEmpty)
    }

    // MARK: - Notification Tests

    func testSettingsChangeNotification() throws {
        // Given
        let expectation = XCTestExpectation(description: "Settings changed notification")

        let observer = NotificationCenter.default.addObserver(
            forName: SettingsManager.settingsDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        defer {
            NotificationCenter.default.removeObserver(observer)
        }

        // When
        settings.maxHistoryItems = 500

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Export/Import Tests

    func testExportSettings() throws {
        // Given
        settings.maxHistoryItems = 500
        settings.theme = .dark
        settings.addExcludedApplication("Xcode")

        // When
        let exported = settings.exportSettings()

        // Then
        XCTAssertNotNil(exported["maxHistoryItems"])
        XCTAssertNotNil(exported["theme"])
        XCTAssertNotNil(exported["excludedApplications"])
    }

    func testImportSettings() throws {
        // Given
        let settingsDict: [String: Any] = [
            "maxHistoryItems": 500,
            "pollingInterval": 1.0,
            "theme": "dark",
            "excludedApplications": ["Xcode", "Safari"]
        ]

        // When
        settings.importSettings(settingsDict)

        // Then
        XCTAssertEqual(settings.maxHistoryItems, 500)
        XCTAssertEqual(settings.pollingInterval, 1.0)
        XCTAssertEqual(settings.theme, .dark)
        XCTAssertTrue(settings.excludedApplications.contains("Xcode"))
        XCTAssertTrue(settings.excludedApplications.contains("Safari"))
    }

    // MARK: - Validation Tests

    func testInvalidValueHandling() throws {
        // Given
        let invalidSettings: [String: Any] = [
            "maxHistoryItems": "invalid", // Should be Int
            "pollingInterval": "invalid", // Should be Double
            "theme": "invalid_theme" // Invalid theme
        ]

        // When
        settings.importSettings(invalidSettings)

        // Then - should keep defaults for invalid values
        XCTAssertEqual(settings.maxHistoryItems, 300)
        XCTAssertEqual(settings.pollingInterval, 0.3)
        XCTAssertEqual(settings.theme, .system)
    }
}
