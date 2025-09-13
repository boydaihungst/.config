#!/usr/bin/env bash

files_raw=$(fd -e jpg -e jpeg -e png -e gif -e webp -d 1 -t f "." | sort | while IFS= read -r A; do
  safe_filename=$(printf '%s\n' "$(basename -- "$A")" | sed 's/\\/\\\\/g; s/"/\\"/g')
  if [[ "$A" =~ \.(jpg|jpeg|png|gif|webp|bmp|tiff|svg)$ ]]; then
    printf '%s\x00icon\x1f%s\n' "$safe_filename" "$safe_filename"
  else
    printf '%s\0icon\x1fthumbnail://%s\n' "$safe_filename" "$safe_filename"
  fi
done |
  rofi \
    -show-icons \
    -theme "$HOME"/.config/rofi/rofi-gridview.rasi \
    -show-icons \
    -format "q" \
    -ballot-selected-str "󰄲 " \
    -ballot-unselected-str " " \
    -dmenu -multi-select -p "Select images")

while IFS= read -r B; do
  selected_files="$selected_files $B"
done <<<"$files_raw"

if [[ -n "$selected_files" ]]; then
  ya emit-to "$YAZI_ID" plugin rofi-img-gridview -- "$selected_files"
fi
