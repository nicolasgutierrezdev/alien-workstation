#!/bin/sh
# CPU temperature for waybar (custom/temperature), one JSON line every 5 s.
# The sensor is found by driver name, so the same config works on Intel, AMD
# and ARM machines. If nothing usable exists, the module stays hidden.
CRITICAL=85

# Inside a hwmon dir, prefer the package/die reading over single cores.
pick_input() {
    for label in "$1"/temp*_label; do
        [ -r "$label" ] || continue
        case "$(cat "$label")" in
            "Package id 0" | Tctl | Tdie | CPU)
                echo "${label%_label}_input"; return ;;
        esac
    done
    [ -r "$1/temp1_input" ] && echo "$1/temp1_input"
}

find_sensor() {
    # Most specific first: CPU drivers, then laptop EC, then generic ACPI.
    for want in coretemp k10temp zenpower cpu_thermal thinkpad; do
        for h in ${SYSFS:-/sys}/class/hwmon/hwmon*; do
            [ "$(cat "$h/name" 2>/dev/null)" = "$want" ] || continue
            input=$(pick_input "$h") && [ -n "$input" ] && { echo "$want $input"; return; }
        done
    done
    for z in ${SYSFS:-/sys}/class/thermal/thermal_zone*; do
        case "$(cat "$z/type" 2>/dev/null)" in
            x86_pkg_temp | cpu-thermal | acpitz) echo "$(cat "$z/type") $z/temp"; return ;;
        esac
    done
}

set -- $(find_sensor)
NAME=$1 INPUT=$2
[ -n "$INPUT" ] || { echo '{"text": ""}'; exit 0; }

while :; do
    t=$(( $(cat "$INPUT") / 1000 ))
    if [ "$t" -ge "$CRITICAL" ]; then
        printf '{"text": "%s° hot", "class": "critical", "tooltip": "CPU %s°C (%s)"}\n' "$t" "$t" "$NAME"
    else
        printf '{"text": "%s°", "class": "normal", "tooltip": "CPU %s°C (%s)"}\n' "$t" "$t" "$NAME"
    fi
    sleep 5
done
