import Foundation

/// Search engine for finding clipboard items using fuzzy matching
public final class SearchEngine {

    // MARK: - Properties

    public var useFuzzyMatching: Bool = true
    public var isCaseSensitive: Bool = false
    public var includeSourceApp: Bool = true
    public var fuzzyThreshold: Double = 0.6

    // MARK: - Initialization

    public init() {}

    // MARK: - Public Methods

    /// Searches clipboard items based on the query
    public func search(query: String, in items: [ClipboardItem]) -> [ClipboardItem] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Return all items for empty query
        guard !trimmedQuery.isEmpty else {
            return items
        }

        let searchQuery = isCaseSensitive ? trimmedQuery : trimmedQuery.lowercased()
        let queryWords = searchQuery.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

        // Score and filter items
        let minimumScore: Double = useFuzzyMatching ? 90.0 : 1.0
        let scoredItems: [(item: ClipboardItem, score: Double)] = items.compactMap { item in
            let score = calculateScore(for: item, query: searchQuery, words: queryWords)
            return score >= minimumScore ? (item, score) : nil
        }

        // Sort by score (descending) and return items
        return scoredItems
            .sorted { $0.score > $1.score }
            .map { $0.item }
    }

    // MARK: - Private Methods

    private func calculateScore(for item: ClipboardItem, query: String, words: [String]) -> Double {
        let content = isCaseSensitive ? item.content : item.content.lowercased()
        let sourceApp = isCaseSensitive ? item.sourceApp : item.sourceApp.lowercased()

        var totalScore: Double = 0
        var hasDirectMatch = false

        // Check exact match (highest score)
        if content == query {
            return 1000.0
        }

        // Check if content starts with query
        if content.hasPrefix(query) {
            totalScore += 500.0
            hasDirectMatch = true
        }

        // Check if content contains query
        if !hasDirectMatch && content.contains(query) {
            totalScore += 300.0
            hasDirectMatch = true
        }

        // If case sensitive and no match, return 0
        if isCaseSensitive && totalScore == 0 {
            return 0
        }

        // Multi-word search: all words must appear
        if words.count > 1 {
            let allWordsPresent = words.allSatisfy { word in
                content.contains(word) || (includeSourceApp && sourceApp.contains(word))
            }

            if allWordsPresent {
                // Only add multi-word bonus if we already have a direct match
                // or if this creates a match where there wasn't one
                if hasDirectMatch {
                    totalScore += 200.0
                } else {
                    totalScore += 200.0
                    hasDirectMatch = true
                }
            } else {
                // If not all words present and fuzzy is disabled, return 0
                if !useFuzzyMatching {
                    return 0
                }
            }
        }

        // Check source app if enabled
        if includeSourceApp {
            if sourceApp.contains(query) {
                totalScore += 100.0
            }
        }

        // Fuzzy matching (only if no direct match found)
        if useFuzzyMatching && !hasDirectMatch {
            let fuzzyScore = fuzzyMatch(query: query, text: content)
            if fuzzyScore >= fuzzyThreshold {
                totalScore += fuzzyScore * 150.0
            }

            // Also check fuzzy match for individual words
            for word in words {
                let wordFuzzyScore = fuzzyMatch(query: word, text: content)
                if wordFuzzyScore >= fuzzyThreshold {
                    totalScore += wordFuzzyScore * 50.0
                }
            }
        }

        // Abbreviation matching (e.g., "sbf" matches "Swift Brown Fox")
        if useFuzzyMatching {
            let abbrevScore = abbreviationMatch(query: query, text: content)
            if abbrevScore > 0 {
                totalScore += abbrevScore * 100.0
            }
        }

        return totalScore
    }

    /// Calculates fuzzy match score using Levenshtein distance
    private func fuzzyMatch(query: String, text: String) -> Double {
        // Find the best matching substring in text
        let queryLength = query.count
        guard queryLength > 0 else { return 0 }

        // Check for exact substring match first
        if text.contains(query) {
            return 1.0
        }

        // Find best matching substring of similar length
        var bestScore: Double = 0
        let textArray = Array(text)

        // Try all substrings of length query ± 2
        for len in max(1, queryLength - 2)...min(textArray.count, queryLength + 2) {
            for start in 0...(textArray.count - len) {
                let substring = String(textArray[start..<(start + len)])
                let distance = levenshteinDistance(query, substring)
                let maxLen = max(query.count, substring.count)
                let score = 1.0 - (Double(distance) / Double(maxLen))
                bestScore = max(bestScore, score)
            }
        }

        return bestScore
    }

    /// Calculates Levenshtein distance between two strings
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let s1Count = s1Array.count
        let s2Count = s2Array.count

        guard s1Count > 0 else { return s2Count }
        guard s2Count > 0 else { return s1Count }

        var matrix = Array(repeating: Array(repeating: 0, count: s2Count + 1), count: s1Count + 1)

        // Initialize first column and row
        for i in 0...s1Count {
            matrix[i][0] = i
        }
        for j in 0...s2Count {
            matrix[0][j] = j
        }

        // Fill in the rest of the matrix
        for i in 1...s1Count {
            for j in 1...s2Count {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,      // deletion
                    matrix[i][j - 1] + 1,      // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }

        return matrix[s1Count][s2Count]
    }

    /// Checks if query matches as an abbreviation (first letters)
    private func abbreviationMatch(query: String, text: String) -> Double {
        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard words.count >= query.count else { return 0 }

        let queryChars = Array(query.lowercased())
        var matchedCount = 0
        var wordIndex = 0

        // Try to match each query character to the first letter of consecutive words
        for char in queryChars {
            var found = false

            // Look ahead in remaining words
            while wordIndex < words.count {
                let word = words[wordIndex]
                let firstChar = word.lowercased().first

                if firstChar == char {
                    matchedCount += 1
                    wordIndex += 1
                    found = true
                    break
                } else {
                    wordIndex += 1
                }
            }

            if !found {
                break
            }
        }

        // Return score if all query chars matched
        let matchRatio = Double(matchedCount) / Double(queryChars.count)
        return matchRatio == 1.0 ? 1.0 : 0
    }
}
