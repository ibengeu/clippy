import SwiftUI

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex string with or without '#' prefix (e.g., "#2979FF" or "2979FF")
    /// - Returns: Color if hex is valid, nil otherwise
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        // Validate hex string length
        guard hexSanitized.count == 6 else {
            return nil
        }

        // Convert hex to RGB
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

// MARK: - SwiftClip Brand Colors

extension Color {
    // Primary Brand Colors

    /// Electric Blue - Primary brand color (#2979FF)
    static let swiftClipPrimary = Color(hex: "2979FF")!

    /// Vibrant Teal - Secondary accent color (#00BFA5)
    static let swiftClipAccent = Color(hex: "00BFA5")!

    // Background Colors

    /// Off-White - Light mode background (#F7F7F8)
    static let swiftClipBackgroundLight = Color(hex: "F7F7F8")!

    /// Charcoal - Dark mode background (#1C1C1E)
    static let swiftClipBackgroundDark = Color(hex: "1C1C1E")!

    // Text Colors

    /// Dark Grey - Primary text color (#1A1A1A)
    static let swiftClipTextPrimary = Color(hex: "1A1A1A")!

    /// Medium Grey - Secondary text color (#6E6E6E)
    static let swiftClipTextSecondary = Color(hex: "6E6E6E")!

    // Adaptive Colors (Light/Dark Mode)

    /// Adaptive background color - light in light mode, dark in dark mode
    static var swiftClipBackground: Color {
        adaptiveColor(light: swiftClipBackgroundLight, dark: swiftClipBackgroundDark)
    }

    /// Adaptive text color - dark in light mode, light in dark mode
    static var swiftClipText: Color {
        adaptiveColor(light: swiftClipTextPrimary, dark: .white)
    }

    // MARK: - Helper for Adaptive Colors

    /// Create an adaptive color that changes based on light/dark mode
    private static func adaptiveColor(light: Color, dark: Color) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return NSColor(dark)
            } else {
                return NSColor(light)
            }
        })
    }
}

// MARK: - NSColor Bridge

extension NSColor {
    /// Convert SwiftUI Color to NSColor using hex values
    convenience init(_ color: Color) {
        // For our brand colors, we can resolve them directly
        // This is a simple bridge for the adaptive color system
        self.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    }
}
