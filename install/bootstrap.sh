#!/usr/bin/env bash
# Install Arch + the full workstation from the Arch ISO, in one go.
#
#   1. Boot the Arch ISO, connect to Wi-Fi:   iwctl station wlan0 connect "<SSID>"
#   2. Get this repo:                          pacman -Sy --noconfirm git
#                                              git clone https://github.com/nicolasgutierrezdev/alien-workstation
#   3. Run:                                    ./alien-workstation/install/bootstrap.sh
#
# archinstall opens with everything pre-filled (locale, kernels, bootloader, network,
# audio, bluetooth, printing, timezone). You only choose:
#   - Disk configuration  (which disk, and "wipe + default layout" is fine)
#   - Authentication      (root password + your user, with sudo)
#   - Hostname            (optional, defaults to alien-workstation)
# then press Install. At the end it runs install/post-install.sh inside the new system,
# using THIS copy of the repo (local changes included), served over localhost.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PORT=8765
WORK=$(mktemp -d)
trap 'kill "${SERVER_PID:-}" 2>/dev/null || true; rm -rf "$WORK"' EXIT

[ "$(id -u)" -eq 0 ] || { echo "Run as root from the Arch ISO."; exit 1; }
[ -d /sys/firmware/efi ] || { echo "Not booted in UEFI mode; systemd-boot needs UEFI. Enable UEFI in the firmware and retry."; exit 1; }
ping -c1 -W3 archlinux.org >/dev/null 2>&1 || { echo "No internet. Connect first (iwctl)."; exit 1; }

if [ "${1:-}" != "--no-update" ]; then
    echo "==> Updating archinstall on the ISO (config targets archinstall 4.x)"
    pacman -Sy --noconfirm --needed archinstall archlinux-keyring
fi

echo "==> Packing the repo and serving it on 127.0.0.1:$PORT"
tar -C "$REPO/.." -czf "$WORK/alien-workstation.tar.gz" "$(basename "$REPO")" \
    --transform "s|^$(basename "$REPO")|alien-workstation|"
(cd "$WORK" && exec python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1) &
SERVER_PID=$!
sleep 1

# Same preset, but fetch the repo from this machine instead of GitHub.
python3 - "$REPO/install/archinstall.json" "$WORK/config.json" "$PORT" <<'EOF'
import json, sys
src, dst, port = sys.argv[1:]
cfg = json.load(open(src))
cfg["custom_commands"] = [
    f"mkdir -p /var/tmp && curl -fsS http://127.0.0.1:{port}/alien-workstation.tar.gz"
    " | tar -xz -C /var/tmp && bash /var/tmp/alien-workstation/install/post-install.sh;"
    " rm -rf /var/tmp/alien-workstation"
]
json.dump(cfg, open(dst, "w"), indent=2)
EOF

echo "==> Starting archinstall"
archinstall --config "$WORK/config.json"

echo
echo "All done. Type 'reboot', remove the USB, log in and choose sway."
