#!/bin/bash

# Use hyprctl to get client info in JSON format, then use jq to find the window
# address of the kitty instance with the app-id 'gemini'.
WINDOW_ADDRESS=$(hyprctl clients -j | jq -r '.[] | select(.class == "gemini") | .address')

# Check if a window address was found
if [ -n "$WINDOW_ADDRESS" ]; then
    # If the window exists, toggle the workspace special.
    hyprctl dispatch togglespecialworkspace
else
    # If the window does not exist, run the specified kitty command.
    hyprctl dispatch exec [workspace special] "kitty --app-id 'gemini' -- gemini"
fi
