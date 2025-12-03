import Foundation

class ClipboardHistoryManager: ObservableObject {
    @Published var items: [ClipboardItem] = []

    private let userDefaults: UserDefaults
    private let storageKey = "clipboard.history"

    // FIFO limit for history (can be configured)
    var maxHistorySize: Int = 100

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadItems()
    }

    func addItem(_ item: ClipboardItem, autoDetectSensitive: Bool = false) {
        var newItem = item

        // Auto-detect sensitive content if enabled
        if autoDetectSensitive, let sourceApp = item.sourceApp {
            let sensitiveManager = SensitiveAppManager()
            if sensitiveManager.isSensitiveApp(bundleId: sourceApp) {
                newItem.isSensitive = true
            }
        }

        items.insert(newItem, at: 0)

        // Apply FIFO removal if limit exceeded
        enforceHistoryLimit()

        saveItems()
    }

    func deleteItem(with id: UUID) {
        items.removeAll { $0.id == id }
        saveItems()
    }

    func toggleFavorite(for id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isFavorite.toggle()
            saveItems()
        }
    }

    func updateCategory(for id: UUID, to category: String) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].category = category
            saveItems()
        }
    }

    func clearHistory() {
        items.removeAll()
        saveItems()
    }

    func search(for query: String) -> [ClipboardItem] {
        guard !query.isEmpty else { return items }
        // Exclude sensitive items from regular search
        return items.filter { !$0.isSensitive && $0.content.localizedCaseInsensitiveContains(query) }
    }

    func getFavorites() -> [ClipboardItem] {
        items.filter { $0.isFavorite }
    }

    // MARK: - Pin/Unpin Methods

    func togglePin(for id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isPinned.toggle()
            saveItems()
        }
    }

    func getPinnedItems() -> [ClipboardItem] {
        items.filter { $0.isPinned }
    }

    // MARK: - Access Tracking Methods

    func incrementAccessCount(for id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].accessCount += 1
            saveItems()
        }
    }

    func updateLastAccessed(for id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].lastAccessedDate = Date()
            saveItems()
        }
    }

    // MARK: - Sensitive Content Methods

    func markAsSensitive(for id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isSensitive = true
            saveItems()
        }
    }

    func markAsNotSensitive(for id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isSensitive = false
            saveItems()
        }
    }

    func getRedactedContent(for item: ClipboardItem) -> String {
        return item.isSensitive ? "••••••••" : item.content
    }

    func getDisplayContent(for item: ClipboardItem) -> String {
        return item.isSensitive ? "•••••••• (sensitive)" : item.content
    }

    func getActualContent(for item: ClipboardItem) -> String {
        return item.content
    }

    func searchIncludingSensitive(for query: String) -> [ClipboardItem] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.content.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Sorting Methods

    func sortByRecency() -> [ClipboardItem] {
        items.sorted { $0.timestamp > $1.timestamp }
    }

    func sortByFrequency() -> [ClipboardItem] {
        items.sorted { $0.accessCount > $1.accessCount }
    }

    // MARK: - FIFO Management

    private func enforceHistoryLimit() {
        guard items.count > maxHistorySize else { return }

        // Calculate how many items to remove
        let excessCount = items.count - maxHistorySize

        // Get IDs of oldest non-pinned items to remove
        let itemsToRemove = items
            .filter { !$0.isPinned }
            .suffix(excessCount)
            .map { $0.id }

        // Remove oldest non-pinned items
        items.removeAll { itemsToRemove.contains($0.id) }
    }

    // MARK: - Private Methods

    private func saveItems() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to save clipboard items: \(error)")
        }
    }

    private func loadItems() {
        guard let data = userDefaults.data(forKey: storageKey) else { return }

        do {
            let decoder = JSONDecoder()
            items = try decoder.decode([ClipboardItem].self, from: data)
        } catch {
            print("Failed to load clipboard items: \(error)")
            items = []
        }
    }
}
