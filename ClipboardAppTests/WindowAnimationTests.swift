import XCTest
import SwiftUI
@testable import ClipboardApp

final class WindowAnimationTests: XCTestCase {
    // MARK: - Animation Transition Tests

    func testWindowAppearsWithScaleTransition() {
        // Given
        let response = AnimationConfig.windowAppearResponse
        let damping = AnimationConfig.windowAppearDamping

        // Then
        XCTAssertEqual(response, 0.3, accuracy: 0.01)
        XCTAssertEqual(damping, 0.8, accuracy: 0.01)
    }

    func testWindowDisappearsWithOpacityTransition() {
        // Given
        let duration = AnimationConfig.windowDisappearDuration

        // Then
        XCTAssertEqual(duration, 0.15, accuracy: 0.01)
    }

    func testItemPinAnimationHasSpringEffect() {
        // Given
        let response = AnimationConfig.itemPinResponse
        let damping = AnimationConfig.itemPinDamping

        // Then
        XCTAssertEqual(response, 0.4, accuracy: 0.01)
        XCTAssertEqual(damping, 0.6, accuracy: 0.01)
    }

    func testItemHoverAnimationIsSmooth() {
        // Given
        let duration = AnimationConfig.itemHoverDuration

        // Then
        XCTAssertEqual(duration, 0.2, accuracy: 0.01)
    }

    func testItemSelectionAnimationIsSmooth() {
        // Given
        let duration = AnimationConfig.itemSelectionDuration

        // Then
        XCTAssertEqual(duration, 0.2, accuracy: 0.01)
    }

    // MARK: - Animation Scale Tests

    func testWindowAppearScaleValues() {
        // Given
        let initialScale = AnimationConfig.windowInitialScale
        let finalScale = AnimationConfig.windowFinalScale

        // Then
        XCTAssertEqual(initialScale, 0.95, accuracy: 0.01)
        XCTAssertEqual(finalScale, 1.0, accuracy: 0.01)
    }

    func testItemHoverScaleValue() {
        // Given
        let hoverScale = AnimationConfig.itemHoverScale

        // Then
        XCTAssertEqual(hoverScale, 1.02, accuracy: 0.01)
    }

    func testItemClickScaleValue() {
        // Given
        let clickScale = AnimationConfig.itemClickScale

        // Then
        XCTAssertEqual(clickScale, 0.98, accuracy: 0.01)
    }

    // MARK: - Animation Duration Tests

    func testWindowAppearDurationIsOptimal() {
        // Given
        let duration = AnimationConfig.windowAppearResponse

        // Then - Should be fast enough to feel responsive (< 0.5s)
        XCTAssertLessThan(duration, 0.5)
    }

    func testWindowDisappearDurationIsQuick() {
        // Given
        let duration = AnimationConfig.windowDisappearDuration

        // Then - Should disappear quickly (< 0.2s)
        XCTAssertLessThan(duration, 0.2)
    }

    func testItemInteractionDurationIsSnappy() {
        // Given
        let hoverDuration = AnimationConfig.itemHoverDuration
        let selectionDuration = AnimationConfig.itemSelectionDuration

        // Then - Should feel snappy (< 0.25s)
        XCTAssertLessThan(hoverDuration, 0.25)
        XCTAssertLessThan(selectionDuration, 0.25)
    }

    // MARK: - Animation Timing Tests

    func testPinAnimationIsBouncier() {
        // Given
        let pinDamping = AnimationConfig.itemPinDamping
        let windowDamping = AnimationConfig.windowAppearDamping

        // Then - Pin should be bouncier (lower damping than window)
        XCTAssertLessThan(pinDamping, windowDamping)
    }

    func testWindowAppearHasModerateSpring() {
        // Given
        let damping = AnimationConfig.windowAppearDamping

        // Then - Should have moderate spring (0.7-0.9)
        XCTAssertGreaterThan(damping, 0.7)
        XCTAssertLessThan(damping, 0.9)
    }

    // MARK: - Animation Configuration Exists Tests

    func testAllAnimationConfigsExist() {
        // Given/When/Then - Should not crash
        _ = AnimationConfig.windowAppear
        _ = AnimationConfig.windowDisappear
        _ = AnimationConfig.itemPin
        _ = AnimationConfig.itemHover
        _ = AnimationConfig.itemSelection
        _ = AnimationConfig.windowInitialScale
        _ = AnimationConfig.windowFinalScale
        _ = AnimationConfig.itemHoverScale
        _ = AnimationConfig.itemClickScale
    }
}
