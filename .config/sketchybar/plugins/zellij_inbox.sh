#!/usr/bin/env bash
# Zellij attention inbox → sketchybar badge (see sketchybarrc "Zellij inbox").
# Counts, across every running session, panes whose attention status is:
#   NeedsYou (permission/question/auth; unless muted), Failed or Done (unless already seen or muted).
# Status values measured on Zellij 0.46.0: Idle, Working, NeedsYou, Done, Failed.
ZELLIJ="${ZELLIJ_BIN:-/opt/homebrew/bin/zellij}"
[ -x "$ZELLIJ" ] || { sketchybar --set "$NAME" drawing=off; exit 0; }

read -r needs failed done < <(
  "$ZELLIJ" list-sessions -n 2>/dev/null | grep -v EXITED | awk '{print $1}' | while read -r s; do
    [ -n "$s" ] && "$ZELLIJ" -s "$s" action list-panes -j -a 2>/dev/null
    echo
  done | /usr/bin/python3 -I -c '
import json, sys
needs = failed = done = 0
dec = json.JSONDecoder()
text = sys.stdin.read()
i = 0
while i < len(text):
    while i < len(text) and text[i].isspace():
        i += 1
    if i >= len(text):
        break
    try:
        panes, i = dec.raw_decode(text, i)
    except ValueError:
        break
    for p in panes if isinstance(panes, list) else []:
        a = p.get("attention") or {}
        if p.get("is_plugin") or a.get("muted"):
            continue
        st = a.get("status")
        if st == "NeedsYou":
            needs += 1
        elif st == "Failed" and not a.get("seen"):
            failed += 1
        elif st == "Done" and not a.get("seen"):
            done += 1
print(needs, failed, done)
'
)

total=$(( ${needs:-0} + ${failed:-0} + ${done:-0} ))
if [ "$total" -eq 0 ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi
if [ "${needs:-0}" -gt 0 ]; then color=0xffff5f5f
elif [ "${failed:-0}" -gt 0 ]; then color=0xfffe8019
else color=0xff9dd274
fi
sketchybar --set "$NAME" drawing=on icon.color="$color" label="$total"
