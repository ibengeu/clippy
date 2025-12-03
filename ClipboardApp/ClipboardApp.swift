import SwiftUI

@main
struct ClipboardApp: App {
    @StateObject private var historyManager = ClipboardHistoryManager()
    @StateObject private var monitor: ClipboardMonitor
    @StateObject private var settings = SettingsManager()

    init() {
        let logFile = "/tmp/clipboard_app.log"
        try? "🚀 ClipboardApp initializing...\n".write(toFile: logFile, atomically: true, encoding: .utf8)

        let manager = ClipboardHistoryManager()
        let clipboardMonitor = ClipboardMonitor(historyManager: manager)
        let settingsManager = SettingsManager()
        _historyManager = StateObject(wrappedValue: manager)
        _monitor = StateObject(wrappedValue: clipboardMonitor)
        _settings = StateObject(wrappedValue: settingsManager)

        try? "  Managers created\n".appending(try! String(contentsOfFile: logFile)).write(toFile: logFile, atomically: true, encoding: .utf8)

        // Register Option+V keyboard shortcut to show floating window
        // MUST happen on main thread and AFTER app initialization
        DispatchQueue.main.async {
            try? "  Requesting accessibility permission...\n".appending(try! String(contentsOfFile: logFile)).write(toFile: logFile, atomically: true, encoding: .utf8)
            AccessibilityPermissionManager.shared.requestPermission()

            // Check if permission is granted
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
            let isGranted = AXIsProcessTrustedWithOptions(options as CFDictionary)
            try? "  Accessibility permission granted: \(isGranted)\n".appending(try! String(contentsOfFile: logFile)).write(toFile: logFile, atomically: true, encoding: .utf8)

            // Register shortcut on main thread with permission check
            try? "  Registering Option+V shortcut (keyCode: 9)\n".appending(try! String(contentsOfFile: logFile)).write(toFile: logFile, atomically: true, encoding: .utf8)
            KeyboardShortcutManager.shared.registerShortcut(keyCode: 9, modifiers: .option) {
                try? "📋 Option+V callback triggered!\n".appending(try! String(contentsOfFile: logFile)).write(toFile: logFile, atomically: true, encoding: .utf8)
                FloatingWindowManager.shared.showFloatingWindow(
                    historyManager: manager,
                    monitor: clipboardMonitor,
                    settings: settingsManager
                )
            }
        }

        // Start monitoring clipboard immediately
        try? "  Starting clipboard monitoring...\n".appending(try! String(contentsOfFile: logFile)).write(toFile: logFile, atomically: true, encoding: .utf8)
        clipboardMonitor.startMonitoring()

        try? "✅ ClipboardApp initialization complete!\n".appending(try! String(contentsOfFile: logFile)).write(toFile: logFile, atomically: true, encoding: .utf8)
    }

    var body: some Scene {
        // Onboarding window - shows if permission not granted
        WindowGroup("Setup", id: "onboarding") {
            OnboardingView()
                .onAppear {
                    // Close window if permission is already granted
                    if AccessibilityPermissionManager.shared.isPermissionGranted() {
                        NSApplication.shared.windows.first(where: { $0.title == "Setup" })?.close()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // Settings window
        Window("SwiftClip Settings", id: "settings") {
            SettingsView(settings: settings)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // Hidden window for background operation
        Window("", id: "hidden") {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 0, height: 0)
    }
}
