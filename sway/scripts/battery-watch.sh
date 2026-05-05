#!/usr/bin/env bash

# Battery thresholds
LOW_BATTERY=15
CRITICAL_BATTERY=2

# --- INITIAL STARTUP CHECK ---
# Get current device paths
BAT_DEV=$(upower -e | grep 'BAT')
ADP_DEV=$(upower -e | grep 'line_power')

# Initial Power Profile & Notification logic
initial_online=$(upower -i "$ADP_DEV" | grep "online:" | awk '{print $2}')
initial_cap=$(upower -i "$BAT_DEV" | grep "percentage:" | grep -oP '\d+(?=%)')

if ! command -v "powerprofilesctl" >/dev/null 2>&1; then
  function powerprofilesctl {
    :
  }
fi

if [[ "$initial_online" == "yes" ]]; then
  powerprofilesctl set balanced
else
  # Set profile based on current percentage if on battery
  if [ "$initial_cap" -le "$LOW_BATTERY" ]; then
    powerprofilesctl set power-saver
  else
    powerprofilesctl set balanced
  fi
fi

# Monitor upower and react to specific changes
upower --monitor-detail | stdbuf -oL awk '/device changed|online:|percentage:|state:/' | while read -r line; do

  # 1. Detect AC Power Changes
  if [[ "$line" =~ "online:" ]]; then
    if [[ "$line" =~ "yes" ]]; then
      notify-send -a battery -t 1000 -u low -i "ac-adapter" "Power Connected" "System is now on AC power."
      # powerprofilesctl set balanced
    else
      notify-send -a battery -t 1000 -u normal -i "battery-caution" "Power Disconnected" "System is now on Battery."
      powerprofilesctl set power-saver
    fi
  fi

  # 2. Detect Battery Percentage and Low/Critical alerts
  if [[ "$line" =~ "percentage:" ]]; then
    # Extract only the number
    cap=$(echo "$line" | grep -oP '\d+(?=%)')

    # Check if we are currently discharging to avoid low alerts while charging
    # We fetch the state quickly from upower directly for accuracy
    status=$(upower -i "$(upower -e | grep 'BAT')" | grep "state" | awk '{print $2}')

    if [[ "$status" == "discharging" ]]; then
      if [ "$cap" -le "$CRITICAL_BATTERY" ]; then
        notify-send -a battery -t 1000 -u critical -i "battery-empty" "CRITICAL BATTERY" "Only $cap% remaining!"
        if grep -qw disk /sys/power/state; then
          loginctl hibernate
        fi

      elif [ "$cap" -le "$LOW_BATTERY" ]; then
        notify-send -a battery -t 1000 -u normal -i "battery-low" "Low Battery" "Battery dropped to $cap%."
        powerprofilesctl set power-saver
      fi
    fi
  fi
done
