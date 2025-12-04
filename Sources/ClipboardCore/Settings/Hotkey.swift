import Foundation
import Carbon

/// Modifier keys for hotkeys
public struct HotkeyModifiers: OptionSet, Codable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let command = HotkeyModifiers(rawValue: 1 << 0)
    public static let shift = HotkeyModifiers(rawValue: 1 << 1)
    public static let option = HotkeyModifiers(rawValue: 1 << 2)
    public static let control = HotkeyModifiers(rawValue: 1 << 3)
}

/// Represents a keyboard hotkey
public struct Hotkey: Codable, Equatable {
    public let keyCode: UInt16
    public let modifiers: HotkeyModifiers

    public init(keyCode: UInt16, modifiers: HotkeyModifiers) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    /// Default hotkey: Control + Command + V
    public static var `default`: Hotkey {
        return Hotkey(keyCode: 9, modifiers: [.command, .control]) // V key
    }
}
