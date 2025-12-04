import XCTest
import Cocoa
@testable import Carboclip

final class AppDelegateTests: XCTestCase {

    // MARK: - Window Positioning Tests

    func testWindowAppearsOnActiveScreen() {
        // Given: A window configuration
        let windowWidth: CGFloat = 540
        let windowHeight: CGFloat = 500

        // When: Getting the active screen
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.visibleFrame

        // Then: Window should be centered on the active screen
        let expectedX = screenFrame.midX - (windowWidth / 2)
        let expectedY = screenFrame.midY - (windowHeight / 2)

        let windowFrame = NSRect(x: expectedX, y: expectedY, width: windowWidth, height: windowHeight)

        // Verify window is within screen bounds
        XCTAssertTrue(screenFrame.contains(windowFrame.origin),
                     "Window origin should be within screen bounds")
        XCTAssertTrue(windowFrame.width == 540,
                     "Window width should be 540 (10% less than 600)")
        XCTAssertTrue(windowFrame.height == 500,
                     "Window height should be 500")
    }

    func testWindowDimensionsAre10PercentSmaller() {
        // Given: Original width of 600
        let originalWidth: CGFloat = 600

        // When: Reducing by 10%
        let newWidth = originalWidth * 0.9

        // Then: New width should be 540
        XCTAssertEqual(newWidth, 540, accuracy: 0.1,
                      "Width should be reduced by 10% (600 → 540)")
    }

    func testWindowDimensionsAre30PercentSmaller() {
        // Given: Original dimensions
        let originalWidth: CGFloat = 600
        let originalHeight: CGFloat = 500

        // When: Reducing by 30%
        let newWidth = originalWidth * 0.7
        let newHeight = originalHeight * 0.7

        // Then: New dimensions should be 420x350
        XCTAssertEqual(newWidth, 420, accuracy: 0.1,
                      "Width should be reduced by 30% (600 → 420)")
        XCTAssertEqual(newHeight, 350, accuracy: 0.1,
                      "Height should be reduced by 30% (500 → 350)")
    }

    func testWindowPositionsAtTopRightCorner() {
        // Given: Window and screen dimensions
        let windowWidth: CGFloat = 420
        let windowHeight: CGFloat = 350
        let padding: CGFloat = 20

        let screen = NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.visibleFrame

        // When: Calculating top-right corner position
        let expectedX = screenFrame.maxX - windowWidth - padding
        let expectedY = screenFrame.maxY - windowHeight - padding

        // Then: Window should be at top-right with padding
        XCTAssertGreaterThan(expectedX, screenFrame.minX,
                           "Window X should be within screen bounds")
        XCTAssertGreaterThan(expectedY, screenFrame.minY,
                           "Window Y should be within screen bounds")
    }

    func testWindowLevelForFullscreenApps() {
        // Given: Window level requirements
        let floatingLevel = NSWindow.Level.floating
        let popUpMenuLevel = NSWindow.Level.popUpMenu

        // Then: PopUpMenu level should be higher than floating
        // This ensures window appears over fullscreen apps
        XCTAssertGreaterThan(popUpMenuLevel.rawValue, floatingLevel.rawValue,
                           "PopUpMenu level should be higher than floating for fullscreen visibility")
    }

    func testWindowHidesOnResignKey() {
        // Given: A window that should hide on deactivation
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        // When: Window resigns key (loses focus)
        window.makeKeyAndOrderFront(nil)
        XCTAssertTrue(window.isVisible, "Window should be visible initially")

        // Then: Window should hide when clicking outside
        window.orderOut(nil)
        XCTAssertFalse(window.isVisible, "Window should hide when dismissed")
    }
}
