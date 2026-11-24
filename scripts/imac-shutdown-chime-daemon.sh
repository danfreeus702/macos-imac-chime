#!/bin/sh
# System daemon: on SIGTERM at shutdown, play the 15s chime in the user's GUI session.
play_chime() {
  /bin/echo "$(/bin/date) daemon trap fired" >> /tmp/imac-shutdown-chime-daemon.log
  /bin/launchctl asuser 501 /usr/bin/afplay -v 1.2 /Users/Shared/chime/chime-15s.mp3 >/dev/null 2>&1
  exit 0
}
trap play_chime SIGTERM SIGINT SIGHUP
while true; do
  sleep 86400 &
  wait $!
done
