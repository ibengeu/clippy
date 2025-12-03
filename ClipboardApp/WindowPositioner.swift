import AppKit
import Foundation

class WindowPositioner {
    private let settings: SettingsManager
    private let offset: CGFloat = 20 // Pixels away from cursor

    init(settings: SettingsManager) {
        self.settings = settings
    }

    /// Calculate window position based on user preference
    func calculateWindowPosition(
        cursorLocation: NSPoint,
        windowSize: NSSize,
        screenBounds: NSRect
    ) -> NSPoint {
        switch settings.windowPosition {
        case .cursor:
            return calculateCursorProximalPosition(
                cursorLocation: cursorLocation,
                windowSize: windowSize,
                screenBounds: screenBounds
            )
        case .bottomRight:
            return calculateBottomRightPosition(
                windowSize: windowSize,
                screenBounds: screenBounds
            )
        case .center:
            return calculateCenterPosition(
                windowSize: windowSize,
                screenBounds: screenBounds
            )
        }
    }

    /// Position window near cursor with intelligent fallback
    private func calculateCursorProximalPosition(
        cursorLocation: NSPoint,
        windowSize: NSSize,
        screenBounds: NSRect
    ) -> NSPoint {
        // Try bottom-right of cursor first (preferred)
        var x = cursorLocation.x + offset
        var y = cursorLocation.y - offset - windowSize.height

        // Check if window fits on right side
        if x + windowSize.width > screenBounds.maxX {
            // Fallback: position on left side
            x = cursorLocation.x - offset - windowSize.width
        }

        // Check if window fits on bottom side
        if y < screenBounds.minY {
            // Fallback: position on top side
            y = cursorLocation.y + offset
        }

        // Final boundary check - ensure window is fully visible
        x = max(screenBounds.minX, min(x, screenBounds.maxX - windowSize.width))
        y = max(screenBounds.minY, min(y, screenBounds.maxY - windowSize.height))

        return NSPoint(x: x, y: y)
    }

    /// Position window at bottom-right of screen
    private func calculateBottomRightPosition(
        windowSize: NSSize,
        screenBounds: NSRect
    ) -> NSPoint {
        let x = screenBounds.maxX - windowSize.width - 20
        let y = screenBounds.minY + 50
        return NSPoint(x: x, y: y)
    }

    /// Position window at center of screen
    private func calculateCenterPosition(
        windowSize: NSSize,
        screenBounds: NSRect
    ) -> NSPoint {
        let x = screenBounds.minX + (screenBounds.width - windowSize.width) / 2
        let y = screenBounds.minY + (screenBounds.height - windowSize.height) / 2
        return NSPoint(x: x, y: y)
    }

    /// Get the screen that contains the given point
    func getScreenContaining(point: NSPoint) -> NSScreen? {
        // NSScreen coordinates are flipped, so we need to convert
        for screen in NSScreen.screens {
            if screen.frame.contains(point) {
                return screen
            }
        }
        // Fallback to main screen
        return NSScreen.main
    }

    /// Get current mouse cursor location
    static func getCurrentCursorLocation() -> NSPoint {
        return NSEvent.mouseLocation
    }
}
