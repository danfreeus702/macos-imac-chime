# macOS login + shutdown chime

Plays a 15-second audio clip on the **first login after a boot** and again at **shutdown/restart**.

> **Tested on:** Daniel's **late-2009 Apple iMac** (`iMac10,1`) running **macOS 15.8.2** via OCLP.

## How it works

- **Firmware bong is left untouched.** macOS cannot play an arbitrary MP3 before the OS boots.
- **Login chime:** a `RunAtLoad` LaunchAgent calls `imac-login-chime.sh`, which checks a boot-time marker and plays only once per boot.
- **Shutdown chime:** a root **LaunchDaemon** stays alive and plays the clip when launchd sends `SIGTERM` at shutdown (`AlwaysSIGTERMOnShutdown`). It uses `launchctl asuser 501 afplay` so audio reaches the logged-in user session.

The old `LogoutHook` is not used — it is unreliable on modern macOS.

## Files

- `scripts/imac-login-chime.sh` — one-shot login chime (15s clip, boot-time marker)
- `scripts/imac-shutdown-chime-daemon.sh` — shutdown trap, plays as user 501
- `launchd/com.daniel.startupchime.plist` — user LaunchAgent
- `launchd/com.daniel.shutdownchime.plist` — system LaunchDaemon
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
- **User ID:** the daemon uses `asuser 501`; change if the target user has a different UID.

## Test

```sh
# Login chime (once per boot)
launchctl kickstart -k gui/$(id -u)/com.daniel.startupchime

# Shutdown chime
sudo launchctl kill SIGTERM system/com.daniel.shutdownchime
```

## Uninstall

```sh
launchctl unload -w ~/Library/LaunchAgents/com.daniel.startupchime.plist
sudo launchctl unload -w /Library/LaunchDaemons/com.daniel.shutdownchime.plist
rm ~/Library/LaunchAgents/com.daniel.startupchime.plist
sudo rm /Library/LaunchDaemons/com.daniel.shutdownchime.plist
rm ~/Library/Scripts/imac-login-chime.sh
sudo rm /usr/local/bin/imac-shutdown-chime-daemon.sh /Users/Shared/chime/chime-15s.mp3
```

License: MIT for the code. Audio remains under its original copyright.
