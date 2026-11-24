#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This installer is for macOS only." >&2
  exit 1
fi

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "Usage: ./install.sh /path/to/30s-clip.mp3" >&2
  exit 1
fi

for cmd in afplay launchctl mkdir cp chmod; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing: $cmd" >&2; exit 1; }
done

echo "==> Installing audio"
mkdir -p /Users/Shared/chime
cp "$SRC" /Users/Shared/chime/chime-30s.mp3
chmod 644 /Users/Shared/chime/chime-30s.mp3

echo "==> Installing scripts"
mkdir -p "$HOME/Library/Scripts"
cp "$SCRIPT_DIR/scripts/imac-chime.sh" "$HOME/Library/Scripts/imac-chime.sh"
cp "$SCRIPT_DIR/scripts/imac-shutdown-chime.sh" "$HOME/Library/Scripts/imac-shutdown-chime.sh"
chmod 755 "$HOME/Library/Scripts/imac-chime.sh" "$HOME/Library/Scripts/imac-shutdown-chime.sh"

echo "==> Installing LaunchAgents"
mkdir -p "$HOME/Library/LaunchAgents"
cp "$SCRIPT_DIR/launchd/com.daniel.startupchime.plist" \
   "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"
cp "$SCRIPT_DIR/launchd/com.daniel.shutdownchime.plist" \
   "$HOME/Library/LaunchAgents/com.daniel.shutdownchime.plist"
chmod 644 "$HOME/Library/LaunchAgents/"com.daniel.*chime.plist

for LABEL in com.daniel.startupchime com.daniel.shutdownchime; do
  launchctl unload "$HOME/Library/LaunchAgents/$LABEL.plist" 2>/dev/null || true
  launchctl load -w "$HOME/Library/LaunchAgents/$LABEL.plist"
done

echo "==> Done"
echo "Test startup:  launchctl kickstart -k gui/\$(id -u)/com.daniel.startupchime"
echo "Test shutdown: launchctl kill SIGTERM gui/\$(id -u)/com.daniel.shutdownchime"
