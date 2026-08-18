#!/usr/bin/env bash

swaymsg -t get_outputs -r |
  jq -c '
  .[]
  | select(.name == "DP-1")
  | if .hdr then
      {
        text: "HDR",
        tooltip: "HDR mode",
        class: "on"
      }
    else
      {
        text: "SDR",
        tooltip: "SDR mode",
        class: "off"
      }
    end
'
