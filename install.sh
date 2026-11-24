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

echo "==> Installing login chime (user LaunchAgent)"
mkdir -p "$HOME/Library/Scripts" "$HOME/Library/LaunchAgents"
cp "$SCRIPT_DIR/scripts/imac-login-chime.sh" "$HOME/Library/Scripts/imac-login-chime.sh"
chmod 755 "$HOME/Library/Scripts/imac-login-chime.sh"
cp "$SCRIPT_DIR/launchd/com.daniel.startupchime.plist" \
   "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"
chmod 644 "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"
launchctl unload "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist" 2>/dev/null || true
launchctl load -w "$HOME/Library/LaunchAgents/com.daniel.startupchime.plist"

echo "==> Installing shutdown chime (root LaunchDaemon, sudo required)"
sudo install -m 755 "$SCRIPT_DIR/scripts/imac-shutdown-chime-daemon.sh" \
  /usr/local/bin/imac-shutdown-chime-daemon.sh
sed "s/asuser 501/asuser $UID_NUM/" "$SCRIPT_DIR/launchd/com.daniel.shutdownchime.plist" > /tmp/com.daniel.shutdownchime.plist
sudo install -m 644 /tmp/com.daniel.shutdownchime.plist \
  /Library/LaunchDaemons/com.daniel.shutdownchime.plist
sudo launchctl unload /Library/LaunchDaemons/com.daniel.shutdownchime.plist 2>/dev/null || true
sudo launchctl load -w /Library/LaunchDaemons/com.daniel.shutdownchime.plist

echo "==> Done"
echo "Test login:    launchctl kickstart -k gui/\$(id -u)/com.daniel.startupchime"
echo "Test shutdown: sudo launchctl kill SIGTERM system/com.daniel.shutdownchime"
