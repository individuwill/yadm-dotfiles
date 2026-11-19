# A shell that is not a login shell (a Zellij pane started from the Dock or Alfred) never runs
# /etc/zprofile, so it lacks the system paths (/usr/local/bin: code, docker, cursor, zed) and LANG.
# Do here what /etc/zprofile does for a login shell.
if [[ ! -o login && -x /usr/libexec/path_helper ]]; then
  eval "$(/usr/libexec/path_helper -s)"
  [[ -n "$LANG" ]] || export LANG=C.UTF-8
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Auto-attach tmux on interactive SSH sessions (silent no-op otherwise).
# Fragment is provided unconditionally; runtime guards inside handle when to fire.
[[ -r "$HOME/.zshrc.tmux-autoattach" ]] && source "$HOME/.zshrc.tmux-autoattach"

autoload -Uz compinit
compinit

source "$HOME/.myprofile"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
