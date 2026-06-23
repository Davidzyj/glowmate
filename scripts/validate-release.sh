#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT_DIR/GlowMate.xcodeproj"
PLIST="$ROOT_DIR/GlowMate/Info.plist"
LOG_DIR="$ROOT_DIR/build/logs"
DERIVED_DATA="$ROOT_DIR/build/DerivedData-release"
mkdir -p "$LOG_DIR"

echo "Validating Info.plist..."
plutil -lint "$PLIST"

encryption="$(plutil -extract ITSAppUsesNonExemptEncryption raw "$PLIST")"
if [[ "$encryption" != "false" ]]; then
  echo "ITSAppUsesNonExemptEncryption must be false, got $encryption"
  exit 1
fi

style="$(plutil -extract UIUserInterfaceStyle raw "$PLIST")"
if [[ "$style" != "Light" ]]; then
  echo "UIUserInterfaceStyle must be Light, got $style"
  exit 1
fi

photo_usage="$(plutil -extract NSPhotoLibraryAddUsageDescription raw "$PLIST")"
if [[ -z "$photo_usage" ]]; then
  echo "NSPhotoLibraryAddUsageDescription must be present for save-to-library"
  exit 1
fi

family="$(plutil -extract UIDeviceFamily.0 raw "$PLIST")"
if [[ "$family" != "1" ]]; then
  echo "UIDeviceFamily must be iPhone-only, got $family"
  exit 1
fi

settings="$(xcodebuild -project "$PROJECT" -target GlowMate -configuration Release -showBuildSettings)"
if ! grep -q "INFOPLIST_FILE = GlowMate/Info.plist" <<< "$settings"; then
  echo "Target is not using GlowMate/Info.plist"
  exit 1
fi
if ! grep -q "PRODUCT_BUNDLE_IDENTIFIER = com.zhouyajie.glowmate" <<< "$settings"; then
  echo "Unexpected bundle identifier"
  exit 1
fi
if ! grep -q "TARGETED_DEVICE_FAMILY = 1" <<< "$settings"; then
  echo "Target must be iPhone-only"
  exit 1
fi

echo "Checking screenshot demo isolation..."
if ! grep -q "#if DEBUG" "$ROOT_DIR/GlowMate/ScreenshotMode.swift"; then
  echo "ScreenshotMode.swift must guard screenshot behavior with #if DEBUG"
  exit 1
fi
if ! grep -q "#if DEBUG" "$ROOT_DIR/GlowMate/GlowMateModel.swift"; then
  echo "GlowMateModel.swift must guard screenshot demo state with #if DEBUG"
  exit 1
fi

echo "Checking app icon..."
sips -g pixelWidth -g pixelHeight -g hasAlpha "$ROOT_DIR/GlowMate/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" > "$LOG_DIR/icon-check.txt"
if ! grep -q "pixelWidth: 1024" "$LOG_DIR/icon-check.txt" || ! grep -q "pixelHeight: 1024" "$LOG_DIR/icon-check.txt"; then
  cat "$LOG_DIR/icon-check.txt"
  echo "App icon must be 1024x1024"
  exit 1
fi
if ! grep -q "hasAlpha: no" "$LOG_DIR/icon-check.txt"; then
  cat "$LOG_DIR/icon-check.txt"
  echo "App icon must not contain alpha"
  exit 1
fi

echo "Building Release for simulator..."
xcodebuild \
  -project "$PROJECT" \
  -scheme GlowMate \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.2' \
  -derivedDataPath "$DERIVED_DATA" \
  build > "$LOG_DIR/release-build.log" 2>&1

echo "Release validation passed."
