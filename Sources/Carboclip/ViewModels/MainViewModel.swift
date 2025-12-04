import Foundation
import SwiftUI
import ClipboardCore
import Combine

/// Main view model that coordinates all core components
@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Core Components

    private let monitor: ClipboardMonitor
    private let store: ClipboardStore
    private let searchEngine: SearchEngine
    private let filterManager: FilterManager
    let settings: SettingsManager // Public for Settings window

    // MARK: - Published State

    @Published var items: [ClipboardItem] = []
    @Published var filteredItems: [ClipboardItem] = []
    @Published var searchQuery: String = "" {
        didSet {
            applyFiltersAndSearch()
        }
    }
    @Published var selectedTypeFilters: Set<ClipboardItemType> = [] {
        didSet {
            applyFiltersAndSearch()
        }
    }
    @Published var isMonitoring: Bool = false

    // MARK: - Computed Properties

    var pinnedItems: [ClipboardItem] {
        filterManager.filterPinned(items)
    }

    var unpinnedItems: [ClipboardItem] {
        filterManager.filterUnpinned(filteredItems)
    }

    // MARK: - Initialization

    init(
        monitor: ClipboardMonitor = ClipboardMonitor(),
        store: ClipboardStore = ClipboardStore(),
        searchEngine: SearchEngine = SearchEngine(),
        filterManager: FilterManager = FilterManager(),
        settings: SettingsManager = SettingsManager()
    ) {
        self.monitor = monitor
        self.store = store
        self.searchEngine = searchEngine
        self.filterManager = filterManager
        self.settings = settings

        // Configure monitor
        self.monitor.pollingInterval = settings.pollingInterval
        self.monitor.excludedApplications = settings.excludedApplications

        // Set up clipboard change handler
        self.monitor.onClipboardChange = { [weak self] item in
            Task { @MainActor in
                self?.handleNewClipboardItem(item)
            }
        }

        // Load stored items
        loadStoredItems()
    }

    // MARK: - Lifecycle

    func startMonitoring() {
        monitor.start()
        isMonitoring = true
        print("📋 Clipboard monitoring started")
    }

    func stopMonitoring() {
        monitor.stop()
        isMonitoring = false
        print("📋 Clipboard monitoring stopped")
    }

    // MARK: - Item Management

    private func handleNewClipboardItem(_ item: ClipboardItem) {
        // Add to store
        store.add(item)

        // Update items list
        items = store.getAllItems()

        // Apply current filters
        applyFiltersAndSearch()

        print("✅ New clipboard item: \(item.type.displayName) - \(item.content.prefix(50))")
    }

    func pinItem(_ item: ClipboardItem) {
        item.pin()
        store.update(item)
        items = store.getAllItems()
        applyFiltersAndSearch()
    }

    func unpinItem(_ item: ClipboardItem) {
        item.unpin()
        store.update(item)
        items = store.getAllItems()
        applyFiltersAndSearch()
    }

    func togglePin(_ item: ClipboardItem) {
        item.togglePin()
        store.update(item)
        items = store.getAllItems()
        applyFiltersAndSearch()
    }

    func deleteItem(_ item: ClipboardItem) {
        store.remove(item)
        items = store.getAllItems()
        applyFiltersAndSearch()
    }

    func clearAll() {
        store.clear()
        items = []
        filteredItems = []
    }

    func copyToPasteboard(_ item: ClipboardItem) {
        // Ignore the next change to prevent re-capturing this programmatic copy
        monitor.ignoreNextChange()

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        // If we have the original raw data, restore it with the correct type
        if let rawData = item.rawData {
            switch item.type {
            case .rtf:
                pasteboard.setData(rawData, forType: .rtf)
                // Also set plain text as fallback
                pasteboard.setString(item.content, forType: .string)
            case .html:
                pasteboard.setData(rawData, forType: .html)
                pasteboard.setString(item.content, forType: .string)
            case .image:
                pasteboard.setData(rawData, forType: .tiff)
            case .pdf:
                pasteboard.setData(rawData, forType: .pdf)
            default:
                // For other types with raw data, use string
                pasteboard.setString(item.content, forType: .string)
            }
        } else {
            // Fallback to plain text
            pasteboard.setString(item.content, forType: .string)
        }

        print("📋 Copied to clipboard: \(item.content.prefix(50))")
    }

    // MARK: - Search and Filter

    private func applyFiltersAndSearch() {
        var filtered = items

        // Apply type filters
        if !selectedTypeFilters.isEmpty {
            filtered = filterManager.filter(filtered, by: Array(selectedTypeFilters))
        }

        // Apply search
        if !searchQuery.isEmpty {
            filtered = searchEngine.search(query: searchQuery, in: filtered)
        }

        filteredItems = filtered
    }

    func toggleTypeFilter(_ type: ClipboardItemType) {
        if selectedTypeFilters.contains(type) {
            selectedTypeFilters.remove(type)
        } else {
            selectedTypeFilters.insert(type)
        }
    }

    func clearFilters() {
        selectedTypeFilters.removeAll()
        searchQuery = ""
    }

    // MARK: - Persistence

    private func loadStoredItems() {
        do {
            try store.load()
            items = store.getAllItems()
            filteredItems = items
            print("📂 Loaded \(items.count) items from storage")
        } catch {
            print("⚠️ Failed to load stored items: \(error)")
        }
    }

    func saveItems() {
        do {
            try store.save()
            print("💾 Saved \(items.count) items to storage")
        } catch {
            print("⚠️ Failed to save items: \(error)")
        }
    }

    // MARK: - Settings

    func updateSettings() {
        monitor.pollingInterval = settings.pollingInterval
        monitor.excludedApplications = settings.excludedApplications
        store.maxItems = settings.maxHistoryItems
    }
}
