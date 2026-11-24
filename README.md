# macOS startup + shutdown chime

Plays a short audio clip when a user logs in and when macOS terminates the background job at logout/shutdown.

> **Tested on:** Daniel's **late-2009 Apple iMac** (`iMac10,1`) running **macOS 15.8.2** via OCLP. The built-in `afplay` and CoreAudio work fine.

## macOS limitation

macOS cannot play audio before the OS boots, so the "startup" chime plays at **login**, not at the Apple logo. The firmware startup bong is left untouched.

For shutdown, the old `LogoutHook` is unreliable on modern macOS. This project instead uses a **LaunchAgent that stays alive and plays the chime when launchd sends SIGTERM at shutdown** (`AlwaysSIGTERMOnShutdown`).

## Files

- `scripts/imac-chime.sh` — plays the MP3 with `afplay -v 1.2`
- `scripts/imac-shutdown-chime.sh` — traps SIGTERM/SIGINT/SIGHUP and plays the chime
- `launchd/com.daniel.startupchime.plist` — `RunAtLoad` login chime
- `launchd/com.daniel.shutdownchime.plist` — always-on background job with `AlwaysSIGTERMOnShutdown`
- `prepare-clip.sh` — optional helper to trim a source MP3 to 30 seconds with `ffmpeg`
- `install.sh` — installs audio, scripts, and both LaunchAgents

The original MP3 is **not included**. Supply your own clip and make sure you have the right to use it.

## Install

```sh
./prepare-clip.sh /path/to/song.mp3   # optional: makes a 30-second clip
./install.sh /path/to/clip-30s.mp3
```

`install.sh` will:

- copy the clip to `/Users/Shared/chime/chime-30s.mp3`
- install both scripts into `~/Library/Scripts/`
- install both plists into `~/Library/LaunchAgents/` and load them

## Customize

- **Volume:** edit `-v 1.2` in both scripts and the plists.
- **Clip length:** `prepare-clip.sh` uses 30 seconds; change `-t 30` to taste.
- **Audio path:** edit `/Users/Shared/chime/chime-30s.mp3` in both scripts.

## Test

```sh
# Login chime
launchctl kickstart -k gui/$(id -u)/com.daniel.startupchime

# Shutdown chime (simulates what launchd does at shutdown)
launchctl kill SIGTERM gui/$(id -u)/com.daniel.shutdownchime
```

## Uninstall

```sh
launchctl unload ~/Library/LaunchAgents/com.daniel.startupchime.plist
launchctl unload ~/Library/LaunchAgents/com.daniel.shutdownchime.plist
rm ~/Library/LaunchAgents/com.daniel.startupchime.plist
rm ~/Library/LaunchAgents/com.daniel.shutdownchime.plist
rm ~/Library/Scripts/imac-chime.sh ~/Library/Scripts/imac-shutdown-chime.sh
rm /Users/Shared/chime/chime-30s.mp3
```

License: MIT for the code. Audio remains under its original copyright.
