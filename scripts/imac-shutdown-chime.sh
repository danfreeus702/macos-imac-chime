#!/bin/sh
# Runs as a LaunchAgent. Plays the chime when launchd terminates it at logout/shutdown.
chime() {
  /usr/bin/afplay -v 1.2 /Users/Shared/chime/chime-30s.mp3 >/dev/null 2>&1
  exit 0
}
trap chime SIGTERM SIGINT SIGHUP
while true; do
  sleep 86400 &
  wait $!
done
