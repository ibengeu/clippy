import Foundation
import AppKit

/// Monitors the system clipboard for changes
public final class ClipboardMonitor {

    // MARK: - Properties

    private let pasteboard: NSPasteboard
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private var lastClipboardItem: ClipboardItem?

    public var pollingInterval: TimeInterval = 0.3
    public var excludedApplications: [String] = []
    public var onClipboardChange: ((ClipboardItem) -> Void)?
    public private(set) var isMonitoring: Bool = false
    private var isPaused: Bool = false

    // MARK: - Initialization

    public init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
        self.lastChangeCount = pasteboard.changeCount
    }

    deinit {
        stop()
    }

    // MARK: - Public Methods

    /// Starts monitoring the clipboard
    public func start() {
        guard !isMonitoring else { return }

        isMonitoring = true
        lastChangeCount = pasteboard.changeCount

        timer = Timer.scheduledTimer(
            withTimeInterval: pollingInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkForChanges()
        }

        // Ensure timer fires on common run loop modes
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    /// Stops monitoring the clipboard
    public func stop() {
        guard isMonitoring else { return }

        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }

    /// Checks if an application should be excluded from monitoring
    public func isApplicationExcluded(_ appName: String) -> Bool {
        return excludedApplications.contains(appName)
    }

    /// Temporarily ignores the next clipboard change
    /// Used when programmatically copying to avoid re-capturing
    public func ignoreNextChange() {
        lastChangeCount = pasteboard.changeCount
    }

    // MARK: - Private Methods

    private func checkForChanges() {
        guard !isPaused else { return }

        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else {
            return
        }

        lastChangeCount = currentChangeCount

        guard let clipboardItem = extractClipboardItem() else {
            return
        }

        // Check if source app is excluded
        if isApplicationExcluded(clipboardItem.sourceApp) {
            return
        }

        // Check for duplicate content
        if let lastItem = lastClipboardItem,
           lastItem.hasSameContent(as: clipboardItem) {
            return
        }

        lastClipboardItem = clipboardItem
        onClipboardChange?(clipboardItem)
    }

    private func extractClipboardItem() -> ClipboardItem? {
        let sourceApp = getActiveApplicationName()

        // Check for images first (higher priority)
        if let imageData = extractImage() {
            return ClipboardItem(
                content: imageData,
                type: .image,
                sourceApp: sourceApp
            )
        }

        // Check for RTF - preserve original data
        if let rtfData = pasteboard.data(forType: .rtf) {
            // Also get plain text for display
            let plainText = pasteboard.string(forType: .string) ?? "[RTF content]"
            return ClipboardItem(
                content: plainText,
                type: .rtf,
                sourceApp: sourceApp,
                rawData: rtfData
            )
        }

        // Check for HTML - preserve original data
        if let htmlData = pasteboard.data(forType: .html) {
            let plainText = pasteboard.string(forType: .string) ?? "[HTML content]"
            return ClipboardItem(
                content: plainText,
                type: .html,
                sourceApp: sourceApp,
                rawData: htmlData
            )
        }

        // Check for file URLs
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           let firstURL = urls.first,
           firstURL.isFileURL {
            return ClipboardItem(
                content: firstURL.path,
                type: .file,
                sourceApp: sourceApp
            )
        }

        // Check for URLs
        if let urlString = pasteboard.string(forType: .string),
           isValidURL(urlString) {
            return ClipboardItem(
                content: urlString,
                type: .url,
                sourceApp: sourceApp
            )
        }

        // Default to plain text
        if let stringContent = pasteboard.string(forType: .string) {
            let type = detectContentType(stringContent)
            return ClipboardItem(
                content: stringContent,
                type: type,
                sourceApp: sourceApp
            )
        }

        return nil
    }

    private func extractImage() -> Data? {
        guard let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            return nil
        }

        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        return bitmapImage.representation(using: .png, properties: [:])
    }

    private func getActiveApplicationName() -> String {
        return NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
    }

    private func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string),
              let scheme = url.scheme else {
            return false
        }

        return ["http", "https", "ftp", "file"].contains(scheme.lowercased())
    }

    private func detectContentType(_ content: String) -> ClipboardItemType {
        // Detect HTML
        if content.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") &&
           content.contains("</") {
            return .html
        }

        // Detect color hex codes
        if content.hasPrefix("#") && content.count <= 9 {
            let hex = content.dropFirst()
            if hex.allSatisfy({ $0.isHexDigit }) {
                return .color
            }
        }

        // Detect code (heuristic: contains common code patterns)
        let codePatterns = [
            "func ", "function ", "class ", "def ", "import ",
            "const ", "let ", "var ", "public ", "private ",
            "{", "}", "(", ")", "=>", "->", "::", "println"
        ]

        let lowercased = content.lowercased()
        let hasCodePattern = codePatterns.contains { lowercased.contains($0) }
        let hasMultipleLines = content.components(separatedBy: .newlines).count > 1

        if hasCodePattern && hasMultipleLines {
            return .code
        }

        // Default to text
        return .text
    }
}
