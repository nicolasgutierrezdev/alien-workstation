#!/usr/bin/env bash
# Preview the installed splash without rebooting: replays this boot's journal into
# the panel (tagged like at boot) for a few seconds, then quits. Run it from a text console
# (Ctrl+Alt+F3, log in), not from a terminal inside sway:
#   sudo ./splash/preview.sh [seconds]      (default 10)
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run as root: sudo $0 [seconds]"; exit 1; }
duration=${1:-10}

plymouthd --mode=boot
trap 'plymouth quit' EXIT
plymouth show-splash
sleep 1
journalctl --boot --lines=$((duration * 25)) --priority=info --output=json |
while IFS= read -r line; do
    printf '%s\n' "$line"
    sleep 0.04
done | /usr/local/bin/splash-journal --send
