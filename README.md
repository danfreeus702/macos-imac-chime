# macOS login + shutdown chime

Plays a 15-second audio clip on the **first login after a boot** and again at **shutdown/restart**.

> **Tested on:** Daniel's **late-2009 Apple iMac** (`iMac10,1`) running **macOS 15.8.2** via OCLP.

## How it works

- **Firmware bong is left untouched.** macOS cannot play an arbitrary MP3 before the OS boots.
- **Login chime:** a `RunAtLoad` LaunchAgent calls `imac-login-chime.sh`, which checks a boot-time marker and plays only once per boot.
- **Shutdown chime:** a small Cocoa observer app (`ShutdownChime.swift`) runs as a LaunchAgent. It watches macOS's real logout/restart/shutdown Apple Event and delays termination until the 15-second clip finishes.

The old `LogoutHook` and the `SIGTERM`/LaunchDaemon approach are not used — neither is reliable on modern macOS.

## Files

- `scripts/imac-login-chime.sh` — one-shot login chime (15s clip, boot-time marker)
- `scripts/ShutdownChime.swift` — Cocoa app that detects shutdown and plays the chime
- `launchd/com.daniel.startupchime.plist` — user LaunchAgent
- `launchd/com.daniel.shutdownchime.plist` — user LaunchAgent for the observer app
- `prepare-clip.sh` — trims a source MP3 to 15 seconds with `ffmpeg`
- `install.sh` — installs everything

Audio is **not included**. Supply your own clip.

## Install

```sh
./prepare-clip.sh /path/to/song.mp3      # makes a 15-second clip
./install.sh /path/to/clip-15s.mp3
```

## Customize

- **Volume:** edit `-v 1.2` in the scripts.
- **Duration:** `prepare-clip.sh` uses `-t 15`.

## Test

```sh
# Login chime (once per boot)
launchctl kickstart -k gui/$(id -u)/com.daniel.startupchime

# Shutdown chime
# Shutdown chime is verified by restarting the Mac
```

## Uninstall

```sh
launchctl unload -w ~/Library/LaunchAgents/com.daniel.startupchime.plist
launchctl unload -w ~/Library/LaunchAgents/com.daniel.shutdownchime.plist
rm ~/Library/LaunchAgents/com.daniel.startupchime.plist
rm ~/Library/LaunchAgents/com.daniel.shutdownchime.plist
rm ~/Library/Scripts/imac-login-chime.sh ~/Library/Scripts/ShutdownChime
rm /Users/Shared/chime/chime-15s.mp3
```

License: MIT for the code. Audio remains under its original copyright.
