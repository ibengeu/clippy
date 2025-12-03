import SwiftUI

/// Central configuration for all animations in SwiftClip
struct AnimationConfig {
    // MARK: - Window Animations

    /// Window appear animation parameters
    static let windowAppearResponse: Double = 0.3
    static let windowAppearDamping: Double = 0.8

    /// Window appear animation: fade in + scale up
    static let windowAppear = Animation.spring(response: windowAppearResponse, dampingFraction: windowAppearDamping)

    /// Window disappear duration
    static let windowDisappearDuration: Double = 0.15

    /// Window disappear animation: fade out
    static let windowDisappear = Animation.easeOut(duration: windowDisappearDuration)

    // MARK: - Item Animations

    /// Item pin animation parameters
    static let itemPinResponse: Double = 0.4
    static let itemPinDamping: Double = 0.6

    /// Item pin animation: bouncy spring effect
    static let itemPin = Animation.spring(response: itemPinResponse, dampingFraction: itemPinDamping)

    /// Item hover duration
    static let itemHoverDuration: Double = 0.2

    /// Item hover animation: smooth scale up
    static let itemHover = Animation.easeInOut(duration: itemHoverDuration)

    /// Item selection duration
    static let itemSelectionDuration: Double = 0.2

    /// Item selection animation: smooth color transition
    static let itemSelection = Animation.easeInOut(duration: itemSelectionDuration)

    // MARK: - Scale Values

    /// Window initial scale when appearing
    static let windowInitialScale: CGFloat = 0.95

    /// Window final scale when fully visible
    static let windowFinalScale: CGFloat = 1.0

    /// Item scale when hovered
    static let itemHoverScale: CGFloat = 1.02

    /// Item scale when clicked
    static let itemClickScale: CGFloat = 0.98
}
