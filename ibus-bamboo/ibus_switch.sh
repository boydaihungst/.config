#!/usr/bin/env bash
EN_ibus="xkb:us::eng"
VN_ibus="Bamboo"

if ! command -v ibus-daemon &>/dev/null; then
  exit 1
fi

# if ! pgrep -x "ibus-daemon" >/dev/null; then
#   "$HOME"/.config/ibus-bamboo/sway-watch-window-change.sh &
#   disown
# fi

CUR_ENGINE=$(ibus engine 2>/dev/null)
if [ "$CUR_ENGINE" == "$EN_ibus" ]; then
  ibus engine $VN_ibus
  pkill -SIGRTMIN+30 waybar
  notify-send.sh -u low --replace-file=/tmp/notification_language "VN"
else
  ibus engine $EN_ibus
  pkill -SIGRTMIN+30 waybar
  notify-send.sh -u low --replace-file=/tmp/notification_language "EN"
fi
