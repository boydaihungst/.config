#!/bin/bash
INTERFACE="$1"
ACTION="$2"

# Get the active SSID name
CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

if [ "$ACTION" = "up" ] && [ "$CURRENT_SSID" = "Hoang 6G" ]; then
  # Run the soundbar script as the logged-in user
  su - huyhoang -c "/home/huyhoang/bin/soundbar-on.sh"
fi
