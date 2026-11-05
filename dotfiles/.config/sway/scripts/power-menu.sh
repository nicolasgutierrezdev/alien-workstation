#!/bin/sh
# Power menu: $mod+Shift+e or the power button in the bar.
CHOICE=$(printf '%s\n' Lock Suspend "Log out" Reboot "Shut down" |
    fuzzel --dmenu --prompt "Power › " --lines 5) || exit 0

case "$CHOICE" in
    Lock)        swaylock -f ;;
    Suspend)     systemctl suspend ;;
    "Log out")   swaymsg exit ;;
    Reboot)      systemctl reboot ;;
    "Shut down") systemctl poweroff ;;
esac
