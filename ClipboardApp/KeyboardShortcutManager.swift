import AppKit
import Carbon

class KeyboardShortcutManager {
    static let shared = KeyboardShortcutManager()

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var shortcuts: [(keyCode: UInt32, modifiers: NSEvent.ModifierFlags, callback: () -> Void)] = []

    func registerShortcut(keyCode: UInt32, modifiers: NSEvent.ModifierFlags, callback: @escaping () -> Void) {
        shortcuts.append((keyCode: keyCode, modifiers: modifiers, callback: callback))
        startMonitoring()
    }

    func unregisterShortcuts() {
        shortcuts.removeAll()
        stopMonitoring()
    }

    // Test helper to manually trigger callbacks
    func testTriggerCallback(keyCode: UInt32, modifiers: NSEvent.ModifierFlags) {
        for shortcut in shortcuts {
            if shortcut.keyCode == keyCode {
                let eventModifiers = modifiers.intersection([.option, .command, .control, .shift])
                let shortcutModifiers = shortcut.modifiers.intersection([.option, .command, .control, .shift])

                if eventModifiers == shortcutModifiers {
                    DispatchQueue.main.async {
                        shortcut.callback()
                    }
                }
            }
        }
    }

    private func startMonitoring() {
        guard eventTap == nil else { return }

        let eventMask = (1 << CGEventType.keyDown.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                let manager = Unmanaged<KeyboardShortcutManager>.fromOpaque(refcon!).takeUnretainedValue()
                return manager.handleCGEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            let logFile = "/tmp/clipboard_app.log"
            try? "❌ Failed to create event tap - accessibility permission may be missing\n".appending((try? String(contentsOfFile: logFile)) ?? "").write(toFile: logFile, atomically: true, encoding: .utf8)
            return
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        self.eventTap = eventTap
        self.runLoopSource = runLoopSource

        let logFile = "/tmp/clipboard_app.log"
        try? "✅ Event tap created successfully\n".appending((try? String(contentsOfFile: logFile)) ?? "").write(toFile: logFile, atomically: true, encoding: .utf8)
    }

    private func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            }
            self.runLoopSource = nil
            self.eventTap = nil
        }
    }

    private func handleCGEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return Unmanaged.passRetained(event)
        }

        let keyCode = UInt32(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        // Convert CGEventFlags to NSEvent.ModifierFlags
        var modifiers: NSEvent.ModifierFlags = []
        if flags.contains(.maskAlternate) {
            modifiers.insert(.option)
        }
        if flags.contains(.maskCommand) {
            modifiers.insert(.command)
        }
        if flags.contains(.maskControl) {
            modifiers.insert(.control)
        }
        if flags.contains(.maskShift) {
            modifiers.insert(.shift)
        }

        // Check if this matches any registered shortcut
        for shortcut in shortcuts {
            if keyCode == shortcut.keyCode {
                let eventModifiers = modifiers.intersection([.option, .command, .control, .shift])
                let shortcutModifiers = shortcut.modifiers.intersection([.option, .command, .control, .shift])

                if eventModifiers == shortcutModifiers {
                    print("🎯 Hotkey triggered: keyCode=\(keyCode), modifiers=\(modifiers)")
                    DispatchQueue.main.async {
                        shortcut.callback()
                    }
                    // Don't consume the event, pass it through
                    return Unmanaged.passRetained(event)
                }
            }
        }

        return Unmanaged.passRetained(event)
    }
}
