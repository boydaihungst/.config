#!/bin/bash

brightnessctl set "${1}"
CURRENT_BRIGHTNESS=$(brightnessctl g)
MAX_BRIGHTNESS=$(brightnessctl m)
BASE_100_BRIGHTNESS=$((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))
notify-send -a brightness -i "brightnesssettings" -h int:value:"$BASE_100_BRIGHTNESS" "Brightness" "Brightness - ${BASE_100_BRIGHTNESS}%"
