#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
sleep 1
primary_display=$(polybar --list-monitors | grep "primary" | cut -d":" -f1)
for m in $(polybar --list-monitors | cut -d":" -f1); do
	if [ "$m" == "$primary_display" ]; then
		MONITOR=$m polybar -c ~/.config/polybar/config.ini primarybar &
	else
		MONITOR=$m polybar -c ~/.config/polybar/config.ini secondarybar &
	fi
done

echo "Bars launched..."
