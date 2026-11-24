#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="${1:-}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "This installer is for macOS only." >&2
  exit 1
fi

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "Usage: sudo? no — run as your normal user: ./install.sh /path/to/30s-clip.mp3" >&2
  exit 1
fi

for cmd in afplay launchctl sudo defaults install; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing: $cmd" >&2; exit 1; }
done

echo "==> Installing audio"
mkdir -p /Users/Shared/chime
cp "$SRC" /Users/Shared/chime/chime-30s.mp3
chmod 644 /Users/Shared/chime/chime-30s.mp3

echo "==> Installing playback script (sudo required)"
sudo install -m 755 "$SCRIPT_DIR/scripts/imac-chime.sh" /usr/local/bin/imac-chime.sh
sudo defaults write com.apple.loginwindow LogoutHook /usr/local/bin/imac-chime.sh

echo "==> Installing LaunchAgent"
mkdir -p "$HOME/Library/LaunchAgents"
cp "$SCRIPT_DIR/launchd/com.daniel.startupchime.plist" \
   "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"
chmod 644 "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"
launchctl unload "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist" 2>/dev/null || true
launchctl load -w "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"

echo "==> Done"
echo "Test: /usr/local/bin/imac-chime.sh"
echo "Logout hook: $(sudo defaults read com.apple.loginwindow LogoutHook)"
