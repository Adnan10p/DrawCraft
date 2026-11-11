#!/usr/bin/env bash
# Build an AppImage. Usage: build-appimage.sh <version> <release-dir> [x86_64|arm64]
set -euo pipefail
VERSION="$1"; BIN="$2"; ARCH="${3:-x86_64}"
# linuxdeploy names the machine its own way. The x86_64 file is named
# amd64 so that it sorts before arm64 in a release's file list: updaters
# of 0.19.8 and earlier take the first AppImage listed (#1038).
case "$ARCH" in arm64) TOOL_ARCH=aarch64 ;; *) TOOL_ARCH=x86_64 ;; esac
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DIR="$ROOT/dist/AppDir"; rm -rf "$DIR"
mkdir -p "$DIR/usr/bin" "$DIR/usr/share/applications" "$DIR/usr/share/icons/hicolor/256x256/apps"
if [ -f "$BIN/drawcraft" ]; then cp "$BIN/drawcraft" "$DIR/usr/bin/drawcraft"; else cp "$BIN/tracedraw" "$DIR/usr/bin/drawcraft"; fi
ln -sf drawcraft "$DIR/usr/bin/tracedraw"
if [ -f "$BIN/tracedraw-cli" ]; then cp "$BIN/tracedraw-cli" "$DIR/usr/bin/"; fi
cp "$ROOT/packaging/linux/tracedraw.desktop" "$DIR/usr/share/applications/drawcraft.desktop"
cp "$ROOT/assets/icon/drawcraft-256.png" "$DIR/usr/share/icons/hicolor/256x256/apps/tracedraw.png"
TOOL="$ROOT/dist/linuxdeploy.AppImage"
[ -f "$TOOL" ] || curl -sSL -o "$TOOL" https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$TOOL_ARCH.AppImage
chmod +x "$TOOL"
cd "$ROOT/dist"
OUT="drawcraft-$VERSION-linux-$TOOL_ARCH.AppImage"
VERSION="$VERSION" ARCH="$TOOL_ARCH" OUTPUT="$OUT" "$TOOL" --appimage-extract-and-run \
  --appdir "$DIR" --desktop-file "$DIR/usr/share/applications/drawcraft.desktop" \
  --icon-file "$DIR/usr/share/icons/hicolor/256x256/apps/tracedraw.png" --output appimage
rm -rf "$DIR"
