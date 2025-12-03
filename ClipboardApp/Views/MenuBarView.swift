import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var historyManager: ClipboardHistoryManager
    @EnvironmentObject private var monitor: ClipboardMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Items")
                    .font(.headline)
                Spacer()
                if monitor.isMonitoring {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 4)

            Divider()

            if historyManager.items.isEmpty {
                Text("No items")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(historyManager.items.prefix(10)) { item in
                            Button(action: {
                                copyToClipboard(item.content)
                            }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.content.prefix(50))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                    Text(item.timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .help("Click to copy")

                            if item.id != historyManager.items.prefix(10).last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 300)
            }

            Divider()

            VStack(spacing: 4) {
                Button(action: { openMainWindow() }) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Open Full Window")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: { openSettingsWindow() }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings...")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()

                Button(action: {
                    monitor.isMonitoring ? monitor.stopMonitoring() : monitor.startMonitoring()
                }) {
                    HStack {
                        Image(systemName: monitor.isMonitoring ? "pause.circle" : "play.circle")
                        Text(monitor.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: {
                    historyManager.clearHistory()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear History")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.red)
                }
            }
            .font(.caption)
        }
        .padding()
        .frame(width: 280)
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

    private func openSettingsWindow() {
        // Find and show the settings window
        if let settingsWindow = NSApplication.shared.windows.first(where: { $0.title == "SwiftClip Settings" }) {
            settingsWindow.makeKeyAndOrderFront(nil)
        } else {
            // If window doesn't exist yet, open it
            NSApplication.shared.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        NSApp.activate(ignoringOtherApps: true)
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
