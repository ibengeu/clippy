# Carboclip

A lightweight, powerful clipboard history manager for macOS. Built with Swift and SwiftUI, Carboclip helps you access your clipboard history instantly with a global hotkey.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Tests](https://img.shields.io/badge/tests-156%20passing-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

## Features

### 🚀 Quick Access
- **Global Hotkey**: Press `⌃⌘V` (Control + Command + V) anywhere to open your clipboard history
- **Fullscreen Support**: Works seamlessly across all spaces and fullscreen apps
- **Smart Positioning**: Window appears in the top-right corner of your active screen
- **Click Outside to Dismiss**: Automatically hides when you click outside

### 📋 Clipboard Management
- **Rich Format Support**: Text, RTF, HTML, images, PDFs, URLs, files, and more
- **Original Formatting Preserved**: Copy formatted text, paste formatted text
- **Smart Detection**: Automatically detects and categorizes clipboard content
- **Up to 1000 Items**: Configurable history size (default: 300)

### 🔍 Search & Filter
- **Fuzzy Search**: Find anything with intelligent fuzzy matching
- **Filter by Type**: Quickly filter by text, images, URLs, code, etc.
- **Pin Favorites**: Keep important items at the top
- **No Duplicates**: Automatically prevents duplicate entries

### 🎨 User Interface
- **Compact Design**: 30% smaller than traditional clipboard managers
- **Menu Bar Icon**: Quick access from your menu bar
- **Dark Mode Support**: Automatically adapts to system appearance
- **Clean, Modern UI**: Built with attention to detail

### 🔒 Privacy & Security
- **Local Storage**: All data stays on your Mac
- **Exclude Apps**: Prevent specific apps from being monitored (e.g., password managers)
- **Optional Encryption**: Secure your clipboard history with AES-256-GCM

## Installation

### Download (Recommended)
Download the latest release from the [Releases](https://github.com/ibengeu/clippy/releases) page.

### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/ibengeu/clippy.git
cd clippy
```

2. Build the app bundle:
```bash
swift build -c release
mkdir -p Carboclip.app/Contents/{MacOS,Resources}
cp .build/arm64-apple-macosx/release/Carboclip Carboclip.app/Contents/MacOS/
cp Resources/Info.plist Carboclip.app/Contents/
cp Resources/AppIcon.icns Carboclip.app/Contents/Resources/
chmod +x Carboclip.app/Contents/MacOS/Carboclip
```

3. Run the app:
```bash
open Carboclip.app
```

## Usage

### Getting Started
1. Launch Carboclip - you'll see a 📋 icon in your menu bar
2. Grant Accessibility permissions when prompted (required for global hotkey)
3. Start copying! Your clipboard history is automatically tracked

### Keyboard Shortcuts
- `⌃⌘V` - Open clipboard history
- `Click` on any item - Copy to clipboard
- `Click outside` - Close window
- `ESC` - Close window

### Menu Bar Options
- **Show Clipboard History** - Open the history window
- **Monitoring: Active/Paused** - Toggle clipboard monitoring
- **Settings** - Configure preferences
- **Clear All History** - Delete all clipboard items
- **Quit Carboclip** - Exit the application

## Configuration

### Settings Window
Access via menu bar → **Settings** or `⌘,`

#### General
- **Max History Items**: 50-1000 items (default: 300)
- **Polling Interval**: 0.1-5.0 seconds (default: 0.3s)
- **Launch at Login**: Start automatically on login
- **Show Menu Bar Icon**: Toggle menu bar visibility
- **Keep Rich Formats**: Preserve formatting in clipboard items
- **Theme**: Light, Dark, or System

#### Exclusions
Exclude specific applications from clipboard monitoring:
```
1Password
Dashlane
LastPass
```

#### Advanced
- **Encrypt Database**: Enable AES-256-GCM encryption
- **Global Hotkey**: Currently `⌃⌘V` (customization coming soon)
- **Export/Import Settings**: Backup your preferences

## Architecture

Carboclip is built with a modular architecture using Swift Package Manager:

### Core Modules

**ClipboardCore** - Core functionality
- `ClipboardMonitor`: Monitors system clipboard with configurable polling
- `ClipboardStore`: Thread-safe storage with JSON persistence
- `SearchEngine`: Fuzzy search with Levenshtein distance algorithm
- `FilterManager`: Type, date, and length filtering
- `SettingsManager`: UserDefaults-backed preferences
- Models: `ClipboardItem`, `ClipboardItemType`

**Carboclip** - Main application
- `AppDelegate`: Application lifecycle and menu bar management
- `MainViewModel`: Coordinates all core components
- `ClipboardListView`: Main UI with search and filtering
- `SettingsView`: Preferences interface
- `GlobalHotkeyManager`: System-wide hotkey registration

**CarbonSwiftUI** - UI components
- Carbon Design System components (future expansion)

### Key Design Decisions

1. **Thread-Safe Storage**: Uses GCD with concurrent queue and barrier flags
2. **Duplicate Prevention**: Content comparison before adding to history
3. **Format Preservation**: Stores raw data alongside plain text
4. **Ignore Programmatic Copies**: Prevents re-capturing when selecting from history
5. **Memory Efficient**: Automatic limit enforcement with pinned item protection

## Development

### Requirements
- macOS 13.0+ (Ventura, Sonoma, Sequoia)
- Swift 5.9+
- Xcode 15.0+

### Build & Test

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter ClipboardCoreTests

# Build debug
swift build

# Build release
swift build -c release

# Run app
swift run
```

### Test Coverage

156 tests across all modules:
- ✅ ClipboardItem: 19 tests
- ✅ ClipboardMonitor: 17 tests
- ✅ SearchEngine: 22 tests
- ✅ FilterManager: 31 tests
- ✅ ClipboardStore: 27 tests
- ✅ SettingsManager: 26 tests
- ✅ MainViewModel: 7 tests
- ✅ AppDelegate: 6 tests

### Contributing

Contributions are welcome! This project was built with Test-Driven Development (TDD).

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Implement your feature
5. Ensure all tests pass (`swift test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Troubleshooting

### Menu bar icon not visible
- Check if the menu bar is crowded - try hiding other icons
- Restart Carboclip
- Check System Settings → Control Center → Menu Bar Only

### Global hotkey not working
1. Open System Settings → Privacy & Security → Accessibility
2. Ensure Carboclip is listed and enabled
3. If not, click the `+` button and add Carboclip
4. Restart Carboclip

### Window doesn't appear in fullscreen apps
- Ensure Accessibility permissions are granted
- The window should appear with `.popUpMenu` level for fullscreen support
- Try quitting and relaunching Carboclip

### Clipboard monitoring stopped
- Check menu bar → "Monitoring: Active" status
- If paused, click to resume monitoring
- Verify excluded applications list doesn't include current app

## Technical Details

### Supported Clipboard Types
- **Text**: Plain text, rich text (RTF), HTML
- **Images**: PNG, JPEG, TIFF
- **Files**: File paths and URLs
- **URLs**: Web links
- **Code**: Syntax-highlighted code snippets
- **PDFs**: PDF documents
- **Colors**: Color values
- **Custom**: Other clipboard types

### Storage Location
```
~/Library/Application Support/com.carboclip.app/clipboard_history.json
```

### Permissions Required
- **Accessibility**: For global hotkey registration
- **Files**: For clipboard data storage (automatically granted)

## Roadmap

- [ ] Customizable global hotkey
- [ ] Snippets and templates
- [ ] Sync across devices (iCloud)
- [ ] Clipboard transformations (case conversion, formatting)
- [ ] Quick actions (URL preview, QR codes)
- [ ] App-specific clipboard profiles
- [ ] Sparkle auto-updates
- [ ] Mac App Store distribution

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Swift and SwiftUI
- Icons from SF Symbols
- Inspired by clipboard managers like Paste, CopyClip, and Maccy

---

**Note**: Carboclip is a menu bar application and won't appear in the Dock. Look for the 📋 icon in your menu bar after launching.

For detailed usage instructions, see [USAGE.md](USAGE.md).
