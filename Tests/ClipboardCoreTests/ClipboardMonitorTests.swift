import XCTest
@testable import ClipboardCore
import AppKit

final class ClipboardMonitorTests: XCTestCase {

    var monitor: ClipboardMonitor!
    var mockPasteboard: NSPasteboard!

    override func setUp() {
        super.setUp()
        // Use a unique pasteboard for testing
        mockPasteboard = NSPasteboard(name: NSPasteboard.Name("TestPasteboard"))
        monitor = ClipboardMonitor(pasteboard: mockPasteboard)
    }

    override func tearDown() {
        monitor.stop()
        monitor = nil
        mockPasteboard.clearContents()
        mockPasteboard = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testClipboardMonitorInitialization() throws {
        XCTAssertNotNil(monitor)
        XCTAssertFalse(monitor.isMonitoring)
    }

    // MARK: - Start/Stop Tests

    func testStartMonitoring() throws {
        // When
        monitor.start()

        // Then
        XCTAssertTrue(monitor.isMonitoring)
    }

    func testStopMonitoring() throws {
        // Given
        monitor.start()

        // When
        monitor.stop()

        // Then
        XCTAssertFalse(monitor.isMonitoring)
    }

    func testMultipleStartCallsAreIdempotent() throws {
        // When
        monitor.start()
        monitor.start()
        monitor.start()

        // Then
        XCTAssertTrue(monitor.isMonitoring)
    }

    func testMultipleStopCallsAreIdempotent() throws {
        // Given
        monitor.start()

        // When
        monitor.stop()
        monitor.stop()
        monitor.stop()

        // Then
        XCTAssertFalse(monitor.isMonitoring)
    }

    // MARK: - Change Detection Tests

    func testDetectPlainTextChange() throws {
        // Given
        let expectation = XCTestExpectation(description: "Clipboard change detected")
        var detectedItem: ClipboardItem?

        monitor.onClipboardChange = { item in
            detectedItem = item
            expectation.fulfill()
        }

        monitor.start()

        // When
        mockPasteboard.clearContents()
        mockPasteboard.setString("Hello, World!", forType: .string)

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(detectedItem)
        XCTAssertEqual(detectedItem?.content, "Hello, World!")
        XCTAssertEqual(detectedItem?.type, .text)
    }

    func testDetectImageChange() throws {
        // Given
        let expectation = XCTestExpectation(description: "Image clipboard change detected")
        var detectedItem: ClipboardItem?

        monitor.onClipboardChange = { item in
            detectedItem = item
            expectation.fulfill()
        }

        monitor.start()

        // When
        mockPasteboard.clearContents()
        // Create a simple 1x1 pixel image
        let image = NSImage(size: NSSize(width: 1, height: 1))
        image.lockFocus()
        NSColor.red.setFill()
        NSRect(x: 0, y: 0, width: 1, height: 1).fill()
        image.unlockFocus()
        mockPasteboard.writeObjects([image])

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(detectedItem)
        XCTAssertEqual(detectedItem?.type, .image)
    }

    func testDetectURLChange() throws {
        // Given
        let expectation = XCTestExpectation(description: "URL clipboard change detected")
        var detectedItem: ClipboardItem?

        monitor.onClipboardChange = { item in
            detectedItem = item
            expectation.fulfill()
        }

        monitor.start()

        // When
        mockPasteboard.clearContents()
        let url = URL(string: "https://example.com")!
        mockPasteboard.setString(url.absoluteString, forType: .string)

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(detectedItem)
        // Note: URL detection will be based on content analysis
    }

    func testDetectHTMLChange() throws {
        // Given
        let expectation = XCTestExpectation(description: "HTML clipboard change detected")
        var detectedItem: ClipboardItem?

        monitor.onClipboardChange = { item in
            detectedItem = item
            expectation.fulfill()
        }

        monitor.start()

        // When
        mockPasteboard.clearContents()
        let htmlContent = "<html><body><h1>Hello</h1></body></html>"
        mockPasteboard.setString(htmlContent, forType: .html)

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(detectedItem)
        XCTAssertEqual(detectedItem?.type, .html)
    }

    func testDetectRTFChange() throws {
        // Given
        let expectation = XCTestExpectation(description: "RTF clipboard change detected")
        var detectedItem: ClipboardItem?

        monitor.onClipboardChange = { item in
            detectedItem = item
            expectation.fulfill()
        }

        monitor.start()

        // When
        mockPasteboard.clearContents()
        let rtfContent = "{\\rtf1\\ansi\\deff0 {\\b Hello World}}"
        mockPasteboard.setString(rtfContent, forType: .rtf)

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(detectedItem)
        XCTAssertEqual(detectedItem?.type, .rtf)
    }

    // MARK: - Source App Detection Tests

    func testSourceAppDetection() throws {
        // Given
        let expectation = XCTestExpectation(description: "Source app detected")
        var detectedItem: ClipboardItem?

        monitor.onClipboardChange = { item in
            detectedItem = item
            expectation.fulfill()
        }

        monitor.start()

        // When
        mockPasteboard.clearContents()
        mockPasteboard.setString("Test", forType: .string)

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(detectedItem)
        XCTAssertFalse(detectedItem?.sourceApp.isEmpty ?? true)
    }

    // MARK: - Exclusion Tests

    func testExcludeApplication() throws {
        // Given
        monitor.excludedApplications = ["TestApp"]

        // When
        let shouldExclude = monitor.isApplicationExcluded("TestApp")

        // Then
        XCTAssertTrue(shouldExclude)
    }

    func testDoNotExcludeUnlistedApplication() throws {
        // Given
        monitor.excludedApplications = ["TestApp"]

        // When
        let shouldExclude = monitor.isApplicationExcluded("OtherApp")

        // Then
        XCTAssertFalse(shouldExclude)
    }

    func testExcludedApplicationDoesNotTriggerCallback() throws {
        // Given
        let expectation = XCTestExpectation(description: "Callback should not be called")
        expectation.isInverted = true

        monitor.excludedApplications = ["Xcode"]
        monitor.onClipboardChange = { _ in
            expectation.fulfill()
        }

        monitor.start()

        // When
        // Simulate clipboard change from excluded app
        // Note: This test may need adjustment based on how we determine source app

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - No Duplicate Detection Tests

    func testNoDuplicateDetection() throws {
        // Given
        let expectation = XCTestExpectation(description: "Only one clipboard change detected")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        var callCount = 0
        monitor.onClipboardChange = { _ in
            callCount += 1
            expectation.fulfill()
        }

        monitor.start()

        // When - set same content twice
        mockPasteboard.clearContents()
        mockPasteboard.setString("Same content", forType: .string)

        // Small delay
        Thread.sleep(forTimeInterval: 0.5)

        // Set same content again
        mockPasteboard.clearContents()
        mockPasteboard.setString("Same content", forType: .string)

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(callCount, 1, "Callback should only be called once for identical content")
    }

    // MARK: - Polling Interval Tests

    func testPollingIntervalCanBeConfigured() throws {
        // Given
        let customInterval: TimeInterval = 0.5

        // When
        monitor.pollingInterval = customInterval

        // Then
        XCTAssertEqual(monitor.pollingInterval, customInterval)
    }

    func testDefaultPollingInterval() throws {
        // Then
        XCTAssertEqual(monitor.pollingInterval, 0.3, "Default polling interval should be 0.3 seconds")
    }
}
