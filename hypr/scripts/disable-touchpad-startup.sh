#!/bin/bash

# Define ignore name patterns (case-insensitive)
ignore_patterns=(
    "ydotoold-virtual"
    "etps/2-elantech-touchpad"
    "ite-tech.-inc.-ite-device(8258)-keyboard-1"
    "elan06fa:00-04f3:327e-mouse"
    "elan06fa:00-04f3:327e-touchpad"
)

# Build jq filter dynamically
jq_filter=""
for pattern in "${ignore_patterns[@]}"; do
    jq_filter+="(.name | startswith(\"$pattern\") | not) and "
done
# remove trailing " and "
jq_filter="${jq_filter::-5}"

# Check for devices not matching the ignore patterns
result=$(hyprctl devices -j | jq -r ".mice[] | select($jq_filter) | .name")

if [ -n "$result" ]; then
    # enable touchpad
    hyprctl -r keyword "device[elan06fa:00-04f3:327e-touchpad]:enabled" false
fi
