# Carboclip

A macOS-only clipboard history manager built with Swift and SwiftUI, featuring IBM Carbon Design System v11.

## Features

- Global hotkey access (⌃⌘V)
- Rich clipboard history with previews
- Search and filtering
- Pin favorites
- Encryption support
- Carbon Design System UI

## Requirements

- macOS 13.0+ (Ventura, Sonoma, Sequoia)
- Swift 5.9+
- Xcode 15.0+

## Development

Built with Test-Driven Development (TDD) using Swift Package Manager.

### Build

```bash
swift build
```

### Test

```bash
swift test
```

### Run

```bash
swift run
```

## Architecture

- **ClipboardCore**: Core clipboard monitoring, storage, and management
- **CarbonSwiftUI**: Carbon Design System components in SwiftUI
- **Carboclip**: Main application

## License

TBD
