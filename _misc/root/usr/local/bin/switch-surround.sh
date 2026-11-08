#!/usr/bin/env bash

CARD="alsa_card.pci-0000_01_00.1"

PROFILE=$(
    pactl list cards |
        awk -v card="$CARD" '
        # Find our card
        $1 == "Name:" && $2 == card {
            in_card = 1
            next
        }

        # Stop at the next card
        in_card && $1 == "Card" {
            exit
        }

        # Enter Profiles section
        in_card && $1 == "Profiles:" {
            in_profiles = 1
            next
        }

        # Leave Profiles section
        in_profiles && $1 == "Active" && $2 == "Profile:" {
            exit
        }

        # Process available profiles
        in_profiles && /available: yes/ {
            name = $1
            sub(/:$/, "", name)

            # Prefer 7.1 surround, including -extraN
            if (name ~ /^output:hdmi-surround71(-extra[0-9]+)?$/) {
                selected = name
                found_71 = 1
                next
            }

            # 5.1 fallback
            if (!found_71 && name ~ /^output:hdmi-surround(-extra[0-9]+)?$/) {
                selected = name
            }
        }

        END {
            if (selected != "")
                print selected
        }
    '
)

if [[ -z "$PROFILE" ]]; then
    echo "No available HDMI surround profile found for $CARD"
    exit 1
fi

echo "Found profile: $PROFILE"
echo "Switching $CARD -> $PROFILE"

pactl set-card-profile "$CARD" "$PROFILE"
