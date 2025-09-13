#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu
#
## Available Styles
#
## style-1   style-2   style-3   style-4   style-5
## style-6   style-7   style-8   style-9   style-10

# Current Theme
dir="$HOME/.config/rofi/powermenu/type-2"
theme='style-4'

# CMDs
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(hostname)

# Options
shutdown=''
reboot=''
lock=''
hibernate=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$hibernate\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	# selected="$(confirm_exit)"
	selected=$yes
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--hibernate' ]]; then
			playerctl pause
			# amixer set Master mute
			# systemctl hybrid-sleep
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			if command -v uwsm &>/dev/null; then
				uwsm stop
			elif [[ "$XDG_CURRENT_DESKTOP" == openbox* ]]; then
				openbox --exit
			elif [[ "$XDG_CURRENT_DESKTOP" == bspwm* ]]; then
				bspc quit
			elif [[ "$XDG_CURRENT_DESKTOP" == i3* ]]; then
				i3-msg exit
			elif [[ "$XDG_CURRENT_DESKTOP" == plasma* ]]; then
				qdbus org.kde.ksmserver /KSMServer logout 0 0 0
			fi
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
	run_cmd --shutdown
	;;
$reboot)
	run_cmd --reboot
	;;
$lock)
	if [[ "$XDG_CURRENT_DESKTOP" == sway* ]]; then
		pidof swaylock || swaylock -C ~/.config/swaylock/config
	elif [[ "$XDG_CURRENT_DESKTOP" == Hyprland* ]]; then
		pidof hyprlock || hyprlock -q
	elif command -v betterlockscreen &>/dev/null; then
		betterlockscreen -l
	elif [[ "$XDG_CURRENT_DESKTOP" == i3* ]]; then
		pidof i3lock || i3lock
	fi
	;;
$hibernate)
	run_cmd --hibernate
	;;
$logout)
	run_cmd --logout
	;;
esac
