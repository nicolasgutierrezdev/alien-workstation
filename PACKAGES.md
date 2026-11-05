# Packages

Everything installed on the workstation, grouped by purpose.
Generated from `packages/*.txt` by `scripts/gen-packages-md.py`; edit the `.txt` files, not this one.

**133 system packages** · hardware packages are chosen automatically at install time.

## Contents

- [Base system](#base-system) (24)
- [Networking & VPN](#networking--vpn) (7)
- [Desktop: sway](#desktop-sway) (29)
- [Audio & Bluetooth](#audio--bluetooth) (5)
- [Look & feel](#look--feel) (11)
- [Files, documents & office](#files-documents--office) (14)
- [Media & internet](#media--internet) (3)
- [Development](#development) (14)
- [Virtualization](#virtualization) (4)
- [Smart cards, Uruguayan eID & OCR](#smart-cards-uruguayan-eid--ocr) (7)
- [Phones](#phones) (2)
- [Printing](#printing) (2)
- [3D printing, CAD & games](#3d-printing-cad--games) (3)
- [Intel hardware](#intel-hardware) (3)
- [AMD hardware](#amd-hardware) (2)
- [Laptop](#laptop) (1)
- [AUR](#aur) (2)
- [User-level tools](#user-level-tools)

## Base system

| Package | What it is |
|---|---|
| `base` | Minimal package set to define a basic Arch Linux installation |
| `base-devel` | Basic tools to build Arch Linux packages |
| `linux` | The Linux kernel and modules |
| `linux-lts` | The LTS Linux kernel and modules — *fallback kernel (second boot entry)* |
| `linux-firmware` | Firmware files for Linux - Default set |
| `efibootmgr` | Linux user-space application to modify the EFI Boot Manager |
| `sudo` | Give certain users the ability to run some commands as root |
| `man-db` | A utility for reading man pages |
| `man-pages` | Linux man pages |
| `nano` | Pico editor clone with enhancements |
| `micro` | Modern and intuitive terminal-based text editor — *default editor (git core.editor)* |
| `git` | the fast distributed version control system |
| `openssh` | SSH protocol implementation for remote login, command execution and file transfer |
| `pacman-contrib` | Contributed scripts and tools for pacman systems — *paccache.timer, checkupdates* |
| `fwupd` | Simple daemon to allow session software to update firmware — *firmware updates* |
| `smartmontools` | Control and monitor S.M.A.R.T. enabled ATA and SCSI Hard Drives |
| `dosfstools` | DOS filesystem utilities |
| `exfatprogs` | exFAT filesystem userspace utilities for the Linux Kernel exfat driver |
| `7zip` | File archiver for extremely high compression |
| `unrar` | The RAR uncompression program |
| `unzip` | For extracting and viewing files in .zip archives |
| `jq` | Command-line JSON processor |
| `terminus-font` | Monospace bitmap font (for X11 and console) — *big console font (ter-132b)* |
| `fastfetch` | A feature-rich and performance oriented neofetch like system information tool |

## Networking & VPN

| Package | What it is |
|---|---|
| `iwd` | Internet Wireless Daemon — *Wi-Fi daemon* |
| `impala` | TUI for managing wifi — *Wi-Fi TUI (Super+Shift+W, click NET in the bar)* |
| `tailscale` | A mesh VPN that makes it easy to connect your devices, wherever they are. |
| `zerotier-one` | Creates virtual Ethernet networks of almost unlimited size. |
| `ufw` | Uncomplicated and easy to use CLI tool for managing a netfilter firewall — *firewall: deny incoming, allow outgoing* |
| `nmap` | Utility for network discovery and security auditing |
| `dnsmasq` | Lightweight, easy to configure DNS forwarder and DHCP server — *NAT/DHCP for libvirt VMs* |

## Desktop: sway

| Package | What it is |
|---|---|
| `sway` | Tiling Wayland compositor and replacement for the i3 window manager |
| `swaybg` | Wallpaper tool for Wayland compositors |
| `swayidle` | Idle management daemon for Wayland |
| `swaylock` | Screen locker for Wayland |
| `swayimg` | A lightweight image viewer for Wayland display servers |
| `waybar` | Highly customizable Wayland bar for Sway and Wlroots based compositors |
| `fuzzel` | Application launcher for wlroots based Wayland compositors — *launcher + every menu (power, displays, clipboard, screen share)* |
| `mako` | Lightweight notification daemon for Wayland — *notifications* |
| `ly` | TUI display manager — *TUI login manager* |
| `wayland` | A computer display server protocol |
| `xorg-xwayland` | run X clients under wayland |
| `xdg-desktop-portal-wlr` | xdg-desktop-portal backend for wlroots — *screen sharing* |
| `xdg-user-dirs` | Manage user directories like ~/Desktop and ~/Music |
| `polkit-gnome` | Legacy polkit authentication agent for GNOME — *auth prompts* |
| `libnotify` | Library for sending desktop notifications |
| `libappindicator` | Allow applications to extend a menu via Ayatana indicators in Unity, KDE or Systray |
| `alacritty` | A cross-platform, GPU-accelerated terminal emulator |
| `wl-clipboard` | Command-line copy/paste utilities for Wayland |
| `wl-clip-persist` | Keep Wayland clipboard even after programs close |
| `cliphist` | wayland clipboard manager — *clipboard history (Super+Shift+V)* |
| `grim` | Screenshot utility for Wayland — *screenshots* |
| `slurp` | Select a region in a Wayland compositor |
| `swappy` | A Wayland native snapshot editing tool — *screenshot annotation* |
| `wlsunset` | Day/night gamma adjustments for Wayland compositors — *night light* |
| `wdisplays` | Graphical application for configuring Wayland displays — *drag-and-drop display layout* |
| `wl-mirror` | a simple Wayland output mirror client — *mirror screens* |
| `brightnessctl` | Lightweight brightness control tool |
| `playerctl` | mpris media player controller and lib for spotify, vlc, audacious, bmp, xmms2, and others. — *media keys* |
| `libinput-tools` | Input device management and event handling library (debug utilities) |

## Audio & Bluetooth

| Package | What it is |
|---|---|
| `pipewire-pulse` | Low-latency audio/video router and processor - PulseAudio replacement |
| `wireplumber` | Session / policy manager implementation for PipeWire |
| `pavucontrol` | PulseAudio Volume Control |
| `bluez-utils` | Development and debugging utilities for the bluetooth protocol stack |
| `bluetui` | TUI for managing bluetooth devices — *Bluetooth TUI (Super+Shift+B, click BT in the bar)* |

## Look & feel

| Package | What it is |
|---|---|
| `adw-gtk-theme` | Unofficial GTK 3 port of the libadwaita theme |
| `breeze` | Artwork, styles and assets for the Breeze visual style for the Plasma Desktop |
| `qt6-wayland` | Provides APIs for Wayland |
| `qt6ct` | Qt 6 Configuration Utility |
| `ttf-ibm-plex` | IBM Plex Mono, Sans, and Serif — *UI + mono font everywhere* |
| `noto-fonts` | Google Noto TTF fonts |
| `noto-fonts-emoji` | Google Noto Color Emoji font |
| `ttf-dejavu` | Font family based on the Bitstream Vera Fonts with a wider range of characters |
| `ttf-liberation` | Font family which aims at metric compatibility with Arial, Times New Roman, and Courier New |
| `ttf-nerd-fonts-symbols` | High number of extra glyphs from popular 'iconic fonts' |
| `woff2-font-awesome` | Iconic font designed for Bootstrap - woff2 format |

## Files, documents & office

| Package | What it is |
|---|---|
| `dolphin` | KDE File Manager |
| `archlinux-xdg-menu` | automatic generate WM menu from xdg files — *Dolphin "Open with" outside Plasma* |
| `ffmpegthumbs` | FFmpeg-based thumbnail creator for video files |
| `kdegraphics-thumbnailers` | Thumbnailers for various graphics file formats |
| `kimageformats` | Image format plugins for Qt 6 |
| `ark` | Archiving Tool |
| `kate` | Advanced text editor |
| `okular` | Document Viewer |
| `gwenview` | A fast and easy to use image viewer |
| `libreoffice-fresh` | LibreOffice branch which contains new features and program enhancements |
| `hunspell-en_us` | US English hunspell dictionaries |
| `hunspell-es_uy` | Spanish (Uruguay) hunspell dictionary |
| `glow` | Command-line markdown renderer — *markdown in the terminal* |
| `anki` | A smart spaced repetition flashcard program |

## Media & internet

| Package | What it is |
|---|---|
| `firefox` | Fast, Private & Safe Web Browser |
| `mpv` | a free, open source, and cross-platform media player |
| `obs-studio` | Free, open source software for live streaming and recording |

## Development

| Package | What it is |
|---|---|
| `code` | The Open Source build of Visual Studio Code (vscode) editor |
| `opencode` | The open source coding agent |
| `github-cli` | The GitHub CLI |
| `clang` | C language family frontend for LLVM |
| `rustup` | The Rust toolchain installer |
| `nodejs` | Evented I/O for V8 javascript ("Current" release) |
| `pnpm` | Fast, disk space efficient package manager |
| `python-pip` | The PyPA recommended tool for installing Python packages |
| `uv` | An extremely fast Python package installer and resolver written in Rust |
| `hexedit` | View and edit files in hexadecimal or in ASCII |
| `docbook-xsl` | XML stylesheets for Docbook-xml transformations |
| `docker` | Pack, ship and run any application as a lightweight container |
| `docker-buildx` | Docker CLI plugin for extended build capabilities with BuildKit |
| `docker-compose` | Fast, isolated development environments using Docker |

## Virtualization

| Package | What it is |
|---|---|
| `qemu-desktop` | A QEMU setup for desktop environments |
| `libvirt` | API for controlling virtualization engines (openvz,kvm,qemu,virtualbox,xen,etc) |
| `virt-manager` | Desktop user interface for managing virtual machines |
| `edk2-ovmf` | Firmware for Virtual Machines (x86_64, i686 on x86_64) |

## Smart cards, Uruguayan eID & OCR

| Package | What it is |
|---|---|
| `pcsclite` | PC/SC Architecture smartcard middleware library |
| `ccid` | A generic USB Chip/Smart Card Interface Devices driver |
| `opensc` | Tools and libraries for smart cards |
| `pcsc-tools` | PC/SC Architecture smartcard tools |
| `softhsm` | Software PKCS#11 store |
| `tesseract` | An OCR program |
| `tesseract-data-eng` | Tesseract OCR data (eng) |

## Phones

| Package | What it is |
|---|---|
| `android-tools` | Android platform tools |
| `heimdall` | Tool suite used to flash firmware (ROMs) onto Samsung Galaxy S devices (grimler fork) — *Samsung flashing* |

## Printing

| Package | What it is |
|---|---|
| `cups` | OpenPrinting CUPS - daemon package |
| `system-config-printer` | A CUPS printer configuration tool and status applet |

## 3D printing, CAD & games

| Package | What it is |
|---|---|
| `prusa-slicer` | G-code generator for 3D printers (Prusa fork of Slic3r) |
| `freecad` | Feature based parametric 3D CAD modeler |
| `prismlauncher` | Minecraft launcher with ability to manage multiple instances |

## Intel hardware

| Package | What it is |
|---|---|
| `intel-ucode` | Microcode update files for Intel CPUs |
| `intel-media-driver` | Intel Media Driver for VAAPI — Broadwell+ iGPUs — *GPU video encode/decode (OBS, mpv, Firefox)* |
| `vulkan-intel` | Open-source Vulkan driver for Intel GPUs |

## AMD hardware

| Package | What it is |
|---|---|
| `amd-ucode` | Microcode update image for AMD CPUs |
| `vulkan-radeon` | Open-source Vulkan driver for AMD GPUs |

## Laptop

| Package | What it is |
|---|---|
| `tlp` | Linux Advanced Power Management — *battery life + charge thresholds (handles radios, so systemd-rfkill is masked)* |

## AUR

| Package | What it is |
|---|---|
| `yay-bin` |  |
| `cedula-uruguay-pkcs11` | PKCS#11 middleware for the Uruguayan electronic ID card (cédula) — *Uruguayan eID PKCS#11 module* |

## User-level tools

Installed per user by `install/user-setup.sh`, outside pacman.

| Kind | Packages |
|---|---|
| pip `--user` | `openpyxl`, `python-pptx`, `linkify-it-py` |
| `uv tool` | `firmauy`, `cedulauy-mrz-scan` |
| VS Code extensions | `anthropic.claude-code`, `ms-python.debugpy`, `ms-python.python`, `ms-python.vscode-python-envs` |
| Rust | `rustup` stable toolchain |
| Claude Code | official installer (`claude.ai/install.sh`) |
