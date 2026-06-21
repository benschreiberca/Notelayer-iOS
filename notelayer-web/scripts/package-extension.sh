#!/usr/bin/env bash
# Builds and zips the Notelayer Chrome extension for Web Store submission.
# Run from the repo root: bash notelayer-web/scripts/package-extension.sh
# Output: notelayer-web/notelayer-extension-v<version>.zip

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$(dirname "$SCRIPT_DIR")"
EXT_DIR="$WEB_DIR/extension"

cd "$WEB_DIR"

echo "→ Installing dependencies..."
npm install --silent

echo "→ Building extension..."
npm run build --workspace=extension

# Read version from manifest
MANIFEST="$EXT_DIR/dist/manifest.json"
if [[ ! -f "$MANIFEST" ]]; then
  # Fall back to public manifest if dist isn't populated yet
  MANIFEST="$EXT_DIR/public/manifest.json"
fi
VERSION=$(node -pe "require('$MANIFEST').version")

OUTPUT="$WEB_DIR/notelayer-extension-v${VERSION}.zip"

echo "→ Packaging dist/ → $(basename "$OUTPUT")..."
cd "$EXT_DIR/dist"
zip -r "$OUTPUT" . -x "*.DS_Store" -x "__MACOSX/*"

echo ""
echo "✓ Done: $OUTPUT"
echo ""
echo "Next steps:"
echo "  1. Go to https://chrome.google.com/webstore/devconsole"
echo "  2. Select Notelayer → Package tab → Upload new package"
echo "  3. Upload $(basename "$OUTPUT")"
echo "  4. Fill in store listing, screenshots, and privacy policy URL"
echo "  5. Submit for review"
