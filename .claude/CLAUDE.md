# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Carboclip is a macOS clipboard history manager built with Swift 5.9+, SwiftUI, and AppKit. The project follows strict Test-Driven Development (TDD) practices with 156 passing tests.

**Key Philosophy**: Write tests first, then implementation. All new features and bug fixes must include tests.

## Development Commands

### Building & Running
```bash
# Build debug
swift build

# Build release (for distribution)
swift build -c release

# Run the app (debug mode)
swift run

# Build and update app bundle
swift build -c release
cp .build/arm64-apple-macosx/release/Carboclip Carboclip.app/Contents/MacOS/
chmod +x Carboclip.app/Contents/MacOS/Carboclip
open Carboclip.app
```

### Testing (TDD Required)
```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter ClipboardCoreTests
swift test --filter CarboclipTests
swift test --filter MainViewModelTests

# Run single test
swift test --filter testCopyToPasteboardPreservesOriginalData

# Test with coverage
swift test --enable-code-coverage
```

### Git Workflow
```bash
# Stage and commit with descriptive message
git add .
git commit -m "feat: description"  # or fix:, docs:, test:, refactor:

# Push to remote
git push origin master
```

## Architecture

### Module Structure

**ClipboardCore** (Pure Swift, no UI dependencies)
- `Models/`: ClipboardItem, ClipboardItemType
- `Monitor/`: ClipboardMonitor - polls NSPasteboard every 300ms
- `Store/`: ClipboardStore - thread-safe storage with GCD barriers
- `Search/`: SearchEngine - fuzzy matching with Levenshtein distance
- `Filter/`: FilterManager - type, date, length filtering
- `Settings/`: SettingsManager - UserDefaults wrapper

**Carboclip** (Main app)
- `main.swift`: NSApplication entry point
- `AppDelegate.swift`: Lifecycle, menu bar (NSStatusItem), window management
- `ViewModels/MainViewModel.swift`: Coordinates ClipboardCore components
- `Views/ClipboardListView.swift`: Main UI (search, filters, item list)
- `Views/SettingsView.swift`: Preferences panel (3 tabs)
- `Utilities/GlobalHotkeyManager.swift`: Carbon Event Manager wrapper

**CarbonSwiftUI** (UI components)
- Future: Carbon Design System components

### Key Design Patterns

1. **Thread-Safe Storage**: ClipboardStore uses GCD concurrent queue with barrier flags
   ```swift
   queue.async(flags: .barrier) { /* write */ }
   queue.sync { /* read */ }
   ```

2. **Duplicate Prevention**: Monitor checks `hasSameContent()` before adding items

3. **Format Preservation**: Items store both plain text (`content`) and original data (`rawData`)
   - RTF/HTML items: `content` = plain text, `rawData` = original format
   - When copying back: restore `rawData` with correct pasteboard type

4. **Ignore Programmatic Copies**: `monitor.ignoreNextChange()` called before `copyToPasteboard()`
   - Prevents re-capturing when user selects from history

5. **Window Management**:
   - `.popUpMenu` level: appears over fullscreen apps
   - `.canJoinAllSpaces` + `.fullScreenAuxiliary`: follows user across spaces
   - `hidesOnDeactivate = true`: click outside to dismiss
   - Repositioned on `showWindow()`: tracks active screen via mouse location

### Data Flow

```
User copies text
    ↓
NSPasteboard changeCount increases
    ↓
ClipboardMonitor.checkForChanges() (every 300ms)
    ↓
extractClipboardItem() - detects type, stores rawData
    ↓
onClipboardChange callback
    ↓
MainViewModel.handleNewClipboardItem()
    ↓
ClipboardStore.add() - thread-safe with barrier
    ↓
applyFiltersAndSearch() - update UI
```

### Critical Files

- `Sources/ClipboardCore/Monitor/ClipboardMonitor.swift:117-138` - Format preservation for RTF/HTML
- `Sources/Carboclip/ViewModels/MainViewModel.swift:136-167` - Copy with format restoration
- `Sources/Carboclip/AppDelegate.swift:110-163` - Window config and positioning
- `Sources/ClipboardCore/Store/ClipboardStore.swift` - Thread-safe operations

## TDD Workflow

**ALWAYS follow this pattern:**

1. Write failing test first
2. Run test to confirm failure
3. Implement minimal code to pass
4. Run test to confirm pass
5. Refactor if needed
6. Commit

Example:
```bash
# 1. Write test in Tests/ClipboardCoreTests/
# 2. Run and verify failure
swift test --filter YourNewTest

# 3. Implement feature
# 4. Run and verify pass
swift test --filter YourNewTest

# 5. Run all tests
swift test

# 6. Commit
git add . && git commit -m "feat: add feature with tests"
```

## Important Constraints

### macOS Version Support
- **Minimum**: macOS 13.0 (Ventura)
- **Target**: Ventura, Sonoma, Sequoia
- **Avoid**: SwiftData (@Model), @Observable macro (requires macOS 14+)
- **Use**: Codable, ObservableObject with @Published

### Performance Requirements
- Search latency: < 80ms for instant results
- Monitor latency: ~300ms (polling interval)
- Storage operations: < 5ms
- All requirements currently met

### Global Hotkey Implementation
- Uses Carbon Event Manager (not MASShortcut)
- Default: ⌃⌘V (Control + Command + V)
- Requires Accessibility permissions
- Implemented in `GlobalHotkeyManager.swift`

## Common Development Tasks

### Adding a New ClipboardItemType

1. Add enum case to `ClipboardItemType.swift`
2. Update `displayName` computed property
3. Add detection logic to `ClipboardMonitor.extractClipboardItem()`
4. Add icon mapping in `ClipboardItemRow.iconName`
5. Write tests in `ClipboardItemTests.swift`

### Modifying Window Behavior

Window configuration is in `AppDelegate.createWindow()`:
- Size: 420x350 (30% smaller than original 600x500)
- Position: Top-right corner with 20px padding
- Level: `.popUpMenu` for fullscreen support
- Behavior: `hidesOnDeactivate`, `.canJoinAllSpaces`, `.fullScreenAuxiliary`

### Clipboard Format Handling

When adding support for new formats:
1. Detect in `ClipboardMonitor.extractClipboardItem()`
2. Store `rawData` with plain text `content`
3. Restore in `MainViewModel.copyToPasteboard()` with correct `NSPasteboard.PasteboardType`

## Troubleshooting

### Tests Failing
- Check if using SwiftData or @Observable (not compatible with macOS 13)
- Verify @MainActor isolation for UI tests
- Ensure ClipboardItemType uses `.text` not `.string`

### App Not Running
```bash
# Kill existing processes
pkill -f Carboclip

# Check for running instances
ps aux | grep Carboclip

# Rebuild app bundle
swift build -c release
cp .build/arm64-apple-macosx/release/Carboclip Carboclip.app/Contents/MacOS/
chmod +x Carboclip.app/Contents/MacOS/Carboclip
```

### Menu Bar Icon Not Visible
- Icon is 📋 emoji set in `AppDelegate.setupMenuBar()`
- Uses `button.title = "📋"` (not SF Symbol)
- Check menu bar isn't crowded

### Hotkey Not Working
- Requires Accessibility permissions in System Settings
- Registered in `AppDelegate.registerGlobalHotkey()`
- Uses Carbon Event Manager (macOS 13+ compatible)

## Project Standards

- **Language**: Swift 5.9+
- **Minimum OS**: macOS 13.0
- **Test Coverage**: 156 tests, all must pass before commit
- **Development Style**: TDD only - tests before implementation
- **Architecture**: Modular with clear separation (Core, UI, App)
- **Thread Safety**: Required for ClipboardStore operations
- **Performance**: All operations must meet documented requirements
