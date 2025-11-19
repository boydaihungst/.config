#!/bin/bash

# Check if a window address was found
if swaymsg -t get_tree | grep -q '"app_id": "gemini"'; then
    # If it exists, toggle its visibility on the scratchpad.
    swaymsg '[app_id="gemini"] focus'
else
    # If it doesn't exist, launch it.
    # A 'for_window' rule in the sway config will automatically move it.
    swaymsg exec "kitty --app-id 'gemini' -- gemini"
fi
