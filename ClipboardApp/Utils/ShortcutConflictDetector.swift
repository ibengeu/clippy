import Foundation
import Carbon

// MARK: - Shortcut Modifiers

struct ShortcutModifiers: OptionSet, Equatable {
    let rawValue: Int

    static let command = ShortcutModifiers(rawValue: 1 << 0)
    static let shift = ShortcutModifiers(rawValue: 1 << 1)
    static let option = ShortcutModifiers(rawValue: 1 << 2)
    static let control = ShortcutModifiers(rawValue: 1 << 3)

    var displayString: String {
        var result = ""
        if contains(.control) { result += "⌃" }
        if contains(.option) { result += "⌥" }
        if contains(.shift) { result += "⇧" }
        if contains(.command) { result += "⌘" }
        return result
    }
}

// MARK: - System Shortcut

struct SystemShortcut {
    let name: String
    let keyCode: UInt16
    let modifiers: ShortcutModifiers

    var displayString: String {
        let modifierString = modifiers.displayString
        let keyString = keyCodeToString(keyCode)
        return "\(modifierString)\(keyString)"
    }

    private func keyCodeToString(_ keyCode: UInt16) -> String {
        switch Int(keyCode) {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_Space: return "Space"
        case kVK_Return: return "⏎"
        case kVK_Tab: return "⇥"
        case kVK_Delete: return "⌫"
        default: return "?"
        }
    }
}

// MARK: - Shortcut Conflict Detector

class ShortcutConflictDetector {

    // Common macOS system shortcuts that should not be overridden
    let commonSystemShortcuts: [SystemShortcut] = [
        // Essential system shortcuts
        SystemShortcut(name: "Spotlight", keyCode: UInt16(kVK_Space), modifiers: [.command]),
        SystemShortcut(name: "Copy", keyCode: UInt16(kVK_ANSI_C), modifiers: [.command]),
        SystemShortcut(name: "Paste", keyCode: UInt16(kVK_ANSI_V), modifiers: [.command]),
        SystemShortcut(name: "Cut", keyCode: UInt16(kVK_ANSI_X), modifiers: [.command]),
        SystemShortcut(name: "Undo", keyCode: UInt16(kVK_ANSI_Z), modifiers: [.command]),
        SystemShortcut(name: "Redo", keyCode: UInt16(kVK_ANSI_Z), modifiers: [.command, .shift]),
        SystemShortcut(name: "Save", keyCode: UInt16(kVK_ANSI_S), modifiers: [.command]),
        SystemShortcut(name: "Open", keyCode: UInt16(kVK_ANSI_O), modifiers: [.command]),
        SystemShortcut(name: "New", keyCode: UInt16(kVK_ANSI_N), modifiers: [.command]),
        SystemShortcut(name: "Close Window", keyCode: UInt16(kVK_ANSI_W), modifiers: [.command]),
        SystemShortcut(name: "Quit", keyCode: UInt16(kVK_ANSI_Q), modifiers: [.command]),
        SystemShortcut(name: "Find", keyCode: UInt16(kVK_ANSI_F), modifiers: [.command]),
        SystemShortcut(name: "Print", keyCode: UInt16(kVK_ANSI_P), modifiers: [.command]),
        SystemShortcut(name: "Select All", keyCode: UInt16(kVK_ANSI_A), modifiers: [.command]),
        SystemShortcut(name: "Bold", keyCode: UInt16(kVK_ANSI_B), modifiers: [.command]),
        SystemShortcut(name: "Italic", keyCode: UInt16(kVK_ANSI_I), modifiers: [.command]),
        SystemShortcut(name: "Preferences", keyCode: UInt16(kVK_ANSI_Comma), modifiers: [.command]),
        SystemShortcut(name: "Hide App", keyCode: UInt16(kVK_ANSI_H), modifiers: [.command]),
        SystemShortcut(name: "Minimize", keyCode: UInt16(kVK_ANSI_M), modifiers: [.command]),
        SystemShortcut(name: "Tab Switch", keyCode: UInt16(kVK_Tab), modifiers: [.command]),
        SystemShortcut(name: "Screenshot Area", keyCode: UInt16(kVK_ANSI_4), modifiers: [.command, .shift]),
        SystemShortcut(name: "Screenshot Window", keyCode: UInt16(kVK_ANSI_5), modifiers: [.command, .shift]),
        SystemShortcut(name: "Force Quit", keyCode: UInt16(kVK_ANSI_Q), modifiers: [.command, .option]),
    ]

    /// Detect if a shortcut conflicts with a common system shortcut
    func detectConflict(keyCode: UInt16, modifiers: ShortcutModifiers) -> SystemShortcut? {
        return commonSystemShortcuts.first { shortcut in
            shortcut.keyCode == keyCode && shortcut.modifiers == modifiers
        }
    }

    /// Check if a shortcut is a common conflict
    func isCommonConflict(keyCode: UInt16, modifiers: ShortcutModifiers) -> Bool {
        return detectConflict(keyCode: keyCode, modifiers: modifiers) != nil
    }

    /// Get a warning message for a conflicting shortcut
    func getConflictWarningMessage(keyCode: UInt16, modifiers: ShortcutModifiers) -> String? {
        guard let conflict = detectConflict(keyCode: keyCode, modifiers: modifiers) else {
            return nil
        }
        return "This shortcut conflicts with the system '\(conflict.name)' shortcut (\(conflict.displayString))"
    }

    /// Suggest alternative shortcuts that don't conflict
    func suggestAlternatives() -> [String] {
        let safeShortcuts: [(UInt16, ShortcutModifiers)] = [
            (UInt16(kVK_ANSI_V), [.option]),           // ⌥V (default)
            (UInt16(kVK_ANSI_C), [.option, .shift]),   // ⌥⇧C
            (UInt16(kVK_ANSI_V), [.option, .shift]),   // ⌥⇧V
            (UInt16(kVK_Space), [.option]),            // ⌥Space
            (UInt16(kVK_ANSI_X), [.option, .shift]),   // ⌥⇧X
        ]

        return safeShortcuts.compactMap { keyCode, modifiers in
            guard !isCommonConflict(keyCode: keyCode, modifiers: modifiers) else {
                return nil
            }
            let modString = modifiers.displayString
            let keyString = SystemShortcut(name: "", keyCode: keyCode, modifiers: modifiers).displayString
            return keyString
        }
    }
}
