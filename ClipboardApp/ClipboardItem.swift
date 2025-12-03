import Foundation

// MARK: - Content Type Enum

enum ContentType: String, Codable {
    case text
    case image
    case file
    case richText

    var displayName: String {
        switch self {
        case .text:
            return "Text"
        case .image:
            return "Image"
        case .file:
            return "File"
        case .richText:
            return "Rich Text"
        }
    }

    var icon: String {
        switch self {
        case .text:
            return "doc.text"
        case .image:
            return "photo"
        case .file:
            return "doc"
        case .richText:
            return "doc.richtext"
        }
    }
}

// MARK: - Enhanced Clipboard Item

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    var isFavorite: Bool = false
    var category: String = "General"

    // New properties for SwiftClip enhancements
    var isPinned: Bool = false
    var contentType: ContentType = .text
    var isSensitive: Bool = false
    var sourceApp: String? = nil
    var accessCount: Int = 0
    var lastAccessedDate: Date? = nil

    init(
        content: String,
        timestamp: Date = Date(),
        contentType: ContentType = .text,
        sourceApp: String? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.timestamp = timestamp
        self.contentType = contentType
        self.sourceApp = sourceApp
    }
}

// MARK: - Codable Implementation with Backward Compatibility

extension ClipboardItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, content, timestamp, isFavorite, category
        case isPinned, contentType, isSensitive, sourceApp, accessCount, lastAccessedDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required old properties
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        timestamp = try container.decode(Date.self, forKey: .timestamp)

        // Optional old properties with defaults
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "General"

        // New properties with defaults (backward compatible)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        contentType = try container.decodeIfPresent(ContentType.self, forKey: .contentType) ?? .text
        isSensitive = try container.decodeIfPresent(Bool.self, forKey: .isSensitive) ?? false
        sourceApp = try container.decodeIfPresent(String.self, forKey: .sourceApp)
        accessCount = try container.decodeIfPresent(Int.self, forKey: .accessCount) ?? 0
        lastAccessedDate = try container.decodeIfPresent(Date.self, forKey: .lastAccessedDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(category, forKey: .category)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(isSensitive, forKey: .isSensitive)
        try container.encodeIfPresent(sourceApp, forKey: .sourceApp)
        try container.encode(accessCount, forKey: .accessCount)
        try container.encodeIfPresent(lastAccessedDate, forKey: .lastAccessedDate)
    }
}
