#!/usr/bin/env bash
MC=/opt/homebrew/bin/media-control
ICON_MUSIC=$'\xef\x80\x81'   # U+F001  nf-fa-music

json="$("$MC" get 2>/dev/null)"
title="$(jq -r '.title // empty' <<<"$json")"
artist="$(jq -r '.artist // empty' <<<"$json")"
playing="$(jq -r '.playing // false' <<<"$json")"

if [ -z "$title" ]; then
  sketchybar --set "$NAME" drawing=off \
             --set media_bracket drawing=off
  exit 0
fi

label="$title"
[ -n "$artist" ] && label="$title — $artist"

if [ "$playing" = "true" ]; then
  icon_color=0xfffe8019
  text_color=0xffffffff
else
  icon_color=0x80fe8019
  text_color=0x99ffffff
fi

sketchybar --set "$NAME" drawing=on \
             icon="$ICON_MUSIC" \
             icon.color="$icon_color" \
             label="$label" \
             label.color="$text_color" \
           --set media_bracket drawing=on
