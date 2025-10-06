#!/usr/bin/env bash
# rerun as non-root user
if [ "$(whoami)" != "$USER" ]; then
  # Get logged in user
  USER=$(loginctl list-users | awk 'NR>1 {print $2}' | head -n1)
  [ -z "$USER" ] && exit 0
  sudo -u "$USER" ACTION="$ACTION" DISPLAY=:0 XDG_RUNTIME_DIR="/run/user/$(id -u "$USER")" "$0"
  exit 0
fi

TOUCHPAD_NAME="$(hyprctl --instance 0 devices | grep touchpad | xargs)"
# Set environment variables expected in Wayland sessions
export DISPLAY=:0
USER_ID="$(id -u)"
# export XDG_RUNTIME_DIR=/run/user/1000
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"
TOUCHPAD_STATE_TMP="/tmp/touchpad-toggle"
TOUCHPAD_STATE="$ACTION"
if [ -z "$TOUCHPAD_STATE" ]; then
  TOUCHPAD_STATE="$(cat "$TOUCHPAD_STATE_TMP")"
fi
if [[ "$TOUCHPAD_STATE" == "add" ]]; then
  hyprctl -r --instance 0 keyword "device[$TOUCHPAD_NAME]:enabled" false
  echo "remove" >"$TOUCHPAD_STATE_TMP"
  TOUCHPAD_STATE="disabled"
else
  hyprctl -r --instance 0 keyword "device[$TOUCHPAD_NAME]:enabled" true
  echo "add" >"$TOUCHPAD_STATE_TMP"
  TOUCHPAD_STATE="enabled"
fi

notify-send -a touchpad -i touchpad -p "Touchpad $TOUCHPAD_STATE"
