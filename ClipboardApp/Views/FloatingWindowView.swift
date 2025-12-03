import SwiftUI

struct FloatingWindowView: View {
    @EnvironmentObject private var historyManager: ClipboardHistoryManager
    @EnvironmentObject private var monitor: ClipboardMonitor
    @ObservedObject var settings: SettingsManager
    @State private var hideTimer: Timer?
    @State private var searchText: String = ""
    @State private var selectedIndex: Int = 0
    @State private var showPasteModeMenu: Bool = false
    @Binding var isVisible: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("SwiftClip")
                    .swiftClipHeadline()
                    .foregroundColor(.swiftClipPrimary)
                Spacer()
                Button(action: { hideWindow() }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.swiftClipTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color.swiftClipBackground.opacity(0.95))

            // Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.swiftClipTextSecondary)
                    .font(.caption)

                TextField("Search clipboard...", text: $searchText)
                    .textFieldStyle(.plain)
                    .swiftClipBody()

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.swiftClipTextSecondary)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.swiftClipBackground.opacity(0.5))

            Divider()

            // Content area
            let filteredItems = searchText.isEmpty ? historyManager.items : historyManager.search(for: searchText)

            if filteredItems.isEmpty {
                VStack {
                    Text(searchText.isEmpty ? "No items copied" : "No results found")
                        .swiftClipCaption()
                        .foregroundColor(.swiftClipTextSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Pinned Section
                        let pinnedItems = filteredItems.filter { $0.isPinned }.prefix(5)
                        if !pinnedItems.isEmpty {
                            VStack(spacing: 0) {
                                // Pinned header
                                HStack {
                                    Image(systemName: "pin.fill")
                                        .font(.caption2)
                                        .foregroundColor(.swiftClipAccent)
                                    Text("PINNED")
                                        .swiftClipCaptionSmall()
                                        .fontWeight(.semibold)
                                        .foregroundColor(.swiftClipAccent)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.swiftClipAccent.opacity(0.1))

                                // Pinned items
                                ForEach(Array(pinnedItems.enumerated()), id: \.element.id) { index, item in
                                    itemRow(item: item, isPinned: true, index: index)
                                }
                            }

                            // Divider between pinned and recent
                            Divider()
                                .background(Color.swiftClipAccent)
                                .padding(.vertical, 4)
                        }

                        // Recent Section
                        let recentItems = filteredItems.filter { !$0.isPinned }.prefix(8)
                        if !recentItems.isEmpty {
                            VStack(spacing: 0) {
                                // Recent header (only show if we have pinned items)
                                if !pinnedItems.isEmpty {
                                    HStack {
                                        Text("RECENT")
                                            .swiftClipCaptionSmall()
                                            .fontWeight(.semibold)
                                            .foregroundColor(.swiftClipTextSecondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                }

                                // Recent items
                                ForEach(Array(recentItems.enumerated()), id: \.element.id) { index, item in
                                    let globalIndex = pinnedItems.count + index
                                    itemRow(item: item, isPinned: false, index: globalIndex)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 350, height: 280)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 8)
        .scaleEffect(isVisible ? AnimationConfig.windowFinalScale : AnimationConfig.windowInitialScale)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(AnimationConfig.windowAppear, value: isVisible)
        .onReceive(monitor.$clipboardItems) { _ in
            showWindow()
            scheduleAutoHide()
        }
        .onAppear {
            selectedIndex = 0
        }
        .onChange(of: searchText) { _ in
            selectedIndex = 0 // Reset selection when search changes
        }
    }

    // MARK: - Keyboard Navigation Handlers

    private func handleUpArrow() {
        let filteredItems = searchText.isEmpty ? historyManager.items : historyManager.search(for: searchText)
        selectedIndex = max(selectedIndex - 1, 0)
    }

    private func handleDownArrow() {
        let filteredItems = searchText.isEmpty ? historyManager.items : historyManager.search(for: searchText)
        selectedIndex = min(selectedIndex + 1, filteredItems.count - 1)
    }

    private func handleEnter() {
        let filteredItems = searchText.isEmpty ? historyManager.items : historyManager.search(for: searchText)
        guard selectedIndex < filteredItems.count else { return }

        let selectedItem = filteredItems[selectedIndex]
        historyManager.incrementAccessCount(for: selectedItem.id)
        historyManager.updateLastAccessed(for: selectedItem.id)
        copyAndPaste(selectedItem.content)
        hideWindow()
    }

    private func handleDelete() {
        let filteredItems = searchText.isEmpty ? historyManager.items : historyManager.search(for: searchText)
        guard selectedIndex < filteredItems.count else { return }

        let selectedItem = filteredItems[selectedIndex]
        historyManager.deleteItem(with: selectedItem.id)

        // Adjust selection if needed
        let newFilteredItems = searchText.isEmpty ? historyManager.items : historyManager.search(for: searchText)
        selectedIndex = min(selectedIndex, max(0, newFilteredItems.count - 1))
    }

    private func handleTogglePin() {
        let filteredItems = searchText.isEmpty ? historyManager.items : historyManager.search(for: searchText)
        guard selectedIndex < filteredItems.count else { return }

        let selectedItem = filteredItems[selectedIndex]
        historyManager.togglePin(for: selectedItem.id)
    }

    // MARK: - Item Row Helper

    @ViewBuilder
    private func itemRow(item: ClipboardItem, isPinned: Bool, index: Int) -> some View {
        let isSelected = index == selectedIndex
        HStack(spacing: 8) {
            // Content button
            Button(action: {
                historyManager.incrementAccessCount(for: item.id)
                historyManager.updateLastAccessed(for: item.id)
                copyAndPaste(item.content)
                hideWindow()
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.content.prefix(60))
                        .lineLimit(2)
                        .swiftClipBody()
                        .foregroundColor(.swiftClipText)
                    Text(item.timestamp.formatted(date: .omitted, time: .shortened))
                        .swiftClipCaptionSmall()
                        .foregroundColor(.swiftClipTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(action: {
                    historyManager.incrementAccessCount(for: item.id)
                    historyManager.updateLastAccessed(for: item.id)
                    copyAndPaste(item.content, mode: .withFormatting)
                    hideWindow()
                }) {
                    Label("Paste with Formatting", systemImage: "doc.richtext")
                }

                Button(action: {
                    historyManager.incrementAccessCount(for: item.id)
                    historyManager.updateLastAccessed(for: item.id)
                    copyAndPaste(item.content, mode: .plainText)
                    hideWindow()
                }) {
                    Label("Paste as Plain Text", systemImage: "doc.plaintext")
                }
            }

            // Pin/Unpin button
            Button(action: {
                withAnimation(AnimationConfig.itemPin) {
                    historyManager.togglePin(for: item.id)
                }
            }) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .font(.caption)
                    .foregroundColor(isPinned ? .swiftClipAccent : .swiftClipTextSecondary)
            }
            .buttonStyle(.plain)
            .help(isPinned ? "Unpin" : "Pin")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            isSelected ? Color.swiftClipPrimary.opacity(0.15) :
            isPinned ? Color.swiftClipAccent.opacity(0.05) : Color.clear
        )
        .animation(AnimationConfig.itemSelection, value: isSelected)
        .animation(AnimationConfig.itemPin, value: isPinned)
        .overlay(
            isSelected ?
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.swiftClipPrimary, lineWidth: 2)
                .padding(2) : nil
        )
        .contentShape(Rectangle())
    }

    // MARK: - Private Methods

    private func hideWindow() {
        isVisible = false
        hideTimer?.invalidate()
    }

    private func showWindow() {
        isVisible = true
    }

    private func scheduleAutoHide() {
        hideTimer?.invalidate()
        // Auto-hide after configured timeout
        hideTimer = Timer.scheduledTimer(withTimeInterval: settings.autoHideTimeout, repeats: false) { _ in
            hideWindow()
        }
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func copyAndPaste(_ text: String, mode: PasteMode = .withFormatting) {
        // Prepare text based on paste mode
        let preparedText = StringFormatter.prepareForPaste(text, mode: mode)

        // Copy the prepared text to clipboard
        copyToClipboard(preparedText)

        // Delay to ensure clipboard is updated and focus returns to previous app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Simulate Command+V keypress
            self.simulateCommandV()
        }
    }

    private func simulateCommandV() {
        // Create proper event source
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else {
            print("Failed to create CGEventSource")
            return
        }

        // Create Command+V keydown event (V key = 9)
        guard let keyDownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 9, keyDown: true) else {
            print("Failed to create keydown event")
            return
        }
        keyDownEvent.flags = .maskCommand

        // Create Command+V keyup event
        guard let keyUpEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 9, keyDown: false) else {
            print("Failed to create keyup event")
            return
        }
        keyUpEvent.flags = .maskCommand

        // Post the events using proper tap location
        keyDownEvent.post(tap: .cgSessionEventTap)
        keyUpEvent.post(tap: .cgSessionEventTap)
    }
}

#Preview {
    let manager = ClipboardHistoryManager(userDefaults: UserDefaults(suiteName: "preview")!)
    let monitor = ClipboardMonitor()
    let settings = SettingsManager(userDefaults: UserDefaults(suiteName: "preview")!)

    let item1 = ClipboardItem(content: "Pinned item 1")
    let item2 = ClipboardItem(content: "Pinned item 2")
    let item3 = ClipboardItem(content: "Recent clipboard item")
    let item4 = ClipboardItem(content: "Another recent item")

    manager.addItem(item1)
    manager.addItem(item2)
    manager.addItem(item3)
    manager.addItem(item4)

    manager.togglePin(for: item1.id)
    manager.togglePin(for: item2.id)

    return FloatingWindowView(settings: settings, isVisible: .constant(true))
        .environmentObject(manager)
        .environmentObject(monitor)
}
