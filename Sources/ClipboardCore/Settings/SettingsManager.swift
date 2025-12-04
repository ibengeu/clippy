import Foundation

/// Manages application settings and preferences
public final class SettingsManager: ObservableObject {

    // MARK: - Notification

    public static let settingsDidChangeNotification = Notification.Name("SettingsDidChange")

    // MARK: - Keys

    private enum Keys {
        static let maxHistoryItems = "maxHistoryItems"
        static let pollingInterval = "pollingInterval"
        static let excludedApplications = "excludedApplications"
        static let launchAtLogin = "launchAtLogin"
        static let encryptDatabase = "encryptDatabase"
        static let keepRichFormats = "keepRichFormats"
        static let showMenuBarIcon = "showMenuBarIcon"
        static let theme = "theme"
        static let globalHotkeyKeyCode = "globalHotkeyKeyCode"
        static let globalHotkeyModifiers = "globalHotkeyModifiers"
    }

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Settings

    @Published public var maxHistoryItems: Int = 300 {
        didSet {
            let clamped = clamp(maxHistoryItems, min: 50, max: 1000)
            userDefaults.set(clamped, forKey: Keys.maxHistoryItems)
            notifyChange()
        }
    }

    @Published public var pollingInterval: TimeInterval = 0.3 {
        didSet {
            let clamped = clamp(pollingInterval, min: 0.1, max: 5.0)
            userDefaults.set(clamped, forKey: Keys.pollingInterval)
            notifyChange()
        }
    }

    public var excludedApplications: [String] {
        get {
            return userDefaults.stringArray(forKey: Keys.excludedApplications) ?? []
        }
        set {
            userDefaults.set(newValue, forKey: Keys.excludedApplications)
            notifyChange()
        }
    }

    @Published public var launchAtLogin: Bool = true {
        didSet {
            userDefaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            notifyChange()
        }
    }

    @Published public var encryptDatabase: Bool = false {
        didSet {
            userDefaults.set(encryptDatabase, forKey: Keys.encryptDatabase)
            notifyChange()
        }
    }

    @Published public var keepRichFormats: Bool = true {
        didSet {
            userDefaults.set(keepRichFormats, forKey: Keys.keepRichFormats)
            notifyChange()
        }
    }

    @Published public var showMenuBarIcon: Bool = true {
        didSet {
            userDefaults.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon)
            notifyChange()
        }
    }

    @Published public var theme: Theme = .system {
        didSet {
            userDefaults.set(theme.rawValue, forKey: Keys.theme)
            notifyChange()
        }
    }

    public var globalHotkey: Hotkey? {
        get {
            let keyCode = userDefaults.integer(forKey: Keys.globalHotkeyKeyCode)
            let modifiersRaw = userDefaults.integer(forKey: Keys.globalHotkeyModifiers)

            guard keyCode > 0 else {
                return nil
            }

            return Hotkey(
                keyCode: UInt16(keyCode),
                modifiers: HotkeyModifiers(rawValue: UInt(modifiersRaw))
            )
        }
        set {
            if let hotkey = newValue {
                userDefaults.set(Int(hotkey.keyCode), forKey: Keys.globalHotkeyKeyCode)
                userDefaults.set(Int(hotkey.modifiers.rawValue), forKey: Keys.globalHotkeyModifiers)
            } else {
                userDefaults.removeObject(forKey: Keys.globalHotkeyKeyCode)
                userDefaults.removeObject(forKey: Keys.globalHotkeyModifiers)
            }
            notifyChange()
        }
    }

    // MARK: - Initialization

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Load saved values
        let savedMaxItems = userDefaults.integer(forKey: Keys.maxHistoryItems)
        if savedMaxItems > 0 {
            self.maxHistoryItems = clamp(savedMaxItems, min: 50, max: 1000)
        }

        let savedInterval = userDefaults.double(forKey: Keys.pollingInterval)
        if savedInterval > 0 {
            self.pollingInterval = clamp(savedInterval, min: 0.1, max: 5.0)
        }

        if let themeRaw = userDefaults.string(forKey: Keys.theme),
           let savedTheme = Theme(rawValue: themeRaw) {
            self.theme = savedTheme
        }

        if userDefaults.object(forKey: Keys.launchAtLogin) != nil {
            self.launchAtLogin = userDefaults.bool(forKey: Keys.launchAtLogin)
        }

        if userDefaults.object(forKey: Keys.keepRichFormats) != nil {
            self.keepRichFormats = userDefaults.bool(forKey: Keys.keepRichFormats)
        }

        if userDefaults.object(forKey: Keys.showMenuBarIcon) != nil {
            self.showMenuBarIcon = userDefaults.bool(forKey: Keys.showMenuBarIcon)
        }

        self.encryptDatabase = userDefaults.bool(forKey: Keys.encryptDatabase)
    }

    // MARK: - Excluded Applications

    public func addExcludedApplication(_ appName: String) {
        var apps = excludedApplications
        if !apps.contains(appName) {
            apps.append(appName)
            excludedApplications = apps
        }
    }

    public func removeExcludedApplication(_ appName: String) {
        var apps = excludedApplications
        apps.removeAll { $0 == appName }
        excludedApplications = apps
    }

    public func isApplicationExcluded(_ appName: String) -> Bool {
        return excludedApplications.contains(appName)
    }

    public func clearExcludedApplications() {
        excludedApplications = []
    }

    // MARK: - Reset

    public func resetToDefaults() {
        userDefaults.removeObject(forKey: Keys.maxHistoryItems)
        userDefaults.removeObject(forKey: Keys.pollingInterval)
        userDefaults.removeObject(forKey: Keys.excludedApplications)
        userDefaults.removeObject(forKey: Keys.launchAtLogin)
        userDefaults.removeObject(forKey: Keys.encryptDatabase)
        userDefaults.removeObject(forKey: Keys.keepRichFormats)
        userDefaults.removeObject(forKey: Keys.showMenuBarIcon)
        userDefaults.removeObject(forKey: Keys.theme)
        userDefaults.removeObject(forKey: Keys.globalHotkeyKeyCode)
        userDefaults.removeObject(forKey: Keys.globalHotkeyModifiers)

        notifyChange()
    }

    // MARK: - Export/Import

    public func exportSettings() -> [String: Any] {
        return [
            "maxHistoryItems": maxHistoryItems,
            "pollingInterval": pollingInterval,
            "excludedApplications": excludedApplications,
            "launchAtLogin": launchAtLogin,
            "encryptDatabase": encryptDatabase,
            "keepRichFormats": keepRichFormats,
            "showMenuBarIcon": showMenuBarIcon,
            "theme": theme.rawValue
        ]
    }

    public func importSettings(_ settings: [String: Any]) {
        if let maxItems = settings["maxHistoryItems"] as? Int {
            maxHistoryItems = maxItems
        }

        if let interval = settings["pollingInterval"] as? Double {
            pollingInterval = interval
        }

        if let apps = settings["excludedApplications"] as? [String] {
            excludedApplications = apps
        }

        if let launch = settings["launchAtLogin"] as? Bool {
            launchAtLogin = launch
        }

        if let encrypt = settings["encryptDatabase"] as? Bool {
            encryptDatabase = encrypt
        }

        if let keepRich = settings["keepRichFormats"] as? Bool {
            keepRichFormats = keepRich
        }

        if let showIcon = settings["showMenuBarIcon"] as? Bool {
            showMenuBarIcon = showIcon
        }

        if let themeRaw = settings["theme"] as? String,
           let themeValue = Theme(rawValue: themeRaw) {
            theme = themeValue
        }

        notifyChange()
    }

    // MARK: - Private Helpers

    private func clamp<T: Comparable>(_ value: T, min minValue: T, max maxValue: T) -> T {
        return Swift.min(Swift.max(value, minValue), maxValue)
    }

    private func notifyChange() {
        NotificationCenter.default.post(name: Self.settingsDidChangeNotification, object: self)
    }
}
