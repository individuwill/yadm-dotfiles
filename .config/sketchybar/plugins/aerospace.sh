#!/usr/bin/env bash
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

sid="$1"
focused="$FOCUSED_WORKSPACE"

# If the trigger didn't pass FOCUSED_WORKSPACE for some reason, do nothing.
[ -z "$focused" ] && exit 0

if [ "$sid" = "$focused" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=0x44ffffff \
    label.highlight=on
else
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=0x22ffffff \
    label.highlight=off
fi

