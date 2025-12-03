import Foundation

// MARK: - Window Position Enum

enum WindowPosition: String, Codable, CaseIterable {
    case cursor = "cursor"
    case bottomRight = "bottomRight"
    case center = "center"

    var displayName: String {
        switch self {
        case .cursor: return "Near Cursor"
        case .bottomRight: return "Bottom Right"
        case .center: return "Center"
        }
    }
}

// MARK: - Settings Manager

class SettingsManager: ObservableObject {
    private let userDefaults: UserDefaults

    // MARK: - Settings Keys

    private enum Keys {
        static let maxHistorySize = "settings.maxHistorySize"
        static let autoHideTimeout = "settings.autoHideTimeout"
        static let windowPosition = "settings.windowPosition"
    }

    // MARK: - Default Values

    private enum Defaults {
        static let maxHistorySize = 100
        static let autoHideTimeout = 5.0
        static let windowPosition = WindowPosition.bottomRight
    }

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        // Load saved values or use defaults
        let savedMaxHistory = userDefaults.integer(forKey: Keys.maxHistorySize)
        self.maxHistorySize = savedMaxHistory == 0 ? Defaults.maxHistorySize : savedMaxHistory

        let savedTimeout = userDefaults.double(forKey: Keys.autoHideTimeout)
        self.autoHideTimeout = savedTimeout == 0 ? Defaults.autoHideTimeout : savedTimeout

        if let savedPositionRaw = userDefaults.string(forKey: Keys.windowPosition),
           let savedPosition = WindowPosition(rawValue: savedPositionRaw) {
            self.windowPosition = savedPosition
        } else {
            self.windowPosition = Defaults.windowPosition
        }
    }

    // MARK: - General Settings

    @Published var maxHistorySize: Int {
        didSet {
            userDefaults.set(maxHistorySize, forKey: Keys.maxHistorySize)
        }
    }

    @Published var autoHideTimeout: Double {
        didSet {
            userDefaults.set(autoHideTimeout, forKey: Keys.autoHideTimeout)
        }
    }

    // MARK: - Appearance Settings

    @Published var windowPosition: WindowPosition {
        didSet {
            userDefaults.set(windowPosition.rawValue, forKey: Keys.windowPosition)
        }
    }

    // MARK: - Reset to Defaults

    func resetToDefaults() {
        maxHistorySize = Defaults.maxHistorySize
        autoHideTimeout = Defaults.autoHideTimeout
        windowPosition = Defaults.windowPosition
    }
}
