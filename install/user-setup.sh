#!/usr/bin/env bash
# User part of the setup: dotfiles + per-user tools. Run as the normal user (not root):
#   ./install/user-setup.sh            deploy dotfiles and install user tools
#   ./install/user-setup.sh --dotfiles only deploy dotfiles
# Existing files that would be overwritten are backed up first. Safe to re-run.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
log()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
[ "$(id -u)" -ne 0 ] || { echo "Run as your normal user, not root."; exit 1; }

# --- Dotfiles -----------------------------------------------------------------
log "Deploying dotfiles to $HOME"
BACKUP="$HOME/.local/state/alien-workstation/backup-$(date +%Y%m%d-%H%M%S)"
cd "$REPO/dotfiles"
find . -type f -print0 | while IFS= read -r -d '' f; do
    rel="${f#./}"; dest="$HOME/$rel"
    tmp=$(mktemp)
    # Configs reference /home/alien; point them at this user's home instead.
    if grep -Iq . "$f" 2>/dev/null; then sed "s|/home/alien|$HOME|g" "$f" > "$tmp"; else cp "$f" "$tmp"; fi
    if [ -e "$dest" ] && cmp -s "$tmp" "$dest"; then rm -f "$tmp"; continue; fi
    if [ -e "$dest" ]; then
        mkdir -p "$BACKUP/$(dirname "$rel")"
        cp -a "$dest" "$BACKUP/$rel"
    fi
    mkdir -p "$(dirname "$dest")"
    mv "$tmp" "$dest"
    if [ -x "$f" ]; then chmod 755 "$dest"; else chmod 644 "$dest"; fi
    echo "   ~/$rel"
done
[ -d "$BACKUP" ] && echo "   (previous versions saved in $BACKUP)"
cd - >/dev/null

mkdir -p "$HOME/screenshots" "$HOME/workspace" "$HOME/.local/bin"
xdg-user-dirs-update 2>/dev/null || true
fc-cache -f >/dev/null 2>&1 || true

[ "${1:-}" = "--dotfiles" ] && { log "Dotfiles done."; exit 0; }

lines() { sed 's/#.*//; s/[[:space:]]*$//' "$1" | grep -v '^$'; }

# --- Rust ---------------------------------------------------------------------
if command -v rustup >/dev/null; then
    log "Rust stable toolchain"
    rustup default stable >/dev/null 2>&1 || warn "rustup failed"
fi

# --- Python: pip --user and uv tools --------------------------------------------
log "pip --user packages"
pip install --user --break-system-packages --quiet $(lines "$REPO/packages/pip.txt") || warn "pip install failed"

if command -v uv >/dev/null; then
    log "uv tools"
    for t in $(lines "$REPO/packages/uv-tools.txt"); do
        uv tool install --quiet "$t" 2>/dev/null || uv tool upgrade --quiet "$t" 2>/dev/null || warn "uv tool $t failed"
        echo "   $t"
    done
fi

# --- VS Code (Code - OSS) extensions --------------------------------------------
if command -v code >/dev/null; then
    log "VS Code extensions"
    for e in $(lines "$REPO/packages/vscode-extensions.txt"); do
        code --install-extension "$e" --force >/dev/null 2>&1 && echo "   $e" || warn "extension $e failed"
    done
fi

# --- Claude Code ----------------------------------------------------------------
if [ ! -x "$HOME/.local/bin/claude" ]; then
    log "Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash || warn "Claude Code install failed"
fi

# --- KDE app menus (Dolphin "Open with") ---------------------------------------
XDG_MENU_PREFIX=arch- kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

log "User setup done."
