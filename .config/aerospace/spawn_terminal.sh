#!/bin/sh

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
tell application "$ITERM_APP_NAME"
	create window with default profile
end tell
EOF
}

open_terminal() {
	osascript <<EOF
tell application "$TERMINAL_APP_NAME"
	do script ""
end tell
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
