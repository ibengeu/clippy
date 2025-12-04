#!/bin/bash
set -e

# Build configuration
VERSION="1.0.0"
APP_NAME="Carboclip"
BUNDLE_ID="com.carboclip.app"
BUILD_CONFIG="release"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Building ${APP_NAME} v${VERSION}...${NC}"

# Clean previous build
if [ -d "${APP_NAME}.app" ]; then
    echo -e "${YELLOW}🗑️  Removing previous app bundle...${NC}"
    rm -rf "${APP_NAME}.app"
fi

# Build the Swift package (release mode for current architecture)
echo -e "${BLUE}📦 Building Swift package (${BUILD_CONFIG})...${NC}"
swift build -c ${BUILD_CONFIG}

# Determine current architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    BUILD_PATH=".build/arm64-apple-macosx/${BUILD_CONFIG}/${APP_NAME}"
else
    BUILD_PATH=".build/x86_64-apple-macosx/${BUILD_CONFIG}/${APP_NAME}"
fi

# Verify executable exists
if [ ! -f "$BUILD_PATH" ]; then
    echo -e "${RED}❌ Build failed: executable not found at $BUILD_PATH${NC}"
    exit 1
fi

# Create app bundle structure
echo -e "${BLUE}📂 Creating app bundle structure...${NC}"
mkdir -p "${APP_NAME}.app/Contents/"{MacOS,Resources}

# Copy executable
echo -e "${BLUE}📋 Copying executable...${NC}"
cp "$BUILD_PATH" "${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

# Copy Info.plist
if [ ! -f "Resources/Info.plist" ]; then
    echo -e "${RED}❌ Error: Resources/Info.plist not found${NC}"
    exit 1
fi
cp Resources/Info.plist "${APP_NAME}.app/Contents/"

# Copy app icon if it exists
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "${APP_NAME}.app/Contents/Resources/"
    echo -e "${GREEN}✅ App icon added${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: AppIcon.icns not found, app will use default icon${NC}"
fi

# Verify app bundle structure
echo -e "${BLUE}🔍 Verifying app bundle...${NC}"
if [ ! -f "${APP_NAME}.app/Contents/MacOS/${APP_NAME}" ]; then
    echo -e "${RED}❌ Error: Executable missing in app bundle${NC}"
    exit 1
fi

if [ ! -f "${APP_NAME}.app/Contents/Info.plist" ]; then
    echo -e "${RED}❌ Error: Info.plist missing in app bundle${NC}"
    exit 1
fi

# Get app bundle size
BUNDLE_SIZE=$(du -sh "${APP_NAME}.app" | cut -f1)

echo -e "${GREEN}✅ App bundle created successfully!${NC}"
echo -e "${GREEN}   Location: $(pwd)/${APP_NAME}.app${NC}"
echo -e "${GREEN}   Size: ${BUNDLE_SIZE}${NC}"
echo ""
echo -e "${BLUE}To run the app:${NC}"
echo -e "   open ${APP_NAME}.app"
echo ""
echo -e "${YELLOW}Note: This is an unsigned development build.${NC}"
echo -e "${YELLOW}For distribution, use scripts/build-release.sh with code signing.${NC}"
