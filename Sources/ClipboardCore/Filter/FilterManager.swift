import Foundation

/// Sort order for clipboard items
public enum SortOrder {
    case dateDescending
    case dateAscending
    case contentLength
    case type
}

/// Manages filtering and sorting of clipboard items
public final class FilterManager {

    // MARK: - Initialization

    public init() {}

    // MARK: - Filter by Type

    /// Filters items by clipboard item types
    public func filter(_ items: [ClipboardItem], by types: [ClipboardItemType]) -> [ClipboardItem] {
        guard !types.isEmpty else {
            return items
        }

        return items.filter { item in
            types.contains(item.type)
        }
    }

    // MARK: - Filter by Source App

    /// Filters items by a single source application
    public func filter(_ items: [ClipboardItem], bySourceApp app: String) -> [ClipboardItem] {
        return items.filter { $0.sourceApp == app }
    }

    /// Filters items by multiple source applications
    public func filter(_ items: [ClipboardItem], bySourceApps apps: [String]) -> [ClipboardItem] {
        return items.filter { item in
            apps.contains(item.sourceApp)
        }
    }

    // MARK: - Filter by Date Range

    /// Filters items within a date range (inclusive)
    public func filter(_ items: [ClipboardItem], from startDate: Date, to endDate: Date) -> [ClipboardItem] {
        return items.filter { item in
            item.timestamp >= startDate && item.timestamp <= endDate
        }
    }

    // MARK: - Filter by Pinned Status

    /// Returns only pinned items
    public func filterPinned(_ items: [ClipboardItem]) -> [ClipboardItem] {
        return items.filter { $0.isPinned }
    }

    /// Returns only unpinned items
    public func filterUnpinned(_ items: [ClipboardItem]) -> [ClipboardItem] {
        return items.filter { !$0.isPinned }
    }

    // MARK: - Filter by Content Length

    /// Filters items by minimum content length
    public func filter(_ items: [ClipboardItem], minimumLength: Int) -> [ClipboardItem] {
        return items.filter { $0.content.count >= minimumLength }
    }

    /// Filters items by maximum content length
    public func filter(_ items: [ClipboardItem], maximumLength: Int) -> [ClipboardItem] {
        return items.filter { $0.content.count <= maximumLength }
    }

    /// Filters items by content length range
    public func filter(_ items: [ClipboardItem], minimumLength: Int, maximumLength: Int) -> [ClipboardItem] {
        return items.filter { item in
            let length = item.content.count
            return length >= minimumLength && length <= maximumLength
        }
    }

    // MARK: - Sorting

    /// Sorts items by the specified sort order
    public func sort(_ items: [ClipboardItem], by order: SortOrder) -> [ClipboardItem] {
        switch order {
        case .dateDescending:
            return items.sorted { $0.timestamp > $1.timestamp }

        case .dateAscending:
            return items.sorted { $0.timestamp < $1.timestamp }

        case .contentLength:
            return items.sorted { $0.content.count < $1.content.count }

        case .type:
            return items.sorted { $0.type.rawValue < $1.type.rawValue }
        }
    }

    // MARK: - Combined Filters

    /// Applies multiple filters in sequence
    public func applyFilters(
        to items: [ClipboardItem],
        types: [ClipboardItemType]? = nil,
        sourceApps: [String]? = nil,
        dateRange: (from: Date, to: Date)? = nil,
        pinnedOnly: Bool = false,
        unpinnedOnly: Bool = false,
        minimumLength: Int? = nil,
        maximumLength: Int? = nil
    ) -> [ClipboardItem] {
        var filtered = items

        // Filter by types
        if let types = types, !types.isEmpty {
            filtered = filter(filtered, by: types)
        }

        // Filter by source apps
        if let apps = sourceApps, !apps.isEmpty {
            filtered = filter(filtered, bySourceApps: apps)
        }

        // Filter by date range
        if let range = dateRange {
            filtered = filter(filtered, from: range.from, to: range.to)
        }

        // Filter by pinned status
        if pinnedOnly {
            filtered = filterPinned(filtered)
        } else if unpinnedOnly {
            filtered = filterUnpinned(filtered)
        }

        // Filter by content length
        if let minLength = minimumLength {
            filtered = filter(filtered, minimumLength: minLength)
        }

        if let maxLength = maximumLength {
            filtered = filter(filtered, maximumLength: maxLength)
        }

        return filtered
    }
}
