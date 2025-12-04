import Foundation

/// Thread-safe in-memory and persistent storage for clipboard items
public final class ClipboardStore {

    // MARK: - Properties

    private var items: [ClipboardItem] = []
    private let queue = DispatchQueue(label: "com.carboclip.store", attributes: .concurrent)

    public let storageURL: URL
    public var maxItems: Int = 300
    public var autoSave: Bool = false

    public var count: Int {
        queue.sync { items.count }
    }

    public var isEmpty: Bool {
        queue.sync { items.isEmpty }
    }

    // MARK: - Initialization

    public init(storageURL: URL? = nil) {
        if let url = storageURL {
            self.storageURL = url
        } else {
            // Default storage location
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let appFolder = appSupport.appendingPathComponent("Carboclip")
            try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
            self.storageURL = appFolder.appendingPathComponent("clipboard_history.json")
        }
    }

    // MARK: - Add/Remove

    /// Adds an item to the store
    public func add(_ item: ClipboardItem) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            // Check for duplicates
            if self.items.contains(where: { $0.hasSameContent(as: item) }) {
                return
            }

            // Add to beginning (most recent first)
            self.items.insert(item, at: 0)

            // Enforce max items limit (preserve pinned items)
            if self.items.count > self.maxItems {
                let unpinned = self.items.filter { !$0.isPinned }
                let pinned = self.items.filter { $0.isPinned }

                // Keep most recent unpinned items up to limit
                let keepCount = max(0, self.maxItems - pinned.count)
                let keptUnpinned = Array(unpinned.prefix(keepCount))

                self.items = keptUnpinned + pinned
            }

            if self.autoSave {
                DispatchQueue.global().async {
                    try? self.save()
                }
            }
        }
    }

    /// Removes an item from the store
    public func remove(_ item: ClipboardItem) {
        queue.async(flags: .barrier) { [weak self] in
            self?.items.removeAll { $0.id == item.id }

            if self?.autoSave == true {
                DispatchQueue.global().async {
                    try? self?.save()
                }
            }
        }
    }

    /// Removes an item by ID
    public func remove(byId id: UUID) {
        queue.async(flags: .barrier) { [weak self] in
            self?.items.removeAll { $0.id == id }

            if self?.autoSave == true {
                DispatchQueue.global().async {
                    try? self?.save()
                }
            }
        }
    }

    /// Clears all items
    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            self?.items.removeAll()

            if self?.autoSave == true {
                DispatchQueue.global().async {
                    try? self?.save()
                }
            }
        }
    }

    // MARK: - Retrieve

    /// Returns all items
    public func getAllItems() -> [ClipboardItem] {
        queue.sync { items }
    }

    /// Gets an item by ID
    public func getItem(byId id: UUID) -> ClipboardItem? {
        queue.sync { items.first { $0.id == id } }
    }

    /// Gets recent items
    public func getRecentItems(limit: Int) -> [ClipboardItem] {
        queue.sync {
            let sorted = items.sorted { $0.timestamp > $1.timestamp }
            return Array(sorted.prefix(limit))
        }
    }

    /// Gets all pinned items
    public func getPinnedItems() -> [ClipboardItem] {
        queue.sync { items.filter { $0.isPinned } }
    }

    /// Checks if store contains an item
    public func contains(_ item: ClipboardItem) -> Bool {
        queue.sync { items.contains { $0.id == item.id } }
    }

    // MARK: - Update

    /// Updates an existing item
    public func update(_ item: ClipboardItem) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                self.items[index] = item
            }

            if self.autoSave {
                DispatchQueue.global().async {
                    try? self.save()
                }
            }
        }
    }

    // MARK: - Persistence

    /// Saves items to disk
    public func save() throws {
        let itemsToSave = queue.sync { items }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(itemsToSave)
        try data.write(to: storageURL, options: .atomic)
    }

    /// Loads items from disk
    public func load() throws {
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            // No file exists yet, start with empty store
            return
        }

        let data = try Data(contentsOf: storageURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let loadedItems = try decoder.decode([ClipboardItem].self, from: data)

        queue.async(flags: .barrier) { [weak self] in
            self?.items = loadedItems
        }
    }
}
