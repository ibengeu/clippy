import Foundation
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    @Published var isMonitoring: Bool = false

    private var monitoringTimer: Timer?
    private var lastChangeCount: Int = 0
    private let maxHistorySize = 100
    private weak var historyManager: ClipboardHistoryManager?

    init(historyManager: ClipboardHistoryManager? = nil) {
        self.historyManager = historyManager
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        lastChangeCount = NSPasteboard.general.changeCount

        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForClipboardChanges()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }

    func addItem(_ item: ClipboardItem) {
        // Check for duplicates - don't add if the same content already exists
        if !clipboardItems.contains(where: { $0.content == item.content }) {
            clipboardItems.insert(item, at: 0)

            // Keep history size under limit
            if clipboardItems.count > maxHistorySize {
                clipboardItems.removeLast()
            }

            // Also add to history manager
            historyManager?.addItem(item)
        }
    }

    func getCurrentClipboardContent() -> String? {
        return NSPasteboard.general.string(forType: .string)
    }

    private func checkForClipboardChanges() {
        let currentChangeCount = NSPasteboard.general.changeCount

        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount

            if let content = getCurrentClipboardContent() {
                let item = ClipboardItem(content: content)
                addItem(item)
            }
        }
    }
}
