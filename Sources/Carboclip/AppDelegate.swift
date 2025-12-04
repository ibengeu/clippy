import Cocoa
import SwiftUI
import ClipboardCore

class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow?
    private var settingsWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private var viewModel: MainViewModel!
    private var hotkeyManager: GlobalHotkeyManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            // Initialize view model
            viewModel = MainViewModel()

            // Set up menu bar
            setupMenuBar()

            // Start clipboard monitoring
            viewModel.startMonitoring()

            // Register global hotkey (Control + Command + V)
            registerGlobalHotkey()

            print("🚀 Carboclip started successfully")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Task { @MainActor in
            // Save items before quitting
            viewModel.saveItems()
            viewModel.stopMonitoring()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when window closes - we're a menu bar app
        return false
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Try text-based icon first for visibility
            button.title = "📋"
            button.action = #selector(toggleWindow)
            button.target = self
            print("✅ Menu bar button configured with title: 📋")
        } else {
            print("❌ Failed to get status item button")
        }

        print("✅ Status item created: \(statusItem != nil)")

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Show Clipboard History", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let monitoringItem = NSMenuItem(
            title: "Monitoring: Active",
            action: #selector(toggleMonitoring),
            keyEquivalent: ""
        )
        monitoringItem.tag = 100
        menu.addItem(monitoringItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Clear All History", action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Carboclip", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    // MARK: - Window Management

    @objc private func toggleWindow() {
        if window?.isVisible == true {
            hideWindow()
        } else {
            showWindow()
        }
    }

    @objc private func showWindow() {
        if window == nil {
            createWindow()
        }

        // Reposition window at corner of active screen every time it's shown
        positionWindowAtCorner()

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func hideWindow() {
        window?.orderOut(nil)
    }

    private func createWindow() {
        let contentView = ClipboardListView(viewModel: viewModel)
            .onDisappear {
                self.hideWindow()
            }

        // Window dimensions (30% smaller: 600 → 420, 500 → 350)
        let windowWidth: CGFloat = 420
        let windowHeight: CGFloat = 350

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        // Position window at top-right corner
        positionWindowAtCorner()

        window?.title = "Carboclip"
        window?.contentView = NSHostingView(rootView: contentView)
        window?.isReleasedWhenClosed = false

        // Use popUpMenu level to appear over fullscreen apps
        window?.level = .popUpMenu

        // Make window appear in all spaces/desktops
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Hide window when it loses focus (click outside to dismiss)
        window?.hidesOnDeactivate = true

        // Set up window appearance
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
    }

    private func positionWindowAtCorner() {
        guard let window = window else { return }

        // Get the screen containing the mouse cursor (active space/fullscreen app)
        let mouseLocation = NSEvent.mouseLocation
        let activeScreen = NSScreen.screens.first { screen in
            screen.frame.contains(mouseLocation)
        } ?? NSScreen.main ?? NSScreen.screens.first!

        let screenFrame = activeScreen.visibleFrame
        let windowFrame = window.frame
        let padding: CGFloat = 20

        // Position at top-right corner with padding
        let x = screenFrame.maxX - windowFrame.width - padding
        let y = screenFrame.maxY - windowFrame.height - padding

        window.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: - Actions

    @objc private func toggleMonitoring() {
        Task { @MainActor in
            if viewModel.isMonitoring {
                viewModel.stopMonitoring()
                updateMenuBarMonitoringStatus(active: false)
            } else {
                viewModel.startMonitoring()
                updateMenuBarMonitoringStatus(active: true)
            }
        }
    }

    private func updateMenuBarMonitoringStatus(active: Bool) {
        if let menu = statusItem?.menu,
           let item = menu.item(withTag: 100) {
            item.title = active ? "Monitoring: Active" : "Monitoring: Paused"
        }
    }

    @objc private func clearHistory() {
        let alert = NSAlert()
        alert.messageText = "Clear All History?"
        alert.informativeText = "This will permanently delete all clipboard items. Pinned items will also be removed."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            Task { @MainActor in
                viewModel.clearAll()
            }
        }
    }

    @objc private func showSettings() {
        if settingsWindow == nil {
            createSettingsWindow()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func createSettingsWindow() {
        Task { @MainActor in
            let settingsView = SettingsView(settings: viewModel.settings)

            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )

            settingsWindow?.center()
            settingsWindow?.title = "Carboclip Settings"
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
            settingsWindow?.isReleasedWhenClosed = false
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: - Global Hotkey

    private func registerGlobalHotkey() {
        hotkeyManager = GlobalHotkeyManager()

        let success = hotkeyManager.registerDefault { [weak self] in
            self?.showWindow()
        }

        if success {
            print("⌨️ Global hotkey registered: ⌃⌘V")
            print("💡 Press Control+Command+V anywhere to show clipboard history")
        } else {
            print("⚠️ Failed to register global hotkey. Using menu bar icon instead.")
        }
    }
}
