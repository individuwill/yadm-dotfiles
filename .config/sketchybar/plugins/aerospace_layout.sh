#!/usr/bin/env bash
layout="$(aerospace list-windows --focused --format '%{window-parent-container-layout}' 2>/dev/null || echo '—')"
sketchybar --set "$NAME" label="$layout"
