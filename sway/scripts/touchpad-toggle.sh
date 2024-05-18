#!/usr/bin/env bash
swaymsg input type:touchpad events toggle
# TOUCHPAD_NAME="ETPS/2 Elantech Touchpad"
# TOUCHPAD_STATE=$(xinput list-props "$TOUCHPAD_NAME" | grep 'Device Enabled' | awk '{print $4}')
# if [ $TOUCHPAD_STATE -eq 1 ]; then
# 	swaymsg input type:touchpad events toggle disabled
# 	notify-send.sh -a touchpad -i touchpad --replace-file=/tmp/notification_touchpad "Touchpad Disabled"
# else
# 	swaymsg input type:touchpad events toggle enabled
# 	notify-send.sh -a touchpad -i touchpad --replace-file=/tmp/notification_touchpad "Touchpad enabled"
# fi
