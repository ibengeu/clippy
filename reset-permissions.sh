#!/bin/bash

# Reset Permissions Script for ClipboardApp
# This script helps reset accessibility permissions during development

set -e

echo "🧹 Resetting ClipboardApp Permissions..."
echo ""

# 1. Kill any running instances
echo "1️⃣  Killing any running ClipboardApp instances..."
pkill -f ClipboardApp || true
sleep 1

# 2. Clear UserDefaults permission cache
echo "2️⃣  Clearing permission cache..."
defaults delete com.clipboardapp.ClipboardApp 2>/dev/null || true
defaults delete ClipboardApp 2>/dev/null || true

# 3. Remove app from accessibility database (requires user action)
echo "3️⃣  Removing from accessibility permissions..."
echo ""
echo "⚠️  IMPORTANT: You need to manually remove ClipboardApp from accessibility:"
echo ""
echo "   1. Open System Settings (will open automatically)"
echo "   2. Go to: Privacy & Security > Accessibility"
echo "   3. Find 'ClipboardApp' in the list"
echo "   4. Click the (-) minus button to remove it"
echo "   5. Alternatively, uncheck it to revoke permission"
echo ""
echo "Press any key to open System Settings..."
read -n 1 -s

# Open System Settings to Accessibility
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

echo ""
echo "4️⃣  Waiting for you to remove the app from accessibility..."
echo "   Press any key when done..."
read -n 1 -s

# 4. Clean build artifacts
echo ""
echo "5️⃣  Cleaning build artifacts..."
rm -rf .build/
rm -rf ClipboardApp.app

echo ""
echo "✅ Reset complete!"
echo ""
echo "Next steps:"
echo "  1. Run: ./build-app.sh"
echo "  2. Run: open ClipboardApp.app"
echo "  3. Grant accessibility permission when prompted"
echo ""
