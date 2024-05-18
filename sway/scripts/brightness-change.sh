#!/bin/bash

brightnessctl set "${1}"
CURRENT_BRIGHTNESS=$(brightnessctl g)
MAX_BRIGHTNESS=$(brightnessctl m)
notify-send.sh -a brightness -i "brightnesssettings" --replace-file=/tmp/notification_brightness "Brightness" "Brightness - $((CURRENT_BRIGHTNESS * 100 / MAX_BRIGHTNESS))%"
