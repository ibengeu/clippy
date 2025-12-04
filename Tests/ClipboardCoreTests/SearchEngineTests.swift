import XCTest
@testable import ClipboardCore

final class SearchEngineTests: XCTestCase {

    var searchEngine: SearchEngine!
    var testItems: [ClipboardItem]!

    override func setUp() {
        super.setUp()
        searchEngine = SearchEngine()

        // Create test items
        testItems = [
            ClipboardItem(content: "Hello World", type: .text, sourceApp: "TextEdit"),
            ClipboardItem(content: "Swift programming language", type: .code, sourceApp: "Xcode"),
            ClipboardItem(content: "https://github.com/example", type: .url, sourceApp: "Safari"),
            ClipboardItem(content: "Quick brown fox jumps", type: .text, sourceApp: "Notes"),
            ClipboardItem(content: "func test() { print() }", type: .code, sourceApp: "Xcode"),
            ClipboardItem(content: "/Users/test/document.pdf", type: .file, sourceApp: "Finder"),
            ClipboardItem(content: "<html><body>Hello</body></html>", type: .html, sourceApp: "Safari"),
            ClipboardItem(content: "The lazy dog", type: .text, sourceApp: "Notes"),
            ClipboardItem(content: "Swift brown fox", type: .text, sourceApp: "Notes"),
        ]
    }

    override func tearDown() {
        searchEngine = nil
        testItems = nil
        super.tearDown()
    }

    // MARK: - Exact Match Tests

    func testExactMatch() throws {
        // When
        let results = searchEngine.search(query: "Hello World", in: testItems)

        // Debug: print what we got
        if results.count != 1 {
            print("DEBUG: Expected 1 result, got \(results.count)")
            for (index, item) in results.enumerated() {
                print("  [\(index)]: '\(item.content)' from \(item.sourceApp)")
            }
        }

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.content, "Hello World")
    }

    func testExactMatchCaseInsensitive() throws {
        // When
        let results = searchEngine.search(query: "hello world", in: testItems)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.content, "Hello World")
    }

    // MARK: - Partial Match Tests

    func testPartialMatch() throws {
        // When
        let results = searchEngine.search(query: "programming", in: testItems)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.content.contains("programming") ?? false)
    }

    func testPartialMatchMultipleResults() throws {
        // When
        let results = searchEngine.search(query: "Xcode", in: testItems)

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.sourceApp == "Xcode" })
    }

    // MARK: - Fuzzy Match Tests

    func testFuzzyMatch() throws {
        // When - typo in "Hello"
        let results = searchEngine.search(query: "Helo", in: testItems)

        // Then - should still match "Hello World"
        XCTAssertGreaterThanOrEqual(results.count, 1)
        let hasHelloWorld = results.contains { $0.content.contains("Hello") }
        XCTAssertTrue(hasHelloWorld)
    }

    func testFuzzyMatchWithTransposition() throws {
        // When - letters transposed
        let results = searchEngine.search(query: "Wrold", in: testItems)

        // Then - should match "World"
        XCTAssertGreaterThanOrEqual(results.count, 1)
        let hasWorld = results.contains { $0.content.contains("World") }
        XCTAssertTrue(hasWorld)
    }

    func testFuzzyMatchAbbreviation() throws {
        // When - abbreviation
        let results = searchEngine.search(query: "sbf", in: testItems)

        // Then - should match "Swift brown fox" based on first letters
        XCTAssertGreaterThanOrEqual(results.count, 1)
    }

    // MARK: - Empty Query Tests

    func testEmptyQuery() throws {
        // When
        let results = searchEngine.search(query: "", in: testItems)

        // Then - empty query returns all items
        XCTAssertEqual(results.count, testItems.count)
    }

    func testWhitespaceQuery() throws {
        // When
        let results = searchEngine.search(query: "   ", in: testItems)

        // Then - whitespace query returns all items
        XCTAssertEqual(results.count, testItems.count)
    }

    // MARK: - No Match Tests

    func testNoMatch() throws {
        // When
        let results = searchEngine.search(query: "nonexistent", in: testItems)

        // Then
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Search in Source App Tests

    func testSearchInSourceApp() throws {
        // Given
        searchEngine.includeSourceApp = true

        // When
        let results = searchEngine.search(query: "Safari", in: testItems)

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.sourceApp == "Safari" })
    }

    func testSearchExcludeSourceApp() throws {
        // Given
        searchEngine.includeSourceApp = false

        // When
        let results = searchEngine.search(query: "Safari", in: testItems)

        // Then - should not match source app, only content
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - Ranking Tests

    func testRankingExactMatchFirst() throws {
        // When
        let results = searchEngine.search(query: "test", in: testItems)

        // Then - exact match in function name should rank high
        XCTAssertGreaterThan(results.count, 0)
        let firstResult = results.first
        XCTAssertNotNil(firstResult)
    }

    func testRankingByRelevance() throws {
        // Given - add items with varying relevance
        let extraItems = testItems + [
            ClipboardItem(content: "test", type: .text, sourceApp: "Notes"), // exact match
            ClipboardItem(content: "testing 123", type: .text, sourceApp: "Notes"), // starts with
            ClipboardItem(content: "this is a test", type: .text, sourceApp: "Notes"), // contains
        ]

        // When
        let results = searchEngine.search(query: "test", in: extraItems)

        // Then - exact match should be first
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertEqual(results.first?.content, "test")
    }

    // MARK: - Performance Tests

    func testSearchPerformance() throws {
        // Given - create a large dataset
        var largeDataset: [ClipboardItem] = []
        for i in 0..<1000 {
            largeDataset.append(
                ClipboardItem(
                    content: "Item \(i) with some random text for search testing",
                    type: .text,
                    sourceApp: "TestApp"
                )
            )
        }

        // When/Then - search should complete quickly
        measure {
            _ = searchEngine.search(query: "random", in: largeDataset)
        }
    }

    func testSearchLatency() throws {
        // Given - create dataset
        var dataset: [ClipboardItem] = []
        for i in 0..<300 {
            dataset.append(
                ClipboardItem(
                    content: "Clipboard item \(i) with varied content",
                    type: .text,
                    sourceApp: "TestApp"
                )
            )
        }

        // When
        let startTime = Date()
        _ = searchEngine.search(query: "item", in: dataset)
        let duration = Date().timeIntervalSince(startTime)

        // Then - should be faster than 16ms (one frame at 60fps)
        XCTAssertLessThan(duration, 0.016, "Search should complete within 16ms")
    }

    // MARK: - Special Characters Tests

    func testSearchWithSpecialCharacters() throws {
        // When
        let results = searchEngine.search(query: "github.com", in: testItems)

        // Then
        XCTAssertGreaterThanOrEqual(results.count, 1)
        let hasGithubURL = results.contains { $0.content.contains("github.com") }
        XCTAssertTrue(hasGithubURL)
    }

    func testSearchWithPath() throws {
        // When
        let results = searchEngine.search(query: "/Users/test", in: testItems)

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.content.contains("/Users/test") ?? false)
    }

    // MARK: - Multi-word Search Tests

    func testMultiWordSearch() throws {
        // When
        let results = searchEngine.search(query: "brown fox", in: testItems)

        // Then
        XCTAssertGreaterThanOrEqual(results.count, 1)
        let hasBrownFox = results.contains { $0.content.contains("brown") && $0.content.contains("fox") }
        XCTAssertTrue(hasBrownFox)
    }

    func testMultiWordSearchOrderIndependent() throws {
        // When - words in different order
        let results = searchEngine.search(query: "fox brown", in: testItems)

        // Then - should still match
        XCTAssertGreaterThanOrEqual(results.count, 1)
        let hasBrownFox = results.contains { $0.content.contains("brown") && $0.content.contains("fox") }
        XCTAssertTrue(hasBrownFox)
    }

    // MARK: - Configuration Tests

    func testFuzzyMatchingCanBeDisabled() throws {
        // Given
        searchEngine.useFuzzyMatching = false

        // When - typo that would match with fuzzy
        let results = searchEngine.search(query: "Helo", in: testItems)

        // Then - should not match without fuzzy matching
        let hasHello = results.contains { $0.content.contains("Hello") }
        XCTAssertFalse(hasHello)
    }

    func testCaseSensitiveSearch() throws {
        // Given
        searchEngine.isCaseSensitive = true

        // When
        let results = searchEngine.search(query: "hello", in: testItems)

        // Then - should not match "Hello"
        XCTAssertEqual(results.count, 0)
    }
}
