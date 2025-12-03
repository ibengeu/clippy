import SwiftUI

// MARK: - SwiftClip Typography System

extension Font {
    // MARK: - Font Sizes (based on blueprint)

    /// Title font - 28pt, used for main headings
    static let swiftClipTitle = Font.system(size: 28, weight: .regular, design: .default)

    /// Title font - Bold variant
    static let swiftClipTitleBold = Font.system(size: 28, weight: .bold, design: .default)

    /// Headline font - 20pt, used for section headers
    static let swiftClipHeadline = Font.system(size: 20, weight: .semibold, design: .default)

    /// Body font - 16pt, used for main content
    static let swiftClipBody = Font.system(size: 16, weight: .regular, design: .default)

    /// Body font - Medium variant
    static let swiftClipBodyMedium = Font.system(size: 16, weight: .medium, design: .default)

    /// Caption font - 14pt, used for secondary text
    static let swiftClipCaption = Font.system(size: 14, weight: .regular, design: .default)

    /// Caption small font - 12pt, used for timestamps and metadata
    static let swiftClipCaptionSmall = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Text View Modifiers

extension Text {
    /// Apply SwiftClip title font (28pt, regular)
    func swiftClipTitle() -> Text {
        self.font(.swiftClipTitle)
    }

    /// Apply SwiftClip title font (28pt, bold)
    func swiftClipTitleBold() -> Text {
        self.font(.swiftClipTitleBold)
    }

    /// Apply SwiftClip headline font (20pt, semibold)
    func swiftClipHeadline() -> Text {
        self.font(.swiftClipHeadline)
    }

    /// Apply SwiftClip body font (16pt, regular)
    func swiftClipBody() -> Text {
        self.font(.swiftClipBody)
    }

    /// Apply SwiftClip body font (16pt, medium)
    func swiftClipBodyMedium() -> Text {
        self.font(.swiftClipBodyMedium)
    }

    /// Apply SwiftClip caption font (14pt, regular)
    func swiftClipCaption() -> Text {
        self.font(.swiftClipCaption)
    }

    /// Apply SwiftClip caption small font (12pt, regular)
    func swiftClipCaptionSmall() -> Text {
        self.font(.swiftClipCaptionSmall)
    }
}

// MARK: - View Modifiers for any View

extension View {
    /// Apply SwiftClip title font (28pt, regular)
    func swiftClipTitle() -> some View {
        self.font(.swiftClipTitle)
    }

    /// Apply SwiftClip title font (28pt, bold)
    func swiftClipTitleBold() -> some View {
        self.font(.swiftClipTitleBold)
    }

    /// Apply SwiftClip headline font (20pt, semibold)
    func swiftClipHeadline() -> some View {
        self.font(.swiftClipHeadline)
    }

    /// Apply SwiftClip body font (16pt, regular)
    func swiftClipBody() -> some View {
        self.font(.swiftClipBody)
    }

    /// Apply SwiftClip body font (16pt, medium)
    func swiftClipBodyMedium() -> some View {
        self.font(.swiftClipBodyMedium)
    }

    /// Apply SwiftClip caption font (14pt, regular)
    func swiftClipCaption() -> some View {
        self.font(.swiftClipCaption)
    }

    /// Apply SwiftClip caption small font (12pt, regular)
    func swiftClipCaptionSmall() -> some View {
        self.font(.swiftClipCaptionSmall)
    }
}
