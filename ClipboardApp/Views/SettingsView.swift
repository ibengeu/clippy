import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        TabView {
            GeneralSettingsTab(settings: settings)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)

            AppearanceSettingsTab(settings: settings)
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .tag(1)
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings Tab

struct GeneralSettingsTab: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Max History Size
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Maximum History Size:")
                                .swiftClipBody()
                            Spacer()
                            Text("\(settings.maxHistorySize)")
                                .swiftClipBody()
                                .foregroundColor(.swiftClipTextSecondary)
                        }
                        Slider(value: Binding(
                            get: { Double(settings.maxHistorySize) },
                            set: { settings.maxHistorySize = Int($0) }
                        ), in: 50...500, step: 10)
                        .tint(.swiftClipPrimary)

                        Text("Number of clipboard items to keep in history")
                            .swiftClipCaption()
                            .foregroundColor(.swiftClipTextSecondary)
                    }
                    .padding(.vertical, 8)

                    Divider()

                    // Auto-Hide Timeout
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Auto-Hide Timeout:")
                                .swiftClipBody()
                            Spacer()
                            Text(String(format: "%.1f seconds", settings.autoHideTimeout))
                                .swiftClipBody()
                                .foregroundColor(.swiftClipTextSecondary)
                        }
                        Slider(value: $settings.autoHideTimeout, in: 3...30, step: 1)
                            .tint(.swiftClipPrimary)

                        Text("Seconds before the window automatically hides")
                            .swiftClipCaption()
                            .foregroundColor(.swiftClipTextSecondary)
                    }
                    .padding(.vertical, 8)
                }
                .padding()
            }

            Spacer()

            // Reset to Defaults Button
            HStack {
                Spacer()
                Button(action: {
                    settings.resetToDefaults()
                }) {
                    Text("Reset to Defaults")
                        .swiftClipBody()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .formStyle(.grouped)
    }
}

// MARK: - Appearance Settings Tab

struct AppearanceSettingsTab: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Window Position
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Window Position:")
                            .swiftClipBody()

                        Picker("", selection: $settings.windowPosition) {
                            ForEach(WindowPosition.allCases, id: \.self) { position in
                                Text(position.displayName)
                                    .tag(position)
                            }
                        }
                        .pickerStyle(.radioGroup)
                        .tint(.swiftClipPrimary)

                        Text("Where the clipboard window appears on screen")
                            .swiftClipCaption()
                            .foregroundColor(.swiftClipTextSecondary)
                    }
                    .padding(.vertical, 8)
                }
                .padding()
            }

            Spacer()
        }
        .formStyle(.grouped)
    }
}

// MARK: - Preview

#Preview {
    let settings = SettingsManager(userDefaults: UserDefaults(suiteName: "preview")!)
    return SettingsView(settings: settings)
}
