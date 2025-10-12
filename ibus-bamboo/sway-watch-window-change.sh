#!/usr/bin/env bash

TMPFILE=/tmp/ibus-bamboo.config.json
WLCONFIGFILE=$HOME/.config/ibus-bamboo/mode.config
CONFIGFILE=$HOME/.config/ibus-bamboo/ibus-bamboo.config.json
DEFAULT_MODE=5

change_bamboo_mode() {
  CURENGINE=$(ibus engine 2>/dev/null)
  echo "======================="
  echo "current id: $1"
  echo "current engine: $CURENGINE"
  if [ "$CURENGINE" != "Bamboo" ]; then
    return
  fi
  if [ "$1" = "null" ]; then
    sleep 0.1
    return
  fi
  MODE=$(grep "$1" "$WLCONFIGFILE" | head -n1 | cut -d ':' -f 2 2>/dev/null)
  MODE=${MODE:-$DEFAULT_MODE}
  CURRENT_MODE=$(jq -r '.DefaultInputMode' "$CONFIGFILE" 2>/dev/null)
  # echo "current mode: $CURRENT_MODE"
  if [ "$CURRENT_MODE" = "$MODE" ]; then
    sleep 0.1
    return
  fi
  echo "new mode: $MODE"

  ibus engine xkb:us::eng
  jq ".DefaultInputMode = $MODE" "$CONFIGFILE" >"$TMPFILE"
  if [[ ! -s "$TMPFILE" ]]; then
    return
  fi
  mv "$TMPFILE" "$CONFIGFILE"
  ibus engine Bamboo
  if [ "$(ibus engine 2>/dev/null)" != "Bamboo" ]; then
    sleep 0.1
    ibus engine Bamboo
  fi
}

event_activewindow() {
  if command -v ibus-daemon &>/dev/null; then
    # ibus engine "xkb:us::eng" &>/dev/null
    # pkill -SIGRTMIN+30 waybar
    # swaymsg -t SUBSCRIBE '["window"]' -m | jq --unbuffered -r ".container.app_id" | while read -r app_id; do
    #   change_bamboo_mode "$app_id"
    # done

    change_bamboo_mode "$WINDOWCLASS"
  fi
}
