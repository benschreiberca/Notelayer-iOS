#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/ios-swift/Notelayer/Notelayer.xcodeproj"
PBXPROJ_PATH="$PROJECT_PATH/project.pbxproj"
SCHEME_PATH="$PROJECT_PATH/xcshareddata/xcschemes/Screenshot Generation.xcscheme"
TEST_FILE="$ROOT_DIR/ios-swift/Notelayer/NotelayerScreenshotTests/ScreenshotGenerationTests.swift"

if [ ! -f "$PBXPROJ_PATH" ]; then
  echo "Error: project file not found at $PBXPROJ_PATH"
  exit 1
fi

if [ ! -f "$SCHEME_PATH" ]; then
  echo "Error: scheme not found at $SCHEME_PATH"
  exit 1
fi

if [ ! -f "$TEST_FILE" ]; then
  echo "Error: test file not found at $TEST_FILE"
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Error: xcodebuild not found."
  exit 1
fi

echo "Checking Xcode project targets and schemes..."
project_list="$(xcodebuild -list -project "$PROJECT_PATH" 2>/dev/null || true)"

if ! echo "$project_list" | grep -q "NotelayerScreenshotTests"; then
  echo "Error: NotelayerScreenshotTests target not found in xcodebuild list."
  exit 1
fi

if ! echo "$project_list" | grep -q "Screenshot Generation"; then
  echo "Error: Screenshot Generation scheme not found in xcodebuild list."
  exit 1
fi

if command -v rg >/dev/null 2>&1; then
  if ! rg -q "ScreenshotGenerationTests.swift" "$PBXPROJ_PATH"; then
    echo "Error: ScreenshotGenerationTests.swift is not referenced in project.pbxproj."
    exit 1
  fi
else
  if ! grep -q "ScreenshotGenerationTests.swift" "$PBXPROJ_PATH"; then
    echo "Error: ScreenshotGenerationTests.swift is not referenced in project.pbxproj."
    exit 1
  fi
fi

echo "Verification complete."
