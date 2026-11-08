#!/usr/bin/env bash
(
    # 1. Wait at the start
    sleep 5

    CARD_MATCH="GB206 High Definition Audio Controller"
    PORT_MATCH="SAMSUNG"
    PROFILE_PREFIX="output:hdmi-stereo"

    command -v pactl >/dev/null || {
        echo "Error: pactl not found."
        exit 1
    }

    command -v jq >/dev/null || {
        echo "Error: jq not found."
        exit 1
    }

    cards=$(pactl -f json list cards)

    card=$(jq -cer --arg match "$CARD_MATCH" '
        [
            .[]
            | select(.properties["device.product.name"] == $match)
        ]
        | if length == 1 then .[0] else error("Expected exactly one NVIDIA card") end
    ' <<<"$cards")

    card_name=$(jq -r '.name' <<<"$card")

    # Find the Samsung HDMI port.
    port=$(jq -cer --arg match "$PORT_MATCH" '
        [
            .ports
            | to_entries[]
            | select(
                (.value.properties["device.product.name"] // "") == $match
            )
        ]
        | if length == 1 then .[0] else error("Expected exactly one Samsung HDMI port") end
    ' <<<"$card")

    port_name=$(jq -r '.key' <<<"$port")

    # Find the stereo profile belonging to this specific port.
    profile=$(jq -cer --arg port "$port_name" --arg prefix "$PROFILE_PREFIX" '
        .ports[$port].profiles
        | map(select(startswith($prefix)))
        | if length == 1 then .[0] else error("Expected exactly one stereo profile") end
    ' <<<"$card")

    echo "Audio card: $card_name"
    echo "Samsung port: $port_name"
    echo "Selected profile: $profile"

    current_profile=$(jq -r '.active_profile' <<<"$card")

    if [[ "$current_profile" == "$profile" ]]; then
        echo "Already using the correct profile."
        exit 0
    fi

    pactl set-card-profile "$card_name" "$profile"
) &

# Disown the entire subshell group so it persists after this script exits
disown

