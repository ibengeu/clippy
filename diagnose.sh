#!/bin/bash

echo "🔍 ClipboardApp Diagnostics"
echo "=========================="
echo ""

echo "1️⃣ App Running Status:"
ps aux | grep -i clipboard | grep -v grep | grep -v diagnose || echo "  ❌ Not running"
echo ""

echo "2️⃣ Code Signing:"
codesign -dv ClipboardApp.app 2>&1 | head -5
echo ""

echo "3️⃣ Bundle Identifier:"
defaults read ClipboardApp.app/Contents/Info.plist CFBundleIdentifier
echo ""

echo "4️⃣ TCC Database Check:"
tccutil list Accessibility 2>/dev/null | grep -i clipboard || echo "  ❌ Not in TCC database"
echo ""

echo "5️⃣ Permission Check (from running app):"
cat /tmp/clipboard_app.log 2>/dev/null | grep -i permission || echo "  ❌ No log file"
echo ""

echo "6️⃣ Testing AXIsProcessTrusted directly:"
swift -e 'import ApplicationServices; print("AXIsProcessTrusted:", AXIsProcessTrusted())'
echo ""

echo "7️⃣ Event Tap Test:"
cat /tmp/clipboard_app.log 2>/dev/null | grep -i "event tap" || echo "  ❌ No event tap info in log"
echo ""

echo "8️⃣ Permission Cache:"
defaults read com.clipboard.accessibility.permission.requested 2>/dev/null && echo "  Cached as requested" || echo "  ❌ Not cached"
echo ""

echo "=========================="
echo "📋 Next Steps:"
echo ""
echo "If AXIsProcessTrusted is false:"
echo "  - Open System Settings → Privacy & Security → Accessibility"
echo "  - Look for ClipboardApp and enable it"
echo "  - Restart the app"
echo ""
echo "If event tap failed to create:"
echo "  - The app needs accessibility permission BEFORE it starts"
echo "  - Grant permission, then: pkill ClipboardApp && open ClipboardApp.app"
echo ""
