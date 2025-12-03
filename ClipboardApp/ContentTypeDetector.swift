import AppKit
import Foundation

/// Utility for detecting clipboard content types
struct ContentTypeDetector {

    /// Detect content type from pasteboard types
    static func detectType(from types: [NSPasteboard.PasteboardType]) -> ContentType {
        // Priority order: image > file > richText > text

        // Check for images
        if types.contains(.png) || types.contains(.tiff) {
            return .image
        }

        // Check for files
        if types.contains(.fileURL) {
            return .file
        }

        // Check for rich text
        if types.contains(.rtf) || types.contains(.html) {
            return .richText
        }

        // Default to text
        return .text
    }

    /// Detect content type from current pasteboard
    static func detectCurrentType() -> ContentType {
        let pasteboard = NSPasteboard.general
        guard let types = pasteboard.types else {
            return .text
        }
        return detectType(from: types)
    }
}
