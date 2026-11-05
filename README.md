# alien-workstation

My Arch Linux workstation as code: every package, every config file, and an installer that
rebuilds the whole setup on a new machine. The desktop is **sway** + **waybar** with the
*Grounded* theme (dark, IBM Plex, alien-green accent).

| | |
|---|---|
| [`PACKAGES.md`](PACKAGES.md) | Readable list of everything installed, grouped by purpose |
| [`packages/`](packages) | The same lists as plain text, read by the installer |
| [`dotfiles/`](dotfiles) | Config files and scripts, laid out exactly like `$HOME` |
| [`system/`](system) | Files under `/etc` that differ from stock Arch |
| [`install/`](install) | The installer: archinstall preset + setup scripts |
| [`scripts/`](scripts) | Maintenance: export the live setup back into the repo |

---

## Install on a new computer

Needs a UEFI machine and the Arch ISO on a USB stick.

```sh
# 1. Boot the ISO and get online
iwctl station wlan0 connect "<SSID>"

# 2. Get this repo
pacman -Sy --noconfirm git
git clone https://github.com/nicolasgutierrezdev/alien-workstation

# 3. Go
./alien-workstation/install/bootstrap.sh
```

archinstall opens **pre-filled** (locale, timezone, both kernels, systemd-boot, iwd, PipeWire,
Bluetooth, printing, zram swap). You only pick:

1. **Disk configuration**: the disk, then *wipe + default layout* (or partition by hand)
2. **Authentication**: root password, plus your user with sudo
3. **Hostname** (optional; defaults to `alien-workstation`)

Then press **Install**. When the base system is in, archinstall runs
[`install/post-install.sh`](install/post-install.sh) inside it. That script installs all
packages and the AUR ones, copies the system files, enables services, adds you to
`docker`/`libvirt`, and deploys the dotfiles. Reboot, log in at the **ly** prompt, and choose **sway**.

> No local clone? archinstall can also use the preset directly from GitHub:
> `archinstall --config-url https://raw.githubusercontent.com/nicolasgutierrezdev/alien-workstation/master/install/archinstall.json`

### On an Arch install that already exists

```sh
git clone https://github.com/nicolasgutierrezdev/alien-workstation ~/workspace/alien-workstation
cd ~/workspace/alien-workstation
sudo ./install/post-install.sh          # everything: packages, system, services, dotfiles
./install/user-setup.sh --dotfiles      # or: only the dotfiles, nothing else
```

Every script can be re-run safely. Before a dotfile is replaced, the old copy is saved in
`~/.local/state/alien-workstation/backup-<date>/`.

### What adapts to the machine

- **CPU/GPU**: Intel gets `intel-ucode`, `intel-media-driver`, `vulkan-intel`. AMD gets `amd-ucode`, `vulkan-radeon`.
- **Laptop** (battery present): gets `tlp`, and `systemd-rfkill` is masked.
- **Username**: configs that mention `/home/alien` are rewritten to the new user's home.

- **Screens** (detected when used, not at install): the built-in panel is whichever output is named
  `eDP-*`, `LVDS-*` or `DSI-*`. Closing the lid turns it off (`lid.sh`), and `Super+P`
  (`display-mode.sh`) works on laptops and two-monitor desktops alike.
- **CPU temperature** in the bar (`cpu-temp.sh`): reads Intel `coretemp`, AMD `k10temp`/`zenpower`,
  ARM `cpu_thermal`, else the ThinkPad EC or an ACPI thermal zone. Hidden if no sensor exists.

### Manual steps after install

- Wi-Fi: `Super+Shift+W` (impala). VPNs: `sudo tailscale up`, `sudo zerotier-cli join <id>`
- Copy `~/.ssh` and `~/.gnupg` from a backup. `.gitconfig` signs commits with GPG key `FC166CA442735B8B`.
- `gh auth login`, then sign in to Firefox and Claude Code (`claude`)
- `~/.local/bin/postal` (`whatsapp`) is a standalone binary and isn't tracked here

---

## Keeping the repo up to date

After changing a config or installing something on this PC:

```sh
./scripts/export.sh     # copy live configs into dotfiles/ + system/, check package drift, rebuild PACKAGES.md
git diff                # review, then commit
```

`export.sh` lists packages that are installed but not in `packages/*.txt`, and the reverse.
To track a new config file, add its path to `HOME_FILES` in `scripts/export.sh`.

---

## Desktop cheat sheet

| Keys | Action |
|---|---|
| `Super+Enter` / `Super+Shift+Enter` | Terminal (Alacritty) / Files (Dolphin) |
| `Super+D` | Launcher (fuzzel) |
| `Super+Shift+W` | Wi-Fi (impala) |
| `Super+Shift+B` | Bluetooth (bluetui) |
| `Super+P` | Displays: extend / mirror / single screen |
| `Super+Space` | Keyboard layout US ⇄ Latin American |
| `Super+Shift+V` | Clipboard history |
| `Print` / `Shift+Print` / `Super+Shift+S` | Screenshot: full / region / region + annotate |
| `Super+N` / `Super+Shift+N` | Dismiss / restore notifications |
| `Super+Escape` | Lock |
| `Super+Shift+E` | Power menu |
| `Super+Shift+Q` | Close window |
| `Super+1…0` / `Super+Shift+1…0` | Go to / move window to workspace |
| `Super+H J K L` or arrows | Focus (add `Shift` to move) |
| `Super+F` / `Super+Shift+Space` / `Super+R` | Fullscreen / float / resize mode |

Clicking in the bar: **NET** opens impala, **BT** bluetui, **VOL** pavucontrol, the date a
calendar, ⏻ the power menu.
