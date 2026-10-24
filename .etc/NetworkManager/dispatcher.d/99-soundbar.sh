#!/bin/bash
INTERFACE="$1"
ACTION="$2"
USER_NAME="huyhoang"
USER_USER_HOME="/home/$USER_NAME"
USER_ID="$(id -u "$USER_NAME")"

# Get the active SSID name
CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [ "$ACTION" = "up" ] && [ "$CURRENT_SSID" = "Hoang 6G" ] && [ "$INTERFACE" = "wlp4s0" ]; then
    sudo -u "$USER_NAME" \
        HOME="$USER_USER_HOME" \
        XDG_RUNTIME_DIR="/run/user/$USER_ID" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
        systemctl --user restart soundbar-connect.service
fi
