#!/bin/bash

DEVICE=$(brightnessctl -l | grep "amdgpu" | awk -F"'" '/Device/{print $2}')
if [[ -z "$DEVICE" ]]; then
  return
fi
brightnessctl -d "$DEVICE" set "${1}"
CURRENT_BRIGHTNESS=$(brightnessctl -d "$DEVICE" get)
MAX_BRIGHTNESS=$(brightnessctl -d "$DEVICE" m)
BASE_100_BRIGHTNESS=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))
notify-send -a brightness -i "brightnesssettings" -h int:value:"$BASE_100_BRIGHTNESS" "Brightness" "Brightness - ${BASE_100_BRIGHTNESS}%"
