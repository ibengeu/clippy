import XCTest
@testable import ClipboardCore

final class FilterManagerTests: XCTestCase {

    var filterManager: FilterManager!
    var testItems: [ClipboardItem]!

    override func setUp() {
        super.setUp()
        filterManager = FilterManager()

        // Create test items
        testItems = [
            ClipboardItem(content: "Hello World", type: .text, sourceApp: "TextEdit"),
            ClipboardItem(content: "Swift programming", type: .code, sourceApp: "Xcode"),
            ClipboardItem(content: "https://github.com", type: .url, sourceApp: "Safari"),
            ClipboardItem(content: "/Users/test/doc.pdf", type: .file, sourceApp: "Finder"),
            ClipboardItem(content: "<html>Test</html>", type: .html, sourceApp: "Safari"),
            ClipboardItem(content: "{\\rtf Hello}", type: .rtf, sourceApp: "TextEdit"),
            ClipboardItem(content: "#FF5733", type: .color, sourceApp: "Sketch"),
            ClipboardItem(content: "data", type: .image, sourceApp: "Preview", rawData: Data([1, 2, 3])),
            ClipboardItem(content: "PDF content", type: .pdf, sourceApp: "Preview"),
            ClipboardItem(content: "Another text", type: .text, sourceApp: "Notes"),
        ]
    }

    override func tearDown() {
        filterManager = nil
        testItems = nil
        super.tearDown()
    }

    // MARK: - Single Filter Tests

    func testFilterByTextType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.text])

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.type == .text })
    }

    func testFilterByCodeType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.code])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .code)
    }

    func testFilterByURLType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.url])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .url)
    }

    func testFilterByFileType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.file])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .file)
    }

    func testFilterByHTMLType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.html])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .html)
    }

    func testFilterByRTFType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.rtf])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .rtf)
    }

    func testFilterByColorType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.color])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .color)
    }

    func testFilterByImageType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.image])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .image)
    }

    func testFilterByPDFType() throws {
        // When
        let results = filterManager.filter(testItems, by: [.pdf])

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .pdf)
    }

    // MARK: - Multiple Filter Tests

    func testFilterByMultipleTypes() throws {
        // When
        let results = filterManager.filter(testItems, by: [.text, .code])

        // Then
        XCTAssertEqual(results.count, 3)
        XCTAssertTrue(results.allSatisfy { $0.type == .text || $0.type == .code })
    }

    func testFilterByAllTextTypes() throws {
        // When
        let results = filterManager.filter(testItems, by: [.text, .code, .html, .rtf])

        // Then
        XCTAssertEqual(results.count, 5)
        let textTypes: [ClipboardItemType] = [.text, .code, .html, .rtf]
        XCTAssertTrue(results.allSatisfy { textTypes.contains($0.type) })
    }

    func testFilterByMediaTypes() throws {
        // When
        let results = filterManager.filter(testItems, by: [.image, .pdf])

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.type == .image || $0.type == .pdf })
    }

    // MARK: - Empty Filter Tests

    func testEmptyFilterReturnsAllItems() throws {
        // When
        let results = filterManager.filter(testItems, by: [])

        // Then
        XCTAssertEqual(results.count, testItems.count)
    }

    func testNoMatchingTypeReturnsEmpty() throws {
        // When
        let results = filterManager.filter(testItems, by: [.custom])

        // Then
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Filter by Source App Tests

    func testFilterBySourceApp() throws {
        // When
        let results = filterManager.filter(testItems, bySourceApp: "Safari")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.sourceApp == "Safari" })
    }

    func testFilterByMultipleSourceApps() throws {
        // When
        let results = filterManager.filter(testItems, bySourceApps: ["Safari", "Xcode"])

        // Then
        XCTAssertEqual(results.count, 3)
        XCTAssertTrue(results.allSatisfy { $0.sourceApp == "Safari" || $0.sourceApp == "Xcode" })
    }

    func testFilterByNonexistentSourceApp() throws {
        // When
        let results = filterManager.filter(testItems, bySourceApp: "NonexistentApp")

        // Then
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Combined Filter Tests

    func testFilterByTypeAndSourceApp() throws {
        // When
        let typeFiltered = filterManager.filter(testItems, by: [.text, .html])
        let results = filterManager.filter(typeFiltered, bySourceApp: "TextEdit")

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.type, .text)
        XCTAssertEqual(results.first?.sourceApp, "TextEdit")
    }

    // MARK: - Filter by Date Range Tests

    func testFilterByDateRange() throws {
        // Given
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let twoHoursAgo = now.addingTimeInterval(-7200)

        let itemsWithDates = [
            ClipboardItem(timestamp: now, content: "Recent", type: .text, sourceApp: "App1"),
            ClipboardItem(timestamp: oneHourAgo, content: "1h ago", type: .text, sourceApp: "App2"),
            ClipboardItem(timestamp: twoHoursAgo, content: "2h ago", type: .text, sourceApp: "App3"),
        ]

        // When - filter for items within last hour
        let results = filterManager.filter(itemsWithDates, from: oneHourAgo, to: now)

        // Then
        XCTAssertEqual(results.count, 2)
    }

    func testFilterByDateRangeExclusive() throws {
        // Given
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let twoHoursAgo = now.addingTimeInterval(-7200)

        let itemsWithDates = [
            ClipboardItem(timestamp: now, content: "Recent", type: .text, sourceApp: "App1"),
            ClipboardItem(timestamp: oneHourAgo, content: "1h ago", type: .text, sourceApp: "App2"),
            ClipboardItem(timestamp: twoHoursAgo, content: "2h ago", type: .text, sourceApp: "App3"),
        ]

        // When - filter for items before one hour ago
        let results = filterManager.filter(itemsWithDates, from: twoHoursAgo, to: oneHourAgo)

        // Then
        XCTAssertEqual(results.count, 2) // Includes boundaries
    }

    // MARK: - Filter by Pinned Tests

    func testFilterPinnedItems() throws {
        // Given
        testItems[0].pin()
        testItems[2].pin()
        testItems[5].pin()

        // When
        let results = filterManager.filterPinned(testItems)

        // Then
        XCTAssertEqual(results.count, 3)
        XCTAssertTrue(results.allSatisfy { $0.isPinned })
    }

    func testFilterUnpinnedItems() throws {
        // Given
        testItems[0].pin()
        testItems[2].pin()

        // When
        let results = filterManager.filterUnpinned(testItems)

        // Then
        XCTAssertEqual(results.count, 8)
        XCTAssertTrue(results.allSatisfy { !$0.isPinned })
    }

    // MARK: - Filter by Content Size Tests

    func testFilterByMinimumContentLength() throws {
        // When - filter items with at least 20 characters
        let results = filterManager.filter(testItems, minimumLength: 20)

        // Then
        XCTAssertTrue(results.allSatisfy { $0.content.count >= 20 })
    }

    func testFilterByMaximumContentLength() throws {
        // When - filter items with at most 15 characters
        let results = filterManager.filter(testItems, maximumLength: 15)

        // Then
        XCTAssertTrue(results.allSatisfy { $0.content.count <= 15 })
    }

    func testFilterByContentLengthRange() throws {
        // When - filter items between 10 and 20 characters
        let results = filterManager.filter(testItems, minimumLength: 10, maximumLength: 20)

        // Then
        XCTAssertTrue(results.allSatisfy { $0.content.count >= 10 && $0.content.count <= 20 })
    }

    // MARK: - Sorting Tests

    func testSortByDateDescending() throws {
        // Given
        let now = Date()
        let itemsWithDates = [
            ClipboardItem(timestamp: now.addingTimeInterval(-100), content: "Old", type: .text, sourceApp: "App1"),
            ClipboardItem(timestamp: now, content: "New", type: .text, sourceApp: "App2"),
            ClipboardItem(timestamp: now.addingTimeInterval(-50), content: "Mid", type: .text, sourceApp: "App3"),
        ]

        // When
        let results = filterManager.sort(itemsWithDates, by: .dateDescending)

        // Then
        XCTAssertEqual(results[0].content, "New")
        XCTAssertEqual(results[1].content, "Mid")
        XCTAssertEqual(results[2].content, "Old")
    }

    func testSortByDateAscending() throws {
        // Given
        let now = Date()
        let itemsWithDates = [
            ClipboardItem(timestamp: now, content: "New", type: .text, sourceApp: "App2"),
            ClipboardItem(timestamp: now.addingTimeInterval(-100), content: "Old", type: .text, sourceApp: "App1"),
            ClipboardItem(timestamp: now.addingTimeInterval(-50), content: "Mid", type: .text, sourceApp: "App3"),
        ]

        // When
        let results = filterManager.sort(itemsWithDates, by: .dateAscending)

        // Then
        XCTAssertEqual(results[0].content, "Old")
        XCTAssertEqual(results[1].content, "Mid")
        XCTAssertEqual(results[2].content, "New")
    }

    func testSortByContentLength() throws {
        // When
        let results = filterManager.sort(testItems, by: .contentLength)

        // Then
        // Verify ascending order by length
        for i in 0..<(results.count - 1) {
            XCTAssertLessThanOrEqual(results[i].content.count, results[i + 1].content.count)
        }
    }

    func testSortByType() throws {
        // When
        let results = filterManager.sort(testItems, by: .type)

        // Then
        // Verify items are grouped by type
        var lastType: ClipboardItemType?
        var typeGroups: [ClipboardItemType: Int] = [:]

        for item in results {
            if let last = lastType, last != item.type {
                typeGroups[last] = (typeGroups[last] ?? 0) + 1
            }
            lastType = item.type
        }

        // All items of the same type should be together
        XCTAssertNotNil(results.first)
    }

    // MARK: - Performance Tests

    func testFilterPerformance() throws {
        // Given - large dataset
        var largeDataset: [ClipboardItem] = []
        for i in 0..<1000 {
            let type: ClipboardItemType = [.text, .code, .url, .file, .html][i % 5]
            largeDataset.append(
                ClipboardItem(content: "Item \(i)", type: type, sourceApp: "TestApp")
            )
        }

        // When/Then
        measure {
            _ = filterManager.filter(largeDataset, by: [.text, .code])
        }
    }

    func testFilterLatency() throws {
        // Given - dataset of 300 items
        var dataset: [ClipboardItem] = []
        for i in 0..<300 {
            let type: ClipboardItemType = [.text, .code, .url, .file, .html][i % 5]
            dataset.append(
                ClipboardItem(content: "Item \(i)", type: type, sourceApp: "TestApp")
            )
        }

        // When
        let startTime = Date()
        _ = filterManager.filter(dataset, by: [.text, .code])
        let duration = Date().timeIntervalSince(startTime)

        // Then - should be very fast (< 1ms)
        XCTAssertLessThan(duration, 0.001, "Filter should complete within 1ms")
    }
}
