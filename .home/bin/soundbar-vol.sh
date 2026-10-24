#!/bin/bash
TOKEN="$(pass ha/token)"
if [ -z "$TOKEN" ]; then
  notify-send "Error" "No home assistant token"
  exit 1
fi

VOL=$(awk "BEGIN {printf \"%.2f\", $1/100}")
echo "$VOL"
curl -X POST 'https://homeassistant.linuxholic.com/api/services/media_player/volume_set' \
  -H "Authorization: Bearer ${TOKEN}" \
  -H 'Content-Type: application/json' \
  -d "{
    \"entity_id\": \"media_player.living_room_q990f\",
    \"volume_level\": \"${VOL}\"
  }"
