#!/bin/bash

# Check if any device name does NOT match the two patterns
result=$(hyprctl devices -j | jq -r '
.mice[] | select(
    (.name | startswith("ydotoold-virtual") | not) and
    (.name | startswith("etps/2-elantech-touchpad") | not)
) | .name
')

if [ -n "$result" ]; then
    ACTION=add ~/.config/hypr/scripts/touchpad-toggle.sh
fi
