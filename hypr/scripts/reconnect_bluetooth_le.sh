#!/usr/bin/env bash

(
  {
    echo "power on"
    sleep 2
    echo "remove DC:04:5A:5D:F7:52"
    sleep 1
    echo "scan on"
    sleep 5
    echo "scan off"
    echo "agent on"
    sleep 1
    echo "pair DC:04:5A:5D:F7:52"
    sleep 1
    echo "trust DC:04:5A:5D:F7:52"
    sleep 1
    echo "connect DC:04:5A:5D:F7:52"
    sleep 1
    echo "quit"
  } | bluetoothctl
) &
disown
