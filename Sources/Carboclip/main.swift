import Cocoa
import ClipboardCore

// Create and configure the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Prevent app from appearing in Dock (menu bar app only)
app.setActivationPolicy(.accessory)

// Run the application
app.run()
