#!/bin/sh

# --- CONFIGURATION ---
CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
CHROME_STATE_FILE="$HOME/Library/Application Support/Google/Chrome/Local State"

# --- LOGIC ---
if [ -f "$CHROME_STATE_FILE" ]; then
	# Extract the last used profile name
	LAST_PROFILE=$(python3 -c "import json; print(json.load(open('$CHROME_STATE_FILE'))['profile']['last_used'])" 2>/dev/null)
fi

# Fallback to Default if detection fails
LAST_PROFILE="${LAST_PROFILE:-Default}"

# --- EXECUTION ---
if [ -f "$CHROME_PATH" ]; then
	# Calling the binary directly bypasses macOS 'open' quirks
	# We use '& disown' so the script finishes but Chrome keeps running
	"$CHROME_PATH" --profile-directory="$LAST_PROFILE" --new-window >/dev/null 2>&1 &
	disown
elif open -Ra "Brave Browser" >/dev/null 2>&1; then
	open -a "Brave Browser" --args --new-window
else
	open -a "Safari"
fi
