import Cocoa
import Carbon

class GlobalHotkeyManager {

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var callback: (() -> Void)?

    private let signature: OSType = {
        let string = "CBRD"
        var result: FourCharCode = 0
        for char in string.utf8 {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }()

    func register(keyCode: UInt32, modifiers: UInt32, callback: @escaping () -> Void) -> Bool {
        self.callback = callback

        // Unregister existing hotkey if any
        unregister()

        var hotKeyID = EventHotKeyID(signature: signature, id: 1)

        // Create event handler
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }

                let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()

                DispatchQueue.main.async {
                    manager.callback?()
                }

                return noErr
            },
            1,
            &eventSpec,
            selfPtr,
            &eventHandler
        )

        guard status == noErr else {
            print("❌ Failed to install event handler: \(status)")
            return false
        }

        // Register the hotkey
        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if registerStatus != noErr {
            print("❌ Failed to register hotkey: \(registerStatus)")
            // Clean up event handler
            if let handler = eventHandler {
                RemoveEventHandler(handler)
                eventHandler = nil
            }
            return false
        }

        print("✅ Global hotkey registered successfully")
        return true
    }

    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    deinit {
        unregister()
    }
}

// MARK: - Convenience Extension

extension GlobalHotkeyManager {

    /// Register Control + Command + V (default hotkey)
    func registerDefault(callback: @escaping () -> Void) -> Bool {
        let keyCode: UInt32 = 9 // V key
        let modifiers: UInt32 = UInt32(controlKey | cmdKey)
        return register(keyCode: keyCode, modifiers: modifiers, callback: callback)
    }

    /// Register with custom key combination
    func register(keyCode: UInt16, commandKey: Bool = false, controlKey: Bool = false,
                  optionKey: Bool = false, shiftKey: Bool = false, callback: @escaping () -> Void) -> Bool {
        var modifiers: UInt32 = 0

        if commandKey {
            modifiers |= UInt32(Carbon.cmdKey)
        }
        if controlKey {
            modifiers |= UInt32(Carbon.controlKey)
        }
        if optionKey {
            modifiers |= UInt32(Carbon.optionKey)
        }
        if shiftKey {
            modifiers |= UInt32(Carbon.shiftKey)
        }

        return register(keyCode: UInt32(keyCode), modifiers: modifiers, callback: callback)
    }
}
