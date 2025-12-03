import AppKit
import Foundation

/// Manages detection and handling of sensitive apps (password managers, banking apps, etc.)
class SensitiveAppManager: ObservableObject {
    private let userDefaults: UserDefaults

    // MARK: - Settings Keys

    private enum Keys {
        static let userExcludedApps = "sensitiveApps.userExcludedApps"
        static let autoDetectEnabled = "sensitiveApps.autoDetectEnabled"
    }

    // MARK: - Default Sensitive Apps

    /// List of bundle IDs for common password managers and sensitive apps
    static let defaultSensitiveApps: Set<String> = [
        // Password Managers
        "com.agilebits.onepassword7",
        "com.agilebits.onepassword-osx",
        "com.bitwarden.desktop",
        "com.lastpass.LastPass",
        "com.dashlane.Dashlane",
        "org.keepassx.keepassxc",
        "com.mcglon.enpass",

        // Banking & Finance
        "com.apple.KeychainAccess",

        // Developer Tools (when containing secrets)
        "com.apple.Terminal",
        "com.googlecode.iterm2",

        // Browsers in private mode (basic bundle IDs)
        // Note: Cannot detect private mode, but can exclude terminal/secure contexts
    ]

    // MARK: - Published Properties

    @Published var isAutoDetectEnabled: Bool {
        didSet {
            userDefaults.set(isAutoDetectEnabled, forKey: Keys.autoDetectEnabled)
        }
    }

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Load auto-detect setting (default: true)
        self.isAutoDetectEnabled = userDefaults.object(forKey: Keys.autoDetectEnabled) as? Bool ?? true
    }

    // MARK: - Detection Methods

    /// Check if a given bundle ID is considered sensitive
    func isSensitiveApp(bundleId: String?) -> Bool {
        guard let bundleId = bundleId else { return false }

        // Check default list
        if Self.defaultSensitiveApps.contains(bundleId) {
            return true
        }

        // Check user-added apps
        let userExcludedApps = getUserExcludedApps()
        return userExcludedApps.contains(bundleId)
    }

    /// Determine if clipboard content from this app should be tracked
    func shouldTrackClipboard(fromApp bundleId: String?) -> Bool {
        // If auto-detect is disabled, track everything
        guard isAutoDetectEnabled else { return true }

        // Don't track if app is sensitive
        return !isSensitiveApp(bundleId: bundleId)
    }

    // MARK: - User Excluded Apps Management

    /// Get list of user-added excluded apps
    func getUserExcludedApps() -> [String] {
        return userDefaults.stringArray(forKey: Keys.userExcludedApps) ?? []
    }

    /// Add an app to the excluded list
    func addExcludedApp(_ bundleId: String) {
        var excludedApps = getUserExcludedApps()
        guard !excludedApps.contains(bundleId) else { return }

        excludedApps.append(bundleId)
        userDefaults.set(excludedApps, forKey: Keys.userExcludedApps)
    }

    /// Remove an app from the excluded list
    func removeExcludedApp(_ bundleId: String) {
        var excludedApps = getUserExcludedApps()
        excludedApps.removeAll { $0 == bundleId }
        userDefaults.set(excludedApps, forKey: Keys.userExcludedApps)
    }

    // MARK: - Current App Detection

    /// Get the bundle ID of the currently active application
    static func getCurrentAppBundleId() -> String? {
        let workspace = NSWorkspace.shared
        let activeApp = workspace.frontmostApplication
        return activeApp?.bundleIdentifier
    }
}
