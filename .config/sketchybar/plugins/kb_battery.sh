#!/usr/bin/env bash

# Load per-machine config if present
PLUGIN_DIR="${PLUGIN_DIR:-$HOME/.config/sketchybar/plugins}"
[[ -f "$PLUGIN_DIR/config.env" ]] && source "$PLUGIN_DIR/config.env"

# Icons
ICON_KEYBOARD="󰌌"
ICON_ERROR="󰅙" # nf-md-alert_circle_outline (pick any Nerd Font glyph you like)
ICON_UNKNOWN="󰂎"

# If disabled on this machine: hide completely and exit
if [[ "${KB_BATT_ENABLED:-1}" != "1" ]]; then
	sketchybar --set "$NAME" drawing=off
	exit 0
fi

DEVICE_NAME="${KB_BATT_DEVICE:-}"

JSON="$(system_profiler -json SPBluetoothDataType 2>/dev/null)"
if [[ -z "$JSON" ]]; then
	# Expected device configured? show error; otherwise hide
	if [[ -n "$DEVICE_NAME" ]]; then
		sketchybar --set "$NAME" drawing=on icon="$ICON_ERROR" label="err"
	else
		sketchybar --set "$NAME" drawing=off
	fi
	exit 0
fi

if [[ -n "$DEVICE_NAME" ]]; then
	PCT="$(jq -r --arg n "$DEVICE_NAME" '
    .SPBluetoothDataType[]
    | (.device_connected // [])
    | .[]
    | .[$n]?
    | .device_batteryLevelMain? // empty
  ' <<<"$JSON")"
else
	PCT="$(jq -r '
    .SPBluetoothDataType[]
    | (.device_connected // [])
    | .[]
    | to_entries[]
    | select(.value.device_batteryLevelMain? != null)
    | .value.device_batteryLevelMain
  ' <<<"$JSON" | head -n1)"
fi

# If we couldn't get battery:
if [[ -z "$PCT" ]]; then
	if [[ -n "$DEVICE_NAME" ]]; then
		# You explicitly asked for a specific device, so this is an error state
		sketchybar --set "$NAME" drawing=on icon="$ICON_ERROR" label="--"
	else
		# No explicit device configured: treat as "nothing to show"
		sketchybar --set "$NAME" drawing=off
	fi
	exit 0
fi

# Sanity check format like "100%"
if ! [[ "$PCT" =~ ^[0-9]{1,3}%$ ]]; then
	sketchybar --set "$NAME" drawing=on icon="$ICON_ERROR" label="$PCT"
	exit 0
fi

# Normal display
sketchybar --set "$NAME" drawing=on icon="$ICON_KEYBOARD" label="$PCT"

