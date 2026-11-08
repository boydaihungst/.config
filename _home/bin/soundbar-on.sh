#!/bin/bash
TOKEN=$(pass ha/token)
if [ -z "$TOKEN" ]; then
  notify-send "Error" "No home assistant token"
  exit 1
fi
curl -X POST 'https://homeassistant.linuxholic.com/api/services/switch/turn_on' \
  -H "Authorization: Bearer ${TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{
    "entity_id": "switch.living_room_q990f_power"
  }'
# Use shikane instead
# /usr/local/bin/switch-surround.sh
