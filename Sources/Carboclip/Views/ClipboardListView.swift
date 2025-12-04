import SwiftUI
import ClipboardCore

struct ClipboardListView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBar(text: $viewModel.searchQuery)
                .padding()

            // Type filters
            if !viewModel.selectedTypeFilters.isEmpty {
                FilterChips(
                    selectedFilters: $viewModel.selectedTypeFilters,
                    onClear: viewModel.clearFilters
                )
                .padding(.horizontal)
            }

            Divider()

            // Clipboard items
            if viewModel.filteredItems.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Pinned items section
                        if !viewModel.pinnedItems.isEmpty {
                            Section {
                                ForEach(viewModel.pinnedItems) { item in
                                    ClipboardItemRow(
                                        item: item,
                                        onSelect: {
                                            viewModel.copyToPasteboard(item)
                                            dismiss()
                                        },
                                        onPin: { viewModel.unpinItem(item) },
                                        onDelete: { viewModel.deleteItem(item) }
                                    )
                                }
                            } header: {
                                SectionHeader(title: "Pinned")
                            }
                        }

                        // Regular items section
                        if !viewModel.unpinnedItems.isEmpty {
                            Section {
                                ForEach(viewModel.unpinnedItems) { item in
                                    ClipboardItemRow(
                                        item: item,
                                        onSelect: {
                                            viewModel.copyToPasteboard(item)
                                            dismiss()
                                        },
                                        onPin: { viewModel.pinItem(item) },
                                        onDelete: { viewModel.deleteItem(item) }
                                    )
                                }
                            } header: {
                                if !viewModel.pinnedItems.isEmpty {
                                    SectionHeader(title: "Recent")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }

        }
        .frame(width: 420, height: 350)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search clipboard...", text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
}

// MARK: - Filter Chips

struct FilterChips: View {
    @Binding var selectedFilters: Set<ClipboardItemType>
    let onClear: () -> Void

    var body: some View {
        HStack {
            ForEach(Array(selectedFilters), id: \.self) { type in
                FilterChip(type: type) {
                    selectedFilters.remove(type)
                }
            }

            Button("Clear All") {
                onClear()
            }
            .buttonStyle(.link)
            .font(.caption)
        }
    }
}

struct FilterChip: View {
    let type: ClipboardItemType
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(type.displayName)
                .font(.caption)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Clipboard Item Row

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let onSelect: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)

            // Content preview
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText(maxLines: 2, maxLength: 100))
                    .lineLimit(2)
                    .font(.body)

                HStack(spacing: 8) {
                    Text(item.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(item.sourceApp)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                    }
                }
            }

            Spacer()

            // Actions (shown on hover)
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: onPin) {
                        Image(systemName: item.isPinned ? "pin.slash" : "pin")
                    }
                    .buttonStyle(.plain)
                    .help(item.isPinned ? "Unpin" : "Pin")

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .help("Delete")
                }
            }
        }
        .padding(12)
        .background(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .onHover { hovering in
            isHovered = hovering
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }

    private var iconName: String {
        switch item.type {
        case .text: return "doc.text"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .url: return "link"
        case .file: return "folder"
        case .image: return "photo"
        case .html: return "doc.richtext"
        case .rtf: return "doc.richtext"
        case .color: return "paintpalette"
        case .pdf: return "doc.pdf"
        case .custom: return "doc"
        }
    }

    private var timeAgo: String {
        let interval = Date().timeIntervalSince(item.timestamp)
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No clipboard items")
                .font(.title3)
                .fontWeight(.medium)

            Text("Copy something to get started")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Footer

struct FooterView: View {
    let itemCount: Int

    var body: some View {
        HStack {
            Text("\(itemCount) items")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text("⌘Q to Quit • ESC to Close")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
