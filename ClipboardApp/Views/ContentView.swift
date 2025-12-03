import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var historyManager: ClipboardHistoryManager
    @EnvironmentObject private var monitor: ClipboardMonitor
    @State private var searchText = ""
    @State private var showFavoritesOnly = false

    var filteredItems: [ClipboardItem] {
        let items = showFavoritesOnly ? historyManager.getFavorites() : historyManager.items
        return searchText.isEmpty ? items : historyManager.search(for: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Clipboard History")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Monitor: \(monitor.isMonitoring ? "Active" : "Inactive")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Toggle("Monitoring", isOn: $monitor.isMonitoring)
                            .onChange(of: monitor.isMonitoring) { newValue in
                                if newValue {
                                    monitor.startMonitoring()
                                } else {
                                    monitor.stopMonitoring()
                                }
                            }
                    }
                }
                .padding()

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search clipboard...", text: $searchText)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal)

                // Filter buttons
                HStack(spacing: 8) {
                    Button(action: { showFavoritesOnly.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                            Text("Favorites")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    if !historyManager.items.isEmpty {
                        Menu {
                            Button("Clear History", action: {
                                historyManager.clearHistory()
                            })
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.controlBackgroundColor))

            // Items list
            if filteredItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No clipboard items yet" : "No results found")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredItems) { item in
                    ClipboardItemRow(item: item)
                        .environmentObject(historyManager)
                }
                .listStyle(.plain)
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .onAppear {
            if !monitor.isMonitoring {
                monitor.startMonitoring()
            }
        }
    }
}

struct ClipboardItemRow: View {
    @EnvironmentObject private var historyManager: ClipboardHistoryManager
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.content.prefix(100))
                        .lineLimit(2)
                        .font(.body)
                    HStack(spacing: 8) {
                        Text(item.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.category)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                Spacer()

                HStack(spacing: 6) {
                    Button(action: { copyToClipboard(item.content) }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        historyManager.toggleFavorite(for: item.id)
                    }) {
                        Image(systemName: item.isFavorite ? "star.fill" : "star")
                            .foregroundColor(item.isFavorite ? .yellow : .gray)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        historyManager.deleteItem(with: item.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

#Preview {
    let manager = ClipboardHistoryManager(userDefaults: UserDefaults(suiteName: "preview")!)
    let monitor = ClipboardMonitor()

    manager.addItem(ClipboardItem(content: "Hello, World!"))
    manager.addItem(ClipboardItem(content: "This is a test clipboard item"))

    return ContentView()
        .environmentObject(manager)
        .environmentObject(monitor)
}
