#!/usr/bin/env bash

(
  {
    echo "power on"
    sleep 3
    echo "remove DE:04:5A:5D:F7:52"
    sleep 3
    echo "scan on"
    sleep 5
    echo "scan off"
    # echo "agent on"
    sleep 3
    echo "pair DE:04:5A:5D:F7:52"
    sleep 3
    echo "trust DE:04:5A:5D:F7:52"
    sleep 3
    echo "connect DE:04:5A:5D:F7:52"
    sleep 3
    echo "quit"
  } | bluetoothctl
) &
disown
