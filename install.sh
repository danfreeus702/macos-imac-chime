#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-}"
UID_NUM="${UID_NUM:-501}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This installer is for macOS only." >&2
  exit 1
fi

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "Usage: ./install.sh /path/to/15s-clip.mp3" >&2
  exit 1
fi

echo "==> Installing audio"
mkdir -p /Users/Shared/chime
cp "$SRC" /Users/Shared/chime/chime-15s.mp3
chmod 644 /Users/Shared/chime/chime-15s.mp3

echo "==> Installing login chime (one-shot per boot)"
mkdir -p "$HOME/Library/Scripts" "$HOME/Library/LaunchAgents"
cp "$SCRIPT_DIR/scripts/imac-login-chime.sh" "$HOME/Library/Scripts/imac-login-chime.sh"
chmod 755 "$HOME/Library/Scripts/imac-login-chime.sh"
cp "$SCRIPT_DIR/launchd/com.daniel.startupchime.plist" \
   "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"
chmod 644 "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"

echo "==> Compiling shutdown observer app"
swiftc -O "$SCRIPT_DIR/scripts/ShutdownChime.swift" \
  -o "$HOME/Library/Scripts/ShutdownChime"
chmod 755 "$HOME/Library/Scripts/ShutdownChime"
cp "$SCRIPT_DIR/launchd/com.daniel.shutdownchime.plist" \
   "$HOME/Library/LaunchAgents/com.daniel.shutdownchime.plist"
chmod 644 "$HOME/Library/LaunchAgents/com.daniel.shutdownchime.plist"

for LABEL in com.daniel.startupchime com.daniel.shutdownchime; do
  launchctl unload "$HOME/Library/LaunchAgents/$LABEL.plist" 2>/dev/null || true
  launchctl load -w "$HOME/Library/LaunchAgents/$LABEL.plist"
done

echo "==> Done"
echo "Test login: launchctl kickstart -k gui/$UID_NUM/com.daniel.startupchime"
