import Foundation

/// Represents a single clipboard history item
public final class ClipboardItem: Codable {

    // MARK: - Properties

    public var id: UUID
    public var timestamp: Date
    public var content: String
    public var type: ClipboardItemType
    public var sourceApp: String
    public var isPinned: Bool
    public var rawData: Data?
    public var metadata: [String: String]?

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        content: String,
        type: ClipboardItemType,
        sourceApp: String,
        isPinned: Bool = false,
        rawData: Data? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.content = content
        self.type = type
        self.sourceApp = sourceApp
        self.isPinned = isPinned
        self.rawData = rawData
        self.metadata = metadata
    }

    public convenience init(
        content: Data,
        type: ClipboardItemType,
        sourceApp: String,
        isPinned: Bool = false,
        metadata: [String: String]? = nil
    ) {
        self.init(
            content: "",
            type: type,
            sourceApp: sourceApp,
            isPinned: isPinned,
            rawData: content,
            metadata: metadata
        )
    }

    // MARK: - Pin Management

    public func pin() {
        isPinned = true
    }

    public func unpin() {
        isPinned = false
    }

    public func togglePin() {
        isPinned.toggle()
    }

    // MARK: - Preview

    /// Returns a preview text with limited lines and length
    public func previewText(maxLines: Int, maxLength: Int) -> String {
        guard !content.isEmpty else {
            return ""
        }

        var result = content
        let lines = content.components(separatedBy: .newlines)

        // Limit lines
        if lines.count > maxLines {
            result = lines.prefix(maxLines).joined(separator: "\n")
        }

        // Limit length
        if result.count > maxLength {
            let index = result.index(result.startIndex, offsetBy: maxLength)
            result = String(result[..<index]) + "..."
        }

        return result
    }

    /// Returns the character count of the content
    public var characterCount: Int {
        return content.count
    }

    // MARK: - Comparison

    /// Checks if two clipboard items have the same content
    public func hasSameContent(as other: ClipboardItem) -> Bool {
        return self.content == other.content &&
               self.type == other.type &&
               self.rawData == other.rawData
    }
}

// MARK: - Identifiable

extension ClipboardItem: Identifiable {}

// MARK: - Hashable

extension ClipboardItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
}
