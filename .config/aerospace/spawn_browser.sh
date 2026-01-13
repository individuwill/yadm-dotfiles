#!/bin/sh

CONFIG="$HOME/.config/aerospace/config.env"
[ -r "$CONFIG" ] && . "$CONFIG"

# ---- config defaults (can be overridden in config.env) ----
PREFERRED_BROWSER="${PREFERRED_BROWSER:-Chrome}"

CHROME_BIN="${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
CHROME_STATE_FILE="${CHROME_STATE_FILE:-$HOME/Library/Application Support/Google/Chrome/Local State}"

ZEN_APP_NAME="${ZEN_APP_NAME:-Zen}" # change if it shows as "Zen Browser" etc.
BRAVE_APP_NAME="${BRAVE_APP_NAME:-Brave Browser}"
SAFARI_APP_NAME="${SAFARI_APP_NAME:-Safari}"

# ---- helpers ----
has_app() {
	# macOS: checks if an app is available by name
	open -Ra "$1" >/dev/null 2>&1
}

lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# ---- chrome profile detection ----
chrome_last_profile() {
	[ -f "$CHROME_STATE_FILE" ] || {
		printf '%s\n' "Default"
		return
	}

	python3 - "$CHROME_STATE_FILE" 2>/dev/null <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    print(data.get("profile", {}).get("last_used", "Default"))
except Exception:
    print("Default")
PY
}

# ---- main ----
pref="$(lc "$PREFERRED_BROWSER")"

case "$pref" in
chrome | google\ chrome)
	if [ -x "$CHROME_BIN" ]; then
		LAST_PROFILE="$(chrome_last_profile)"
		# nohup makes it survive if this script is run from a terminal/session that exits
		nohup "$CHROME_BIN" --profile-directory="$LAST_PROFILE" --new-window \
			>/dev/null 2>&1 &
		exit 0
	fi
	;;

zen)
	if has_app "$ZEN_APP_NAME"; then
		# If Zen supports "--new-window" args, this will pass them through.
		# If not, just remove the --args line and it will still open Zen.
		open -a "$ZEN_APP_NAME" --args --new-window >/dev/null 2>&1
		exit 0
	fi
	;;
esac

# ---- fallbacks ----
if has_app "$BRAVE_APP_NAME"; then
	open -a "$BRAVE_APP_NAME" --args --new-window >/dev/null 2>&1
else
	open -a "$SAFARI_APP_NAME" >/dev/null 2>&1
fi
