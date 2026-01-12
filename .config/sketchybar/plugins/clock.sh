#!/bin/sh

# Usage:
#   clock.sh                -> local time
#   clock.sh UTC            -> UTC time
#   clock.sh America/New_York
#   clock.sh Asia/Tokyo
#   clock.sh Europe/London

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

zone="${1-}"

format="+%m/%d %H:%M"
# Optional: show zone abbreviation when a zone is specified
[ -n "$zone" ] && format="$format %Z"

if [ -n "$zone" ]; then
	label="$(TZ="$zone" date "$format")"
else
	label="$(date "$format")"
fi

sketchybar --set "$NAME" label="$label"
