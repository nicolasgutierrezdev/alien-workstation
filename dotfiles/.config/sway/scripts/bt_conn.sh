#!/bin/bash

bluetoothctl power on >/dev/null

SCAN_TIME=5

# Start scan in background
bluetoothctl scan on >/dev/null 2>&1 &
SCAN_PID=$!

sleep $SCAN_TIME

# Stop scan
bluetoothctl scan off >/dev/null 2>&1
kill $SCAN_PID 2>/dev/null

# Get device lists
KNOWN=$(bluetoothctl devices)
CONNECTED=$(bluetoothctl devices Connected)

# Build menu
CHOICE=$( (
    echo "󰓛 Disconnect all"

    echo "$KNOWN" | sed 's/^Device //' | while read -r mac name; do
        [ -z "$name" ] && name="[unknown]"

        # Check if connected
        if echo "$CONNECTED" | grep -q "$mac"; then
            icon="󰂱"   # connected icon
        else
            icon="󰂲"   # disconnected icon
        fi

        printf "%s %s\t%s\n" "$icon" "$name" "$mac"
    done
) | sort -u | fuzzel --dmenu --with-nth=1)

# Extract MAC
MAC=$(printf "%s" "$CHOICE" | awk -F'\t' '{print $2}')

# Actions
if [[ "$CHOICE" == "󰓛 Disconnect all" ]]; then
    bluetoothctl devices Connected | awk '{print $2}' | while read -r dev; do
        bluetoothctl disconnect "$dev"
    done

elif [[ -n "$MAC" ]]; then
    if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
        bluetoothctl disconnect "$MAC"
    else
        bluetoothctl connect "$MAC"
    fi
fi
