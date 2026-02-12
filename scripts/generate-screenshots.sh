#!/bin/bash

# Multi-device App Store screenshot generator.
# Produces standard raw captures plus marketing-ready composites.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/ios-swift/Notelayer/Notelayer.xcodeproj"
WORKSPACE_PATH="$ROOT_DIR/ios-swift/Notelayer/Notelayer.xcworkspace"
SCHEME_NAME="Screenshot Generation"
TEST_TARGET_NAME="NotelayerScreenshotTests"
SCHEME_PATH="$PROJECT_PATH/xcshareddata/xcschemes/$SCHEME_NAME.xcscheme"
MARKETING_RENDER_SCRIPT="$ROOT_DIR/scripts/render-marketing-screenshots.py"

ASSET_ROOT_DEFAULT="$HOME/Downloads/Documents from Macbook Air 2026/App-Icons-&-screenshots"
ASSET_ROOT="${SCREENSHOT_ASSET_ROOT:-$ASSET_ROOT_DEFAULT}"
OUTPUT_ROOT="$ASSET_ROOT/Screenshots for App Store/Generated"
STANDARD_RAW_ROOT="$OUTPUT_ROOT/standard/raw"
MARKETING_RAW_ROOT="$OUTPUT_ROOT/marketing/raw"
MARKETING_COMPOSED_ROOT="$OUTPUT_ROOT/marketing/composed"
TEMP_ROOT="$ROOT_DIR/ios-swift/Notelayer/Screenshots"

TARGETS="${SCREENSHOT_DEVICE_TARGETS:-iphone,ipad}"
GENERATE_MARKETING="${SCREENSHOT_GENERATE_MARKETING:-true}"

SCREENSHOT_METHODS=(
  "testScreenshot1_TodosListView"
  "testScreenshot2_SignInSheet"
  "testScreenshot3_TaskEditView"
  "testScreenshot4_CategoryView"
  "testScreenshot5_AppearanceView"
  "testScreenshot6_PriorityView"
  "testScreenshot7_InsightsOverview"
  "testScreenshot8_InsightsDetail"
)

echo -e "${GREEN}📸 Starting Multi-Device Screenshot Generation${NC}"
echo -e "${GREEN}Output root:${NC} $OUTPUT_ROOT"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo -e "${RED}❌ xcodebuild not found. Install Xcode and retry.${NC}"
  exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo -e "${RED}❌ xcrun not found. Install Xcode command line tools.${NC}"
  exit 1
fi

if [ ! -f "$SCHEME_PATH" ]; then
  echo -e "${RED}❌ Scheme not found at $SCHEME_PATH${NC}"
  echo -e "${YELLOW}Run ./scripts/setup-screenshot-system.sh to create the scheme.${NC}"
  exit 1
fi

BUILD_CONTAINER_ARGS=()
if [ -d "$WORKSPACE_PATH" ]; then
  BUILD_CONTAINER_ARGS=(-workspace "$WORKSPACE_PATH")
else
  BUILD_CONTAINER_ARGS=(-project "$PROJECT_PATH")
fi

if [ "$GENERATE_MARKETING" = "true" ] && [ ! -f "$MARKETING_RENDER_SCRIPT" ]; then
  echo -e "${RED}❌ Marketing renderer missing: $MARKETING_RENDER_SCRIPT${NC}"
  exit 1
fi

find_simulator_udid() {
  local preferred_name="$1"
  local fallback_regex="$2"
  local udid=""

  udid="$(xcrun simctl list devices available | grep "$preferred_name" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1 || true)"
  if [ -z "$udid" ] && [ -n "$fallback_regex" ]; then
    udid="$(xcrun simctl list devices available | grep -E "$fallback_regex" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1 || true)"
  fi

  echo "$udid"
}

configure_status_bar() {
  local simulator_udid="$1"
  xcrun simctl status_bar "$simulator_udid" clear >/dev/null 2>&1 || true
  xcrun simctl status_bar "$simulator_udid" override \
    --time "9:41" \
    --batteryLevel 100 \
    --batteryState charged \
    --wifiMode active \
    >/dev/null 2>&1 || true
}

run_for_device() {
  local device_key="$1"
  local preferred_name="$2"
  local fallback_regex="$3"

  local simulator_udid
  simulator_udid="$(find_simulator_udid "$preferred_name" "$fallback_regex")"
  if [ -z "$simulator_udid" ]; then
    echo -e "${RED}❌ No simulator found for $device_key (${preferred_name}).${NC}"
    return 1
  fi

  local raw_dir="$STANDARD_RAW_ROOT/$device_key"
  local marketing_raw_dir="$MARKETING_RAW_ROOT/$device_key"
  local temp_dir="$TEMP_ROOT/$device_key"
  local derived_dir="$ROOT_DIR/DerivedData/$device_key"
  local log_path="/tmp/screenshot-build-$device_key.log"
  local test_args=()

  mkdir -p "$raw_dir" "$marketing_raw_dir" "$temp_dir" "$derived_dir"
  rm -f "$raw_dir"/*.png "$marketing_raw_dir"/*.png "$temp_dir"/*.png

  for method in "${SCREENSHOT_METHODS[@]}"; do
    test_args+=("-only-testing:${TEST_TARGET_NAME}/ScreenshotGenerationTests/$method")
  done

  echo ""
  echo -e "${YELLOW}🔍 Running capture for $device_key (${preferred_name})${NC}"
  echo -e "${YELLOW}   Simulator UDID:${NC} $simulator_udid"

  xcrun simctl boot "$simulator_udid" >/dev/null 2>&1 || true
  sleep 2
  configure_status_bar "$simulator_udid"

  set +e
  SCREENSHOT_BACKUP_DIR="$raw_dir" \
  SCREENSHOT_TEMP_DIR="$temp_dir" \
  SCREENSHOT_NAME_PREFIX="$device_key" \
  xcodebuild test \
    "${BUILD_CONTAINER_ARGS[@]}" \
    -scheme "$SCHEME_NAME" \
    -destination "platform=iOS Simulator,id=$simulator_udid" \
    "${test_args[@]}" \
    -derivedDataPath "$derived_dir" \
    -quiet \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee "$log_path"
  local build_status=${PIPESTATUS[0]}
  set -e

  # Export attachments from the latest xcresult bundle to host-accessible files.
  local latest_xcresult
  latest_xcresult="$(ls -td "$derived_dir/Logs/Test/"*.xcresult 2>/dev/null | head -1 || true)"
  if [ -n "$latest_xcresult" ]; then
    local export_dir="$derived_dir/ExportedAttachments/$device_key"
    rm -rf "$export_dir"
    mkdir -p "$export_dir"
    xcrun xcresulttool export attachments --path "$latest_xcresult" --output-path "$export_dir" >/dev/null 2>&1 || true

    python3 - "$export_dir" "$raw_dir" "$device_key" <<'PY'
import json
import os
import re
import shutil
import sys

export_dir, raw_dir, device_key = sys.argv[1:4]
manifest_path = os.path.join(export_dir, "manifest.json")
if not os.path.exists(manifest_path):
    raise SystemExit(0)

with open(manifest_path, "r", encoding="utf-8") as manifest_file:
    manifest = json.load(manifest_file)

for test_entry in manifest:
    for attachment in test_entry.get("attachments", []):
        exported_name = attachment.get("exportedFileName")
        suggested_name = attachment.get("suggestedHumanReadableName", "")
        if not exported_name:
            continue

        match = re.search(r"(screenshot-\d+-[A-Za-z0-9-]+)", suggested_name)
        if not match:
            continue

        source_path = os.path.join(export_dir, exported_name)
        if not os.path.exists(source_path):
            continue

        screenshot_stem = match.group(1)
        destination_path = os.path.join(raw_dir, f"{device_key}-{screenshot_stem}.png")
        shutil.copyfile(source_path, destination_path)
PY
  fi

  shopt -s nullglob
  if [ "$GENERATE_MARKETING" = "true" ]; then
    for screenshot in "$raw_dir"/"${device_key}-screenshot-"*.png; do
      cp -f "$screenshot" "$marketing_raw_dir/$(basename "$screenshot")"
    done
  fi
  shopt -u nullglob

  local screenshot_count
  screenshot_count="$(find "$raw_dir" -maxdepth 1 -name "${device_key}-screenshot-*.png" -type f | wc -l | tr -d ' ')"
  if [ "$build_status" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  xcodebuild reported failures for $device_key. Captured files: $screenshot_count${NC}"
  else
    echo -e "${GREEN}✅ $device_key capture complete. Captured files: $screenshot_count${NC}"
  fi

  return "$build_status"
}

mkdir -p "$STANDARD_RAW_ROOT" "$TEMP_ROOT"
if [ "$GENERATE_MARKETING" = "true" ]; then
  mkdir -p "$MARKETING_RAW_ROOT" "$MARKETING_COMPOSED_ROOT"
fi

overall_status=0
IFS=',' read -r -a requested_targets <<< "$TARGETS"
for target in "${requested_targets[@]}"; do
  case "${target// /}" in
    iphone)
      run_for_device "iphone" "iPhone 17 Pro" "iPhone.*Pro" || overall_status=1
      ;;
    ipad)
      run_for_device "ipad" "iPad Pro 13-inch (M5)" "iPad Pro.*13-inch" || overall_status=1
      ;;
    *)
      echo -e "${YELLOW}⚠️  Unknown target '$target' skipped.${NC}"
      ;;
  esac
done

if [ "$GENERATE_MARKETING" = "true" ]; then
  echo ""
  echo -e "${YELLOW}🎨 Rendering marketing-oriented composites...${NC}"
  python3 "$MARKETING_RENDER_SCRIPT" \
    --source-root "$MARKETING_RAW_ROOT" \
    --output-root "$MARKETING_COMPOSED_ROOT"
fi

echo ""
echo -e "${GREEN}📁 Standard raw set:${NC} $STANDARD_RAW_ROOT"
if [ "$GENERATE_MARKETING" = "true" ]; then
  echo -e "${GREEN}📁 Marketing raw set:${NC} $MARKETING_RAW_ROOT"
  echo -e "${GREEN}📁 Marketing composed set:${NC} $MARKETING_COMPOSED_ROOT"
fi

if [ "$overall_status" -ne 0 ]; then
  echo -e "${YELLOW}⚠️  Completed with some test failures. Check /tmp/screenshot-build-*.log${NC}"
  exit 1
fi

echo -e "${GREEN}🎉 Screenshot generation complete.${NC}"
