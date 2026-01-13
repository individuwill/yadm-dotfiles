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

pref="$(lc "$PREFERRED_TERMINAL")"

case "$pref" in
ghostty)
	if has_app "$GHOSTTY_APP_NAME"; then
		open -n -a "$GHOSTTY_APP_NAME"
		exit 0
	fi
	;;
iterm | iterm2)
	if has_app "$ITERM_APP_NAME"; then
		open -n -a "$ITERM_APP_NAME"
		exit 0
	fi
	;;
terminal | apple\ terminal)
	if has_app "$TERMINAL_APP_NAME"; then
		open -n -a "$TERMINAL_APP_NAME"
		exit 0
	fi
	;;
esac

# Fallback chain: Ghostty -> iTerm -> Terminal
if has_app "$GHOSTTY_APP_NAME"; then
	open -n -a "$GHOSTTY_APP_NAME"
elif has_app "$ITERM_APP_NAME"; then
	open -n -a "$ITERM_APP_NAME"
else
	open -n -a "$TERMINAL_APP_NAME"
fi
