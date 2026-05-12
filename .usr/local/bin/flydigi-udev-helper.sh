#!/bin/sh
# This script is called by udev and must exit quickly

case "$1" in
    add)
        # Start the service if not already running
        rc-service flydigi-fan-control start
        ;;
    remove)
        # Stop the service when controller disconnects
        rc-service flydigi-fan-control stop
        ;;
esac

exit 0
