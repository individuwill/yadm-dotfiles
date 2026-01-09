#!/usr/bin/env bash
title="$(aerospace list-windows --focused --format '%{app-name}: %{window-title}' 2>/dev/null || echo '—')"
sketchybar --set "$NAME" label="$title"
