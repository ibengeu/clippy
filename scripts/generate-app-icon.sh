#!/bin/bash
set -e

# Generate app icon using SF Symbols and sips
# This creates a simple icon for MVP - can be replaced with custom design later

ICONSET_DIR="Resources/AppIcon.iconset"
TEMP_BASE="/tmp/carboclip_icon_base.png"

echo "🎨 Generating app icon..."

# Create base icon using SF Symbols (requires macOS with SF Symbols support)
# We'll use the clipboard symbol and render it to different sizes

# For MVP: Create a simple colored square with "C" letter as placeholder
# This can be replaced with proper design tool output later

create_icon_size() {
    local size=$1
    local filename=$2

    # Create a simple icon using ImageMagick or sips
    # For MVP, we'll create a basic colored square
    # In production, you'd use a proper design tool

    sips -s format png \
         --resampleWidth ${size} \
         --resampleHeight ${size} \
         /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ClippingUnknown.icns \
         --out "${ICONSET_DIR}/${filename}" 2>/dev/null || true
}

# Generate all required sizes
create_icon_size 16 "icon_16x16.png"
create_icon_size 32 "icon_16x16@2x.png"
create_icon_size 32 "icon_32x32.png"
create_icon_size 64 "icon_32x32@2x.png"
create_icon_size 128 "icon_128x128.png"
create_icon_size 256 "icon_128x128@2x.png"
create_icon_size 256 "icon_256x256.png"
create_icon_size 512 "icon_256x256@2x.png"
create_icon_size 512 "icon_512x512.png"
create_icon_size 1024 "icon_512x512@2x.png"

# Convert iconset to icns
echo "📦 Converting to .icns format..."
iconutil -c icns "${ICONSET_DIR}" -o "Resources/AppIcon.icns"

echo "✅ App icon generated at Resources/AppIcon.icns"
echo "⚠️  Note: This is a placeholder icon. Replace with custom design for production."
