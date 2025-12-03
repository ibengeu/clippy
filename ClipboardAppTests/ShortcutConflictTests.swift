import XCTest
import Carbon
@testable import ClipboardApp

final class ShortcutConflictTests: XCTestCase {

    // MARK: - SystemShortcut Tests

    func testSystemShortcutInitialization() {
        // Given
        let shortcut = SystemShortcut(
            name: "Spotlight",
            keyCode: UInt16(kVK_Space),
            modifiers: [.command]
        )

        // Then
        XCTAssertEqual(shortcut.name, "Spotlight")
        XCTAssertEqual(shortcut.keyCode, UInt16(kVK_Space))
        XCTAssertEqual(shortcut.modifiers, [.command])
    }

    func testSystemShortcutDisplayString() {
        // Given
        let shortcut = SystemShortcut(
            name: "Copy",
            keyCode: UInt16(kVK_ANSI_C),
            modifiers: [.command]
        )

        // When
        let displayString = shortcut.displayString

        // Then
        XCTAssertTrue(displayString.contains("⌘"))
        XCTAssertTrue(displayString.contains("C"))
    }

    func testSystemShortcutWithMultipleModifiers() {
        // Given
        let shortcut = SystemShortcut(
            name: "Screenshot",
            keyCode: UInt16(kVK_ANSI_4),
            modifiers: [.command, .shift]
        )

        // When
        let displayString = shortcut.displayString

        // Then
        XCTAssertTrue(displayString.contains("⌘"))
        XCTAssertTrue(displayString.contains("⇧"))
    }

    // MARK: - ShortcutConflictDetector Tests

    func testCommonSystemShortcutsLoaded() {
        // Given
        let detector = ShortcutConflictDetector()

        // When
        let shortcuts = detector.commonSystemShortcuts

        // Then
        XCTAssertFalse(shortcuts.isEmpty)
        XCTAssertTrue(shortcuts.count >= 5) // At least a few common shortcuts
    }

    func testDetectConflictWithSpotlight() {
        // Given
        let detector = ShortcutConflictDetector()

        // When - Check Command+Space (Spotlight)
        let conflict = detector.detectConflict(keyCode: UInt16(kVK_Space), modifiers: [.command])

        // Then
        XCTAssertNotNil(conflict)
        XCTAssertEqual(conflict?.name, "Spotlight")
    }

    func testDetectConflictWithCopy() {
        // Given
        let detector = ShortcutConflictDetector()

        // When - Check Command+C (Copy)
        let conflict = detector.detectConflict(keyCode: UInt16(kVK_ANSI_C), modifiers: [.command])

        // Then
        XCTAssertNotNil(conflict)
        XCTAssertEqual(conflict?.name, "Copy")
    }

    func testDetectConflictWithPaste() {
        // Given
        let detector = ShortcutConflictDetector()

        // When - Check Command+V (Paste)
        let conflict = detector.detectConflict(keyCode: UInt16(kVK_ANSI_V), modifiers: [.command])

        // Then
        XCTAssertNotNil(conflict)
        XCTAssertEqual(conflict?.name, "Paste")
    }

    func testNoConflictForUnusedShortcut() {
        // Given
        let detector = ShortcutConflictDetector()

        // When - Check Option+V (our default, should not conflict)
        let conflict = detector.detectConflict(keyCode: UInt16(kVK_ANSI_V), modifiers: [.option])

        // Then
        XCTAssertNil(conflict)
    }

    func testNoConflictForOptionModifierAlone() {
        // Given
        let detector = ShortcutConflictDetector()

        // When - Check various Option+Key combinations
        let conflictB = detector.detectConflict(keyCode: UInt16(kVK_ANSI_B), modifiers: [.option])
        let conflictN = detector.detectConflict(keyCode: UInt16(kVK_ANSI_N), modifiers: [.option])

        // Then
        XCTAssertNil(conflictB)
        XCTAssertNil(conflictN)
    }

    func testIsCommonConflict() {
        // Given
        let detector = ShortcutConflictDetector()

        // When/Then - Common conflicts
        XCTAssertTrue(detector.isCommonConflict(keyCode: UInt16(kVK_Space), modifiers: [.command]))
        XCTAssertTrue(detector.isCommonConflict(keyCode: UInt16(kVK_ANSI_C), modifiers: [.command]))
        XCTAssertTrue(detector.isCommonConflict(keyCode: UInt16(kVK_ANSI_V), modifiers: [.command]))
        XCTAssertTrue(detector.isCommonConflict(keyCode: UInt16(kVK_ANSI_Q), modifiers: [.command]))
    }

    func testIsNotCommonConflict() {
        // Given
        let detector = ShortcutConflictDetector()

        // When/Then - Not common conflicts
        XCTAssertFalse(detector.isCommonConflict(keyCode: UInt16(kVK_ANSI_V), modifiers: [.option]))
        XCTAssertFalse(detector.isCommonConflict(keyCode: UInt16(kVK_ANSI_X), modifiers: [.option, .shift]))
    }

    func testSuggestAlternatives() {
        // Given
        let detector = ShortcutConflictDetector()

        // When
        let alternatives = detector.suggestAlternatives()

        // Then
        XCTAssertFalse(alternatives.isEmpty)
        XCTAssertTrue(alternatives.count >= 3)
        // Should include Option+V as default
        XCTAssertTrue(alternatives.contains(where: { $0.contains("⌥") && $0.contains("V") }))
    }

    func testGetConflictWarningMessage() {
        // Given
        let detector = ShortcutConflictDetector()

        // When - Get warning for Command+V
        let warning = detector.getConflictWarningMessage(keyCode: UInt16(kVK_ANSI_V), modifiers: [.command])

        // Then
        XCTAssertNotNil(warning)
        XCTAssertTrue(warning!.contains("Paste"))
        XCTAssertTrue(warning!.contains("conflicts"))
    }

    func testNoWarningForSafeShortcut() {
        // Given
        let detector = ShortcutConflictDetector()

        // When - Check Option+V (safe)
        let warning = detector.getConflictWarningMessage(keyCode: UInt16(kVK_ANSI_V), modifiers: [.option])

        // Then
        XCTAssertNil(warning)
    }
}
