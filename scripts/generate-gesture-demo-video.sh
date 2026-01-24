#!/bin/bash

set -euo pipefail

SIMULATOR_NAME="iPhone 17 Pro"
SCHEME_NAME="Screenshot Generation"
TEST_TARGET_NAME="NotelayerScreenshotTests"
TEST_CLASS_NAME="ScreenshotGenerationTests"
TEST_METHOD_NAME="testGestureDemoVideo"
PROJECT_PATH="ios-swift/Notelayer/Notelayer.xcodeproj"
VIDEO_DIR="/Users/bens/Notelayer/App-Icons-&-screenshots"
VIDEO_PATH="$VIDEO_DIR/gesture-demo.mp4"

echo "🎬 Starting gesture demo video capture"

if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "❌ Error: xcodebuild not found. Please install Xcode."
    exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
    echo "❌ Error: xcrun not found. Please install Xcode command line tools."
    exit 1
fi

if [ ! -f "$PROJECT_PATH/xcshareddata/xcschemes/$SCHEME_NAME.xcscheme" ]; then
    echo "❌ Error: Scheme not found at $PROJECT_PATH/xcshareddata/xcschemes/$SCHEME_NAME.xcscheme"
    echo "Run ./scripts/setup-screenshot-system.sh to create it."
    exit 1
fi

echo "🔍 Finding simulator..."
SIMULATOR_UDID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)

if [ -z "$SIMULATOR_UDID" ]; then
    echo "⚠️  iPhone 17 Pro not found, looking for any iPhone Pro simulator..."
    SIMULATOR_UDID=$(xcrun simctl list devices available | grep "iPhone.*Pro" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1)
    if [ -z "$SIMULATOR_UDID" ]; then
        echo "❌ Error: No iPhone Pro simulator found. Please create one in Xcode."
        exit 1
    fi
fi

mkdir -p "$VIDEO_DIR"

echo "🚀 Booting simulator..."
xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || echo "Simulator already booted"
sleep 2

echo "⚙️  Configuring simulator status bar..."
xcrun simctl status_bar "$SIMULATOR_UDID" override --time "09:41"
xcrun simctl status_bar "$SIMULATOR_UDID" override --batteryLevel 100
xcrun simctl status_bar "$SIMULATOR_UDID" override --batteryState discharging

echo "🎥 Recording video to $VIDEO_PATH"
if [ -f "$VIDEO_PATH" ]; then
    rm -f "$VIDEO_PATH"
fi

set +e
xcrun simctl io "$SIMULATOR_UDID" recordVideo --codec=h264 --force "$VIDEO_PATH" &
RECORD_PID=$!
set -e

sleep 1

echo "🧪 Running gesture demo test..."
set +e
xcodebuild test \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME_NAME" \
    -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
    -only-testing:"$TEST_TARGET_NAME/$TEST_CLASS_NAME/$TEST_METHOD_NAME" \
    -derivedDataPath ./DerivedData \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee /tmp/gesture-demo-build.log
TEST_STATUS=${PIPESTATUS[0]}
set -e

echo "🛑 Stopping recording..."
if kill -0 "$RECORD_PID" 2>/dev/null; then
    kill -INT "$RECORD_PID" || true
    wait "$RECORD_PID" || true
fi

if [ $TEST_STATUS -ne 0 ]; then
    echo "❌ Gesture demo test failed. See /tmp/gesture-demo-build.log for details."
    exit $TEST_STATUS
fi

echo "✅ Gesture demo video saved to: $VIDEO_PATH"
