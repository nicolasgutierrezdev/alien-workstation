#!/bin/sh
# Lid switch: `lid.sh close` turns the built-in panel off, `lid.sh open` turns it back on.
# The panel is detected by name (eDP-*, LVDS-*, DSI-*), so it works on any laptop.
PANEL=$(swaymsg -t get_outputs -r | jq -r '[.[] | select(.name | test("^(eDP|LVDS|DSI)"))][0].name // empty')
[ -n "$PANEL" ] || exit 0

case "$1" in
    close) swaymsg output "$PANEL" disable ;;
    open)  swaymsg output "$PANEL" enable ;;
esac
