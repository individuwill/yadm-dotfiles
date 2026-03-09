#!/bin/sh

# Terminal launcher notes for AeroSpace:
# - `open -n -a <App>` creates a new app instance, not a new window. That was
#   the original cause of duplicate terminal apps.
# - For iTerm/Terminal, asking the running app to create a window via
#   AppleScript works better than `open -a ...` when the goal is "new window in
#   the current AeroSpace workspace".
# - Avoid `activate` when the app is already running. In practice, that can
#   focus an existing window on another AeroSpace workspace before the new
#   window is created, which pulls focus to the wrong workspace.
# - On a cold start, the opposite is true: without `activate`, iTerm can launch
#   in the background and not surface a window until the Dock icon is clicked.
#   So the working pattern is:
#     running app   -> create a new window without `activate`
#     app not open  -> `activate` and let the app create/show its first window
# - If another terminal app is added here later, start by copying the iTerm
#   pattern above and only add stronger focus/window-moving logic if the app
#   still opens on the wrong workspace.

CONFIG="$HOME/.config/aerospace/config.env"
[ -r "$CONFIG" ] && . "$CONFIG"

# Defaults (override in config.env)
PREFERRED_TERMINAL="${PREFERRED_TERMINAL:-Ghostty}"
GHOSTTY_APP_NAME="${GHOSTTY_APP_NAME:-Ghostty}"
ITERM_APP_NAME="${ITERM_APP_NAME:-iTerm}"
TERMINAL_APP_NAME="${TERMINAL_APP_NAME:-Terminal}"

has_app() { open -Ra "$1" >/dev/null 2>&1; }
lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

open_ghostty() {
	open -a "$GHOSTTY_APP_NAME" --new >/dev/null 2>&1 || open -a "$GHOSTTY_APP_NAME"
}

open_iterm() {
	osascript <<EOF
if application "$ITERM_APP_NAME" is running then
	tell application "$ITERM_APP_NAME"
		create window with default profile
	end tell
else
	tell application "$ITERM_APP_NAME"
		activate
	end tell
end if
EOF
}

open_terminal() {
	osascript <<EOF
if application "$TERMINAL_APP_NAME" is running then
	tell application "$TERMINAL_APP_NAME"
		do script ""
	end tell
else
	tell application "$TERMINAL_APP_NAME"
		activate
	end tell
end if
EOF
}

pref="$(lc "$PREFERRED_TERMINAL")"

case "$pref" in
ghostty)
	if has_app "$GHOSTTY_APP_NAME"; then
		open_ghostty
		exit 0
	fi
	;;
iterm | iterm2)
	if has_app "$ITERM_APP_NAME"; then
		open_iterm
		exit 0
	fi
	;;
terminal | apple\ terminal)
	if has_app "$TERMINAL_APP_NAME"; then
		open_terminal
		exit 0
	fi
	;;
esac

# Fallback chain: Ghostty -> iTerm -> Terminal
if has_app "$GHOSTTY_APP_NAME"; then
	open_ghostty
elif has_app "$ITERM_APP_NAME"; then
	open_iterm
else
	open_terminal
fi
