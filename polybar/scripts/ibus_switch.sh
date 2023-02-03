#!/usr/bin/env bash
EN_ibus="BambooUs"
VN_ibus="Bamboo"

lang=$(ibus engine)

if [ "$lang" == "$EN_ibus" ]; then
	ibus engine $VN_ibus
  polybar-msg action keyboard-layout hook 0
	notify-send.sh -u low --replace-file=/tmp/notification_language "VN"
fi
if [ "$lang" == "$VN_ibus" ]; then
	ibus engine $EN_ibus
  polybar-msg action keyboard-layout hook 0
	notify-send.sh -u low --replace-file=/tmp/notification_language "EN"
fi
