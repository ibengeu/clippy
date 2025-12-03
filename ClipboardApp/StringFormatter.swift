import Foundation

/// Paste mode options for clipboard content
enum PasteMode: String, CaseIterable {
    case withFormatting = "withFormatting"
    case plainText = "plainText"

    var displayName: String {
        switch self {
        case .withFormatting:
            return "With Formatting"
        case .plainText:
            return "Plain Text"
        }
    }
}

/// Utility for formatting and preparing clipboard content
struct StringFormatter {

    /// Strip all formatting from text content
    static func stripFormatting(from content: String) -> String {
        var result = content

        // Remove HTML tags
        result = result.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // Remove markdown bold
        result = result.replacingOccurrences(of: "\\*\\*([^*]+)\\*\\*", with: "$1", options: .regularExpression)

        // Remove markdown italic
        result = result.replacingOccurrences(of: "_([^_]+)_", with: "$1", options: .regularExpression)

        // Remove markdown code blocks
        result = result.replacingOccurrences(of: "`([^`]+)`", with: "$1", options: .regularExpression)

        // Collapse multiple spaces into single space
        result = result.replacingOccurrences(of: " +", with: " ", options: .regularExpression)

        // Trim leading and trailing whitespace
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }

    /// Prepare content for pasting based on the selected mode
    static func prepareForPaste(_ content: String, mode: PasteMode) -> String {
        switch mode {
        case .withFormatting:
            return content
        case .plainText:
            return stripFormatting(from: content)
        }
    }
}
