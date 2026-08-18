#!/usr/bin/env bash

if swaymsg -t get_outputs -r | jq -e '.[] | select(.name=="DP-1") | .hdr' >/dev/null; then
    swaymsg output DP-1 hdr off color_profile icc ~/.config/sway/scripts/color_profiles/Q27G4ZDP.icm
else
    swaymsg output DP-1 hdr on color_profile gamma22
fi
pkill -RTMIN+10 waybar
