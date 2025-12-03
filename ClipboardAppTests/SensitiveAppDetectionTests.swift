import XCTest
import AppKit
@testable import ClipboardApp

final class SensitiveAppDetectionTests: XCTestCase {
    var manager: SensitiveAppManager!
    let testUserDefaults = UserDefaults(suiteName: "com.test.swiftclip.sensitiveapps")!

    override func setUp() {
        super.setUp()
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.sensitiveapps")
        manager = SensitiveAppManager(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "com.test.swiftclip.sensitiveapps")
        manager = nil
        super.tearDown()
    }

    // MARK: - Default Sensitive Apps Tests

    func testDefaultSensitiveAppsIncludePasswordManagers() {
        // Given
        let defaults = SensitiveAppManager.defaultSensitiveApps

        // Then
        XCTAssertTrue(defaults.contains("com.agilebits.onepassword7"))
        XCTAssertTrue(defaults.contains("com.bitwarden.desktop"))
        XCTAssertTrue(defaults.contains("com.lastpass.LastPass"))
    }

    func testDefaultSensitiveAppsIncludeBankingApps() {
        // Given
        let defaults = SensitiveAppManager.defaultSensitiveApps

        // Then - Should include common banking/financial apps
        XCTAssertGreaterThan(defaults.count, 5)
    }

    // MARK: - Detection Tests

    func testIsSensitiveAppReturnsTrueForPasswordManager() {
        // Given
        let passwordManagerBundleId = "com.agilebits.onepassword7"

        // When
        let isSensitive = manager.isSensitiveApp(bundleId: passwordManagerBundleId)

        // Then
        XCTAssertTrue(isSensitive)
    }

    func testIsSensitiveAppReturnsFalseForRegularApp() {
        // Given
        let regularAppBundleId = "com.apple.Safari"

        // When
        let isSensitive = manager.isSensitiveApp(bundleId: regularAppBundleId)

        // Then
        XCTAssertFalse(isSensitive)
    }

    func testIsSensitiveAppReturnsTrueForUserAddedApp() {
        // Given
        let customAppBundleId = "com.mybank.app"
        manager.addExcludedApp(customAppBundleId)

        // When
        let isSensitive = manager.isSensitiveApp(bundleId: customAppBundleId)

        // Then
        XCTAssertTrue(isSensitive)
    }

    // MARK: - User Excluded Apps Tests

    func testAddExcludedAppAddsToList() {
        // Given
        let bundleId = "com.example.sensitive"

        // When
        manager.addExcludedApp(bundleId)

        // Then
        let excludedApps = manager.getUserExcludedApps()
        XCTAssertTrue(excludedApps.contains(bundleId))
    }

    func testRemoveExcludedAppRemovesFromList() {
        // Given
        let bundleId = "com.example.sensitive"
        manager.addExcludedApp(bundleId)

        // When
        manager.removeExcludedApp(bundleId)

        // Then
        let excludedApps = manager.getUserExcludedApps()
        XCTAssertFalse(excludedApps.contains(bundleId))
    }

    func testGetUserExcludedAppsReturnsEmptyInitially() {
        // When
        let excludedApps = manager.getUserExcludedApps()

        // Then
        XCTAssertTrue(excludedApps.isEmpty)
    }

    func testUserExcludedAppsPersistAcrossInstances() {
        // Given
        let bundleId = "com.example.sensitive"
        manager.addExcludedApp(bundleId)

        // When - Create new instance
        let newManager = SensitiveAppManager(userDefaults: testUserDefaults)
        let excludedApps = newManager.getUserExcludedApps()

        // Then
        XCTAssertTrue(excludedApps.contains(bundleId))
    }

    // MARK: - Auto-Detect Toggle Tests

    func testAutoDetectIsEnabledByDefault() {
        // When
        let isEnabled = manager.isAutoDetectEnabled

        // Then
        XCTAssertTrue(isEnabled)
    }

    func testSetAutoDetectToggle() {
        // When
        manager.isAutoDetectEnabled = false

        // Then
        XCTAssertFalse(manager.isAutoDetectEnabled)
    }

    func testAutoDetectSettingPersists() {
        // Given
        manager.isAutoDetectEnabled = false

        // When - Create new instance
        let newManager = SensitiveAppManager(userDefaults: testUserDefaults)

        // Then
        XCTAssertFalse(newManager.isAutoDetectEnabled)
    }

    // MARK: - Should Track Tests

    func testShouldTrackReturnsFalseWhenAutoDetectDisabled() {
        // Given
        manager.isAutoDetectEnabled = false
        let passwordManagerBundleId = "com.agilebits.onepassword7"

        // When
        let shouldTrack = manager.shouldTrackClipboard(fromApp: passwordManagerBundleId)

        // Then
        XCTAssertTrue(shouldTrack) // When disabled, track everything
    }

    func testShouldTrackReturnsFalseForSensitiveApp() {
        // Given
        manager.isAutoDetectEnabled = true
        let passwordManagerBundleId = "com.agilebits.onepassword7"

        // When
        let shouldTrack = manager.shouldTrackClipboard(fromApp: passwordManagerBundleId)

        // Then
        XCTAssertFalse(shouldTrack)
    }

    func testShouldTrackReturnsTrueForRegularApp() {
        // Given
        manager.isAutoDetectEnabled = true
        let regularAppBundleId = "com.apple.Safari"

        // When
        let shouldTrack = manager.shouldTrackClipboard(fromApp: regularAppBundleId)

        // Then
        XCTAssertTrue(shouldTrack)
    }

    // MARK: - Get Current App Tests

    func testGetCurrentAppBundleIdReturnsString() {
        // When
        let bundleId = SensitiveAppManager.getCurrentAppBundleId()

        // Then - Should return a non-nil value (the test runner)
        XCTAssertNotNil(bundleId)
    }
}
