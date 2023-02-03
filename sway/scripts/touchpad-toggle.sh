#!/usr/bin/env bash

TOUCHPAD_NAME="ETPS/2 Elantech Touchpad"
TOUCHPAD_STATE=$(xinput list-props "$TOUCHPAD_NAME" | grep 'Device Enabled' | awk '{print $4}')
if [ $TOUCHPAD_STATE -eq 1 ]; then
	xinput disable "$TOUCHPAD_NAME"
	notify-send.sh -a touchpad -i touchpad --replace-file=/tmp/notification_touchpad "Touchpad Disabled"
else
	xinput enable "$TOUCHPAD_NAME"
	notify-send.sh -a touchpad -i touchpad --replace-file=/tmp/notification_touchpad "Touchpad enabled"
fi
