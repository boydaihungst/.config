#!/usr/bin/env bash

SHIKANE_OUTPUT_NAME="$1"

# Wrap everything in a subshell and run it in the background
(
  # 1. Wait at the start
  sleep 5

  if [[ "$XDG_SESSION_DESKTOP" == "Hyprland" ]]; then
    hyprctl keyword monitor "DP-1, 2560x1440@240, 0x0, 1, bitdepth, 8, vrr, 1, cm, auto, icc, $HOME/.config/sway/scripts/color_profiles/Q27G42ZE.icm"
    hyprctl keyword monitor "eDP-1, disable"
    hyprctl keyword monitor "HDMI-A-1, 4096x2160@119.88, 0x1600"
    for i in {1..9}; do
      hyprctl dispatch moveworkspacetomonitor "$i" "DP-1" >/dev/null 2>&1 &
    done

  elif [[ "$XDG_SESSION_DESKTOP" == "Sway" ]]; then
    # 2. Set the color profile
    # Removed the outer quotes so bash actually executes the command
    swaymsg output "$SHIKANE_OUTPUT_NAME" color_profile icc "$HOME/.config/sway/scripts/color_profiles/Q27G42ZE.icm" >/dev/null 2>&1 &

    # 3. Move workspaces 1 through 9
    for i in {1..9}; do
      swaymsg "workspace $i, move workspace to $SHIKANE_OUTPUT_NAME" >/dev/null 2>&1 &
    done
    swaymsg workspace number 1

  fi
) &

# Disown the entire subshell group so it persists after this script exits
disown
