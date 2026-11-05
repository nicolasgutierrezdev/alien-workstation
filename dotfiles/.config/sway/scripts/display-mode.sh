#!/bin/sh
# Display menu, like Win+P: extend, mirror (duplicate) or use one screen.
# Bound to $mod+p and the laptop display key.
# The main screen is the built-in panel (eDP-*, LVDS-*, DSI-*) when there is one,
# otherwise the first screen sway reports (e.g. a desktop with two monitors).
outputs() { swaymsg -t get_outputs -r; }

INT=$(outputs | jq -r '[.[] | select(.name | test("^(eDP|LVDS|DSI)"))][0].name // empty')
if [ -n "$INT" ]; then
    MIRROR="Mirror laptop screen"; INT_ONLY="Laptop screen only"; EXT_ONLY="External screen only"
else
    INT=$(outputs | jq -r '.[0].name // empty')
    MIRROR="Mirror $INT"; INT_ONLY="$INT only"
fi
EXT=$(outputs | jq -r --arg i "$INT" '[.[] | select(.name != $i)][0].name // empty')
[ -n "${EXT_ONLY:-}" ] || EXT_ONLY="$EXT only"

if [ -z "$EXT" ]; then
    notify-send "Displays" "No second screen connected."
    exit 0
fi

CHOICE=$(printf '%s\n' \
    "Extend to the right" "Extend to the left" "Extend above" \
    "$MIRROR" "$EXT_ONLY" "$INT_ONLY" \
    "Arrange manually" |
    fuzzel --dmenu --prompt "Displays › " --lines 7) || exit 0

pkill -x wl-mirror
swaymsg "output $INT enable; output $EXT enable" >/dev/null
width()  { outputs | jq -r --arg o "$1" '.[] | select(.name == $o) | .rect.width'; }
height() { outputs | jq -r --arg o "$1" '.[] | select(.name == $o) | .rect.height'; }

case "$CHOICE" in
    "Extend to the right") swaymsg "output $INT pos 0 0; output $EXT pos $(width "$INT") 0" ;;
    "Extend to the left")  swaymsg "output $EXT pos 0 0; output $INT pos $(width "$EXT") 0" ;;
    "Extend above")        swaymsg "output $EXT pos 0 0; output $INT pos 0 $(height "$EXT")" ;;
    "$MIRROR")             swaymsg "output $INT pos 0 0; output $EXT pos $(width "$INT") 0"
                           wl-mirror --fullscreen-output "$EXT" "$INT" & ;;
    "$EXT_ONLY")           swaymsg "output $EXT pos 0 0; output $INT disable" ;;
    "$INT_ONLY")           swaymsg "output $EXT disable" ;;
    "Arrange manually")    wdisplays & ;;
esac
