#!/usr/bin/env bash

 xidlehook \
   --detect-sleep \
   --not-when-audio \
   --not-when-fullscreen \
   --timer 600 "betterlockscreen -l --off 60" "" \
   --timer 1800 "systemctl sleep-then-hibernate" "" \
   --socket "/tmp/xidlehook.sock"
