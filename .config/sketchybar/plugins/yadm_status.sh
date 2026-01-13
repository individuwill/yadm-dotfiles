#!/bin/sh

# Can print out a default set with this bash command
# echo -e "Nerd Fonts:\n  Synced: \uf00c\n  Dirty: \uf044\n  Staged: \uf067\n  Unpushed: \uf093\n  Diverged: \uf12a\n\nSF Symbols (macOS):\n  Synced: \U2705\n  Dirty: \U270F\n  Staged: \U2715\n  Unpushed: \U21E7\n  Diverged: \U26A0"

# Define your icons (replace with your preferred SF Symbols or Nerd Font icons)
ICON_SYNCED=""   # Cloud checkmark
ICON_DIRTY=""    # Pencil/Edit
ICON_STAGED=""   # Plus circle
ICON_UNPUSHED="" # Up arrow
ICON_DIVERGED="" # Exclamation mark

COLOR_GREEN="0xffa6da95"
COLOR_YELLOW="0xffeed49f"
COLOR_RED="0xffed8796"
COLOR_BLUE="0xff8aadf4"

# Ensure consistent encoding for glyph icons in non-interactive runs
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Environment
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
YADM="/opt/homebrew/bin/yadm"

# If using SSH, help script find your keys via the macOS agent
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  SSH_AUTH_SOCK="$(launchctl getenv SSH_AUTH_SOCK 2>/dev/null)"
  [ -n "$SSH_AUTH_SOCK" ] && export SSH_AUTH_SOCK
fi

# IMPORTANT: never allow git/ssh to prompt in sketchybar context
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=2"

# Fallback for NAME if running manually
NAME="${NAME:-yadm_status}"

# Fetch remote info, but NEVER block the bar update
# Prefer a short timeout if available (coreutils: gtimeout)
if command -v gtimeout >/dev/null 2>&1; then
  gtimeout 2 "$YADM" fetch --quiet >/dev/null 2>&1 || true
elif command -v timeout >/dev/null 2>&1; then
  timeout 2 "$YADM" fetch --quiet >/dev/null 2>&1 || true
else
  # Background fetch: best-effort, doesn't stall UI
  ( "$YADM" fetch --quiet >/dev/null 2>&1 ) &
fi

# Determine local state (fast, no network)
"$YADM" diff --exit-code >/dev/null 2>&1
DIRTY=$?

"$YADM" diff --cached --exit-code >/dev/null 2>&1
STAGED=$?

STATUS="$("$YADM" status -sb 2>/dev/null)"


# Some debug logging
{
	echo "---- $(date) ----"
	echo "whoami=$(id -un) HOME=$HOME PWD=$(pwd) SENDER=${SENDER:-} NAME=${NAME:-}"
	echo "DIRTY=$DIRTY STAGED=$STAGED"
	echo "status_head=$(echo "$STATUS" | head -n1)"
	echo "porcelain=$("$YADM" status --porcelain -b 2>/dev/null | tr '\n' ';')"
} >>/tmp/yadm_sketchybar.log

if [ "$DIRTY" -ne 0 ]; then
  ICON="$ICON_DIRTY"; COLOR="$COLOR_YELLOW"; DESC="Local changes: Unstaged"
elif [ "$STAGED" -ne 0 ]; then
  ICON="$ICON_STAGED"; COLOR="$COLOR_BLUE"; DESC="Changes staged: Ready to commit"
elif echo "$STATUS" | grep -q "diverged"; then
  ICON="$ICON_DIVERGED"; COLOR="$COLOR_RED"; DESC="Diverged: Manual merge needed"
elif echo "$STATUS" | grep -q "ahead"; then
  ICON="$ICON_UNPUSHED"; COLOR="$COLOR_BLUE"; DESC="Unpushed commits local"
elif echo "$STATUS" | grep -q "behind"; then
  ICON="$ICON_DIVERGED"; COLOR="$COLOR_RED"; DESC="Behind: Pull required"
else
  ICON="$ICON_SYNCED"; COLOR="$COLOR_GREEN"; DESC="Dotfiles are synced"
fi

case "${SENDER:-}" in
  "mouse.entered")
    sketchybar --set "$NAME" popup.drawing=on \
               --set "$NAME.details" label="$DESC"
    ;;
  "mouse.exited")
    sketchybar --set "$NAME" popup.drawing=off
    ;;
  "mouse.clicked")
    open "$HOME/.config/yadm"
    ;;
  *)
    sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR"
    ;;
esac
