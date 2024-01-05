#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
# polybar-msg cmd quit
# Otherwise you can use the nuclear option:
killall -q polybar
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done
for m in $(polybar --list-monitors | cut -d":" -f1); do
  if [ $m == 'eDP-1' ] 
	then
		MONITOR=$m polybar --reload mybar -c ~/.config/polybar/config.ini &	
	elif [ $m == 'HDMI-1' ]
	then
		MONITOR=$m polybar --reload mybar -c ~/.config/polybar/config.ini &
	fi
done

echo "Bars launched..."
