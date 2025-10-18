#!/bin/bash

# Get the current refresh rate of monitor eDP-1
CURRENT_RATE=$(hyprctl monitors | grep "eDP-1" | grep -oP '@ \K[0-9]+')

# Toggle between 60 and 240 Hz
if [ "$CURRENT_RATE" -eq 240 ]; then
  hyprctl keyword monitor eDP-1, 2560x1600@60, auto, 1.6, bitdepth, 10, cm, auto
  notify-send "Refresh Rate" "Set to 60Hz"
else
  hyprctl keyword monitor eDP-1, 2560x1600@240, auto, 1.6, bitdepth, 10, cm, auto
  notify-send "Refresh Rate" "Set to 240Hz"
fi
