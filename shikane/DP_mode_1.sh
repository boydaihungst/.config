#!/usr/bin/env bash

SHIKANE_OUTPUT_NAME="$1"

# Wrap everything in a subshell and run it in the background
(
  # 1. Wait at the start
  sleep 5

  if [[ "$XDG_SESSION_DESKTOP" == "Hyprland" ]]; then
    hyprctl eval '
      hl.monitor({
        output = "DP-2",
        mode = "2560x1440@240",
        scale = 1,
        position = "2560x0",
        bitdepth = 8,
        vrr = 0,
        icc = "/home/huyhoang/.config/sway/scripts/color_profiles/Q27G42ZE.icm",
      })
    '

    hyprctl eval '
      hl.monitor({
        output = "DP-1",
        mode = "2560x1440@280",
        scale = 1,
        position = "0x0",
        cm = "auto",
        vrr = 0,
        bitdepth = 10,
        icc = "/home/huyhoang/.config/sway/scripts/color_profiles/Q27G4ZDP.icm",
      })
    '

    hyprctl eval '
      hl.monitor({
        output = "HDMI-A-1",
        mode = "1920x1080@60",
        position = "5120x1440",
        scale = 1,
        bitdepth = 8,
        vrr = 0,
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
  fi
) &

# Disown the entire subshell group so it persists after this script exits
disown
