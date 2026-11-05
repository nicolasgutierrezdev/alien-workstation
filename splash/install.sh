#!/usr/bin/env bash
# Boot splash: Plymouth with the Grounded theme (alien mark + journal panel).
#   sudo ./splash/install.sh
# install/post-install.sh calls this; run it alone to apply or update just the splash.
# Safe to re-run. SPLASH_SKIP_INITRAMFS=1 leaves the initramfs rebuild to the caller.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
THEME=/usr/share/plymouth/themes/grounded
[ "$(id -u)" -eq 0 ] || { echo "Run as root: sudo $0"; exit 1; }

pacman -S --needed --noconfirm plymouth ttf-ibm-plex jq

install -Dm644 -t "$THEME" "$DIR"/theme/*
install -Dm644 "$DIR/plymouthd.conf" /etc/plymouth/plymouthd.conf
install -Dm644 "$DIR/mkinitcpio.conf" /etc/mkinitcpio.conf.d/plymouth.conf
install -Dm755 "$DIR/splash-journal" /usr/local/bin/splash-journal
install -Dm644 "$DIR/splash-journal.service" /etc/systemd/system/splash-journal.service
systemctl enable splash-journal.service

# Kernel parameters: `splash` turns Plymouth on, `quiet` hides the text it covers.
# The LTS entry is the fallback and stays verbose, to see what happens if a boot fails.
for entry in /boot/loader/entries/*.conf; do
    [ -e "$entry" ] || continue
    case "$entry" in *lts*|*fallback*) continue ;; esac
    for p in quiet splash; do
        grep -qE "^options\s(.*\s)?$p(\s|$)" "$entry" || sed -i -E "s/^options\s.*/& $p/" "$entry"
    done
    echo "   $entry: $(sed -n 's/^options\s*//p' "$entry")"
done

if [ "${SPLASH_SKIP_INITRAMFS:-0}" != 1 ]; then
    mkinitcpio -P
fi
