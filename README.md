# Mac Mini / iMac startup + logout chime (macOS)

Plays a short audio clip when a user logs in and when they log out or shut down/restart.

> **Tested on:** Daniel's **late-2009 Apple iMac** (`iMac10,1`) running **macOS 15.8.2** via OCLP. It has no Metal/GPU apps, but CoreAudio and the built-in `afplay` work fine.

## macOS limitation

macOS cannot play audio before the OS boots, so the "startup" chime plays at **login**, not at the Apple logo. The logout hook runs on logout, which happens before Shut Down or Restart.

## Files

- `scripts/imac-chime.sh` — plays the MP3 with `afplay -v 1.2`
- `launchd/com.daniel.startupchime.plist` — LaunchAgent with `RunAtLoad`
- `prepare-clip.sh` — optional helper to trim a source MP3 to 30 seconds with `ffmpeg`
- `install.sh` — installs the audio, script, LaunchAgent, and LogoutHook

The original MP3 is **not included**. Supply your own clip and make sure you have the right to use it.

## Install

```sh
./prepare-clip.sh /path/to/song.mp3   # optional: makes a 30-second clip
./install.sh /path/to/clip-30s.mp3
```

`install.sh` will:

- copy the clip to `/Users/Shared/chime/chime-30s.mp3`
- install `/usr/local/bin/imac-chime.sh` (requires `sudo`)
- register `com.apple.loginwindow LogoutHook`
- install `~/Library/LaunchAgents/com.daniel.startupchime.plist` and load it

## Customize

- **Volume:** edit `-v 1.2` in both `scripts/imac-chime.sh` and the plist.
- **Clip length:** `prepare-clip.sh` uses 30 seconds; change `-t 30` to taste.
- **Audio path:** edit `/Users/Shared/chime/chime-30s.mp3` in both files.

## Test

```sh
/usr/local/bin/imac-chime.sh                       # manual play
launchctl kickstart -k gui/$(id -u)/com.daniel.startupchime
```

To verify the logout chime, log out (don't just lock the screen).

## Uninstall

```sh
launchctl unload ~/Library/LaunchAgents/com.daniel.startupchime.plist
rm ~/Library/LaunchAgents/com.daniel.startupchime.plist
sudo defaults delete com.apple.loginwindow LogoutHook
sudo rm -f /usr/local/bin/imac-chime.sh /Users/Shared/chime/chime-30s.mp3
```

License: MIT for the code. Audio remains under its original copyright.
