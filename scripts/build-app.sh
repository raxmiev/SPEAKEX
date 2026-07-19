#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_APP="${1:-$ROOT_DIR/dist/SPEAKEX.app}"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

say() {
    printf 'SPEAKEX: %s\n' "$*"
}

fail() {
    printf 'SPEAKEX: %s\n' "$*" >&2
    exit 1
}

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS is required."
[[ "$(uname -m)" == "arm64" ]] || fail "An Apple Silicon Mac (M1 or newer) is required."
command -v swift >/dev/null 2>&1 || fail "Swift is missing. Run: xcode-select --install"
command -v codesign >/dev/null 2>&1 || fail "codesign is missing. Run: xcode-select --install"

say "Building the release app..."
swift build -c release --package-path "$ROOT_DIR/swift"
BIN_DIR="$(swift build -c release --package-path "$ROOT_DIR/swift" --show-bin-path)"
BIN="$BIN_DIR/Speakex"
[[ -x "$BIN" ]] || fail "The Swift build did not produce $BIN"

STAGE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/speakex-build.XXXXXX")"
trap 'rm -rf "$STAGE_DIR"' EXIT
STAGE_APP="$STAGE_DIR/SPEAKEX.app"

mkdir -p "$STAGE_APP/Contents/MacOS" "$STAGE_APP/Contents/Resources"
cp "$BIN" "$STAGE_APP/Contents/MacOS/SPEAKEX"
cp "$ROOT_DIR/swift/Info.plist" "$STAGE_APP/Contents/Info.plist"
cp "$ROOT_DIR/swift/Resources/speakex-menubarTemplate.png" "$STAGE_APP/Contents/Resources/"
cp "$ROOT_DIR/swift/Resources/speakex-menubarTemplate@2x.png" "$STAGE_APP/Contents/Resources/"
cp "$ROOT_DIR/icon/Speakex.icns" "$STAGE_APP/Contents/Resources/Speakex.icns"
chmod 755 "$STAGE_APP/Contents/MacOS/SPEAKEX"

SIGN_ARGS=(--force --deep --sign "$SIGN_IDENTITY" --options runtime
           --entitlements "$ROOT_DIR/entitlements.plist")
if [[ "$SIGN_IDENTITY" == "-" ]]; then
    SIGN_ARGS+=(--timestamp=none)
else
    SIGN_ARGS+=(--timestamp)
fi

say "Signing the app..."
codesign "${SIGN_ARGS[@]}" "$STAGE_APP"
codesign --verify --deep --strict "$STAGE_APP"

mkdir -p "$(dirname "$OUTPUT_APP")"
rm -rf "$OUTPUT_APP"
mv "$STAGE_APP" "$OUTPUT_APP"
trap - EXIT
rm -rf "$STAGE_DIR"

say "Built $OUTPUT_APP"

