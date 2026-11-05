#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# --- Desktop session environment (sway) -------------------------------------
# Qt/KDE apps (Dolphin, Okular…): native Wayland + dark Grounded palette
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt6ct
# Lets KDE apps find every installed app for "Open with" outside Plasma
export XDG_MENU_PREFIX=arch-
# Electron apps (VS Code) and Java apps behave under Wayland/sway
export ELECTRON_OZONE_PLATFORM_HINT=auto
export _JAVA_AWT_WM_NONREPARENTING=1
