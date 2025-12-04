import SwiftUI
import ClipboardCore

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        TabView {
            GeneralSettingsView(settings: settings)
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            ExclusionsSettingsView(settings: settings)
                .tabItem {
                    Label("Exclusions", systemImage: "xmark.circle")
                }

            AdvancedSettingsView(settings: settings)
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Form {
            Section {
                LabeledContent("Max History Items") {
                    Stepper("\(settings.maxHistoryItems)", value: $settings.maxHistoryItems, in: 50...1000, step: 50)
                        .frame(width: 150)
                }

                LabeledContent("Polling Interval") {
                    Stepper(String(format: "%.1fs", settings.pollingInterval),
                           value: $settings.pollingInterval, in: 0.1...5.0, step: 0.1)
                        .frame(width: 150)
                }
            } header: {
                Text("Performance")
            }

            Section {
                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                Toggle("Show Menu Bar Icon", isOn: $settings.showMenuBarIcon)
                Toggle("Keep Rich Formats", isOn: $settings.keepRichFormats)
            } header: {
                Text("Behavior")
            }

            Section {
                Picker("Theme", selection: $settings.theme) {
                    Text("Light").tag(Theme.light)
                    Text("Dark").tag(Theme.dark)
                    Text("System").tag(Theme.system)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Appearance")
            }

            Spacer()

            HStack {
                Button("Reset to Defaults") {
                    settings.resetToDefaults()
                }

                Spacer()
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Exclusions Settings

struct ExclusionsSettingsView: View {
    @ObservedObject var settings: SettingsManager
    @State private var newAppName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Excluded Applications")
                .font(.headline)

            Text("Clipboard content from these apps will not be captured.")
                .font(.caption)
                .foregroundColor(.secondary)

            // Add new app
            HStack {
                TextField("App Name (e.g., 1Password)", text: $newAppName)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    if !newAppName.isEmpty {
                        settings.addExcludedApplication(newAppName)
                        newAppName = ""
                    }
                }
                .disabled(newAppName.isEmpty)
            }

            // List of excluded apps
            if settings.excludedApplications.isEmpty {
                Text("No excluded applications")
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                List {
                    ForEach(settings.excludedApplications, id: \.self) { app in
                        HStack {
                            Text(app)

                            Spacer()

                            Button(action: {
                                settings.removeExcludedApplication(app)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }

            if !settings.excludedApplications.isEmpty {
                Button("Clear All") {
                    settings.clearExcludedApplications()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
    }
}

// MARK: - Advanced Settings

struct AdvancedSettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Form {
            Section {
                Toggle("Encrypt Database", isOn: $settings.encryptDatabase)

                if settings.encryptDatabase {
                    Text("Database will be encrypted using AES-256-GCM with a key stored in the Keychain.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Security")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Global Hotkey")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("⌃⌘V (Control + Command + V)")
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(4)

                    Text("Custom hotkey configuration coming soon.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Hotkey")
            }

            Section {
                Button("Export Settings") {
                    exportSettings()
                }

                Button("Import Settings") {
                    importSettings()
                }
            } header: {
                Text("Backup")
            }

            Spacer()
        }
        .formStyle(.grouped)
        .padding()
    }

    private func exportSettings() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "carboclip-settings.json"
        panel.allowedContentTypes = [.json]

        if panel.runModal() == .OK, let url = panel.url {
            let settingsDict = settings.exportSettings()
            do {
                let data = try JSONSerialization.data(withJSONObject: settingsDict, options: .prettyPrinted)
                try data.write(to: url)
                print("✅ Settings exported to \(url.path)")
            } catch {
                print("❌ Failed to export settings: \(error)")
            }
        }
    }

    private func importSettings() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try Data(contentsOf: url)
                let settingsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let dict = settingsDict {
                    settings.importSettings(dict)
                    print("✅ Settings imported from \(url.path)")
                }
            } catch {
                print("❌ Failed to import settings: \(error)")
            }
        }
    }
}
