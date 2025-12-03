# SwiftClip Comprehensive Implementation Plan

## Overview
Transform the current clipboard manager into SwiftClip following the complete design blueprint with brand identity, visual polish, enhanced features, and privacy controls.

---

## Phase 1: Brand Identity & Visual System

### 1.1 Color System Implementation
**Test Files**: `ColorSystemTests.swift`
**Source Files**: `ColorSystem.swift`

Create SwiftUI Color extension with brand palette:
- Primary: Electric Blue (#2979FF)
- Secondary: Vibrant Teal (#00BFA5)
- Background Light: Off-White (#F7F7F8)
- Background Dark: Charcoal (#1C1C1E)
- Text Primary: Dark Grey (#1A1A1A)
- Text Secondary: Medium Grey (#6E6E6E)

**Implementation:**
- Define Color extensions for hex support
- Create semantic color names (`.swiftClipPrimary`, `.swiftClipAccent`)
- Support light/dark mode adaptation
- Update existing views to use new color system

### 1.2 Typography System
**Test Files**: `TypographyTests.swift`
**Source Files**: `TypographySystem.swift`

Define consistent typography scale:
- Use SF Pro Display (system default)
- Define font modifiers (`.swiftClipTitle`, `.swiftClipBody`, `.swiftClipCaption`)
- Weight variations (Regular, Medium, Bold)
- Size scale (14-18pt body, 20-28pt headers)

### 1.3 Branding Updates
**Files to Update**:
- `OnboardingView.swift` - Update app name to "SwiftClip", add tagline
- `FloatingWindowView.swift` - Update window title
- `Info.plist` - Update app name
- Add app icon assets (clipboard + lightning bolt)

---

## Phase 2: Enhanced Data Model for New Features

### 2.1 Extended ClipboardItem Model
**Test Files**: `ClipboardItemEnhancedTests.swift`
**Source Files**: `ClipboardItem.swift`

Add new properties:
```swift
struct ClipboardItem {
    // Existing: id, content, timestamp, isFavorite, category
    var isPinned: Bool = false           // Pinning separate from favorites
    var contentType: ContentType         // .text, .image, .file, .richText
    var isSensitive: Bool = false        // Privacy flag
    var sourceApp: String?               // App where copied from
    var accessCount: Int = 0             // Track paste frequency
    var lastAccessedDate: Date?          // Track recency
}

enum ContentType: String, Codable {
    case text, image, file, richText
}
```

**Tests:**
- Test new property initialization
- Test Codable compatibility (backward compatible with old data)
- Test pinned vs favorite distinction

### 2.2 Enhanced ClipboardHistoryManager
**Test Files**: `ClipboardHistoryManagerEnhancedTests.swift`
**Source Files**: `ClipboardHistoryManager.swift`

Add new methods:
```swift
// Pinning
func togglePin(for id: UUID)
func getPinnedItems() -> [ClipboardItem]

// Sorting
func sortByRecency() -> [ClipboardItem]
func sortByFrequency() -> [ClipboardItem]

// Privacy
func markAsSensitive(for id: UUID)
func getRedactedContent(for item: ClipboardItem) -> String

// Metadata
func incrementAccessCount(for id: UUID)
func updateLastAccessed(for id: UUID)
```

**Tests:**
- Test pin/unpin operations
- Test sorting algorithms
- Test access count increments
- Test sensitive content redaction

---

## Phase 3: Pinned Items Feature

### 3.1 UI for Pinned Section
**Test Files**: `PinnedItemsSectionTests.swift`
**Source Files**: `FloatingWindowView.swift`

Update FloatingWindowView layout:
```
+----------------------------------+
| SwiftClip                    [×] |
+----------------------------------+
| 📌 PINNED                        |
| [Pinned Item 1]                  |
| [Pinned Item 2]                  |
+----------------------------------+  <- Divider with teal accent
| RECENT                           |
| [Recent Item 1]                  |
| [Recent Item 2]                  |
| ...                              |
+----------------------------------+
```

**Implementation:**
- Separate pinned items at top
- Visual distinction: teal accent color, pin icon
- Limit pinned items to 5 max
- Hover actions: pin/unpin button
- Animate when item is pinned (bounce to top)

**Tests:**
- Test pinned items appear at top
- Test max 5 pinned items enforcement
- Test pin/unpin toggle updates UI
- Test empty pinned section hidden when no pins

---

## Phase 4: Search Functionality

### 4.1 Search Bar UI
**Test Files**: `SearchBarTests.swift`
**Source Files**: `FloatingWindowView.swift`, `SearchBar.swift`

Add search bar below header:
```
+----------------------------------+
| SwiftClip                    [×] |
| [🔍 Search clipboard...]         |  <- New search bar
+----------------------------------+
```

**Implementation:**
- TextField with search icon
- Instant filtering as user types
- Clear button (× icon) when text present
- Keyboard shortcut: ⌘F to focus search
- Highlight matching text in results

**Tests:**
- Test search filters items correctly
- Test case-insensitive search
- Test clear button resets filter
- Test keyboard shortcut focuses field

### 4.2 Search Result Highlighting
**Source Files**: `HighlightedText.swift`

Create reusable component for highlighting search matches:
- Use AttributedString or custom Text view
- Highlight matches with yellow background

---

## Phase 5: Keyboard Navigation

### 5.1 Arrow Key Navigation
**Test Files**: `KeyboardNavigationTests.swift`
**Source Files**: `FloatingWindowView.swift`, `KeyboardNavigationManager.swift`

Implement keyboard controls:
- **↑/↓**: Navigate through items
- **Enter**: Paste selected item
- **⌘↑/⌘↓**: Move between pinned/recent sections
- **⌘P**: Toggle pin on selected item
- **⌘⇧V**: Paste as plain text
- **Escape**: Close window
- **Delete**: Remove selected item

**Implementation:**
- Track selected item index with @State
- Add `.onKeyPress()` modifier (macOS 14+) or CGEvent monitoring
- Visual selection indicator (blue highlight)
- Handle focus management

**Tests:**
- Test arrow keys change selection
- Test Enter pastes selected item
- Test keyboard shortcuts trigger actions
- Test selection wraps at list boundaries

### 5.2 Visual Selection Indicator
**Source Files**: `FloatingWindowView.swift`

Add visual feedback for keyboard selection:
- Blue border/background for selected item
- Ensure selected item scrolls into view
- Distinct from hover state

---

## Phase 6: Cursor-Proximal Window Positioning

### 6.1 Mouse Cursor Detection
**Test Files**: `CursorProximalPositioningTests.swift`
**Source Files**: `FloatingWindowManager.swift`

Replace bottom-right positioning with cursor-aware positioning:

**Implementation:**
```swift
// Get mouse cursor position
let mouseLocation = NSEvent.mouseLocation

// Position window near cursor
// - Offset by 20px to avoid covering cursor
// - Keep within screen bounds
// - Prefer bottom-right of cursor
let windowOrigin = calculateProximalPosition(
    cursorLocation: mouseLocation,
    windowSize: NSSize(width: 350, height: 280),
    screenBounds: screen.visibleFrame
)
```

**Algorithm:**
1. Get cursor position
2. Try bottom-right (+20px offset)
3. If outside screen, try bottom-left
4. If still outside, try top-right
5. Final fallback: center of screen

**Tests:**
- Test window appears near cursor
- Test window stays within screen bounds
- Test multi-monitor support
- Test fallback positioning

---

## Phase 7: Animations & Transitions

### 7.1 Window Appearance Animation
**Test Files**: `WindowAnimationTests.swift`
**Source Files**: `FloatingWindowView.swift`, `FloatingWindowManager.swift`

Add smooth fade + slide animation:
```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.95).combined(with: .opacity),
    removal: .opacity
))
.animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
```

**Animations:**
- **Window appear**: Fade in + scale up (0.95 → 1.0) over 0.2s
- **Window disappear**: Fade out over 0.15s
- **Pin item**: Bounce animation, move to top with spring
- **Hover effects**: Scale up 1.02x with subtle shadow increase
- **Selection**: Smooth color transition 0.2s

### 7.2 Item Interaction Animations
**Source Files**: `ClipboardItemRow.swift` (new component)

Add micro-interactions:
- Hover: Scale 1.02x, shadow increase
- Click: Scale down 0.98x momentarily
- Pin: Bounce animation, teal flash
- Delete: Fade out + slide left

**Tests:**
- Test animations don't crash
- Test animation timing matches spec
- Test animations can be disabled for accessibility

---

## Phase 8: Privacy Features

### 8.1 Sensitive App Detection
**Test Files**: `SensitiveAppDetectionTests.swift`
**Source Files**: `SensitiveAppManager.swift`

Detect when user copies from sensitive apps:
- Password managers (1Password, Bitwarden, Dashlane)
- Banking apps
- Terminal (when certain commands present)
- User-configurable exclusion list

**Implementation:**
```swift
class SensitiveAppManager {
    static let defaultSensitiveApps = [
        "com.agilebits.onepassword7",
        "com.bitwarden.desktop",
        // ... more bundle IDs
    ]

    func isCurrentAppSensitive() -> Bool
    func shouldRedactContent(from app: String) -> Bool
    func getUserExcludedApps() -> [String]
    func addExcludedApp(_ bundleId: String)
}
```

### 8.2 Content Redaction
**Test Files**: `ContentRedactionTests.swift`
**Source Files**: `ClipboardHistoryManager.swift`

When content is sensitive:
- Display as "••••••••" (8 dots) in UI
- Store actual content encrypted/hashed
- Require confirmation to view/paste
- Option to exclude from history entirely

**Tests:**
- Test sensitive content shows as dots
- Test redacted content still pasteable
- Test user can reveal with click
- Test exclusion prevents storage

### 8.3 Privacy Settings UI
**Test Files**: `PrivacySettingsTests.swift`
**Source Files**: `PrivacySettingsView.swift` (new), `SettingsView.swift` (new)

Add settings panel accessible from menu bar:
- Toggle: Auto-detect sensitive apps
- List: Excluded apps (add/remove)
- Toggle: Redact sensitive content vs exclude entirely
- Clear history button

---

## Phase 9: Plain Text Paste Option

### 9.1 Paste Mode Selection
**Test Files**: `PasteModeTests.swift`
**Source Files**: `FloatingWindowView.swift`

Add paste options on item hover/selection:
- **Default**: Paste with formatting (⏎)
- **Plain text**: Paste as plain text (⌘⇧⏎)
- Visual indicators: Two buttons or modifier key detection

**Implementation:**
```swift
private func pasteItem(_ item: ClipboardItem, asPlainText: Bool) {
    if asPlainText {
        // Strip formatting, paste as .string only
        let plainText = stripFormatting(item.content)
        copyAndPaste(plainText)
    } else {
        // Paste with original formatting
        copyAndPaste(item.content)
    }
}
```

**Tests:**
- Test plain text strips formatting
- Test keyboard shortcut triggers plain paste
- Test button UI shows correct state

---

## Phase 10: Image & File Support

### 10.1 Content Type Detection
**Test Files**: `ContentTypeDetectionTests.swift`
**Source Files**: `ClipboardMonitor.swift`

Enhance clipboard monitoring to detect:
- Images: `.tiff`, `.png`, `.jpeg`
- Files: `.fileURL`
- Rich text: `.rtf`, `.html`

**Implementation:**
```swift
func detectContentType() -> ContentType {
    let pasteboard = NSPasteboard.general

    if pasteboard.types?.contains(.png) == true ||
       pasteboard.types?.contains(.tiff) == true {
        return .image
    } else if pasteboard.types?.contains(.fileURL) == true {
        return .file
    } else if pasteboard.types?.contains(.rtf) == true {
        return .richText
    }
    return .text
}
```

### 10.2 Multi-Type Item Display
**Test Files**: `MultiTypeDisplayTests.swift`
**Source Files**: `ClipboardItemRow.swift`, `ImageThumbnailView.swift`

Update UI to show different content types:
- **Text**: Show preview (current behavior)
- **Image**: Show thumbnail (100x100px max)
- **File**: Show file icon + name
- **Rich text**: Show formatted preview

**Tests:**
- Test image thumbnail generation
- Test file icon display
- Test content type icon badges

---

## Phase 11: Enhanced Onboarding

### 11.1 Multi-Step Onboarding Flow
**Test Files**: `EnhancedOnboardingTests.swift`
**Source Files**: `OnboardingView.swift`

Update onboarding to match blueprint (5 steps):

**Step 1: Welcome**
- SwiftClip logo (clipboard + lightning)
- Tagline: "Your clipboard, smarter and faster."
- "Get Started" CTA

**Step 2: Permissions**
- Accessibility permission explanation
- "Open System Settings" button
- Auto-detect when granted

**Step 3: Shortcut Setup**
- Default: Option+V
- Conflict detection
- Custom shortcut picker

**Step 4: Privacy Settings**
- Toggle: Auto-detect sensitive apps
- Quick exclusion list setup
- Redaction options

**Step 5: Quick Tips**
- Pin items tutorial
- Plain text paste tip
- Search instantly tip
- "Start Using SwiftClip" button

**Implementation:**
- Use TabView for swipable steps
- Progress indicator (1/5, 2/5, etc.)
- Skip/Back/Next navigation
- Save preferences on completion

**Tests:**
- Test navigation between steps
- Test preferences save correctly
- Test can skip optional steps
- Test completion closes onboarding

### 11.2 Shortcut Conflict Detection
**Test Files**: `ShortcutConflictTests.swift`
**Source Files**: `ShortcutConflictDetector.swift`

Check for system/app conflicts:
- Detect macOS system shortcuts
- Warn user if conflict exists
- Suggest alternatives

---

## Phase 12: Menu Bar Integration

### 12.1 Menu Bar Icon & Menu
**Test Files**: `MenuBarTests.swift`
**Source Files**: `MenuBarView.swift`

Update menu bar with:
- SwiftClip icon (minimal clipboard)
- Menu items:
  - Show Clipboard (Option+V)
  - ──────────
  - Pinned Items → (submenu)
  - Clear History
  - ──────────
  - Privacy Settings...
  - Preferences...
  - ──────────
  - Quit SwiftClip

**Implementation:**
- Use MenuBarExtra in SwiftUI
- Update MenuBarView with new structure
- Add keyboard shortcuts to menu items

---

## Phase 13: Settings Panel

### 13.1 Settings Window
**Test Files**: `SettingsViewTests.swift`
**Source Files**: `SettingsView.swift` (new)

Create comprehensive settings panel:

**General Tab:**
- Launch at login toggle
- Max history size (50-500 items)
- Auto-hide timeout (3-30 seconds)

**Appearance Tab:**
- Theme: System/Light/Dark
- Window position: Cursor/Bottom-Right/Center
- Font size adjustment

**Keyboard Tab:**
- Shortcut customization
- Keyboard navigation toggle
- Paste mode default

**Privacy Tab:**
- Auto-detect sensitive apps toggle
- Excluded apps list (add/remove)
- Redaction mode: Hide/Exclude
- Clear history button

**Tests:**
- Test settings persist across launches
- Test changes apply immediately
- Test reset to defaults

---

## Critical Files Summary

### Files to Create:
1. `ColorSystem.swift` - Brand color palette
2. `TypographySystem.swift` - Font system
3. `SearchBar.swift` - Search component
4. `ClipboardItemRow.swift` - Reusable item component
5. `KeyboardNavigationManager.swift` - Keyboard handling
6. `SensitiveAppManager.swift` - Privacy detection
7. `PrivacySettingsView.swift` - Privacy settings UI
8. `SettingsView.swift` - Main settings panel
9. `ShortcutConflictDetector.swift` - Conflict detection
10. `ImageThumbnailView.swift` - Image preview component
11. `HighlightedText.swift` - Search highlighting

### Files to Modify:
1. `ClipboardItem.swift` - Add new properties
2. `ClipboardHistoryManager.swift` - Add new methods
3. `ClipboardMonitor.swift` - Multi-type detection
4. `FloatingWindowView.swift` - Enhanced UI with all features
5. `FloatingWindowManager.swift` - Cursor-proximal positioning
6. `OnboardingView.swift` - Multi-step flow
7. `MenuBarView.swift` - Updated menu structure
8. `Info.plist` - App name branding
9. `ClipboardApp.swift` - Settings window integration

### Test Files to Create:
1. `ColorSystemTests.swift`
2. `TypographyTests.swift`
3. `ClipboardItemEnhancedTests.swift`
4. `ClipboardHistoryManagerEnhancedTests.swift`
5. `PinnedItemsSectionTests.swift`
6. `SearchBarTests.swift`
7. `KeyboardNavigationTests.swift`
8. `CursorProximalPositioningTests.swift`
9. `WindowAnimationTests.swift`
10. `SensitiveAppDetectionTests.swift`
11. `ContentRedactionTests.swift`
12. `PrivacySettingsTests.swift`
13. `PasteModeTests.swift`
14. `ContentTypeDetectionTests.swift`
15. `MultiTypeDisplayTests.swift`
16. `EnhancedOnboardingTests.swift`
17. `ShortcutConflictTests.swift`
18. `MenuBarTests.swift`
19. `SettingsViewTests.swift`

---

## Implementation Order (Phased TDD Approach)

**User Preferences Applied:**
- ✅ Phased approach with TDD
- ✅ Cursor positioning: User preference setting (requires settings first)
- ✅ Pinned items: Persist across restarts (save to UserDefaults)
- ✅ History limit: FIFO removal (remove oldest non-pinned items)

### Batch 1: Foundation + Core Branding (Phases 1-2)
**Goal**: Establish visual identity and data model foundation

1. **Color System** (Phase 1.1)
   - Write `ColorSystemTests.swift`
   - Create `ColorSystem.swift` with hex support
   - Test light/dark mode adaptation

2. **Typography System** (Phase 1.2)
   - Write `TypographyTests.swift`
   - Create `TypographySystem.swift`
   - Test font modifiers

3. **Branding Updates** (Phase 1.3)
   - Update app name to "SwiftClip"
   - Update `OnboardingView.swift` with tagline
   - Update `FloatingWindowView.swift` title
   - Apply color system throughout

4. **Enhanced Data Model** (Phase 2.1-2.2)
   - Write `ClipboardItemEnhancedTests.swift`
   - Update `ClipboardItem.swift` with isPinned, contentType, etc.
   - Write `ClipboardHistoryManagerEnhancedTests.swift`
   - Add pin/unpin, FIFO removal logic to `ClipboardHistoryManager.swift`

**Deliverable**: Branded app with foundation for advanced features

---

### Batch 2: Pinning + Search (Phases 3-4)
**Goal**: Core productivity features

5. **Pinned Items UI** (Phase 3.1)
   - Write `PinnedItemsSectionTests.swift`
   - Update `FloatingWindowView.swift` with pinned section
   - Test max 5 pins, visual separation, persistence

6. **Search Functionality** (Phase 4.1-4.2)
   - Write `SearchBarTests.swift`
   - Create `SearchBar.swift` component
   - Create `HighlightedText.swift` for match highlighting
   - Integrate into `FloatingWindowView.swift`
   - Test instant filtering, clear button, ⌘F shortcut

**Deliverable**: Functional pinning and search

---

### Batch 3: Keyboard Navigation (Phase 5)
**Goal**: Keyboard-first experience

7. **Arrow Key Navigation** (Phase 5.1)
   - Write `KeyboardNavigationTests.swift`
   - Create `KeyboardNavigationManager.swift`
   - Update `FloatingWindowView.swift` with keyboard handling
   - Test all shortcuts: ↑/↓, Enter, ⌘P, ⌘⇧V, Escape, Delete

8. **Visual Selection** (Phase 5.2)
   - Update UI with selection indicator
   - Test selection scrolls into view

**Deliverable**: Full keyboard control

---

### Batch 4: Settings Foundation (Phase 13 - Early)
**Goal**: Enable user preferences for cursor positioning

9. **Settings Panel** (Phase 13.1)
   - Write `SettingsViewTests.swift`
   - Create `SettingsView.swift`
   - Implement General, Appearance, Keyboard, Privacy tabs
   - Add window position preference: Cursor/Bottom-Right/Center
   - Test settings persistence

10. **Settings Integration**
    - Update `ClipboardApp.swift` to show settings window
    - Add Settings menu item to `MenuBarView.swift`

**Deliverable**: Working settings panel with position preference

---

### Batch 5: Cursor Positioning + Animations (Phases 6-7)
**Goal**: Polished UX with smooth interactions

11. **Cursor-Proximal Positioning** (Phase 6.1)
    - Write `CursorProximalPositioningTests.swift`
    - Update `FloatingWindowManager.swift` with positioning logic
    - Implement user preference: cursor/fixed/last position
    - Test multi-monitor, boundary detection

12. **Animations** (Phase 7.1-7.2)
    - Write `WindowAnimationTests.swift`
    - Add window appearance animations
    - Add item interaction animations (hover, pin, delete)
    - Test 60fps performance

**Deliverable**: Smooth, responsive UI

---

### Batch 6: Privacy Features (Phases 8-9)
**Goal**: Security and sensitive content handling

13. **Sensitive App Detection** (Phase 8.1)
    - Write `SensitiveAppDetectionTests.swift`
    - Create `SensitiveAppManager.swift`
    - Test password manager detection

14. **Content Redaction** (Phase 8.2)
    - Write `ContentRedactionTests.swift`
    - Implement redaction in `ClipboardHistoryManager.swift`
    - Test dots display, reveal on click

15. **Privacy Settings UI** (Phase 8.3)
    - Write `PrivacySettingsTests.swift`
    - Create `PrivacySettingsView.swift`
    - Integrate into Settings panel

16. **Plain Text Paste** (Phase 9.1)
    - Write `PasteModeTests.swift`
    - Update `FloatingWindowView.swift` with paste modes
    - Test ⌘⇧⏎ shortcut, formatting strip

**Deliverable**: Privacy-conscious clipboard manager

---

### Batch 7: Multi-Type Support (Phase 10)
**Goal**: Images, files, rich text

17. **Content Type Detection** (Phase 10.1)
    - Write `ContentTypeDetectionTests.swift`
    - Update `ClipboardMonitor.swift` for images/files/rich text
    - Test type detection accuracy

18. **Multi-Type Display** (Phase 10.2)
    - Write `MultiTypeDisplayTests.swift`
    - Create `ClipboardItemRow.swift` component
    - Create `ImageThumbnailView.swift`
    - Test thumbnail generation, file icons

**Deliverable**: Support for all clipboard content types

---

### Batch 8: Enhanced Onboarding + Menu (Phases 11-12)
**Goal**: First-run experience and menu polish

19. **Multi-Step Onboarding** (Phase 11.1)
    - Write `EnhancedOnboardingTests.swift`
    - Update `OnboardingView.swift` with 5 steps
    - Test navigation, preference saving

20. **Shortcut Conflict Detection** (Phase 11.2)
    - Write `ShortcutConflictTests.swift`
    - Create `ShortcutConflictDetector.swift`
    - Integrate into onboarding Step 3

21. **Menu Bar Update** (Phase 12.1)
    - Write `MenuBarTests.swift`
    - Update `MenuBarView.swift` with new structure
    - Test menu items, shortcuts

**Deliverable**: Complete, polished app experience

---

## TDD Workflow (Applied to Each Feature)

For every feature in each batch:

1. **Red**: Write failing test first
   ```swift
   func testPinItemPersistsAcrossRestarts() {
       // Test fails - feature doesn't exist yet
   }
   ```

2. **Green**: Write minimum code to pass test
   ```swift
   func togglePin(for id: UUID) {
       // Simplest implementation
   }
   ```

3. **Refactor**: Improve code quality
   - Extract methods
   - Remove duplication
   - Improve naming

4. **Repeat**: Next test for same feature

5. **Integration**: Verify feature works in app

---

## Next Steps

**Ready to implement Batch 1 (Foundation + Core Branding)** - All 4 items together:

1. **Color System** (TDD)
   - Create `ClipboardApp/ColorSystem.swift`
   - Create `ClipboardAppTests/ColorSystemTests.swift`
   - Test hex color conversion, light/dark mode

2. **Typography System** (TDD)
   - Create `ClipboardApp/TypographySystem.swift`
   - Create `ClipboardAppTests/TypographyTests.swift`
   - Test font modifiers

3. **Branding Updates**
   - Update `ClipboardApp/Views/OnboardingView.swift`
   - Update `ClipboardApp/Views/FloatingWindowView.swift`
   - Apply new colors throughout both views
   - Update Info.plist app name

4. **Enhanced Data Model** (TDD)
   - Create `ClipboardAppTests/ClipboardItemEnhancedTests.swift`
   - Update `ClipboardApp/ClipboardItem.swift`
   - Create `ClipboardAppTests/ClipboardHistoryManagerEnhancedTests.swift`
   - Update `ClipboardApp/ClipboardHistoryManager.swift`
   - Implement: togglePin(), getPinnedItems(), FIFO removal

After Batch 1 completion, build and test app, then proceed to Batch 2.

---

## Estimated Complexity

- **High complexity**: Phase 6 (cursor positioning), Phase 8 (privacy), Phase 10 (multi-type)
- **Medium complexity**: Phase 3-5 (pinning, search, keyboard), Phase 11 (onboarding)
- **Low complexity**: Phase 1-2 (branding, data model), Phase 7 (animations), Phase 12-13 (settings)

---

## Success Criteria

✅ All features from blueprint implemented
✅ Brand identity (colors, typography, naming) applied throughout
✅100% test coverage for new features (TDD)
✅ Smooth animations matching 60fps target
✅ Privacy features functional with real-world apps
✅ Keyboard navigation complete and intuitive
✅ Multi-type clipboard support (text, image, file)
✅ Settings persist across app launches
✅ No regressions in existing functionality
