#!/bin/sh
# Play only on the first login after a boot.
BOOT=$(/usr/sbin/sysctl -n kern.boottime | /usr/bin/awk -F"sec = " "{split(\$2,a,\",\"); print a[1]}")
MARK=/Users/Shared/chime/.last-login-boot
LAST=$(/bin/cat "$MARK" 2>/dev/null)
if [ "$BOOT" != "$LAST" ]; then
  /usr/bin/afplay -v 1.2 /Users/Shared/chime/chime-30s.mp3 >/dev/null 2>&1
  /bin/echo "$BOOT" > "$MARK"
fi
exit 0
