#!/bin/sh

# Can print out a default set with this bash command

# echo -e "Nerd Fonts:\n  Synced: \uf00c\n  Dirty: \uf044\n  Staged: \uf067\n  Unpushed: \uf093\n  Diverged: \uf12a\n\nSF Symbols (macOS):\n  Synced: \U2705\n  Dirty: \U270F\n  Staged: \U2715\n  Unpushed: \U21E7\n  Diverged: \U26A0"

# Define your icons (replace with your preferred SF Symbols or Nerd Font icons)
ICON_SYNCED=""      # Cloud checkmark
ICON_DIRTY=""       # Pencil/Edit
ICON_STAGED=""      # Plus circle
ICON_UNPUSHED=""    # Up arrow
ICON_DIVERGED=""    # Exclamation mark

COLOR_GREEN="0xffa6da95"
COLOR_YELLOW="0xffeed49f"
COLOR_RED="0xffed8796"
COLOR_BLUE="0xff8aadf4"

# Fallback for NAME if running manually
NAME="${NAME:-yadm_status}"

# Add this at the very top of yadm_status.sh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# If using SSH, this helps the script find your keys via the macOS agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  export SSH_AUTH_SOCK=$(launchctl getenv SSH_AUTH_SOCK)
fi

# 1. Determine State
if ! yadm diff --quiet; then
  ICON=$ICON_DIRTY; COLOR=$COLOR_YELLOW; DESC="Local changes: Unstaged"
elif ! yadm diff --cached --quiet; then
  ICON=$ICON_STAGED; COLOR=$COLOR_BLUE; DESC="Changes staged: Ready to commit"
else
  # Silent fetch to check remote
  yadm fetch > /dev/null 2>&1
  
  LOCAL=$(yadm rev-parse @ 2>/dev/null)
  REMOTE=$(yadm rev-parse @{u} 2>/dev/null)
  BASE=$(yadm merge-base @ @{u} 2>/dev/null)

  if [ -z "$REMOTE" ]; then
    ICON=$ICON_SYNCED; COLOR=$COLOR_GREEN; DESC="No remote configured"
  elif [ "$LOCAL" = "$REMOTE" ]; then
    ICON=$ICON_SYNCED; COLOR=$COLOR_GREEN; DESC="Dotfiles are synced"
  elif [ "$LOCAL" = "$BASE" ]; then
    ICON=$ICON_DIVERGED; COLOR=$COLOR_RED; DESC="Behind: Pull required"
  elif [ "$REMOTE" = "$BASE" ]; then
    ICON=$ICON_UNPUSHED; COLOR=$COLOR_BLUE; DESC="Unpushed commits local"
  else
    ICON=$ICON_DIVERGED; COLOR=$COLOR_RED; DESC="Diverged: Manual merge needed"
  fi
fi

# 2. Handle Events
# NOTE: Using $NAME ensures it works with whatever name you gave it in sketchybarrc
case "$SENDER" in
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
    # Standard update
    sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR"
    ;;
esac

