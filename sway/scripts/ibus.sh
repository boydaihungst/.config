#!/usr/bin/env bash
EN_ibus="BambooUs"
VN_ibus="Bamboo"
lang=$(ibus engine)

if [ "$lang" == "$EN_ibus" ]; then
	echo "EN"
fi
if [ "$lang" == "$VN_ibus" ]; then
	echo "VN"
fi
