#!/bin/bash

# Pre-Submission Configuration Verification Script
# Verifies app configuration against App Store submission requirements

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_FILE="$PROJECT_ROOT/ios-swift/Notelayer/Notelayer.xcodeproj/project.pbxproj"
INFO_PLIST="$PROJECT_ROOT/ios-swift/Notelayer/Info.plist"
ENTITLEMENTS="$PROJECT_ROOT/ios-swift/Notelayer/Notelayer/Notelayer.entitlements"

# Expected values
EXPECTED_BUNDLE_ID="com.notelayer.app"
EXPECTED_VERSION="1.0"
EXPECTED_BUILD="1"
EXPECTED_DEPLOYMENT_TARGET="16.0"

echo "=========================================="
echo "Pre-Submission Configuration Check"
echo "=========================================="
echo ""

# Function to extract value from project.pbxproj (Release configuration)
extract_project_value() {
    local key=$1
    # Find Release configuration block and extract the value
    # Look for the Release configuration section (BC2CCDE32F174A5200406D9A /* Release */)
    sed -n '/BC2CCDE32F174A5200406D9A \/\* Release \*\//,/^[[:space:]]*};/p' "$PROJECT_FILE" | \
    grep "^[[:space:]]*$key" | \
    head -1 | \
    sed "s/.*$key = *\(.*\);/\1/" | \
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
    sed 's/;$//'
}

# Function to extract value from Info.plist
extract_plist_value() {
    local key=$1
    /usr/libexec/PlistBuddy -c "Print :$key" "$INFO_PLIST" 2>/dev/null || echo "NOT_FOUND"
}

# Function to check entitlements
check_entitlement() {
    local key=$1
    if /usr/libexec/PlistBuddy -c "Print :$key" "$ENTITLEMENTS" 2>/dev/null | grep -q .; then
        echo "YES"
    else
        echo "NO"
    fi
}

# 1. Bundle Identifier
echo "1. Bundle Identifier"
echo "   Expected: $EXPECTED_BUNDLE_ID"
BUNDLE_ID=$(extract_project_value "PRODUCT_BUNDLE_IDENTIFIER")
echo "   Found:    $BUNDLE_ID"
if [ "$BUNDLE_ID" = "$EXPECTED_BUNDLE_ID" ]; then
    echo "   Status:   ✅ MATCH"
else
    echo "   Status:   ❌ MISMATCH"
fi
echo ""

# 2. Version Number (CFBundleShortVersionString)
echo "2. Version Number (CFBundleShortVersionString)"
echo "   Expected: $EXPECTED_VERSION"
VERSION=$(extract_project_value "MARKETING_VERSION")
echo "   Found:    $VERSION"
if [ "$VERSION" = "$EXPECTED_VERSION" ]; then
    echo "   Status:   ✅ MATCH"
else
    echo "   Status:   ❌ MISMATCH"
fi
echo ""

# 3. Build Number (CFBundleVersion)
echo "3. Build Number (CFBundleVersion)"
echo "   Expected: $EXPECTED_BUILD"
BUILD=$(extract_project_value "CURRENT_PROJECT_VERSION")
echo "   Found:    $BUILD"
if [ "$BUILD" = "$EXPECTED_BUILD" ]; then
    echo "   Status:   ✅ MATCH"
else
    echo "   Status:   ❌ MISMATCH"
fi
echo ""

# 4. Deployment Target
echo "4. iOS Deployment Target"
echo "   Expected: $EXPECTED_DEPLOYMENT_TARGET"
DEPLOYMENT_TARGET=$(extract_project_value "IPHONEOS_DEPLOYMENT_TARGET")
echo "   Found:    $DEPLOYMENT_TARGET"
if [ "$DEPLOYMENT_TARGET" = "$EXPECTED_DEPLOYMENT_TARGET" ]; then
    echo "   Status:   ✅ MATCH"
else
    echo "   Status:   ❌ MISMATCH"
fi
echo ""

# 5. Capabilities - Sign in with Apple
echo "5. Capabilities - Sign in with Apple"
SIGN_IN_APPLE=$(check_entitlement "com.apple.developer.applesignin")
if [ "$SIGN_IN_APPLE" = "YES" ]; then
    echo "   Status:   ✅ CONFIGURED"
else
    echo "   Status:   ❌ NOT CONFIGURED"
fi
echo ""

# 6. Capabilities - Push Notifications
echo "6. Capabilities - Push Notifications"
PUSH_NOTIFICATIONS=$(check_entitlement "aps-environment")
if [ "$PUSH_NOTIFICATIONS" = "YES" ]; then
    APS_ENV=$(/usr/libexec/PlistBuddy -c "Print :aps-environment" "$ENTITLEMENTS" 2>/dev/null || echo "NOT_FOUND")
    echo "   Environment: $APS_ENV"
    echo "   Status:   ✅ CONFIGURED"
    # Also check project.pbxproj for Push capability
    PUSH_ENABLED=$(grep -A 3 "com.apple.Push" "$PROJECT_FILE" | grep "enabled" | head -1 | sed 's/.*enabled = *\(.*\);/\1/' | tr -d ' ')
    if [ "$PUSH_ENABLED" = "1" ]; then
        echo "   Project Setting: ✅ Enabled"
    else
        echo "   Project Setting: ❌ Not Enabled"
    fi
else
    echo "   Status:   ❌ NOT CONFIGURED"
fi
echo ""

# 7. Info.plist Required Keys
echo "7. Info.plist Required Keys"
echo "   Checking for required keys..."

REQUIRED_KEYS=(
    "CFBundleIdentifier"
    "CFBundleShortVersionString"
    "CFBundleVersion"
    "CFBundleName"
    "CFBundleExecutable"
    "LSRequiresIPhoneOS"
)

for key in "${REQUIRED_KEYS[@]}"; do
    value=$(extract_plist_value "$key")
    if [ "$value" != "NOT_FOUND" ]; then
        echo "   ✅ $key: Present"
    else
        echo "   ❌ $key: MISSING"
    fi
done
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Bundle ID:        $BUNDLE_ID"
echo "Version:          $VERSION"
echo "Build:            $BUILD"
echo "Deployment:       iOS $DEPLOYMENT_TARGET"
echo "Sign in Apple:    $SIGN_IN_APPLE"
echo "Push Notifications: $PUSH_NOTIFICATIONS"
echo ""

# Exit with error if any checks failed
if [ "$BUNDLE_ID" != "$EXPECTED_BUNDLE_ID" ] || \
   [ "$VERSION" != "$EXPECTED_VERSION" ] || \
   [ "$BUILD" != "$EXPECTED_BUILD" ] || \
   [ "$DEPLOYMENT_TARGET" != "$EXPECTED_DEPLOYMENT_TARGET" ] || \
   [ "$SIGN_IN_APPLE" != "YES" ] || \
   [ "$PUSH_NOTIFICATIONS" != "YES" ]; then
    echo "❌ Some checks failed. Please review the output above."
    exit 1
else
    echo "✅ All checks passed!"
    exit 0
fi
