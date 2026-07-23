#!/bin/bash
#
# Builds a polished, drag-to-Applications DMG from an already-built
# SPEAKEX.app (see build-app.sh) — custom background, positioned
# icons, no visible Finder toolbar/sidebar clutter. Requires macOS
# (uses hdiutil + Finder AppleScript automation).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${1:-$ROOT_DIR/dist/SPEAKEX.app}"
OUTPUT_DMG="${2:-$ROOT_DIR/dist/SPEAKEX.dmg}"
BACKGROUND_PNG="$ROOT_DIR/icon/dmg-background.png"
VOLUME_NAME="SPEAKEX"

say() { printf 'SPEAKEX: %s\n' "$*"; }
fail() { printf 'SPEAKEX: %s\n' "$*" >&2; exit 1; }

[[ -d "$APP_PATH" ]] || fail "App bundle not found at $APP_PATH — run build-app.sh first."
[[ -f "$BACKGROUND_PNG" ]] || fail "Background image not found at $BACKGROUND_PNG."
command -v hdiutil >/dev/null 2>&1 || fail "hdiutil is required (macOS only)."

STAGE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/speakex-dmg.XXXXXX")"
trap 'rm -rf "$STAGE_ROOT"' EXIT
STAGE_DIR="$STAGE_ROOT/contents"
mkdir "$STAGE_DIR"

say "Staging DMG contents..."
cp -R "$APP_PATH" "$STAGE_DIR/"
ln -s /Applications "$STAGE_DIR/Applications"
mkdir "$STAGE_DIR/.background"
cp "$BACKGROUND_PNG" "$STAGE_DIR/.background/background.png"

# The output .dmg must live outside $STAGE_DIR — otherwise hdiutil
# ends up trying to copy its own (growing) output file as part of the
# source folder it's reading from.
RW_DMG="$STAGE_ROOT/rw.dmg"
say "Creating writable DMG..."
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$STAGE_DIR" \
  -fs HFS+ -format UDRW -ov "$RW_DMG" \
  -size 100m >/dev/null

say "Mounting for layout..."
MOUNT_DIR="/Volumes/$VOLUME_NAME"
if [[ -d "$MOUNT_DIR" ]]; then
  hdiutil detach "$MOUNT_DIR" -quiet -force || true
fi
hdiutil attach "$RW_DMG" -noautoopen -quiet

# Give Finder a moment to register the new volume before scripting it.
sleep 1

osascript <<APPLESCRIPT
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {200, 120, 860, 540}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set background picture of viewOptions to file ".background:background.png"
        set position of item "SPEAKEX.app" of container window to {165, 190}
        set position of item "Applications" of container window to {495, 190}
        close
        open
        update without registering applications
        delay 1
    end tell
end tell
APPLESCRIPT

sync
hdiutil detach "$MOUNT_DIR" -quiet

say "Compressing final DMG..."
rm -f "$OUTPUT_DMG"
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -o "$OUTPUT_DMG" >/dev/null

say "Built $OUTPUT_DMG"
