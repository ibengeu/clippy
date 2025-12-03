import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var historyManager: ClipboardHistoryManager
    @EnvironmentObject private var monitor: ClipboardMonitor
    @StateObject private var menuState = MenuBarState()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with app name
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(.swiftClipPrimary)
                Text("SwiftClip")
                    .swiftClipBodyMedium()
                    .foregroundColor(.swiftClipPrimary)
                Spacer()
                if monitor.isMonitoring {
                    Circle()
                        .fill(Color.swiftClipAccent)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.swiftClipPrimary.opacity(0.05))

            Divider()

            // Main menu options
            VStack(spacing: 2) {
                Button(action: { openMainWindow() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.on.rectangle")
                            .foregroundColor(.swiftClipPrimary)
                            .frame(width: 20)
                        Text("Show Clipboard")
                            .swiftClipBody()
                        Spacer()
                        Text("⌥V")
                            .swiftClipCaption()
                            .foregroundColor(.swiftClipTextSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 32)

                // Pinned Items Submenu
                let pinnedItems = historyManager.items.filter { $0.isPinned }
                if !pinnedItems.isEmpty {
                    Menu {
                        ForEach(pinnedItems.prefix(5)) { item in
                            Button(action: {
                                copyToClipboard(item.content)
                            }) {
                                Text(item.content.prefix(40))
                                    .lineLimit(1)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.swiftClipAccent)
                                .frame(width: 20)
                            Text("Pinned Items")
                                .swiftClipBody()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .swiftClipCaption()
                                .foregroundColor(.swiftClipTextSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 32)
                }

                // Clear History
                Button(action: {
                    menuState.showClearConfirmation()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 20)
                        Text("Clear History")
                            .swiftClipBody()
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .alert("Clear Clipboard History?", isPresented: $menuState.isShowingClearConfirmation) {
                    Button("Cancel", role: .cancel) {
                        menuState.dismissClearConfirmation()
                    }
                    Button("Clear", role: .destructive) {
                        historyManager.clearHistory()
                        menuState.dismissClearConfirmation()
                    }
                } message: {
                    Text("This will delete all clipboard items. Pinned items will also be removed.")
                }

                Divider()

                // Privacy Settings
                Button(action: { openSettingsWindow(tab: "Privacy") }) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised.shield")
                            .foregroundColor(.swiftClipPrimary)
                            .frame(width: 20)
                        Text("Privacy Settings...")
                            .swiftClipBody()
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Preferences
                Button(action: { openSettingsWindow() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                            .foregroundColor(.swiftClipPrimary)
                            .frame(width: 20)
                        Text("Preferences...")
                            .swiftClipBody()
                        Spacer()
                        Text("⌘,")
                            .swiftClipCaption()
                            .foregroundColor(.swiftClipTextSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider()

                // Quit SwiftClip
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "power")
                            .foregroundColor(.swiftClipTextSecondary)
                            .frame(width: 20)
                        Text("Quit SwiftClip")
                            .swiftClipBody()
                        Spacer()
                        Text("⌘Q")
                            .swiftClipCaption()
                            .foregroundColor(.swiftClipTextSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 260)
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func openMainWindow() {
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func openSettingsWindow(tab: String? = nil) {
        // Find and show the settings window
        if let settingsWindow = NSApplication.shared.windows.first(where: { $0.title == "SwiftClip Settings" }) {
            settingsWindow.makeKeyAndOrderFront(nil)
        } else {
            // If window doesn't exist yet, open it
            NSApplication.shared.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        NSApp.activate(ignoringOtherApps: true)

        // Note: Tab selection would require passing state to SettingsView
        // For now, opens to General tab
    }
}

#Preview {
    let manager = ClipboardHistoryManager(userDefaults: UserDefaults(suiteName: "preview")!)
    let monitor = ClipboardMonitor()

    manager.addItem(ClipboardItem(content: "Item 1"))
    manager.addItem(ClipboardItem(content: "Item 2"))

    return MenuBarView()
        .environmentObject(manager)
        .environmentObject(monitor)
}
