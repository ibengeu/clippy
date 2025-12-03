#!/bin/bash

# Build script for packaging ClipboardApp as a macOS application

set -e

echo "Building ClipboardApp..."

# Kill any running instances first
echo "Killing any running instances..."
pkill -f ClipboardApp || true
sleep 1

# Clear permission cache to ensure fresh onboarding
echo "Clearing permission cache..."
defaults delete com.clipboardapp.ClipboardApp 2>/dev/null || true
defaults delete ClipboardApp 2>/dev/null || true

# Build the executable
swift build -c release

# Create app bundle structure
APP_NAME="ClipboardApp"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Creating app bundle structure..."

# Remove existing bundle if it exists
rm -rf "${APP_BUNDLE}"

# Create directories
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp ".build/release/${APP_NAME}" "${MACOS_DIR}/"
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Copy Info.plist
cp "Info.plist" "${CONTENTS_DIR}/"

# Create PkgInfo file
echo -n "APPL????" > "${CONTENTS_DIR}/PkgInfo"

echo "✓ App bundle created: ${APP_BUNDLE}"
echo ""
echo "To run the app, execute:"
echo "  open ${APP_BUNDLE}"
echo ""
echo "To code sign the app (required for distribution), run:"
echo "  codesign -s - ${APP_BUNDLE}"
