#!/bin/bash

# Use hyprctl to get client info in JSON format, then use jq to find the window
# address of the kitty instance with the app-id 'gemini'.
WINDOW_ADDRESS=$(hyprctl clients -j | jq -r '.[] | select(.class == "gemini") | .address')

# Check if a window address was found
if [ -n "$WINDOW_ADDRESS" ]; then
    # If the window exists, focus it using its address.
    # hyprctl dispatch togglespecialworkspace
    hyprctl dispatch focuswindow address:"$WINDOW_ADDRESS"
else
    # If the window does not exist, run the specified kitty command.
    # The '&' at the end runs the command in the background.
    # hyprctl dispatch exec [workspace special] "kitty --app-id 'gemini' -- gemini"
    hyprctl dispatch exec "kitty --app-id 'gemini' -- gemini"
fi
