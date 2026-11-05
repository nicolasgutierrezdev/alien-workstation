#!/bin/sh
# Cheat sheet: lists every binding in the sway config in a fuzzel popup.
# Type to filter; Enter or Esc closes it. Bound to $mod+Shift+slash (Super+?).
# To describe a new binding, add a line to describe() below; anything
# without a description shows its command instead.

config="${XDG_CONFIG_HOME:-$HOME/.config}/sway/config"

awk '
# Pretty-print a key combo: $mod+Shift+q -> Super+Shift+Q
function prettykey(k,   n, parts, i, p, out) {
    n = split(k, parts, "+")
    for (i = 1; i <= n; i++) {
        p = parts[i]
        if (p ~ /^\$/ && (p in vars)) p = vars[p]
        if (p == "Mod4") p = "Super"
        else if (p == "Mod1") p = "Alt"
        else if (p == "Control") p = "Ctrl"
        else if (p == "Return") p = "Enter"
        else if (p == "Escape") p = "Esc"
        else if (p == "space") p = "Space"
        else if (p == "minus") p = "-"
        else if (p == "slash") p = "/"
        else if (p == "Print") p = "PrtSc"
        else if (p ~ /^XF86/) sub(/^XF86/, "", p)
        else if (p ~ /^[a-z]$/) p = toupper(p)
        out = out (i > 1 ? "+" : "") p
    }
    return out
}

# Plain-language description of a command (vars already resolved)
function describe(c,   w) {
    if (match(c, /^(focus|move) (left|right|up|down)$/)) {
        split(c, w, " ")
        return (w[1] == "focus" ? "Focus window " : "Move window ") w[2]
    }
    if (c ~ /^workspace number /)     { sub(/.* /, "", c); return "Go to workspace " c }
    if (c ~ /^move container to workspace number /) { sub(/.* /, "", c); return "Send window to workspace " c }
    if (c ~ /^move workspace to output /) { sub(/.* /, "", c); return "Send workspace to " c " screen" }
    if (c ~ /^resize shrink width/)   return "Narrower"
    if (c ~ /^resize grow width/)     return "Wider"
    if (c ~ /^resize shrink height/)  return "Shorter"
    if (c ~ /^resize grow height/)    return "Taller"
    if (c == "exec " vars["$term"])   return "Open terminal"
    if (c == "exec " vars["$files"])  return "Open file manager"
    if (c == "exec " vars["$menu"])   return "App launcher"
    if (c == "exec " vars["$lock"])   return "Lock screen"
    if (c == "kill")                  return "Close window"
    if (c == "reload")                return "Reload sway config"
    if (c ~ /power-menu/)             return "Power menu (lock, suspend, shut down)"
    if (c ~ /display-mode/)           return "Displays (extend / mirror / single)"
    if (c ~ /xkb_switch_layout/)      return "Switch keyboard layout (US / Latam)"
    if (c ~ /cliphist/)               return "Clipboard history"
    if (c ~ /makoctl dismiss/)        return "Dismiss notifications"
    if (c ~ /makoctl restore/)        return "Bring back last notification"
    if (c ~ /keybinds\.sh/)           return "This cheat sheet"
    if (c == "workspace back_and_forth")  return "Previous workspace"
    if (c == "workspace prev_on_output")  return "Previous workspace on this screen"
    if (c == "workspace next_on_output")  return "Next workspace on this screen"
    if (c == "splith")                return "Next window opens beside"
    if (c == "splitv")                return "Next window opens below"
    if (c == "layout stacking")       return "Stacked layout"
    if (c == "layout tabbed")         return "Tabbed layout"
    if (c == "layout toggle split")   return "Toggle split direction"
    if (c == "fullscreen")            return "Fullscreen"
    if (c == "floating toggle")       return "Float / tile window"
    if (c == "focus mode_toggle")     return "Switch focus floating / tiled"
    if (c == "focus parent")          return "Select parent group"
    if (c == "move scratchpad")       return "Hide window in scratchpad"
    if (c == "scratchpad show")       return "Show scratchpad"
    if (c == "mode \"resize\"")       return "Resize mode"
    if (c == "mode \"default\"")      return "Leave resize mode"
    if (c ~ /set-mute .*SINK/)        return "Mute speakers"
    if (c ~ /set-mute .*SOURCE/)      return "Mute microphone"
    if (c ~ /set-volume .*\+$/)       return "Volume up"
    if (c ~ /set-volume .*-$/)        return "Volume down"
    if (c ~ /playerctl play-pause/)   return "Play / pause"
    if (c ~ /playerctl next/)         return "Next track"
    if (c ~ /playerctl previous/)     return "Previous track"
    if (c ~ /brightnessctl .*-$/)     return "Brightness down"
    if (c ~ /brightnessctl .*\+$/)    return "Brightness up"
    if (c ~ /lid\.sh close/)          return "Turn off built-in screen"
    if (c ~ /lid\.sh open/)           return "Turn on built-in screen"
    if (c ~ /swappy/)                 return "Screenshot region + annotate"
    if (c ~ /grim -g/)                return "Screenshot region"
    if (c ~ /grim/)                   return "Screenshot full screen"
    if (c ~ /impala/)                 return "Wi-Fi"
    if (c ~ /bluetui/)                return "Bluetooth"
    # Fallback: the command itself, shortened
    sub(/^exec (--no-startup-id )?/, "", c)
    if (length(c) > 45) c = substr(c, 1, 44) "…"
    return c
}

/^[[:space:]]*set \$/ { vars[$2] = $3; for (i = 4; i <= NF; i++) vars[$2] = vars[$2] " " $i; next }

# A short comment right above bindings names the section (up to ":" or " (")
/^[[:space:]]*# / {
    s = $0
    sub(/^[[:space:]]*# /, "", s); sub(/:.*/, "", s); sub(/ \(.*/, "", s)
    # Long comments are prose, not section names
    pending = (length(s) <= 24 && s !~ /#/) ? s : ""
    next
}

/^[[:space:]]*mode "/ { m = $0; sub(/^[^"]*"/, "", m); sub(/".*/, "", m); mode = m; next }
/^[[:space:]]*\}/     { mode = ""; next }

/^[[:space:]]*(bindsym|bindswitch|bindcode)[[:space:]]/ {
    if (pending != "") { section = pending; pending = "" }
    i = 2
    while ($i ~ /^--/) i++
    key = prettykey($i)
    cmd = ""
    for (j = i + 1; j <= NF; j++) cmd = cmd (j > i + 1 ? " " : "") $j
    for (v in vars) if (v != "$mod") gsub("\\" v, vars[v], cmd)
    sec = (mode != "") ? toupper(substr(mode, 1, 1)) substr(mode, 2) " mode" : section
    if ($1 == "bindswitch") sec = "Laptop lid"
    printf "%-24s %-26s %s\n", key, sec, describe(cmd)
    next
}

# Any other line ends a comment block, so it will not label the next bindings
{ if ($0 !~ /^[[:space:]]*$/) pending = "" }
' "$config" |
fuzzel --dmenu \
    --prompt 'Keys › ' \
    --placeholder 'Type to filter, Esc to close' \
    --font 'IBM Plex Mono:size=10' \
    --width 92 --lines 14 \
    --border-width 2 --border-color b7f34dff >/dev/null
