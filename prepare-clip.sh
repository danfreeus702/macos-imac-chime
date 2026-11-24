#!/bin/sh
set -e

SRC="${1:-}"
OUT="${2:-/tmp/chime-30s.mp3}"

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "Usage: ./prepare-clip.sh /path/to/source.mp3 [output.mp3]" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required to trim the clip." >&2
  exit 1
fi

ffmpeg -y -loglevel error -i "$SRC" -t 30 -c:a libmp3lame -q:a 2 "$OUT"
echo "Created 30-second clip: $OUT"
