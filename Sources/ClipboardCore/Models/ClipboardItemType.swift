import Foundation

/// Represents the type of content stored in a clipboard item
public enum ClipboardItemType: String, Codable, CaseIterable {
    case text
    case image
    case url
    case file
    case html
    case rtf
    case code
    case color
    case pdf
    case custom

    /// Display name for the type
    public var displayName: String {
        switch self {
        case .text: return "Text"
        case .image: return "Image"
        case .url: return "URL"
        case .file: return "File"
        case .html: return "HTML"
        case .rtf: return "Rich Text"
        case .code: return "Code"
        case .color: return "Color"
        case .pdf: return "PDF"
        case .custom: return "Custom"
        }
    }

    /// Icon name for Carbon Design System
    public var carbonIconName: String {
        switch self {
        case .text: return "document"
        case .image: return "image"
        case .url: return "link"
        case .file: return "folder"
        case .html: return "code"
        case .rtf: return "text-creation"
        case .code: return "code-reference"
        case .color: return "color-palette"
        case .pdf: return "document-pdf"
        case .custom: return "unknown"
        }
    }
}
