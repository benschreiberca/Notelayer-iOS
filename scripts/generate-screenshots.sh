#!/bin/bash

# Automated Screenshot Generation Script for NoteLayer
# This script generates App Store screenshots using XCUITest

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SIMULATOR_NAME="iPhone 17 Pro"
SCHEME_NAME="Notelayer"
TEST_SCHEME_NAME="NotelayerScreenshotTests"
SCREENSHOT_BACKUP_DIR="/Users/bens/Notelayer/App-Icons-&-screenshots"
TEMP_SCREENSHOT_DIR="ios-swift/Notelayer/Screenshots"
PROJECT_PATH="ios-swift/Notelayer/Notelayer.xcodeproj"

echo -e "${GREEN}📸 Starting Automated Screenshot Generation${NC}"
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: xcodebuild not found. Please install Xcode.${NC}"
    exit 1
fi

# Check if simulator is available
echo -e "${YELLOW}🔍 Checking for iPhone 17 Pro simulator...${NC}"
SIMULATOR_UDID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)

if [ -z "$SIMULATOR_UDID" ]; then
    echo -e "${YELLOW}⚠️  iPhone 17 Pro not found, looking for any iPhone Pro simulator...${NC}"
    SIMULATOR_UDID=$(xcrun simctl list devices available | grep "iPhone.*Pro" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)
    
    if [ -z "$SIMULATOR_UDID" ]; then
        echo -e "${RED}❌ Error: No iPhone Pro simulator found. Please create one in Xcode.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Found simulator: $(xcrun simctl list devices | grep "$SIMULATOR_UDID" | sed 's/.*(\(.*\))/\1/')${NC}"
else
    echo -e "${GREEN}✅ Found iPhone 17 Pro simulator${NC}"
fi

# Create screenshot directories
echo -e "${YELLOW}📁 Creating screenshot directories...${NC}"
mkdir -p "$SCREENSHOT_BACKUP_DIR"
mkdir -p "$TEMP_SCREENSHOT_DIR"
echo -e "${GREEN}✅ Directories created${NC}"

# Boot simulator
echo -e "${YELLOW}🚀 Booting simulator...${NC}"
xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || echo "Simulator already booted"
sleep 2

# Set simulator state
echo -e "${YELLOW}⚙️  Configuring simulator state...${NC}"
# Set time to 10:00 AM
xcrun simctl status_bar "$SIMULATOR_UDID" override --time "10:00"
# Set battery to 100%
xcrun simctl status_bar "$SIMULATOR_UDID" override --batteryLevel 100
# Set battery state to unplugged (shows battery icon)
xcrun simctl status_bar "$SIMULATOR_UDID" override --batteryState unplugged
echo -e "${GREEN}✅ Simulator configured${NC}"

# Build and test
echo -e "${YELLOW}🔨 Building app and running screenshot tests...${NC}"
echo ""

# Change to project directory
cd "$(dirname "$0")/.."

# Run tests with screenshot generation mode
xcodebuild test \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME_NAME" \
    -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
    -only-testing:"$TEST_SCHEME_NAME/ScreenshotGenerationTests" \
    -derivedDataPath ./DerivedData \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee /tmp/screenshot-build.log

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Screenshot generation completed successfully!${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠️  Some tests may have failed, but checking for screenshots...${NC}"
fi

# Copy screenshots from test attachments to backup location
echo -e "${YELLOW}📋 Collecting screenshots...${NC}"

# Find screenshots in DerivedData
SCREENSHOT_ATTACHMENTS=$(find ./DerivedData -name "screenshot-*.png" -type f 2>/dev/null || true)

if [ -n "$SCREENSHOT_ATTACHMENTS" ]; then
    echo "$SCREENSHOT_ATTACHMENTS" | while read -r screenshot; do
        filename=$(basename "$screenshot")
        cp "$screenshot" "$SCREENSHOT_BACKUP_DIR/$filename"
        echo -e "${GREEN}  ✅ Copied: $filename${NC}"
    done
else
    # Also check temp directory
    if [ -d "$TEMP_SCREENSHOT_DIR" ]; then
        for screenshot in "$TEMP_SCREENSHOT_DIR"/*.png; do
            if [ -f "$screenshot" ]; then
                filename=$(basename "$screenshot")
                cp "$screenshot" "$SCREENSHOT_BACKUP_DIR/$filename"
                echo -e "${GREEN}  ✅ Copied: $filename${NC}"
            fi
        done
    fi
fi

# List generated screenshots
echo ""
echo -e "${GREEN}📸 Generated Screenshots:${NC}"
ls -lh "$SCREENSHOT_BACKUP_DIR"/screenshot-*.png 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}' || echo "  No screenshots found in backup directory"

echo ""
echo -e "${GREEN}✅ Screenshots saved to: $SCREENSHOT_BACKUP_DIR${NC}"
echo ""
echo -e "${GREEN}🎉 Screenshot generation complete!${NC}"
