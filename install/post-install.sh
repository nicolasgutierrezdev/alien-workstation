#!/usr/bin/env bash
# System part of the workstation setup. Runs as root, either:
#   - automatically, inside the new system at the end of archinstall (bootstrap.sh), or
#   - by hand on an existing Arch install:  sudo ./install/post-install.sh [username]
# Safe to re-run.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
log()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }

[ "$(id -u)" -eq 0 ] || { echo "Run as root: sudo $0 [username]"; exit 1; }

# --- Target user: argument, $SUDO_USER, or the first regular account -----------
USER_NAME="${1:-${SUDO_USER:-}}"
if [ -z "$USER_NAME" ] || [ "$USER_NAME" = root ]; then
    USER_NAME=$(awk -F: '$3 >= 1000 && $3 < 60000 { print $1; exit }' /etc/passwd)
fi
[ -n "$USER_NAME" ] && id "$USER_NAME" >/dev/null 2>&1 || { echo "No regular user found. Create one first."; exit 1; }
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)
IN_CHROOT=false
systemd-detect-virt --chroot >/dev/null 2>&1 && IN_CHROOT=true
log "Setting up for user '$USER_NAME' ($USER_HOME)$($IN_CHROOT && echo ', inside installer chroot')"

pkgs() { sed 's/#.*//; s/[[:space:]]*$//' "$@" | grep -v '^$'; }

# --- Packages -----------------------------------------------------------------
LISTS=("$REPO/packages/pacman.txt")
CPU=$(grep -m1 -o 'GenuineIntel\|AuthenticAMD' /proc/cpuinfo || true)
# GPU vendors from sysfs (PCI class 0x03xxxx = display controller); no pciutils needed.
GPU=""
for d in /sys/bus/pci/devices/*; do
    [[ "$(cat "$d/class" 2>/dev/null)" == 0x03* ]] && GPU+=" $(cat "$d/vendor")"
done
if [ "$CPU" = GenuineIntel ] || [[ "$GPU" == *0x8086* ]]; then LISTS+=("$REPO/packages/hw-intel.txt"); fi
if [ "$CPU" = AuthenticAMD ] || [[ "$GPU" == *0x1002* ]]; then LISTS+=("$REPO/packages/hw-amd.txt"); fi
IS_LAPTOP=false
compgen -G '/sys/class/power_supply/BAT*' >/dev/null && IS_LAPTOP=true
$IS_LAPTOP && LISTS+=("$REPO/packages/laptop.txt")

log "Installing packages from: ${LISTS[*]##*/}"
sed -i 's/^#Color$/Color/; s/^#\?ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
pacman -Syu --needed --noconfirm $(pkgs "${LISTS[@]}")

# --- System config files ------------------------------------------------------
log "Installing system config files"
( cd "$REPO/system" && find . -type f ) | while read -r f; do
    install -Dm644 "$REPO/system/$f" "/${f#./}"
    echo "   /${f#./}"
done
# Let iwd handle DHCP itself unless archinstall already configured it (with networkd).
if [ ! -f /etc/iwd/main.conf ]; then
    install -Dm644 /dev/stdin /etc/iwd/main.conf <<<$'[General]\nEnableNetworkConfiguration=true'
fi
# Firewall: deny incoming, allow outgoing (ufw defaults), on at boot.
sed -i 's/^ENABLED=.*/ENABLED=yes/' /etc/ufw/ufw.conf
$IN_CHROOT || ufw --force enable >/dev/null || warn "ufw enable failed"

# --- Services -----------------------------------------------------------------
log "Enabling services"
SERVICES=(
    iwd.service bluetooth.service ufw.service docker.socket libvirtd.socket
    tailscaled.service cups.socket pcscd.socket systemd-timesyncd.service
    fstrim.timer paccache.timer ly@tty2.service
)
$IS_LAPTOP && SERVICES+=(tlp.service)
for s in "${SERVICES[@]}"; do
    systemctl enable "$s" >/dev/null 2>&1 && echo "   $s" || warn "could not enable $s"
done
systemctl disable getty@tty2.service >/dev/null 2>&1 || true
if $IS_LAPTOP; then
    systemctl mask systemd-rfkill.service systemd-rfkill.socket >/dev/null 2>&1   # TLP handles radios
fi

# --- User groups --------------------------------------------------------------
log "Adding $USER_NAME to wheel, docker, libvirt"
usermod -aG wheel,docker,libvirt "$USER_NAME"
if ! grep -rqs '^%wheel ALL=(ALL:ALL) ALL' /etc/sudoers /etc/sudoers.d; then
    echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
    chmod 440 /etc/sudoers.d/10-wheel
fi

# --- AUR (yay) ----------------------------------------------------------------
# makepkg refuses to run as root, so build as the user with temporary passwordless sudo.
log "Installing AUR packages"
SUDOERS_TMP=/etc/sudoers.d/99-alien-workstation-install
echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD: ALL" > "$SUDOERS_TMP"
chmod 440 "$SUDOERS_TMP"
trap 'rm -f "$SUDOERS_TMP"' EXIT

as_user() { sudo -u "$USER_NAME" -H env HOME="$USER_HOME" "$@"; }
if ! command -v yay >/dev/null; then
    build=$(as_user mktemp -d)
    as_user git clone -q https://aur.archlinux.org/yay-bin.git "$build/yay-bin"
    (cd "$build/yay-bin" && as_user makepkg -si --noconfirm)
    rm -rf "$build"
fi
AUR=$(pkgs "$REPO/packages/aur.txt" | grep -vx 'yay-bin' || true)
[ -n "$AUR" ] && as_user yay -S --needed --noconfirm --answerclean None --answerdiff None $AUR

# --- Repo copy in the user's home ---------------------------------------------
DEST="$USER_HOME/workspace/alien-workstation"
if [ "$REPO" != "$DEST" ] && [ ! -e "$DEST" ]; then
    log "Copying this repo to $DEST"
    mkdir -p "$(dirname "$DEST")"
    cp -a "$REPO" "$DEST"
    chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/workspace"
    REPO="$DEST"
fi

# --- User part ----------------------------------------------------------------
log "Running user setup as $USER_NAME"
as_user bash "$REPO/install/user-setup.sh"

# --- Boot splash --------------------------------------------------------------
log "Setting up the boot splash (Plymouth, Grounded theme)"
SPLASH_SKIP_INITRAMFS=1 bash "$REPO/splash/install.sh" || warn "splash setup failed; run 'sudo ./splash/install.sh'"

# The console font (ter-132b) and the splash are only in the initramfs after this.
log "Rebuilding initramfs"
mkinitcpio -P >/dev/null 2>&1 || warn "mkinitcpio reported problems; check 'mkinitcpio -P'"

log "Done. Reboot, log in at the ly prompt and pick 'sway'."
