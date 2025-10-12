#!/usr/bin/env bash

EN_ibus="xkb:us::eng"
VN_ibus="Bamboo"
CUR_ENGINE=$(ibus engine 2>/dev/null)

if [ "$CUR_ENGINE" == "$EN_ibus" ]; then
  printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "EN" "en" "Tiếng Anh"
fi
if [ "$CUR_ENGINE" == "$VN_ibus" ]; then
  printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "VN" "vn" "Tiếng Việt"
fi
