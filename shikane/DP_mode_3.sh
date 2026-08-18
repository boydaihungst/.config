#!/usr/bin/env bash

SHIKANE_OUTPUT_NAME="$1"

# Wrap everything in a subshell and run it in the background
(
  # 1. Wait at the start
  sleep 5

  if [[ "$XDG_SESSION_DESKTOP" == "Hyprland" ]]; then
    hyprctl eval '
      hl.monitor({
        output = "DP-1",
        mode = "2560x1440@280",
        scale = 1,
        position = "0x0",
        bitdepth = 10,
        cm = "auto",
        vrr = 0,
        icc = "/home/huyhoang/.config/sway/scripts/color_profiles/Q27G4ZDP.icm",
      })
    '
    # icc = "/home/huyhoang/.config/sway/scripts/color_profiles/Q27G42ZE.icm",

    hyprctl eval '
      hl.monitor({
        output = "HDMI-A-1",
        mode = "1920x1080@60",
        position = "2560x1440",
        scale = 1,
        vrr = 0,
      })
    '

    hyprctl eval '
      hl.monitor({
        output = "DP-2",
        disabled = true,
      })
    '

    hyprctl eval '
      hl.monitor({
        output = "eDP-1",
        disabled = true,
      })
    '
    for i in {1..3}; do
      hyprctl dispatch moveworkspacetomonitor "$i" "DP-1" >/dev/null 2>&1 &
    done

    for i in {4..9}; do
      hyprctl dispatch moveworkspacetomonitor "$i" "DP-2" >/dev/null 2>&1 &
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
