#!/usr/bin/env bash
# Copy the live setup from this PC back into the repo, and report package drift.
#   ./scripts/export.sh
# Run it after changing a config, then review `git diff` and commit.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOT="$REPO/dotfiles"
SYS="$REPO/system"

# Files/dirs under $HOME that make up the setup (paths relative to $HOME).
HOME_FILES=(
    .bashrc
    .bash_profile
    .gitconfig
    .config/alacritty/alacritty.toml
    .config/environment.d/10-desktop.conf
    .config/fuzzel/fuzzel.ini
    .config/mako/config
    .config/sway/config
    .config/sway/scripts
    .config/sway/assets
    .config/swaylock/config
    .config/waybar/config
    .config/waybar/style.css
    .config/xdg-desktop-portal-wlr/config
    .config/gtk-3.0/settings.ini
    .config/gtk-4.0/settings.ini
    .config/qt6ct/qt6ct.conf
    .config/qt6ct/colors/grounded.conf
    .config/kdeglobals
    .config/dolphinrc
    .config/katerc
    .config/mimeapps.list
    .config/micro/settings.json
    .config/micro/bindings.json
    .config/opencode/opencode.json
    ".config/Code - OSS/User/settings.json"
    .config/PrusaSlicer/printer
    .config/PrusaSlicer/filament
    .config/PrusaSlicer/print
    wallpapers
)

# System files (absolute paths) that differ from a stock Arch install.
SYSTEM_FILES=(
    /etc/vconsole.conf
    /etc/modprobe.d/blacklist-nfc.conf
    /etc/udev/rules.d/51-android.rules
    /etc/udev/rules.d/60-heimdall.rules
    /etc/systemd/system/bluetooth.service.d/override.conf
)

echo "==> Dotfiles"
for f in "${HOME_FILES[@]}"; do
    src="$HOME/$f"
    if [ ! -e "$src" ]; then echo "   missing: ~/$f"; continue; fi
    mkdir -p "$DOT/$(dirname "$f")"
    if [ -d "$src" ]; then
        rm -rf "${DOT:?}/$f"
        cp -a "$src" "$DOT/$f"
        find "$DOT/$f" -name '__pycache__' -prune -exec rm -rf {} +
    else
        cp -a "$src" "$DOT/$f"
    fi
done

echo "==> System files"
for f in "${SYSTEM_FILES[@]}"; do
    if [ ! -r "$f" ]; then echo "   unreadable: $f"; continue; fi
    install -Dm644 "$f" "$SYS$f"
done

echo "==> Package drift (installed vs packages/*.txt)"
strip() { sed 's/#.*//; s/[[:space:]]*$//' "$@" | grep -v '^$' | sort -u; }
listed=$(strip "$REPO"/packages/pacman.txt "$REPO"/packages/hw-*.txt "$REPO"/packages/laptop.txt)
new=$(comm -23 <(pacman -Qqen | sort) <(echo "$listed"))
gone=$(comm -13 <(pacman -Qqen | sort) <(strip "$REPO"/packages/pacman.txt))
foreign=$(pacman -Qqem || true)
[ -n "$new" ]     && printf '   installed, not in lists (add to packages/pacman.txt):\n%s\n' "$(sed 's/^/     /' <<<"$new")"
[ -n "$gone" ]    && printf '   in lists, not installed here:\n%s\n' "$(sed 's/^/     /' <<<"$gone")"
[ -n "$foreign" ] && printf '   AUR/foreign (the installer does not install these):\n%s\n' "$(sed 's/^/     /' <<<"$foreign")"
[ -z "$new$gone$foreign" ] && echo "   in sync"

if command -v code >/dev/null; then code --list-extensions > "$REPO/packages/vscode-extensions.txt"; fi

echo "==> PACKAGES.md"
python3 "$REPO/scripts/gen-packages-md.py"

echo "Done. Review with: git -C '$REPO' diff --stat"
