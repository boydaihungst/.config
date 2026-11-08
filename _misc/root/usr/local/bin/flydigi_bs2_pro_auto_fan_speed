#!/bin/bash

# ==========================================
# Configuration
# ==========================================
CHECK_INTERVAL=10 # How often to check temperatures (in seconds)
CURRENT_GEAR=-1   # Initialize to -1 so it forces a run on startup

# ==========================================
# Functions to fetch temperatures
# ==========================================

get_cpu_temp() {
  local max_temp=0

  # Loop through hwmon directories
  for hwmon in /sys/class/hwmon/hwmon*; do
    # Check if this hwmon is the AMD CPU
    if [[ -f "$hwmon/name" ]] && [[ "$(cat "$hwmon/name" 2>/dev/null)" == "k10temp" ]]; then
      # k10temp usually outputs to temp1_input (Tctl/Tdie)
      if [[ -f "$hwmon/temp1_input" ]]; then
        temp=$(cat "$hwmon/temp1_input" 2>/dev/null)
        if [[ "$temp" =~ ^[0-9]+$ ]]; then
          max_temp=$((temp / 1000))
        fi
      fi
    fi
  done
  echo "$max_temp"
}

get_gpu_temp() {
  # Auto-detect NVIDIA
  if command -v nvidia-smi &>/dev/null; then
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null
    return
  fi

  # Auto-detect AMDGPU / Intel via DRM hwmon
  local max_temp=0
  # Removed the invalid 2>/dev/null here as well
  for hwmon in /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input; do
    if [[ -f "$hwmon" ]]; then
      temp=$(cat "$hwmon" 2>/dev/null)
      if [[ "$temp" =~ ^[0-9]+$ ]]; then
        temp=$((temp / 1000))
        if ((temp > max_temp)); then
          max_temp=$temp
        fi
      fi
    fi
  done

  echo "$max_temp"
}

# ==========================================
# Main Logic
# ==========================================

apply_gear() {
  local target_gear=$1
  local current_max_temp=$2
  # Only execute if the gear is actually changing
  if [[ "$CURRENT_GEAR" != "$target_gear" ]]; then
    echo "$(date '+%H:%M:%S') | Temp: ${current_max_temp}°C | Shifting to gear ${target_gear}..."
    pushd "/home/huyhoang/.config/hypr/scripts" &>/dev/null || exit
    # Run your command
    echo "gear ${target_gear} 3" | go run "hid_controller.go"
    # Update current state
    CURRENT_GEAR=$target_gear
  fi
}

echo "Starting Temperature Watcher..."

while true; do
  cpu=$(get_cpu_temp)
  gpu=$(get_gpu_temp)

  # Fallback to 0 if empty
  cpu=${cpu:-0}
  gpu=${gpu:-0}

  # Find the maximum temperature between CPU and GPU
  # Because your logic is "CPU >= X OR GPU >= X", max() covers this perfectly.
  max_temp=$cpu
  if ((gpu > max_temp)); then
    max_temp=$gpu
  fi

  # Determine which gear to use based on the highest temperature
  if ((max_temp >= 80)); then
    apply_gear 4 "$max_temp"
  elif ((max_temp >= 70)); then
    # The `< 80` condition is implicitly handled by the elif
    apply_gear 3 "$max_temp"
  elif ((max_temp >= 60)); then
    apply_gear 2 "$max_temp"
  elif ((max_temp >= 50)); then
    apply_gear 1 "$max_temp"
  else
    # Optional: What happens if it drops below 50°C?
    # apply_gear 0 "$max_temp"
    : # Do nothing
  fi

  sleep "$CHECK_INTERVAL"
done
