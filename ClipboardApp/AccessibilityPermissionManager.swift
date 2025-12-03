import AppKit

class AccessibilityPermissionManager {
    static let shared = AccessibilityPermissionManager()

    func hasAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        return isTrusted
    }

    func isPermissionGranted() -> Bool {
        return hasAccessibilityPermission()
    }

    func requestPermission() {
        // Only request once
        let cache = PermissionCache.shared
        if cache.wasPermissionRequested() {
            return
        }

        // Requesting with prompt enabled
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)

        // Mark as requested
        cache.markPermissionRequested()
    }

    func showPermissionAlert() {
        if !hasAccessibilityPermission() {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "ClipboardApp needs accessibility permission to monitor your keyboard for the Option+V shortcut.\n\nPlease:\n1. Click 'Open System Preferences'\n2. Go to Security & Privacy > Accessibility\n3. Add ClipboardApp to the list"
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Cancel")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                openAccessibilitySettings()
            }
        }
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
