# Carboclip - Usage Guide

## 🎉 Your Clipboard Manager is Running!

Carboclip is now running as a **menu bar app** on your Mac.

## How to Use

### 1. Check the Menu Bar
Look for the **📋 clipboard icon** in your Mac's menu bar (top-right corner).

### 2. View Clipboard History
Click the menu bar icon and select "Show Clipboard History" to see all your copied items.

### 3. Copy Something
Copy any text, image, or file - Carboclip will automatically capture it!

### 4. Search & Filter
- **Search**: Type in the search box to find items
- **Filter by Type**: Click type badges to filter by text, code, images, etc.

### 5. Use Items
- **Click an item** to copy it back to your clipboard
- **Pin important items** using the pin icon
- **Delete items** using the trash icon

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Click menu bar icon | Show clipboard history |
| ESC | Close window |
| ⌘Q | Quit Carboclip |

**Note**: Global hotkey (⌃⌘V) will be available in the next update with proper system permissions.

## Features Working Now

✅ **Real-time Clipboard Monitoring** - Captures everything you copy
✅ **Rich Content Support** - Text, images, URLs, files, HTML, RTF, code, colors
✅ **Search** - Instant fuzzy search across all items
✅ **Pin Favorites** - Keep important items at the top
✅ **Type Filtering** - Filter by content type
✅ **Persistent Storage** - History saved between sessions
✅ **Source App Tracking** - See which app content came from
✅ **Menu Bar Integration** - Unobtrusive menu bar app

## Menu Bar Options

**Show Clipboard History** - Opens the main window
**Monitoring: Active/Paused** - Toggle clipboard monitoring
**Clear All History** - Delete all items (with confirmation)
**Quit Carboclip** - Exit the application

## Stored Data Location

Clipboard history is saved to:
```
~/Library/Application Support/Carboclip/clipboard_history.json
```

## Performance

- Monitors clipboard every **300ms**
- Stores up to **300 items** by default
- Search results in **< 6ms** (1000 items)
- Filter results in **< 1ms** (1000 items)

## Testing the App

###Try these actions:

1. **Copy some text**
   ```bash
   echo "Hello from Carboclip!" | pbcopy
   ```

2. **Click the menu bar icon** → "Show Clipboard History"

3. **Search for "Hello"** in the search box

4. **Click an item** to copy it back

5. **Pin an item** by hovering and clicking the pin icon

6. **Try copying different types**:
   - Text from any app
   - Code from your editor
   - URLs from browsers
   - File paths from Finder
   - Images (screenshot: ⇧⌘4)

## Troubleshooting

### Menu bar icon not appearing?
- Check if the app is running: `ps aux | grep Carboclip`
- Restart the app: Kill and run again

### Items not being captured?
- Check monitoring status in menu (should say "Monitoring: Active")
- Try toggling monitoring off and on

### Window won't show?
- Click the menu bar icon
- If using Dock, try removing other menu bar apps temporarily

## Stop the App

```bash
# Find the process
ps aux | grep Carboclip

# Kill it
pkill Carboclip

# Or use the menu
Click menu bar icon → Quit Carboclip
```

## Run from Command Line

```bash
cd /Users/macbook/Code/clippy

# Build
swift build

# Run
.build/debug/Carboclip

# Or in one command
swift run
```

## Next Steps

The core features are working! Future enhancements:
- Global hotkey with system permissions
- Encryption for sensitive data
- Syntax highlighting for code
- HTML preview
- More Carbon Design System styling
- Settings panel
- Launch at login option

## Need Help?

Check `PROJECT_STATUS.md` for technical details and architecture.

---

**Enjoy your new clipboard manager!** 📋✨
