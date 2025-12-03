import AppKit
import SwiftUI

class FloatingWindowManager: ObservableObject {
    static let shared = FloatingWindowManager()

    @Published var isVisible = false
    private var floatingWindow: NSWindow?
    private weak var historyManager: ClipboardHistoryManager?
    private weak var monitor: ClipboardMonitor?
    private weak var settings: SettingsManager?

    func showFloatingWindow(historyManager: ClipboardHistoryManager, monitor: ClipboardMonitor, settings: SettingsManager) {
        print("🪟 showFloatingWindow called")
        self.historyManager = historyManager
        self.monitor = monitor
        self.settings = settings
        isVisible = true

        // If window already exists, bring it to front
        if let window = floatingWindow {
            print("  Window already exists, bringing to front")
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        print("  Creating new window on thread: \(Thread.isMainThread ? "main" : "background")")

        // Create floating window immediately on main thread
        if Thread.isMainThread {
            createFloatingWindow(historyManager: historyManager, monitor: monitor, settings: settings)
        } else {
            DispatchQueue.main.sync {
                self.createFloatingWindow(historyManager: historyManager, monitor: monitor, settings: settings)
            }
        }
    }

    func hideFloatingWindow() {
        isVisible = false
        floatingWindow?.close()
        floatingWindow = nil
    }

    private func createFloatingWindow(historyManager: ClipboardHistoryManager, monitor: ClipboardMonitor, settings: SettingsManager) {
        print("  Creating floating window...")

        // Create content view
        let binding = Binding<Bool>(
            get: { self.isVisible },
            set: { self.isVisible = $0 }
        )
        let contentView = FloatingWindowView(settings: settings, isVisible: binding)
            .environmentObject(historyManager)
            .environmentObject(monitor)

        // Create hosting controller
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 350, height: 280)

        // Create window
        let window = NSWindow(contentViewController: hostingController)
        window.setContentSize(NSSize(width: 350, height: 280))
        window.styleMask = [.titled, .closable, .resizable]
        window.title = "SwiftClip"
        window.isOpaque = true
        window.backgroundColor = NSColor.windowBackgroundColor
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false

        // Position window based on user preference
        let positioner = WindowPositioner(settings: settings)
        let cursorLocation = WindowPositioner.getCurrentCursorLocation()
        let windowSize = NSSize(width: 350, height: 280)

        if let screen = positioner.getScreenContaining(point: cursorLocation) ?? NSScreen.main {
            let position = positioner.calculateWindowPosition(
                cursorLocation: cursorLocation,
                windowSize: windowSize,
                screenBounds: screen.visibleFrame
            )
            window.setFrameOrigin(position)
            print("  Positioned at x:\(position.x), y:\(position.y) (mode: \(settings.windowPosition.rawValue))")
        }

        // Make window visible and activate app
        print("  Calling orderFrontRegardless and activate")
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        self.floatingWindow = window
        print("✅ Window created and shown!")
    }
}
