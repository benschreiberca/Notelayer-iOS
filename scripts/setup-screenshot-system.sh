#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/ios-swift/Notelayer/Notelayer.xcodeproj"
PBXPROJ_PATH="$PROJECT_PATH/project.pbxproj"
SCHEME_PATH="$PROJECT_PATH/xcshareddata/xcschemes/Screenshot Generation.xcscheme"
RUBY_SCRIPT="$ROOT_DIR/scripts/add-screenshot-target.rb"
VERIFY_SCRIPT="$ROOT_DIR/scripts/verify-screenshot-setup.sh"
BACKUP_DIR="$ROOT_DIR/scripts/backups"

RUN_GENERATION=true
for arg in "$@"; do
  case "$arg" in
    --skip-generate)
      RUN_GENERATION=false
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 [--skip-generate]"
      exit 1
      ;;
  esac
done

if [ ! -f "$PBXPROJ_PATH" ]; then
  echo "Error: project file not found at $PBXPROJ_PATH"
  exit 1
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "Error: ruby is required but was not found."
  exit 1
fi

if ! command -v gem >/dev/null 2>&1; then
  echo "Error: gem is required but was not found."
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Error: xcodebuild not found. Install Xcode and try again."
  exit 1
fi

mkdir -p "$BACKUP_DIR"
timestamp="$(date +%Y%m%d%H%M%S)"
backup_pbxproj="$BACKUP_DIR/project.pbxproj.$timestamp.bak"
backup_scheme="$BACKUP_DIR/Screenshot-Generation.xcscheme.$timestamp.bak"

cp "$PBXPROJ_PATH" "$backup_pbxproj"
if [ -f "$SCHEME_PATH" ]; then
  cp "$SCHEME_PATH" "$backup_scheme"
else
  backup_scheme=""
fi

restore_on_error() {
  echo "Error detected. Restoring backups..."
  if [ -f "$backup_pbxproj" ]; then
    cp "$backup_pbxproj" "$PBXPROJ_PATH"
  fi
  if [ -n "${backup_scheme}" ] && [ -f "$backup_scheme" ]; then
    cp "$backup_scheme" "$SCHEME_PATH"
  fi
}

trap restore_on_error ERR

GEM_USER_DIR="$(ruby -e 'print Gem.user_dir')"
export PATH="$GEM_USER_DIR/bin:$PATH"

if ! ruby -e "require 'xcodeproj'" >/dev/null 2>&1; then
  echo "Installing xcodeproj gem..."
  gem install xcodeproj --user-install --no-document
fi

if ! ruby -e "require 'xcodeproj'" >/dev/null 2>&1; then
  echo "Error: xcodeproj gem is not available after installation."
  exit 1
fi

echo "Updating Xcode project..."
ruby "$RUBY_SCRIPT" "$PROJECT_PATH"

echo "Verifying setup..."
bash "$VERIFY_SCRIPT"

if [ "$RUN_GENERATION" = true ]; then
  echo "Running screenshot generation..."
  bash "$ROOT_DIR/scripts/generate-screenshots.sh"
fi

echo "Setup complete."
