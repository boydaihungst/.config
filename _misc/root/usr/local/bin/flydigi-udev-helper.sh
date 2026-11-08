#!/bin/sh

USER_NAME="huyhoang"
USER_ID="$(id -u "$USER_NAME")"

case "$1" in
add)
    sudo -u huyhoang \
        XDG_RUNTIME_DIR=/run/user/"$USER_ID" \
        DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$USER_ID"/bus \
        systemctl --user restart flydigi-fan-control.service
    ;;

remove)
    sudo -u huyhoang \
        XDG_RUNTIME_DIR=/run/user/"$USER_ID" \
        DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$USER_ID"/bus \
        systemctl --user stop flydigi-fan-control.service
    ;;
esac

exit 0
